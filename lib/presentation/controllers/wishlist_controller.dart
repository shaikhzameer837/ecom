import 'dart:async';

import 'package:get/get.dart';

import '../../core/utils/app_logger.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/wishlist_repository.dart';
import '../../services/analytics_service.dart';
import 'auth_controller.dart';

/// Realtime wishlist: ids stream from Firebase, resolved to products via
/// the cached product repository.
class WishlistController extends GetxController {
  WishlistController({
    required this.wishlistRepository,
    required this.productRepository,
    required this.analytics,
  });

  final WishlistRepository wishlistRepository;
  final ProductRepository productRepository;
  final AnalyticsService analytics;

  final RxSet<String> ids = <String>{}.obs;
  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = false.obs;

  StreamSubscription<List<String>>? _subscription;
  List<String> _orderedIds = [];

  String? get _uid => Get.find<AuthController>().uid;

  bool isWishlisted(String productId) => ids.contains(productId);

  void bind() {
    final uid = _uid;
    if (uid == null) return;
    _subscription?.cancel();
    isLoading.value = true;
    _subscription = wishlistRepository.watchWishlist(uid).listen(
      (value) async {
        _orderedIds = value;
        ids.assignAll(value);
        await _resolveProducts();
        isLoading.value = false;
      },
      onError: (Object error) {
        AppLogger.e('Wishlist stream error', error: error);
        isLoading.value = false;
      },
    );
  }

  void unbind() {
    _subscription?.cancel();
    ids.clear();
    products.clear();
  }

  Future<void> _resolveProducts() async {
    final resolved = await productRepository.fetchByIds(_orderedIds);
    // Preserve wishlist order (newest first).
    final byId = {for (final p in resolved) p.id: p};
    products.value =
        _orderedIds.map((id) => byId[id]).whereType<Product>().toList();
  }

  Future<void> toggle(Product product) async {
    final uid = _uid;
    if (uid == null) return;
    if (ids.contains(product.id)) {
      await wishlistRepository.remove(uid, product.id);
      analytics.logWishlistRemoved(product.id);
      Get.snackbar('app_name'.tr, 'removed_from_wishlist'.tr);
    } else {
      await wishlistRepository.add(uid, product.id);
      analytics.logWishlistAdded(product);
      Get.snackbar('app_name'.tr, 'added_to_wishlist'.tr);
    }
  }

  @override
  void onClose() {
    unbind();
    super.onClose();
  }
}
