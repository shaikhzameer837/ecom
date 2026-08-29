import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/analytics_events.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_logger.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';
import '../../services/analytics_service.dart';

enum SortOption { newest, popularity, rating, priceLowHigh, priceHighLow }

extension SortOptionX on SortOption {
  String get localizationKey => switch (this) {
        SortOption.newest => 'sort_newest',
        SortOption.popularity => 'sort_popularity',
        SortOption.rating => 'sort_rating',
        SortOption.priceLowHigh => 'sort_price_low_high',
        SortOption.priceHighLow => 'sort_price_high_low',
      };
}

/// Filter state for the listing screen. Immutable so applying/resetting is
/// a single assignment.
class ProductFilters {
  const ProductFilters({
    this.priceRange,
    this.brands = const {},
    this.colors = const {},
    this.sizes = const {},
    this.minDiscount = 0,
    this.inStockOnly = false,
  });

  final RangeValues? priceRange;
  final Set<String> brands;
  final Set<String> colors;
  final Set<String> sizes;
  final int minDiscount;
  final bool inStockOnly;

  bool get isActive =>
      priceRange != null ||
      brands.isNotEmpty ||
      colors.isNotEmpty ||
      sizes.isNotEmpty ||
      minDiscount > 0 ||
      inStockOnly;

  bool matches(Product product) {
    final range = priceRange;
    if (range != null &&
        (product.price < range.start || product.price > range.end)) {
      return false;
    }
    if (brands.isNotEmpty && !brands.contains(product.brand)) return false;
    if (colors.isNotEmpty && !product.colors.any(colors.contains)) return false;
    if (sizes.isNotEmpty && !product.sizes.any(sizes.contains)) return false;
    if (minDiscount > 0 && product.discountPercent < minDiscount) return false;
    if (inStockOnly && !product.inStock) return false;
    return true;
  }
}

/// Product listing with grid/list toggle, filters, sorting and infinite
/// scrolling. The category feed is fetched once; filtering/sorting/paging
/// happen in memory (see [ProductRepository] for the scale-up note).
class ProductListController extends GetxController {
  ProductListController({
    required this.productRepository,
    required this.analytics,
  });

  final ProductRepository productRepository;
  final AnalyticsService analytics;

  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxBool isGridView = true.obs;
  final RxList<Product> visibleProducts = <Product>[].obs;
  final RxBool hasMore = false.obs;
  final Rx<SortOption> sort = SortOption.popularity.obs;
  final Rx<ProductFilters> filters = const ProductFilters().obs;

  final ScrollController scrollController = ScrollController();

  String categoryId = '';
  String subcategoryId = '';
  String title = '';
  String searchQuery = '';

  List<Product> _all = [];
  List<Product> _filtered = [];
  int _renderedCount = 0;

  // Facets derived from the loaded feed.
  List<String> get availableBrands =>
      {for (final p in _all) p.brand}.where((b) => b.isNotEmpty).toList()..sort();
  List<String> get availableColors =>
      {for (final p in _all) ...p.colors}.toList()..sort();
  List<String> get availableSizes => {for (final p in _all) ...p.sizes}.toList();
  double get maxPrice => _all.isEmpty
      ? 0
      : _all.map((p) => p.price).reduce((a, b) => a > b ? a : b);

  int get totalCount => _filtered.length;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      categoryId = args['categoryId']?.toString() ?? '';
      subcategoryId = args['subcategoryId']?.toString() ?? '';
      title = args['title']?.toString() ?? '';
      searchQuery = args['query']?.toString() ?? '';
    }
    scrollController.addListener(_onScroll);
    load();
  }

  Future<void> load({bool forceRefresh = false}) async {
    isLoading.value = true;
    hasError.value = false;
    try {
      if (searchQuery.isNotEmpty) {
        _all = await productRepository.search(searchQuery);
      } else {
        _all = await productRepository.fetchByCategory(categoryId,
            forceRefresh: forceRefresh);
        if (subcategoryId.isNotEmpty) {
          _all =
              _all.where((p) => p.subcategoryId == subcategoryId).toList();
        }
      }
      _apply();
    } catch (error, stackTrace) {
      AppLogger.e('Product list load failed',
          error: error, stackTrace: stackTrace);
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void _apply() {
    _filtered = _all.where(filters.value.matches).toList();
    _filtered.sort(switch (sort.value) {
      SortOption.newest => (a, b) => b.createdAt.compareTo(a.createdAt),
      SortOption.popularity => (a, b) => b.soldCount.compareTo(a.soldCount),
      SortOption.rating => (a, b) => b.rating.compareTo(a.rating),
      SortOption.priceLowHigh => (a, b) => a.price.compareTo(b.price),
      SortOption.priceHighLow => (a, b) => b.price.compareTo(a.price),
    });
    _renderedCount = AppConstants.pageSize.clamp(0, _filtered.length);
    _publish();
  }

  void _publish() {
    visibleProducts.value = _filtered.take(_renderedCount).toList();
    hasMore.value = _renderedCount < _filtered.length;
  }

  void _onScroll() {
    if (!hasMore.value) return;
    if (scrollController.position.pixels >
        scrollController.position.maxScrollExtent - 400) {
      loadMore();
    }
  }

  void loadMore() {
    if (!hasMore.value) return;
    _renderedCount =
        (_renderedCount + AppConstants.pageSize).clamp(0, _filtered.length);
    _publish();
  }

  void applySort(SortOption option) {
    sort.value = option;
    analytics.logEvent(AnalyticsEvents.sortApplied,
        {AnalyticsEvents.pSortType: option.name});
    _apply();
  }

  void applyFilters(ProductFilters newFilters) {
    filters.value = newFilters;
    analytics.logEvent(AnalyticsEvents.filterApplied, {
      AnalyticsEvents.pFilterType: [
        if (newFilters.priceRange != null) 'price',
        if (newFilters.brands.isNotEmpty) 'brand',
        if (newFilters.colors.isNotEmpty) 'color',
        if (newFilters.sizes.isNotEmpty) 'size',
        if (newFilters.minDiscount > 0) 'discount',
        if (newFilters.inStockOnly) 'availability',
      ].join(','),
    });
    _apply();
  }

  void clearFilters() {
    filters.value = const ProductFilters();
    _apply();
  }

  void toggleView() => isGridView.toggle();

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
