import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/product.dart';
import '../../controllers/admin_controller.dart';
import '../../widgets/primary_button.dart';
import 'admin_form_fields.dart';

/// Create/edit a product. Covers the flags that drive the home sections:
/// Featured = Recommended, Best Seller, and Flash Sale. New Arrivals is
/// automatic (newest `createdAt`).
class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.product});

  final Product? product;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final AdminController _admin = Get.find<AdminController>();

  late final _name = TextEditingController(text: widget.product?.name ?? '');
  late final _brand = TextEditingController(text: widget.product?.brand ?? '');
  late final _mrp =
      TextEditingController(text: _numText(widget.product?.mrp));
  late final _price =
      TextEditingController(text: _numText(widget.product?.price));
  late final _stock =
      TextEditingController(text: widget.product?.stock.toString() ?? '');
  late final _colors =
      TextEditingController(text: widget.product?.colors.join(', ') ?? '');
  late final _sizes =
      TextEditingController(text: widget.product?.sizes.join(', ') ?? '');
  late final _images =
      TextEditingController(text: widget.product?.images.join('\n') ?? '');
  late final _keywords =
      TextEditingController(text: widget.product?.keywords.join(', ') ?? '');
  final _description = TextEditingController();
  final _specs = TextEditingController();
  final _offers = TextEditingController();
  final _flashHours = TextEditingController();

  String? _categoryId;
  String? _subcategoryId;
  bool _featured = false;
  bool _bestSeller = false;
  bool _flashSale = false;
  bool _loadingDetails = false;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.product?.categoryId;
    _subcategoryId =
        (widget.product?.subcategoryId.isEmpty ?? true) ? null : widget.product!.subcategoryId;
    _featured = widget.product?.isFeatured ?? false;
    _bestSeller = widget.product?.isBestSeller ?? false;
    _flashSale = widget.product?.isFlashSale ?? false;
    if (widget.product != null) _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() => _loadingDetails = true);
    final details =
        await _admin.productRepository.fetchProductDetails(widget.product!.id);
    _description.text = details.description;
    _specs.text =
        details.specifications.entries.map((e) => '${e.key}: ${e.value}').join('\n');
    _offers.text = details.offers.join('\n');
    if (mounted) setState(() => _loadingDetails = false);
  }

  static String _numText(double? v) =>
      v == null || v == 0 ? '' : (v == v.roundToDouble() ? v.toInt().toString() : v.toString());

  @override
  void dispose() {
    for (final c in [
      _name, _brand, _mrp, _price, _stock, _colors, _sizes, _images,
      _keywords, _description, _specs, _offers, _flashHours,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  List<String> _csv(String v) =>
      v.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  List<String> _lines(String v) =>
      v.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  Map<String, String> _parseSpecs(String v) {
    final map = <String, String>{};
    for (final line in _lines(v)) {
      final i = line.indexOf(':');
      if (i > 0) {
        map[line.substring(0, i).trim()] = line.substring(i + 1).trim();
      }
    }
    return map;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_categoryId == null) {
      Get.snackbar('app_name'.tr, 'field_category'.tr);
      return;
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    final existing = widget.product;
    final flashEnd = _flashSale
        ? now + (int.tryParse(_flashHours.text.trim()) ?? 24) * 3600 * 1000
        : 0;

    final product = Product(
      id: existing?.id ?? '',
      name: _name.text.trim(),
      brand: _brand.text.trim(),
      categoryId: _categoryId!,
      subcategoryId: _subcategoryId ?? '',
      price: double.tryParse(_price.text.trim()) ?? 0,
      mrp: double.tryParse(_mrp.text.trim()) ?? 0,
      images: _lines(_images.text),
      colors: _csv(_colors.text),
      sizes: _csv(_sizes.text),
      stock: int.tryParse(_stock.text.trim()) ?? 0,
      rating: existing?.rating ?? 0,
      ratingCount: existing?.ratingCount ?? 0,
      soldCount: existing?.soldCount ?? 0,
      createdAt: existing?.createdAt ?? now,
      isFeatured: _featured,
      isBestSeller: _bestSeller,
      flashSaleEndsAt: flashEnd,
      keywords: _csv(_keywords.text),
    );
    final details = ProductDetails(
      description: _description.text.trim(),
      specifications: _parseSpecs(_specs.text),
      offers: _lines(_offers.text),
    );

    final ok = await _admin.saveProduct(product, details, id: existing?.id);
    if (ok) {
      Get.back();
      Get.snackbar('app_name'.tr, 'saved_success'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subcategories = _admin.categories
            .firstWhereOrNull((c) => c.id == _categoryId)
            ?.subcategories ??
        [];
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'add_product'.tr : 'edit_product'.tr),
      ),
      body: _loadingDetails
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                children: [
                  AdminField(controller: _name, label: 'field_name'.tr,
                      validator: Validators.requiredField),
                  AdminField(controller: _brand, label: 'field_brand'.tr),
                  DropdownButtonFormField<String>(
                    initialValue: _categoryId,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: 'field_category'.tr),
                    items: _admin.categories
                        .map((c) => DropdownMenuItem(
                            value: c.id, child: Text(c.name)))
                        .toList(),
                    onChanged: (v) => setState(() {
                      _categoryId = v;
                      _subcategoryId = null;
                    }),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  if (subcategories.isNotEmpty)
                    DropdownButtonFormField<String>(
                      initialValue: _subcategoryId,
                      isExpanded: true,
                      decoration:
                          InputDecoration(labelText: 'field_subcategory'.tr),
                      items: [
                        DropdownMenuItem(
                            value: null, child: Text('target_none'.tr)),
                        ...subcategories.map((s) => DropdownMenuItem(
                            value: s.id, child: Text(s.name))),
                      ],
                      onChanged: (v) => setState(() => _subcategoryId = v),
                    ),
                  if (subcategories.isNotEmpty)
                    const SizedBox(height: AppTheme.spacingM),
                  Row(
                    children: [
                      Expanded(
                        child: AdminField(
                            controller: _mrp,
                            label: 'field_mrp'.tr,
                            keyboardType: TextInputType.number,
                            validator: Validators.requiredField),
                      ),
                      const SizedBox(width: AppTheme.spacingM),
                      Expanded(
                        child: AdminField(
                            controller: _price,
                            label: 'field_price'.tr,
                            keyboardType: TextInputType.number,
                            validator: Validators.requiredField),
                      ),
                    ],
                  ),
                  AdminField(
                      controller: _stock,
                      label: 'field_stock'.tr,
                      keyboardType: TextInputType.number),
                  AdminField(controller: _colors, label: 'field_colors'.tr),
                  AdminField(controller: _sizes, label: 'field_sizes'.tr),
                  AdminField(
                      controller: _images,
                      label: 'field_images'.tr,
                      maxLines: 3),
                  AdminField(
                      controller: _keywords, label: 'field_keywords'.tr),
                  AdminField(
                      controller: _description,
                      label: 'field_description'.tr,
                      maxLines: 4),
                  AdminField(
                      controller: _specs,
                      label: 'field_specs'.tr,
                      maxLines: 4),
                  AdminField(
                      controller: _offers,
                      label: 'field_offers'.tr,
                      maxLines: 3),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('flag_featured'.tr),
                    value: _featured,
                    onChanged: (v) => setState(() => _featured = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('flag_bestseller'.tr),
                    value: _bestSeller,
                    onChanged: (v) => setState(() => _bestSeller = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('flag_flash_sale'.tr),
                    value: _flashSale,
                    onChanged: (v) => setState(() => _flashSale = v),
                  ),
                  if (_flashSale)
                    AdminField(
                        controller: _flashHours,
                        label: 'flash_sale_hours'.tr,
                        keyboardType: TextInputType.number),
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
