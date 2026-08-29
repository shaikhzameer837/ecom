import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/analytics_events.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_logger.dart';
import '../../data/models/product.dart';
import '../../data/models/review.dart';
import '../../data/repositories/activity_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/review_repository.dart';
import '../../services/analytics_service.dart';
import 'auth_controller.dart';
import 'cart_controller.dart';

class ProductDetailController extends GetxController {
  ProductDetailController({
    required this.productRepository,
    required this.reviewRepository,
    required this.activityRepository,
    required this.analytics,
  });

  final ProductRepository productRepository;
  final ReviewRepository reviewRepository;
  final ActivityRepository activityRepository;
  final AnalyticsService analytics;

  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;

  final Rxn<Product> product = Rxn<Product>();
  final Rx<ProductDetails> details = const ProductDetails().obs;
  final RxList<Review> reviews = <Review>[].obs;
  final RxList<Product> related = <Product>[].obs;
  final RxList<Product> similar = <Product>[].obs;

  final RxString selectedSize = ''.obs;
  final RxString selectedColor = ''.obs;
  final RxInt currentImage = 0.obs;

  late final String productId;

  DateTime get estimatedDelivery =>
      DateTime.now().add(const Duration(days: AppConstants.maxDeliveryDays));

  @override
  void onInit() {
    super.onInit();
    productId = Get.arguments?.toString() ?? '';
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final loaded = await productRepository.fetchProduct(productId);
      if (loaded == null) {
        hasError.value = true;
        return;
      }
      product.value = loaded;
      analytics.logProductViewed(loaded);
      final uid = Get.find<AuthController>().uid;
      if (uid != null) activityRepository.trackProductView(uid, productId);

      // Secondary content loads in parallel and fails independently.
      await Future.wait<void>([
        _quiet(() async =>
            details.value = await productRepository.fetchProductDetails(productId)),
        _quiet(() async =>
            reviews.value = await reviewRepository.fetchReviews(productId)),
        _quiet(() async =>
            related.value = await productRepository.fetchRelated(loaded)),
        _quiet(() async =>
            similar.value = await productRepository.fetchSimilar(loaded)),
      ]);
    } catch (error, stackTrace) {
      AppLogger.e('Product detail load failed',
          error: error, stackTrace: stackTrace);
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _quiet(Future<void> Function() loader) async {
    try {
      await loader();
    } catch (error) {
      AppLogger.e('Detail section failed', error: error);
    }
  }

  Future<void> refreshReviews() async {
    reviews.value = await reviewRepository.fetchReviews(productId);
    final reloaded =
        await productRepository.fetchProduct(productId, useCache: false);
    if (reloaded != null) product.value = reloaded;
  }

  void selectSize(String size) {
    selectedSize.value = size;
    analytics.logEvent(AnalyticsEvents.sizeSelected,
        {AnalyticsEvents.pProductId: productId, 'size': size});
  }

  void selectColor(String color) {
    selectedColor.value = color;
    analytics.logEvent(AnalyticsEvents.colorSelected,
        {AnalyticsEvents.pProductId: productId, 'color': color});
  }

  void onImageChanged(int index) {
    currentImage.value = index;
    analytics.logEvent(AnalyticsEvents.productImageSwiped,
        {AnalyticsEvents.pProductId: productId, 'index': index});
  }

  void onZoomUsed() => analytics.logEvent(
      AnalyticsEvents.productZoomUsed, {AnalyticsEvents.pProductId: productId});

  /// Validates variant selection and delegates to the cart. Returns true on
  /// success so the UI can offer "Go to cart".
  bool addToCart() {
    final current = product.value;
    if (current == null || !current.inStock) return false;
    // Guests must sign in before a cart can be created for them.
    if (!Get.find<AuthController>().requireLogin()) return false;
    if (current.sizes.isNotEmpty && selectedSize.value.isEmpty) {
      Get.snackbar('app_name'.tr, 'select_size_first'.tr);
      return false;
    }
    if (current.colors.isNotEmpty && selectedColor.value.isEmpty) {
      Get.snackbar('app_name'.tr, 'select_color_first'.tr);
      return false;
    }
    Get.find<CartController>().addProduct(
      current,
      size: selectedSize.value,
      color: selectedColor.value,
    );
    return true;
  }

  Future<void> shareProduct() async {
    final current = product.value;
    if (current == null) return;
    analytics.logShare(current);
    await SharePlus.instance.share(ShareParams(
      text: '${'share_product_text'.trParams({'name': current.name})}\n'
          'https://stylemart.app/product/${current.id}',
    ));
  }

  void logRelatedClick(Product clicked) =>
      analytics.logEvent(AnalyticsEvents.relatedProductClick, {
        AnalyticsEvents.pProductId: clicked.id,
        'source_product': productId,
      });
}
