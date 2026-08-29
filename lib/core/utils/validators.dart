import 'package:get/get.dart';

/// Input validators used across forms. All messages are localized keys.
class Validators {
  Validators._();

  static String? phone(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'error_phone_required'.tr;
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(v)) return 'error_phone_invalid'.tr;
    return null;
  }

  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) return 'error_field_required'.tr;
    return null;
  }

  static String? name(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'error_field_required'.tr;
    if (v.length < 2) return 'error_name_short'.tr;
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null; // email optional
    if (!GetUtils.isEmail(v)) return 'error_email_invalid'.tr;
    return null;
  }

  static String? pincode(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'error_field_required'.tr;
    if (!RegExp(r'^[1-9]\d{5}$').hasMatch(v)) return 'error_pincode_invalid'.tr;
    return null;
  }
}
