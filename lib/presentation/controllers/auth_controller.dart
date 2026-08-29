import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get/get.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_logger.dart';
import '../../data/models/app_user.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../services/analytics_service.dart';
import '../../services/local_storage_service.dart';
import '../../services/notification_service.dart';

/// Owns the phone-OTP login flow and the current session.
class AuthController extends GetxController {
  AuthController({
    required this.authRepository,
    required this.userRepository,
    required this.analytics,
    required this.storage,
  });

  // ---------------------------------------------------------------------------
  // DEV BYPASS — sign in with ANY phone number and the OTP `123456`, with no
  // Firebase Auth at all. The user record is created/updated directly in
  // Realtime Database under `users/<phone>` and the session (synthetic uid =
  // phone digits) is persisted locally so it survives restarts.
  //
  // Requires RTDB rules that allow the write without auth (test-mode/open
  // rules). SET `devBypassEnabled = false` (and remove the hardcoded number in
  // login_screen.dart) before shipping to production.
  static const bool devBypassEnabled = true;
  static const String devBypassOtp = '123456';
  // ---------------------------------------------------------------------------

  final AuthRepository authRepository;
  final UserRepository userRepository;
  final AnalyticsService analytics;
  final LocalStorageService storage;

  final Rxn<AppUser> user = Rxn<AppUser>();
  final RxBool isSendingOtp = false.obs;
  final RxBool isVerifying = false.obs;
  final RxInt resendSeconds = 0.obs;

  String _phone = '';
  String? _verificationId;
  int? _resendToken;
  Timer? _resendTimer;

  /// Synthetic uid for the dev OTP bypass (no Firebase Auth). Null when the
  /// bypass is not the active session.
  String? _bypassUid;

  @override
  void onInit() {
    super.onInit();
    _bypassUid = storage.bypassUid;
  }

  String? get uid => _bypassUid ?? authRepository.currentUser?.uid;
  bool get isLoggedIn => _bypassUid != null || authRepository.isLoggedIn;
  String get phone => _phone;

  /// True when the signed-in user's phone is in [AppConstants.adminPhones].
  /// Matches the last 10 digits so it works for both the bypass (uid = phone
  /// digits) and real Firebase auth (profile phone like +919876543210).
  bool get isAdmin {
    final digits = (user.value?.phone ?? uid ?? '').replaceAll(RegExp(r'\D'), '');
    final last10 =
        digits.length >= 10 ? digits.substring(digits.length - 10) : digits;
    return AppConstants.adminPhones.contains(last10);
  }

  /// Reactive login flag so widgets can rebuild when the session changes.
  bool get isGuest => user.value == null && !authRepository.isLoggedIn;

  /// Guard for auth-gated actions (add to cart, wishlist, checkout, profile).
  /// Returns true when the user is signed in; otherwise routes to login and
  /// returns false so the caller can abort.
  bool requireLogin() {
    if (isLoggedIn) return true;
    Get.toNamed(AppRoutes.login);
    return false;
  }

  /// Restores the session at app start. Returns true when logged in.
  Future<bool> restoreSession() async {
    // Dev bypass session (no Firebase Auth): rehydrate from local storage.
    if (_bypassUid != null) {
      try {
        user.value = await userRepository.upsertUser(
            _bypassUid!, storage.bypassPhone ?? '');
        await analytics.setUserId(_bypassUid);
        Get.find<NotificationService>().registerToken(_bypassUid!);
      } catch (error, stackTrace) {
        AppLogger.e('restoreSession (bypass) failed',
            error: error, stackTrace: stackTrace);
      }
      return true;
    }

    final firebaseUser = authRepository.currentUser;
    if (firebaseUser == null) return false;
    try {
      user.value = await userRepository.ensureProfile(
        firebaseUser.uid,
        firebaseUser.phoneNumber ?? '',
      );
      await analytics.setUserId(firebaseUser.uid);
      await FirebaseCrashlytics.instance.setUserIdentifier(firebaseUser.uid);
      Get.find<NotificationService>().registerToken(firebaseUser.uid);
      return true;
    } catch (error, stackTrace) {
      AppLogger.e('restoreSession failed', error: error, stackTrace: stackTrace);
      return true; // Session is still valid even if profile fetch failed.
    }
  }

