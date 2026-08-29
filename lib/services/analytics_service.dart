import 'package:firebase_analytics/firebase_analytics.dart';

import '../core/constants/analytics_events.dart';
import '../core/utils/app_logger.dart';
import '../data/models/cart_item.dart';
import '../data/models/product.dart';

/// Single funnel for all analytics. Screens/controllers never talk to
/// FirebaseAnalytics directly, so events stay consistent and testable.
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Attached to GetMaterialApp navigatorObservers for automatic
  /// screen_view tracking on every route change.
  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> setUserId(String? uid) => _analytics.setUserId(id: uid);

  Future<void> logEvent(String name, [Map<String, Object>? parameters]) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
      AppLogger.d('event: $name $parameters', tag: 'Analytics');
    } catch (error, stackTrace) {
      AppLogger.e('Analytics failure', error: error, stackTrace: stackTrace);
    }
  }

  // ---- Auth ----
  Future<void> logLogin() => logEvent(AnalyticsEvents.login,
      {AnalyticsEvents.pMethod: 'phone_otp'});

  Future<void> logOtpRequested() => logEvent(AnalyticsEvents.otpRequested);

  Future<void> logOtpVerified() => logEvent(AnalyticsEvents.otpVerified);

  Future<void> logLogout() => logEvent(AnalyticsEvents.logout);

  // ---- Screen engagement ----
  Future<void> logScreenExit(String screenName, Duration timeOnScreen) =>
      logEvent(AnalyticsEvents.screenExit, {
        AnalyticsEvents.pScreenName: screenName,
        AnalyticsEvents.pDurationSeconds: timeOnScreen.inSeconds,
      });

  // ---- Product ----
  Map<String, Object> _productParams(Product product) => {
        AnalyticsEvents.pProductId: product.id,
        AnalyticsEvents.pProductName: product.name,
        AnalyticsEvents.pCategory: product.categoryId,
        AnalyticsEvents.pPrice: product.price,
      };

  Future<void> logProductViewed(Product product) =>
      logEvent(AnalyticsEvents.productViewed, _productParams(product));

  Future<void> logWishlistAdded(Product product) =>
      logEvent(AnalyticsEvents.wishlistAdded, _productParams(product));

  Future<void> logWishlistRemoved(String productId) =>
      logEvent(AnalyticsEvents.wishlistRemoved,
          {AnalyticsEvents.pProductId: productId});

  Future<void> logShare(Product product) =>
      logEvent(AnalyticsEvents.shareProduct, _productParams(product));

  // ---- Cart ----
  Future<void> logAddToCart(CartItem item) =>
      logEvent(AnalyticsEvents.addToCart, {
        AnalyticsEvents.pProductId: item.productId,
        AnalyticsEvents.pProductName: item.name,
        AnalyticsEvents.pPrice: item.price,
        AnalyticsEvents.pQuantity: item.quantity,
      });

  Future<void> logRemoveFromCart(CartItem item) =>
      logEvent(AnalyticsEvents.removeFromCart,
          {AnalyticsEvents.pProductId: item.productId});

  // ---- Checkout ----
  Future<void> logCheckoutStarted(double value, int itemCount) =>
      logEvent(AnalyticsEvents.checkoutStarted, {
        AnalyticsEvents.pValue: value,
        AnalyticsEvents.pCurrency: 'INR',
        AnalyticsEvents.pQuantity: itemCount,
      });

  Future<void> logPurchase(String orderId, double value) =>
      logEvent(AnalyticsEvents.orderCompleted, {
        AnalyticsEvents.pOrderId: orderId,
        AnalyticsEvents.pValue: value,
        AnalyticsEvents.pCurrency: 'INR',
      });

  // ---- Search ----
  Future<void> logSearch(String term, int resultCount) async {
    await logEvent(AnalyticsEvents.search, {AnalyticsEvents.pSearchTerm: term});
    if (resultCount == 0) {
      await logEvent(AnalyticsEvents.searchNoResult,
          {AnalyticsEvents.pSearchTerm: term});
    }
  }
}
