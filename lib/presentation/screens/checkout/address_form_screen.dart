import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/address.dart';
import '../../controllers/address_controller.dart';
import '../../widgets/primary_button.dart';

/// Add / edit address. Pass an [Address] as route argument to edit.
class AddressFormScreen extends StatefulWidget {
  const AddressFormScreen({super.key});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = Get.find<AddressController>();

  late final Address? _editing = Get.arguments as Address?;
  late final _name = TextEditingController(text: _editing?.name ?? '');
  late final _phone = TextEditingController(text: _editing?.phone ?? '');
  late final _line1 = TextEditingController(text: _editing?.line1 ?? '');
  late final _line2 = TextEditingController(text: _editing?.line2 ?? '');
  late final _city = TextEditingController(text: _editing?.city ?? '');
  late final _state = TextEditingController(text: _editing?.state ?? '');
  late final _pincode = TextEditingController(text: _editing?.pincode ?? '');
  late AddressType _type = _editing?.type ?? AddressType.home;
  late bool _isDefault = _editing?.isDefault ?? false;

  @override
  void dispose() {
    for (final controller in [_name, _phone, _line1, _line2, _city, _state, _pincode]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final saved = await _controller.save(Address(
      id: _editing?.id ?? '',
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      line1: _line1.text.trim(),
      line2: _line2.text.trim(),
      city: _city.text.trim(),
      state: _state.text.trim(),
      pincode: _pincode.text.trim(),
      type: _type,
      isDefault: _isDefault,
    ));
    if (saved) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(_editing == null ? 'add_new_address'.tr : 'edit_address'.tr),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          children: [
            TextFormField(
              controller: _name,
              validator: Validators.name,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: 'full_name'.tr),
            ),
            const SizedBox(height: AppTheme.spacingM),
            TextFormField(
              controller: _phone,
              validator: Validators.phone,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                  labelText: 'phone_number'.tr, counterText: ''),
            ),
            const SizedBox(height: AppTheme.spacingM),
            TextFormField(
              controller: _line1,
              validator: Validators.requiredField,
              decoration: InputDecoration(labelText: 'address_line1'.tr),
            ),
            const SizedBox(height: AppTheme.spacingM),
            TextFormField(
              controller: _line2,
              decoration: InputDecoration(labelText: 'address_line2'.tr),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _city,
                    validator: Validators.requiredField,
                    decoration: InputDecoration(labelText: 'city'.tr),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: TextFormField(
                    controller: _pincode,
                    validator: Validators.pincode,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                        labelText: 'pincode'.tr, counterText: ''),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            TextFormField(
              controller: _state,
              validator: Validators.requiredField,
              decoration: InputDecoration(labelText: 'state'.tr),
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text('address_type'.tr,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppTheme.spacingS),
            Wrap(
              spacing: AppTheme.spacingS,
              children: [
                for (final type in AddressType.values)
                  ChoiceChip(
                    label: Text('address_${type.name}'.tr),
                    selected: _type == type,
                    onSelected: (_) => setState(() => _type = type),
                  ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('default_address'.tr),
              value: _isDefault,
              onChanged: (value) => setState(() => _isDefault = value),
            ),
            const SizedBox(height: AppTheme.spacingL),
            Obx(() => PrimaryButton(
                  label: 'save'.tr,
                  isLoading: _controller.isSaving.value,
                  onPressed: _save,
                )),
          ],
        ),
      ),
    );
  }
}
