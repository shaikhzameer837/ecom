import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/theme/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/locale_controller.dart';
import '../../controllers/nav_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../widgets/login_required_view.dart';

/// Profile tab: account, orders, addresses, settings, logout.
class ProfileScreen extends GetView<AuthController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('profile_title'.tr)),
      body: Obx(() {
        if (controller.isGuest) {
          return LoginRequiredView(
            icon: Icons.person_outline_rounded,
            message: 'login_required_profile'.tr,
          );
        }
        return _content(context, theme);
      }),
    );
  }

  Widget _content(BuildContext context, ThemeData theme) {
    return ListView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        children: [
          // Header
          Obx(() {
            final user = controller.user.value;
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  radius: 26,
                  child: Text(
                    (user?.name.isNotEmpty == true
                            ? user!.name[0]
                            : 'G')
                        .toUpperCase(),
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                title: Text(
                  user?.name.isNotEmpty == true ? user!.name : 'guest'.tr,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(user?.phone ?? ''),
                trailing: IconButton(
                  onPressed: () => Get.toNamed(AppRoutes.editProfile),
                  icon: const Icon(Icons.edit_outlined),
                ),
              ),
            );
          }),
          const SizedBox(height: AppTheme.spacingM),

          // Admin panel entry — only for authorized admin phone numbers.
          Obx(() {
            if (!controller.isAdmin) return const SizedBox.shrink();
            return Card(
              margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
              color: theme.colorScheme.inverseSurface,
              child: ListTile(
                leading: Icon(Icons.admin_panel_settings_outlined,
                    color: theme.colorScheme.onInverseSurface),
                title: Text('admin_panel'.tr,
                    style: TextStyle(
                        color: theme.colorScheme.onInverseSurface,
                        fontWeight: FontWeight.w700)),
                subtitle: Text('admin_subtitle'.tr,
                    style: TextStyle(
                        color: theme.colorScheme.onInverseSurface
                            .withValues(alpha: 0.7))),
                trailing: Icon(Icons.chevron_right_rounded,
                    color: theme.colorScheme.onInverseSurface),
                onTap: () => Get.toNamed(AppRoutes.admin),
              ),
            );
          }),

          _tile(
            context,
            icon: Icons.receipt_long_outlined,
            title: 'my_orders'.tr,
            onTap: () => Get.toNamed(AppRoutes.orders),
          ),
          _tile(
            context,
            icon: Icons.location_on_outlined,
            title: 'saved_addresses'.tr,
            onTap: () => Get.toNamed(AppRoutes.addresses),
          ),
          _tile(
            context,
            icon: Icons.favorite_outline_rounded,
            title: 'wishlist_title'.tr,
            onTap: () {
              if (Get.isRegistered<NavController>()) {
                Get.find<NavController>().changeTab(3);
              }
            },
          ),
          _tile(
            context,
            icon: Icons.credit_card_outlined,
            title: 'saved_payments'.tr,
            // Razorpay tokenizes cards on its side; screen reserved for
            // saved payment tokens fetched from the backend later.
            onTap: () => Get.snackbar('app_name'.tr, 'empty_generic'.tr),
          ),
          _tile(
            context,
            icon: Icons.notifications_outlined,
            title: 'notifications_title'.tr,
            onTap: () => Get.toNamed(AppRoutes.notifications),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text('language'.tr,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppTheme.spacingS),
          _tile(
            context,
            icon: Icons.language_rounded,
            title: AppTranslations.languageNames[
                    Get.find<LocaleController>().currentCode.value] ??
                'language'.tr,
            onTap: () => Get.toNamed(AppRoutes.language),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text('theme'.tr,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppTheme.spacingS),
          _ThemeSelector(),
          const SizedBox(height: AppTheme.spacingL),

          OutlinedButton.icon(
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout_rounded),
            label: Text('logout'.tr),
          ),
          const SizedBox(height: AppTheme.spacingXl),
        ],
      );
  }

  Widget _tile(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    Get.defaultDialog(
      title: 'logout'.tr,
      middleText: 'logout_confirm'.tr,
      textConfirm: 'yes'.tr,
      textCancel: 'no'.tr,
      onConfirm: () {
        Get.back();
        controller.logout();
      },
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return Obx(() => SegmentedButton<ThemeMode>(
          segments: [
            ButtonSegment(
                value: ThemeMode.system,
                label: Text('theme_system'.tr),
                icon: const Icon(Icons.brightness_auto_rounded, size: 18)),
            ButtonSegment(
                value: ThemeMode.light,
                label: Text('theme_light'.tr),
                icon: const Icon(Icons.light_mode_rounded, size: 18)),
            ButtonSegment(
                value: ThemeMode.dark,
                label: Text('theme_dark'.tr),
                icon: const Icon(Icons.dark_mode_rounded, size: 18)),
          ],
          selected: {themeController.mode.value},
          onSelectionChanged: (selection) =>
              themeController.setMode(selection.first),
        ));
  }
}
