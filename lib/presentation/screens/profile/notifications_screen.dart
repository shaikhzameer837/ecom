import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/app_notification.dart';
import '../../controllers/notification_controller.dart';
import '../../widgets/state_views.dart';

class NotificationsScreen extends GetView<NotificationController> {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('notifications_title'.tr),
        actions: [
          Obx(() => controller.notifications.isEmpty
              ? const SizedBox.shrink()
              : TextButton(
                  onPressed: controller.clearAll,
                  child: Text('clear_all'.tr),
                )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.notifications.isEmpty) {
          return EmptyState(
            icon: Icons.notifications_none_rounded,
            title: 'notifications_empty'.tr,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          itemCount: controller.notifications.length,
          separatorBuilder: (_, _) =>
              const SizedBox(height: AppTheme.spacingS),
          itemBuilder: (context, index) {
            final notification = controller.notifications[index];
            return Card(
              child: ListTile(
                leading: Icon(
                  switch (notification.type) {
                    NotificationType.offer ||
                    NotificationType.discount =>
                      Icons.local_offer_outlined,
                    NotificationType.order => Icons.local_shipping_outlined,
                    NotificationType.cartReminder =>
                      Icons.shopping_cart_outlined,
                    NotificationType.general =>
                      Icons.notifications_outlined,
                  },
                  color: notification.read
                      ? Theme.of(context).colorScheme.outline
                      : Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: notification.read
                        ? FontWeight.w400
                        : FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  '${notification.body}\n'
                  '${Formatters.dateFromMillis(notification.createdAt)}',
                ),
                isThreeLine: true,
                onTap: () {
                  controller.markRead(notification);
                  _open(notification);
                },
              ),
            );
          },
        );
      }),
    );
  }

  void _open(AppNotification notification) {
    switch (notification.type) {
      case NotificationType.order:
        if (notification.targetId.isNotEmpty) {
          Get.toNamed(AppRoutes.orderDetail, arguments: notification.targetId);
        }
      case NotificationType.cartReminder:
        Get.toNamed(AppRoutes.cart);
      case NotificationType.offer || NotificationType.discount:
        if (notification.targetId.isNotEmpty) {
          Get.toNamed(AppRoutes.productDetail,
              arguments: notification.targetId);
        }
      case NotificationType.general:
        break;
    }
  }
}
