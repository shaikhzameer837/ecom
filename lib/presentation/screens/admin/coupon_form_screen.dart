import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/coupon.dart';
import '../../controllers/admin_controller.dart';
import '../../widgets/primary_button.dart';
import 'admin_form_fields.dart';

/// Create/edit a coupon. The code is the RTDB key, so editing an existing
/// coupon keeps its code fixed.
class CouponFormScreen extends StatefulWidget {
  const CouponFormScreen({super.key, this.coupon});

  final Coupon? coupon;

  @override
  State<CouponFormScreen> createState() => _CouponFormScreenState();
}

class _CouponFormScreenState extends State<CouponFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final AdminController _admin = Get.find<AdminController>();

  late final _code = TextEditingController(text: widget.coupon?.code ?? '');
  late final _value = TextEditingController(
      text: widget.coupon == null ? '' : _numText(widget.coupon!.value));
  late final _minOrder = TextEditingController(
      text: widget.coupon == null ? '' : _numText(widget.coupon!.minOrderValue));
  late final _maxDiscount = TextEditingController(
      text: widget.coupon == null ? '' : _numText(widget.coupon!.maxDiscount));
  late final _expiryDays = TextEditingController(text: _expiryText());
  late final _description =
      TextEditingController(text: widget.coupon?.description ?? '');
  late CouponType _type = widget.coupon?.type ?? CouponType.percent;
  late bool _active = widget.coupon?.active ?? true;

  static String _numText(double v) =>
      v == 0 ? '' : (v == v.roundToDouble() ? v.toInt().toString() : v.toString());

  String _expiryText() {
    final expiresAt = widget.coupon?.expiresAt ?? 0;
    if (expiresAt <= 0) return '0';
    final days = ((expiresAt - DateTime.now().millisecondsSinceEpoch) /
            (1000 * 60 * 60 * 24))
        .ceil();
    return days > 0 ? days.toString() : '0';
  }

  @override
  void dispose() {
    _code.dispose();
    _value.dispose();
    _minOrder.dispose();
    _maxDiscount.dispose();
    _expiryDays.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final days = int.tryParse(_expiryDays.text.trim()) ?? 0;
    final coupon = Coupon(
      code: _code.text.trim().toUpperCase(),
      type: _type,
      value: double.tryParse(_value.text.trim()) ?? 0,
      minOrderValue: double.tryParse(_minOrder.text.trim()) ?? 0,
      maxDiscount: double.tryParse(_maxDiscount.text.trim()) ?? 0,
      expiresAt: days > 0
          ? DateTime.now()
              .add(Duration(days: days))
              .millisecondsSinceEpoch
          : 0,
      active: _active,
      description: _description.text.trim(),
    );
    final ok = await _admin.saveCoupon(coupon);
    if (ok) {
      Get.back();
      Get.snackbar('app_name'.tr, 'saved_success'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.coupon == null ? 'add_coupon'.tr : 'edit_coupon'.tr),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          children: [
            AdminField(
              controller: _code,
              label: 'field_coupon_code'.tr,
              validator: Validators.requiredField,
            ),
            DropdownButtonFormField<CouponType>(
              initialValue: _type,
              isExpanded: true,
              decoration: InputDecoration(labelText: 'field_coupon_type'.tr),
              items: [
                DropdownMenuItem(
                    value: CouponType.percent,
                    child: Text('coupon_percent'.tr)),
                DropdownMenuItem(
                    value: CouponType.flat, child: Text('coupon_flat'.tr)),
              ],
              onChanged: (v) => setState(() => _type = v ?? CouponType.percent),
            ),
            const SizedBox(height: AppTheme.spacingM),
            AdminField(
                controller: _value,
                label: 'field_coupon_value'.tr,
                keyboardType: TextInputType.number,
                validator: Validators.requiredField),
            AdminField(
                controller: _minOrder,
                label: 'field_min_order'.tr,
                keyboardType: TextInputType.number),
            AdminField(
                controller: _maxDiscount,
                label: 'field_max_discount'.tr,
                keyboardType: TextInputType.number),
            AdminField(
                controller: _expiryDays,
                label: 'field_expiry_days'.tr,
                keyboardType: TextInputType.number),
            AdminField(
                controller: _description, label: 'field_description'.tr),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('field_active'.tr),
              value: _active,
              onChanged: (v) => setState(() => _active = v),
            ),
            const SizedBox(height: AppTheme.spacingL),
            Obx(() => PrimaryButton(
                  label: 'save'.tr,
                  isLoading: _admin.isSaving.value,
                  onPressed: _save,
                )),
          ],
        ),
      ),
    );
  }
}
