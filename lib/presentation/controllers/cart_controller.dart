import 'dart:async';

import 'package:get/get.dart';

import '../../core/constants/analytics_events.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_logger.dart';
import '../../data/models/cart_item.dart';
import '../../data/models/coupon.dart';
import '../../data/models/product.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/repositories/coupon_repository.dart';
import '../../services/analytics_service.dart';
import '../../services/remote_config_service.dart';
import 'auth_controller.dart';

/// Cart state synced in real time with Firebase, plus coupon and totals
/// calculation. Registered permanently so the badge and continue-shopping
/// sections stay live across the app.
class CartController extends GetxController {
  CartController({
    required this.cartRepository,
    required this.couponRepository,
    required this.analytics,
    required this.remoteConfig,
  });

  final CartRepository cartRepository;
  final CouponRepository couponRepository;
  final AnalyticsService analytics;
  final RemoteConfigService remoteConfig;

  final RxList<CartItem> items = <CartItem>[].obs;
  final RxList<CartItem> savedItems = <CartItem>[].obs;
  final Rxn<Coupon> appliedCoupon = Rxn<Coupon>();
  final RxBool isApplyingCoupon = false.obs;

  StreamSubscription<List<CartItem>>? _cartSub;
  StreamSubscription<List<CartItem>>? _savedSub;

  String? get _uid => Get.find<AuthController>().uid;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  // ---- Totals ----
  double get subtotal => items.fold(0, (sum, item) => sum + item.lineTotal);
  double get mrpTotal => items.fold(0, (sum, item) => sum + item.lineMrpTotal);
  double get productDiscount => mrpTotal - subtotal;
  double get couponDiscount =>
      appliedCoupon.value?.discountFor(subtotal) ?? 0;
  double get deliveryCharge =>
      subtotal - couponDiscount >= remoteConfig.freeShippingThreshold ||
              items.isEmpty
          ? 0
          : AppConstants.shippingCharge;
  double get tax =>
      ((subtotal - couponDiscount) * AppConstants.taxRate * 100).round() / 100;
  double get total => subtotal - couponDiscount + deliveryCharge + tax;
  double get amountToFreeShipping =>
      (remoteConfig.freeShippingThreshold - (subtotal - couponDiscount))
          .clamp(0, double.infinity);

  /// Starts realtime sync once the user is known.
  void bind() {
    final uid = _uid;
    if (uid == null) return;
    _cartSub?.cancel();
    _savedSub?.cancel();
    _cartSub = cartRepository.watchCart(uid).listen(
      (value) {
        items.value = value;
        _revalidateCoupon();
      },
      onError: (Object error) => AppLogger.e('Cart stream error', error: error),
    );
    _savedSub = cartRepository.watchSavedForLater(uid).listen(
      (value) => savedItems.value = value,
      onError: (Object error) => AppLogger.e('Saved stream error', error: error),
    );
  }

  void unbind() {
    _cartSub?.cancel();
    _savedSub?.cancel();
    items.clear();
    savedItems.clear();
    appliedCoupon.value = null;
  }

  Future<void> addProduct(Product product,
      {String size = '', String color = '', int quantity = 1}) async {
    final uid = _uid;
    if (uid == null) return;
    final item = CartItem(
      productId: product.id,
      name: product.name,
      brand: product.brand,
      image: product.thumbnail,
      price: product.price,
      mrp: product.mrp,
      size: size,
      color: color,
      quantity: quantity,
      maxStock: product.stock.clamp(1, AppConstants.maxQuantityPerItem),
      addedAt: DateTime.now().millisecondsSinceEpoch,
    );
    final existing = items.firstWhereOrNull((i) => i.id == item.id);
    if (existing != null) {
      await updateQuantity(existing, existing.quantity + quantity);
    } else {
      await cartRepository.upsertItem(uid, item);
      analytics.logAddToCart(item);
    }
    Get.snackbar('app_name'.tr, 'added_to_cart'.tr);
  }

  Future<void> updateQuantity(CartItem item, int quantity) async {
    final uid = _uid;
    if (uid == null) return;
    final clamped = quantity.clamp(1, item.maxStock);
    if (clamped == item.quantity) return;
    await cartRepository.updateQuantity(uid, item.id, clamped);
    analytics.logEvent(AnalyticsEvents.quantityUpdated, {
      AnalyticsEvents.pProductId: item.productId,
      AnalyticsEvents.pQuantity: clamped,
    });
  }

  Future<void> removeItem(CartItem item) async {
    final uid = _uid;
    if (uid == null) return;
    await cartRepository.removeItem(uid, item.id);
    analytics.logRemoveFromCart(item);
  }

  Future<void> saveForLater(CartItem item) async {
    final uid = _uid;
    if (uid == null) return;
    await cartRepository.saveForLater(uid, item);
  }

  Future<void> moveToCart(CartItem item) async {
    final uid = _uid;
    if (uid == null) return;
    await cartRepository.moveToCart(uid, item);
  }

  Future<void> removeSaved(CartItem item) async {
    final uid = _uid;
    if (uid == null) return;
    await cartRepository.removeSaved(uid, item.id);
  }

  Future<void> clearCart() async {
    final uid = _uid;
    if (uid == null) return;
    await cartRepository.clearCart(uid);
    appliedCoupon.value = null;
  }

  Future<bool> applyCoupon(String code) async {
    isApplyingCoupon.value = true;
    try {
      final coupon = await couponRepository.fetchCoupon(code);
      if (coupon == null || !coupon.isValid) {
        analytics.logEvent(AnalyticsEvents.couponFailed,
            {AnalyticsEvents.pCouponCode: code, AnalyticsEvents.pReason: 'invalid'});
        Get.snackbar('app_name'.tr, 'coupon_invalid'.tr);
        return false;
      }
      if (subtotal < coupon.minOrderValue) {
        analytics.logEvent(AnalyticsEvents.couponFailed, {
          AnalyticsEvents.pCouponCode: code,
          AnalyticsEvents.pReason: 'min_order',
        });
        Get.snackbar(
          'app_name'.tr,
          'coupon_min_order'
              .trParams({'amount': '₹${coupon.minOrderValue.toStringAsFixed(0)}'}),
        );
        return false;
      }
      appliedCoupon.value = coupon;
      analytics.logEvent(AnalyticsEvents.couponApplied,
          {AnalyticsEvents.pCouponCode: coupon.code});
      Get.snackbar('app_name'.tr, 'coupon_applied'.tr);
      return true;
    } finally {
      isApplyingCoupon.value = false;
    }
  }

  void removeCoupon() => appliedCoupon.value = null;

  void _revalidateCoupon() {
    final coupon = appliedCoupon.value;
    if (coupon != null &&
        (items.isEmpty || subtotal < coupon.minOrderValue || !coupon.isValid)) {
      appliedCoupon.value = null;
    }
  }

  @override
  void onClose() {
    unbind();
    super.onClose();
  }
}
