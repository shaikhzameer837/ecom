import 'package:firebase_auth/firebase_auth.dart';

import '../../core/constants/app_constants.dart';

/// Wraps Firebase Phone Authentication. Session persistence is handled by
/// the Firebase SDK itself; [currentUser] survives app restarts.
class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => _auth.currentUser != null;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Starts phone verification. Firebase auto-verifies on Android when the
  /// SMS is detected, in which case [onAutoVerified] fires.
  Future<void> sendOtp({
    required String phone,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(FirebaseAuthException error) onFailed,
    required void Function(PhoneAuthCredential credential) onAutoVerified,
    int? forceResendingToken,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: '${AppConstants.defaultCountryCode}$phone',
      timeout: const Duration(seconds: AppConstants.otpTimeoutSeconds),
      forceResendingToken: forceResendingToken,
      verificationCompleted: onAutoVerified,
      verificationFailed: onFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return _auth.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithCredential(PhoneAuthCredential credential) =>
      _auth.signInWithCredential(credential);

  Future<void> signOut() => _auth.signOut();
}
