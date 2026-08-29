import 'package:flutter/material.dart';

/// Read-only star display with optional count.
class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.count,
    this.size = 14,
  });

  final double rating;
  final int? count;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          final filled = rating - index;
          return Icon(
            filled >= 0.75
                ? Icons.star_rounded
                : filled >= 0.25
                    ? Icons.star_half_rounded
                    : Icons.star_outline_rounded,
            size: size,
            color: Theme.of(context).colorScheme.onSurface,
          );
        }),
        if (count != null) ...[
          const SizedBox(width: 4),
          Text(
            '($count)',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.outline),
          ),
        ],
      ],
    );
  }
}

/// Tappable star input for the review form.
class RatingInput extends StatelessWidget {
  const RatingInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 40,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: () => onChanged(index + 1.0),
          icon: Icon(
            value > index ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        );
      }),
    );
  }
}
