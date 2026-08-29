import 'dart:async';

import 'package:get/get.dart';

import '../../core/utils/app_logger.dart';
import '../../data/models/app_notification.dart';
import '../../data/repositories/notification_repository.dart';
import 'auth_controller.dart';

class NotificationController extends GetxController {
  NotificationController({required this.notificationRepository});

  final NotificationRepository notificationRepository;

  final RxList<AppNotification> notifications = <AppNotification>[].obs;
  final RxBool isLoading = true.obs;

  StreamSubscription<List<AppNotification>>? _subscription;

  String? get _uid => Get.find<AuthController>().uid;

  int get unreadCount => notifications.where((n) => !n.read).length;

  @override
  void onInit() {
    super.onInit();
    final uid = _uid;
    if (uid == null) {
      isLoading.value = false;
      return;
    }
    _subscription = notificationRepository.watchNotifications(uid).listen(
      (value) {
        notifications.value = value;
        isLoading.value = false;
      },
      onError: (Object error) {
        AppLogger.e('Notification stream error', error: error);
        isLoading.value = false;
      },
    );
  }

  Future<void> markRead(AppNotification notification) async {
    final uid = _uid;
    if (uid == null || notification.read) return;
    await notificationRepository.markRead(uid, notification.id);
  }

  Future<void> clearAll() async {
    final uid = _uid;
    if (uid == null) return;
    await notificationRepository.clearAll(uid);
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
