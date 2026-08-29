/// Every analytics event name and parameter key used in the app.
/// Names follow Firebase Analytics conventions (snake_case, <= 40 chars).
class AnalyticsEvents {
  AnalyticsEvents._();

  // Auth
  static const String login = 'login';
  static const String logout = 'logout';
  static const String otpRequested = 'otp_requested';
  static const String otpVerified = 'otp_verified';
  static const String otpFailed = 'otp_failed';

  // Navigation / engagement
  static const String screenView = 'screen_view';
  static const String screenExit = 'screen_exit';
  static const String scrollDepth = 'scroll_depth';

  // Home
  static const String bannerClick = 'banner_click';
  static const String categoryClick = 'category_click';
  static const String flashSaleClick = 'flash_sale_click';
  static const String recommendationClick = 'recommendation_click';
  static const String continueShoppingClick = 'continue_shopping_click';
  static const String recentlyViewedClick = 'recently_viewed_click';

  // Search
  static const String search = 'search';
  static const String searchSuggestionClick = 'search_suggestion_click';
  static const String searchNoResult = 'search_no_result';
  static const String filterApplied = 'filter_applied';
  static const String sortApplied = 'sort_applied';

  // Product
  static const String productViewed = 'view_item';
  static const String productImageSwiped = 'product_image_swiped';
  static const String productZoomUsed = 'product_zoom_used';
  static const String colorSelected = 'color_selected';
  static const String sizeSelected = 'size_selected';
  static const String shareProduct = 'share';
  static const String wishlistAdded = 'add_to_wishlist';
  static const String wishlistRemoved = 'remove_from_wishlist';
  static const String relatedProductClick = 'related_product_click';

  // Cart
  static const String addToCart = 'add_to_cart';
  static const String removeFromCart = 'remove_from_cart';
  static const String quantityUpdated = 'cart_quantity_updated';
  static const String couponApplied = 'coupon_applied';
  static const String couponFailed = 'coupon_failed';
  static const String cartViewed = 'view_cart';

  // Checkout
  static const String checkoutStarted = 'begin_checkout';
  static const String addressSelected = 'address_selected';
  static const String deliverySelected = 'delivery_selected';
  static const String paymentMethodSelected = 'payment_method_selected';
  static const String paymentSuccess = 'payment_success';
  static const String paymentFailed = 'payment_failed';
  static const String orderCompleted = 'purchase';

  // Orders
  static const String orderViewed = 'order_viewed';
  static const String orderCancelRequested = 'order_cancel_requested';
  static const String orderReturnRequested = 'order_return_requested';
  static const String invoiceViewed = 'invoice_viewed';
  static const String reorder = 'reorder';

  // Notifications
  static const String notificationOpened = 'notification_opened';

  // Reviews
  static const String reviewSubmitted = 'review_submitted';
  static const String reviewHelpfulVote = 'review_helpful_vote';

  // Parameter keys
  static const String pProductId = 'product_id';
  static const String pProductName = 'product_name';
  static const String pCategory = 'category';
  static const String pPrice = 'price';
  static const String pQuantity = 'quantity';
  static const String pOrderId = 'order_id';
  static const String pCouponCode = 'coupon_code';
  static const String pSearchTerm = 'search_term';
  static const String pScreenName = 'screen_name';
  static const String pMethod = 'method';
  static const String pValue = 'value';
  static const String pCurrency = 'currency';
  static const String pReason = 'reason';
  static const String pBannerId = 'banner_id';
  static const String pFilterType = 'filter_type';
  static const String pSortType = 'sort_type';
  static const String pDurationSeconds = 'duration_seconds';
}
