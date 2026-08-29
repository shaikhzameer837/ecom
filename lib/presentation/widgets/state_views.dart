import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import 'primary_button.dart';

/// Empty state with icon, message and optional action.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: theme.colorScheme.outlineVariant),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppTheme.spacingS),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.outline),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppTheme.spacingL),
              PrimaryButton(
                  label: actionLabel!, onPressed: onAction, expanded: false),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state with retry.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    this.message,
    this.onRetry,
    this.isOffline = false,
  });

  final String? message;
  final VoidCallback? onRetry;
  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: isOffline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
      title: message ?? (isOffline ? 'error_no_internet'.tr : 'error_generic'.tr),
      subtitle: isOffline ? 'error_no_internet_desc'.tr : null,
      actionLabel: onRetry != null ? 'retry'.tr : null,
      onAction: onRetry,
    );
  }
}
