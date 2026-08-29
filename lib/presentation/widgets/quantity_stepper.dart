import 'package:flutter/material.dart';

/// - qty + control used in the cart.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
  });

  final int quantity;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _button(context, Icons.remove,
              quantity > min ? () => onChanged(quantity - 1) : null),
          SizedBox(
            width: 32,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          _button(context, Icons.add,
              quantity < max ? () => onChanged(quantity + 1) : null),
        ],
      ),
    );
  }

  Widget _button(BuildContext context, IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          size: 18,
          color: onTap == null
              ? Theme.of(context).colorScheme.outlineVariant
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
