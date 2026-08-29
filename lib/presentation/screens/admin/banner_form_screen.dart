import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/banner_item.dart';
import '../../controllers/admin_controller.dart';
import '../../widgets/primary_button.dart';
import 'admin_form_fields.dart';

/// Create/edit a home-screen banner.
class BannerFormScreen extends StatefulWidget {
  const BannerFormScreen({super.key, this.banner});

  final BannerItem? banner;

  @override
  State<BannerFormScreen> createState() => _BannerFormScreenState();
}

class _BannerFormScreenState extends State<BannerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final AdminController _admin = Get.find<AdminController>();

  late final _image = TextEditingController(text: widget.banner?.image ?? '');
  late final _title = TextEditingController(text: widget.banner?.title ?? '');
  late final _targetId =
      TextEditingController(text: widget.banner?.targetId ?? '');
  late final _sortOrder =
      TextEditingController(text: widget.banner?.sortOrder.toString() ?? '0');
  late BannerTarget _target = widget.banner?.target ?? BannerTarget.none;
  late bool _active = widget.banner?.active ?? true;

  @override
  void dispose() {
    _image.dispose();
    _title.dispose();
    _targetId.dispose();
    _sortOrder.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final banner = BannerItem(
      id: widget.banner?.id ?? '',
      image: _image.text.trim(),
      title: _title.text.trim(),
      target: _target,
      targetId: _target == BannerTarget.none ? '' : _targetId.text.trim(),
      sortOrder: int.tryParse(_sortOrder.text.trim()) ?? 0,
      active: _active,
    );
    final ok = await _admin.saveBanner(banner, id: widget.banner?.id);
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
            Text(widget.banner == null ? 'add_banner'.tr : 'edit_banner'.tr),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          children: [
            AdminField(
                controller: _image,
                label: 'field_image_url'.tr,
                validator: Validators.requiredField),
            AdminField(controller: _title, label: 'field_title'.tr),
            DropdownButtonFormField<BannerTarget>(
              initialValue: _target,
              isExpanded: true,
              decoration: InputDecoration(labelText: 'field_target'.tr),
              items: [
                DropdownMenuItem(
                    value: BannerTarget.none, child: Text('target_none'.tr)),
                DropdownMenuItem(
                    value: BannerTarget.category,
                    child: Text('target_category'.tr)),
                DropdownMenuItem(
                    value: BannerTarget.product,
                    child: Text('target_product'.tr)),
              ],
              onChanged: (v) =>
                  setState(() => _target = v ?? BannerTarget.none),
            ),
            const SizedBox(height: AppTheme.spacingM),
            if (_target != BannerTarget.none)
              AdminField(
                  controller: _targetId, label: 'field_target_id'.tr),
            AdminField(
                controller: _sortOrder,
                label: 'field_sort_order'.tr,
                keyboardType: TextInputType.number),
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
