import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/primary_button.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderId = Get.arguments?.toString() ?? '';
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) =>
                    Transform.scale(scale: value, child: child),
                child: Icon(Icons.check_circle_rounded,
                    size: 110, color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: AppTheme.spacingL),
              Text(
                'order_success'.tr,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                'order_success_desc'.tr,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
              const SizedBox(height: AppTheme.spacingXl),
              PrimaryButton(
                label: 'view_order'.tr,
                onPressed: () {
                  Get.offAllNamed(AppRoutes.main);
                  Get.toNamed(AppRoutes.orderDetail, arguments: orderId);
                },
              ),
              const SizedBox(height: AppTheme.spacingM),
              OutlinedButton(
                onPressed: () => Get.offAllNamed(AppRoutes.main),
                child: Text('continue_shopping'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
