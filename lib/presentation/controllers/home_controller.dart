import 'dart:async';

import 'package:get/get.dart';

import '../../core/constants/analytics_events.dart';
import '../../core/utils/app_logger.dart';
import '../../data/models/banner_item.dart';
import '../../data/models/cart_item.dart';
import '../../data/models/category_model.dart';
import '../../data/models/product.dart';
import '../../data/repositories/activity_repository.dart';
import '../../data/repositories/banner_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../services/analytics_service.dart';
import 'auth_controller.dart';
import 'cart_controller.dart';

/// Home feed: banners, flash sale, arrivals, best sellers, recommendations,
/// recently viewed and continue-shopping. Sections load in parallel and
/// fail independently.
class HomeController extends GetxController {
  HomeController({
    required this.productRepository,
    required this.bannerRepository,
    required this.categoryRepository,
    required this.activityRepository,
    required this.analytics,
  });

  final ProductRepository productRepository;
  final BannerRepository bannerRepository;
  final CategoryRepository categoryRepository;
  final ActivityRepository activityRepository;
  final AnalyticsService analytics;

  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;

  final RxList<BannerItem> banners = <BannerItem>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<Product> flashSale = <Product>[].obs;
  final RxList<Product> newArrivals = <Product>[].obs;
  final RxList<Product> bestSellers = <Product>[].obs;
  final RxList<Product> recommended = <Product>[].obs;
  final RxList<Product> recentlyViewed = <Product>[].obs;
  final RxList<Product> topDeals = <Product>[].obs;

  /// Continue shopping = latest items sitting in the cart.
  List<CartItem> get continueShopping =>
      Get.find<CartController>().items.take(4).toList();

  final Rx<Duration> flashSaleRemaining = Duration.zero.obs;
  Timer? _flashSaleTimer;

  @override
  void onInit() {
    super.onInit();
    loadHome();
  }

  Future<void> loadHome() async {
    isLoading.value = true;
    hasError.value = false;
    await Future.wait<void>([
      _load(() async => banners.value = await bannerRepository.fetchBanners()),
      _load(() async =>
          categories.value = await categoryRepository.fetchCategories()),
      _load(() async =>
          flashSale.value = await productRepository.fetchFlashSale()),
      _load(() async =>
          newArrivals.value = await productRepository.fetchNewArrivals()),
      _load(() async =>
          bestSellers.value = await productRepository.fetchBestSellers()),
      _load(() async =>
          recommended.value = await productRepository.fetchFeatured()),
      _load(_loadRecentlyViewed),
    ]);
    // Top deals: highest discount among what we already have in memory.
    final pool = {...newArrivals, ...bestSellers, ...recommended}.toList()
      ..sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
    topDeals.value = pool.where((p) => p.discountPercent >= 20).take(10).toList();

    // The feed is unusable only when every primary section failed/is empty.
    hasError.value = banners.isEmpty &&
        categories.isEmpty &&
        newArrivals.isEmpty &&
        bestSellers.isEmpty;
    _startFlashSaleTimer();
    isLoading.value = false;
  }

  Future<void> _load(Future<void> Function() loader) async {
    try {
      await loader();
    } catch (error, stackTrace) {
      AppLogger.e('Home section failed', error: error, stackTrace: stackTrace);
    }
  }

  Future<void> _loadRecentlyViewed() async {
    final uid = Get.find<AuthController>().uid;
    if (uid == null) return;
    final ids = await activityRepository.fetchRecentlyViewed(uid);
    recentlyViewed.value =
        await productRepository.fetchByIds(ids.take(10).toList());
  }

  Future<void> refreshHome() => loadHome();

  void _startFlashSaleTimer() {
    _flashSaleTimer?.cancel();
    if (flashSale.isEmpty) return;
    final endsAt = flashSale
        .map((p) => p.flashSaleEndsAt)
        .where((t) => t > 0)
        .fold<int>(0, (max, t) => t > max ? t : max);
    if (endsAt == 0) return;
    _flashSaleTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = Duration(
          milliseconds: endsAt - DateTime.now().millisecondsSinceEpoch);
      if (remaining.isNegative) {
        flashSaleRemaining.value = Duration.zero;
        timer.cancel();
      } else {
        flashSaleRemaining.value = remaining;
      }
    });
  }

  void logBannerClick(BannerItem banner) =>
      analytics.logEvent(AnalyticsEvents.bannerClick,
          {AnalyticsEvents.pBannerId: banner.id});

  void logCategoryClick(CategoryModel category) =>
      analytics.logEvent(AnalyticsEvents.categoryClick,
          {AnalyticsEvents.pCategory: category.id});

  void logSectionClick(String event, Product product) =>
      analytics.logEvent(event, {
        AnalyticsEvents.pProductId: product.id,
        AnalyticsEvents.pProductName: product.name,
      });

  @override
  void onClose() {
    _flashSaleTimer?.cancel();
    super.onClose();
  }
}
