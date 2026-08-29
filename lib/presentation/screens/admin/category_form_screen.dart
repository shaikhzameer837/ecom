import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/category_model.dart';
import '../../controllers/admin_controller.dart';
import '../../widgets/primary_button.dart';
import 'admin_form_fields.dart';

/// Create/edit a top-level category. For an existing category it also manages
/// its subcategories (which feed the product subcategory dropdown).
class CategoryFormScreen extends StatefulWidget {
  const CategoryFormScreen({super.key, this.category});

  final CategoryModel? category;

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final AdminController _admin = Get.find<AdminController>();

  late final _name = TextEditingController(text: widget.category?.name ?? '');
  late final _image = TextEditingController(text: widget.category?.image ?? '');
  late final _sortOrder = TextEditingController(
      text: widget.category?.sortOrder.toString() ?? '0');

  @override
  void dispose() {
    _name.dispose();
    _image.dispose();
    _sortOrder.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final category = CategoryModel(
      id: widget.category?.id ?? '',
      name: _name.text.trim(),
      image: _image.text.trim(),
      parentId: '',
      sortOrder: int.tryParse(_sortOrder.text.trim()) ?? 0,
      subcategories: widget.category?.subcategories ?? const [],
    );
    final ok = await _admin.saveCategory(category, id: widget.category?.id);
    if (ok) {
      Get.back();
      Get.snackbar('app_name'.tr, 'saved_success'.tr);
    }
  }

  Future<void> _addSubcategory() async {
    final controller = TextEditingController();
    await Get.defaultDialog(
      title: 'add_subcategory'.tr,
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
        child: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: 'field_name'.tr),
        ),
      ),
      textConfirm: 'save'.tr,
      textCancel: 'cancel'.tr,
      onConfirm: () async {
        final name = controller.text.trim();
        if (name.isEmpty) return;
        Get.back();
        final order = widget.category!.subcategories.length;
        await _admin.saveSubcategory(
          widget.category!.id,
          CategoryModel(
              id: '', name: name, parentId: widget.category!.id, sortOrder: order),
        );
        setState(() {}); // reflect updated list from controller
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Re-read the (possibly updated) category from the controller so the
    // subcategory list stays in sync after edits.
    final current = widget.category == null
        ? null
        : _admin.categories.firstWhereOrNull((c) => c.id == widget.category!.id);
    final subcategories = current?.subcategories ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null
            ? 'add_category'.tr
            : 'edit_category'.tr),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          children: [
            AdminField(
                controller: _name,
                label: 'field_name'.tr,
                validator: Validators.requiredField),
            AdminField(controller: _image, label: 'field_image_url'.tr),
            AdminField(
                controller: _sortOrder,
                label: 'field_sort_order'.tr,
                keyboardType: TextInputType.number),
            const SizedBox(height: AppTheme.spacingS),
            Obx(() => PrimaryButton(
                  label: 'save'.tr,
                  isLoading: _admin.isSaving.value,
                  onPressed: _save,
                )),
            if (widget.category != null) ...[
              const Divider(height: AppTheme.spacingXl),
              Row(
                children: [
                  Expanded(
                    child: Text('admin_categories'.tr,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  TextButton.icon(
                    onPressed: _addSubcategory,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text('add_subcategory'.tr),
                  ),
                ],
              ),
              ...subcategories.map(
                (sub) => Card(
                  child: ListTile(
                    dense: true,
                    title: Text(sub.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                      onPressed: () async {
                        await _admin.deleteSubcategory(
                            widget.category!.id, sub.id);
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
