import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Labeled text field with consistent spacing, used across the admin forms.
class AdminField extends StatelessWidget {
  const AdminField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
