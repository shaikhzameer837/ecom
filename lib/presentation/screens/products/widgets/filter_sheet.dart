import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../controllers/product_list_controller.dart';

/// Bottom sheet with price slider, brand/color/size chips, discount and
/// availability filters.
class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key, required this.controller});

  final ProductListController controller;

  static Future<void> show(
      BuildContext context, ProductListController controller) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => FilterSheet(controller: controller),
    );
  }

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late RangeValues _price;
  late Set<String> _brands;
  late Set<String> _colors;
  late Set<String> _sizes;
  late int _minDiscount;
  late bool _inStockOnly;
  late double _maxPrice;

  @override
  void initState() {
    super.initState();
    final current = widget.controller.filters.value;
    _maxPrice = (widget.controller.maxPrice / 100).ceil() * 100.0;
    if (_maxPrice <= 0) _maxPrice = 100;
    _price = current.priceRange ?? RangeValues(0, _maxPrice);
    _brands = {...current.brands};
    _colors = {...current.colors};
    _sizes = {...current.sizes};
    _minDiscount = current.minDiscount;
    _inStockOnly = current.inStockOnly;
  }

  void _apply() {
    final fullRange = _price.start <= 0 && _price.end >= _maxPrice;
    widget.controller.applyFilters(ProductFilters(
      priceRange: fullRange ? null : _price,
      brands: _brands,
      colors: _colors,
      sizes: _sizes,
      minDiscount: _minDiscount,
      inStockOnly: _inStockOnly,
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingM, AppTheme.spacingM, AppTheme.spacingS, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'filters'.tr,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    controller.clearFilters();
                    Navigator.of(context).pop();
                  },
                  child: Text('clear_all'.tr),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(AppTheme.spacingM),
              children: [
                _sectionTitle('filter_price'.tr,
                    '${Formatters.price(_price.start)} – ${Formatters.price(_price.end)}'),
                RangeSlider(
                  values: _price,
                  min: 0,
                  max: _maxPrice,
                  divisions: 20,
                  labels: RangeLabels(Formatters.price(_price.start),
                      Formatters.price(_price.end)),
                  onChanged: (value) => setState(() => _price = value),
                ),
                if (controller.availableBrands.isNotEmpty) ...[
                  _sectionTitle('filter_brand'.tr),
                  _chips(controller.availableBrands, _brands),
                ],
                if (controller.availableColors.isNotEmpty) ...[
                  _sectionTitle('filter_color'.tr),
                  _chips(controller.availableColors, _colors),
                ],
                if (controller.availableSizes.isNotEmpty) ...[
                  _sectionTitle('filter_size'.tr),
                  _chips(controller.availableSizes, _sizes),
                ],
                _sectionTitle('filter_discount'.tr),
                Wrap(
                  spacing: AppTheme.spacingS,
                  children: [
                    for (final (label, value) in [
                      ('discount_10_plus'.tr, 10),
                      ('discount_25_plus'.tr, 25),
                      ('discount_50_plus'.tr, 50),
                    ])
                      ChoiceChip(
                        label: Text(label),
                        selected: _minDiscount == value,
                        onSelected: (selected) => setState(
                            () => _minDiscount = selected ? value : 0),
                      ),
                  ],
                ),
                _sectionTitle('filter_availability'.tr),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('in_stock_only'.tr),
                  value: _inStockOnly,
                  onChanged: (value) => setState(() => _inStockOnly = value),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: FilledButton(
                onPressed: _apply,
                child: Text('apply'.tr),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, [String? value]) => Padding(
        padding: const EdgeInsets.only(
            top: AppTheme.spacingM, bottom: AppTheme.spacingS),
        child: Row(
          children: [
            Expanded(
              child: Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ),
            if (value != null)
              Text(value, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );

  Widget _chips(List<String> options, Set<String> selected) => Wrap(
        spacing: AppTheme.spacingS,
        runSpacing: AppTheme.spacingXs,
        children: [
          for (final option in options)
            FilterChip(
              label: Text(option),
              selected: selected.contains(option),
              onSelected: (isSelected) => setState(() {
                isSelected ? selected.add(option) : selected.remove(option);
              }),
            ),
        ],
      );
}

/// Sort options bottom sheet.
class SortSheet {
  SortSheet._();

  static Future<void> show(
      BuildContext context, ProductListController controller) {
    return showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Text(
                'sort_by'.tr,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            RadioGroup<SortOption>(
              groupValue: controller.sort.value,
              onChanged: (value) {
                if (value != null) controller.applySort(value);
                Navigator.of(context).pop();
              },
              child: Column(
                children: [
                  for (final option in SortOption.values)
                    RadioListTile<SortOption>(
                      value: option,
                      title: Text(option.localizationKey.tr),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