  Future<void> sendOtp(String phone) async {
    _phone = phone;
    isSendingOtp.value = true;
    await analytics.logOtpRequested();

    // DEV BYPASS: skip real SMS, go straight to the OTP screen.
    if (devBypassEnabled) {
      isSendingOtp.value = false;
      _startResendTimer();
      if (Get.currentRoute != AppRoutes.otp) Get.toNamed(AppRoutes.otp);
      Get.snackbar('app_name'.tr, 'otp_sent'.tr);
      return;
    }

    try {
      // Android SMS Retriever hint for auto OTP detection.
      await SmsAutoFill().listenForCode();
    } catch (_) {}
    await authRepository.sendOtp(
      phone: phone,
      forceResendingToken: _resendToken,
      onCodeSent: (verificationId, resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        isSendingOtp.value = false;
        _startResendTimer();
        if (Get.currentRoute != AppRoutes.otp) {
          Get.toNamed(AppRoutes.otp);
        }
        Get.snackbar('app_name'.tr, 'otp_sent'.tr);
      },
      onFailed: (error) {
        isSendingOtp.value = false;
        AppLogger.e('OTP send failed', error: error);
        Get.snackbar('app_name'.tr, error.message ?? 'error_auth'.tr);
      },
      onAutoVerified: (credential) async {
        // Android auto-read: sign in without manual entry.
        try {
          final result = await authRepository.signInWithCredential(credential);
          await _onSignedIn(result);
        } catch (error) {
          AppLogger.e('Auto verification failed', error: error);
        }
      },
    );
  }

  Future<void> resendOtp() async {
    if (resendSeconds.value > 0) return;
    await sendOtp(_phone);
  }

  Future<void> verifyOtp(String smsCode) async {
    // DEV BYPASS: accept the fixed OTP and create/update the user directly in
    // Realtime Database — no Firebase Auth involved. The synthetic uid is the
    // entered phone digits, persisted locally so the session survives restarts.
    if (devBypassEnabled) {
      if (smsCode != devBypassOtp) {
        Get.snackbar('app_name'.tr, 'error_otp_invalid'.tr);
        return;
      }
      isVerifying.value = true;
      try {
        final bypassUid = _phone;
        final phoneFull = '${AppConstants.defaultCountryCode}$_phone';
        _bypassUid = bypassUid;
        await storage.setBypassSession(bypassUid, phoneFull);
        user.value = await userRepository.upsertUser(bypassUid, phoneFull);
        await analytics.setUserId(bypassUid);
        await analytics.logOtpVerified();
        await analytics.logLogin();
        await Get.find<NotificationService>().registerToken(bypassUid);
        SmsAutoFill().unregisterListener();
        _resendTimer?.cancel();
        Get.offAllNamed(AppRoutes.main);
      } catch (error, stackTrace) {
        AppLogger.e('Dev bypass sign-in failed',
            error: error, stackTrace: stackTrace);
        // Roll back the partial session so the user can retry.
        _bypassUid = null;
        await storage.clearBypassSession();
        Get.snackbar('app_name'.tr, 'error_generic'.tr);
      } finally {
        isVerifying.value = false;
      }
      return;
    }

    final verificationId = _verificationId;
    if (verificationId == null || smsCode.length != AppConstants.otpLength) {
      Get.snackbar('app_name'.tr, 'error_otp_invalid'.tr);
      return;
    }
    isVerifying.value = true;
    try {
      final result = await authRepository.verifyOtp(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await _onSignedIn(result);
    } on FirebaseAuthException catch (error) {
      AppLogger.e('OTP verify failed', error: error);
      Get.snackbar('app_name'.tr, 'error_otp_invalid'.tr);
    } catch (error) {
      Get.snackbar('app_name'.tr, 'error_auth'.tr);
    } finally {
      isVerifying.value = false;
    }
  }

  Future<void> _onSignedIn(UserCredential credential) async {
    final firebaseUser = credential.user;
    if (firebaseUser == null) return;
    SmsAutoFill().unregisterListener();
    _resendTimer?.cancel();
    user.value = await userRepository.ensureProfile(
      firebaseUser.uid,
      firebaseUser.phoneNumber ?? '${AppConstants.defaultCountryCode}$_phone',
    );
    await analytics.setUserId(firebaseUser.uid);
    await analytics.logOtpVerified();
    await analytics.logLogin();
    await FirebaseCrashlytics.instance.setUserIdentifier(firebaseUser.uid);
    await Get.find<NotificationService>().registerToken(firebaseUser.uid);
    Get.offAllNamed(AppRoutes.main);
  }

  Future<void> updateProfile({String? name, String? email}) async {
    final currentUid = uid;
    if (currentUid == null) return;
    await userRepository.updateProfile(currentUid, name: name, email: email);
    user.value = user.value?.copyWith(name: name, email: email);
    Get.back();
    Get.snackbar('app_name'.tr, 'profile_updated'.tr);
  }

  Future<void> logout() async {
    final currentUid = uid;
    if (currentUid != null) {
      await Get.find<NotificationService>().unregisterToken(currentUid);
    }
    await analytics.logLogout();
    await analytics.setUserId(null);
    if (_bypassUid != null) {
      _bypassUid = null;
      await storage.clearBypassSession();
    } else {
      await authRepository.signOut();
    }
    await storage.clearUserData();
    user.value = null;
    Get.offAllNamed(AppRoutes.login);
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    resendSeconds.value = AppConstants.otpResendSeconds;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds.value <= 1) {
        resendSeconds.value = 0;
        timer.cancel();
      } else {
        resendSeconds.value--;
      }
    });
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    SmsAutoFill().unregisterListener();
    super.onClose();
  }
}
