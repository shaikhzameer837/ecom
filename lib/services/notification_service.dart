import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

import '../app/routes/app_routes.dart';
import '../core/constants/analytics_events.dart';
import '../core/utils/app_logger.dart';
import '../data/repositories/user_repository.dart';
import 'analytics_service.dart';
import 'local_storage_service.dart';

/// Background handler must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Data-only messages can be processed here; notification messages are
  // displayed by the system automatically.
}

/// FCM wiring: token lifecycle, foreground messages, and tap-to-navigate
/// for offers, discounts, order updates and cart reminders.
class NotificationService extends GetxService {
  NotificationService({
    required this.userRepository,
    required this.storage,
    required this.analytics,
  });

  final UserRepository userRepository;
  final LocalStorageService storage;
  final AnalyticsService analytics;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  StreamSubscription<String>? _tokenSubscription;

  Future<void> init() async {
    try {
      await _messaging.requestPermission();
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) _onMessageOpened(initialMessage);
    } catch (error, stackTrace) {
      AppLogger.e('FCM init failed', error: error, stackTrace: stackTrace);
    }
  }

  /// Called after login so tokens are stored against the user.
  Future<void> registerToken(String uid) async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await storage.setFcmToken(token);
        await userRepository.saveFcmToken(uid, token);
      }
      _tokenSubscription?.cancel();
      _tokenSubscription = _messaging.onTokenRefresh.listen((newToken) {
        storage.setFcmToken(newToken);
        userRepository.saveFcmToken(uid, newToken);
      });
    } catch (error, stackTrace) {
      AppLogger.e('FCM token registration failed',
          error: error, stackTrace: stackTrace);
    }
  }

  Future<void> unregisterToken(String uid) async {
    final token = storage.fcmToken;
    if (token != null) await userRepository.removeFcmToken(uid, token);
    _tokenSubscription?.cancel();
  }

  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    Get.snackbar(
      notification.title ?? '',
      notification.body ?? '',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
      onTap: (_) => _navigate(message.data),
    );
  }

  void _onMessageOpened(RemoteMessage message) {
    analytics.logEvent(AnalyticsEvents.notificationOpened, {
      'type': message.data['type']?.toString() ?? 'general',
    });
    _navigate(message.data);
  }

  /// Supported data payloads:
  /// {type: order, orderId: ..} {type: product, productId: ..}
  /// {type: cart} {type: offers|category, categoryId: ..}
  void _navigate(Map<String, dynamic> data) {
    switch (data['type']) {
      case 'order':
        final orderId = data['orderId']?.toString();
        if (orderId != null) {
          Get.toNamed(AppRoutes.orderDetail, arguments: orderId);
        }
      case 'product':
        final productId = data['productId']?.toString();
        if (productId != null) {
          Get.toNamed(AppRoutes.productDetail, arguments: productId);
        }
      case 'cart':
        Get.toNamed(AppRoutes.cart);
      case 'category':
        final categoryId = data['categoryId']?.toString();
        if (categoryId != null) {
          Get.toNamed(AppRoutes.productList, arguments: {
            'categoryId': categoryId,
            'title': data['title']?.toString() ?? '',
          });
        }
    }
  }

  @override
  void onClose() {
    _tokenSubscription?.cancel();
    super.onClose();
  }
}
