import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import 'primary_button.dart';

/// Shown in place of an auth-gated screen (profile, cart, wishlist) when the
/// user is browsing as a guest.
class LoginRequiredView extends StatelessWidget {
  const LoginRequiredView({
    super.key,
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: theme.colorScheme.outline),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacingL),
            PrimaryButton(
              label: 'login'.tr,
              onPressed: () => Get.toNamed(AppRoutes.login),
              expanded: false,
              icon: Icons.login_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
