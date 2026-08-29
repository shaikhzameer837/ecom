import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/formatters.dart';

/// Price + struck MRP + discount badge, used everywhere prices appear.
class PriceText extends StatelessWidget {
  const PriceText({
    super.key,
    required this.price,
    required this.mrp,
    this.large = false,
  });

  final double price;
  final double mrp;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDiscount = mrp > price;
    final percent = hasDiscount ? ((mrp - price) / mrp * 100).round() : 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Flexible(
          child: Text(
            Formatters.price(price),
            overflow: TextOverflow.ellipsis,
            style: (large
                    ? theme.textTheme.headlineSmall
                    : theme.textTheme.titleSmall)
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        if (hasDiscount) ...[
          const SizedBox(width: 6),
          Text(
            Formatters.price(mrp),
            style: theme.textTheme.bodySmall?.copyWith(
              decoration: TextDecoration.lineThrough,
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$percent% ${'off_label'.tr}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}
