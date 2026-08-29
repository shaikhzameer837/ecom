import 'dart:async';

import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/analytics_events.dart';
import '../../core/utils/app_logger.dart';
import '../../data/models/product.dart';
import '../../data/repositories/activity_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../services/analytics_service.dart';
import '../../services/local_storage_service.dart';
import 'auth_controller.dart';

/// Search with live suggestions, recent + trending terms, and history.
/// Voice search: the mic entry point exists in the UI; plug a
/// speech-to-text engine into [startVoiceSearch] later.
class ProductSearchController extends GetxController {
  ProductSearchController({
    required this.productRepository,
    required this.activityRepository,
    required this.storage,
    required this.analytics,
  });

  final ProductRepository productRepository;
  final ActivityRepository activityRepository;
  final LocalStorageService storage;
  final AnalyticsService analytics;

  final RxString query = ''.obs;
  final RxList<Product> suggestions = <Product>[].obs;
  final RxList<String> recentSearches = <String>[].obs;
  final RxList<String> trendingSearches = <String>[].obs;
  final RxBool isSearching = false.obs;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    recentSearches.value = storage.recentSearches;
    _loadTrending();
  }

  Future<void> _loadTrending() async {
    try {
      trendingSearches.value = await activityRepository.fetchTrendingSearches();
    } catch (error) {
      AppLogger.e('Trending load failed', error: error);
    }
  }

  void onQueryChanged(String value) {
    query.value = value;
    _debounce?.cancel();
    if (value.trim().length < 2) {
      suggestions.clear();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      isSearching.value = true;
      try {
        suggestions.value =
            (await productRepository.search(value)).take(8).toList();
      } catch (error) {
        AppLogger.e('Suggestion search failed', error: error);
      } finally {
        isSearching.value = false;
      }
    });
  }

  /// Commits a search: records history and opens the results listing.
  Future<void> submit(String value) async {
    final term = value.trim();
    if (term.isEmpty) return;
    await storage.addRecentSearch(term);
    recentSearches.value = storage.recentSearches;

    final uid = Get.find<AuthController>().uid;
    if (uid != null) activityRepository.trackSearch(uid, term);

    final results = await productRepository.search(term);
    await analytics.logSearch(term, results.length);

    Get.toNamed(AppRoutes.productList, arguments: {
      'query': term,
      'title': term,
    });
  }

  void onSuggestionTap(Product product) {
    analytics.logEvent(AnalyticsEvents.searchSuggestionClick, {
      AnalyticsEvents.pSearchTerm: query.value,
      AnalyticsEvents.pProductId: product.id,
    });
    Get.toNamed(AppRoutes.productDetail, arguments: product.id);
  }

  Future<void> clearHistory() async {
    await storage.clearRecentSearches();
    recentSearches.clear();
  }

  /// Placeholder — architecture hook for a future speech-to-text engine.
  void startVoiceSearch() {
    Get.snackbar('app_name'.tr, 'voice_search_coming_soon'.tr);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}
