import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';

/// Home-section title row with optional "See all".
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
    this.trailing,
  });

  final String title;
  final VoidCallback? onSeeAll;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppTheme.spacingM, AppTheme.spacingL, AppTheme.spacingS, AppTheme.spacingS),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          ?trailing,
          if (onSeeAll != null)
            TextButton(onPressed: onSeeAll, child: Text('see_all'.tr)),
        ],
      ),
    );
  }
}
