/// Firebase Realtime Database node paths.
///
/// Schema overview (all reads/writes must go through repositories):
/// ```
/// users/{uid}                     -> profile
/// users/{uid}/fcmTokens/{token}   -> true
/// products/{productId}
/// productDetails/{productId}      -> heavy fields (description, specs)
/// categories/{categoryId}
/// banners/{bannerId}
/// carts/{uid}/{productId_variant}
/// savedForLater/{uid}/{itemId}
/// wishlists/{uid}/{productId}     -> timestamp
/// orders/{uid}/{orderId}
/// ordersByStatus/{status}/{orderId} -> uid (admin fan-out, future)
/// addresses/{uid}/{addressId}
/// coupons/{code}
/// reviews/{productId}/{reviewId}
/// reviewVotes/{reviewId}/{uid}    -> true
/// notifications/{uid}/{notificationId}
/// recentlyViewed/{uid}/{productId} -> timestamp
/// searchHistory/{uid}/{pushId}    -> {query, timestamp}
/// trendingSearches/{term}          -> count
/// admins/{uid}                     -> true (future admin panel)
/// ```
class DbPaths {
  DbPaths._();

  static const String users = 'users';
  static const String products = 'products';
  static const String productDetails = 'productDetails';
  static const String categories = 'categories';
  static const String banners = 'banners';
  static const String carts = 'carts';
  static const String savedForLater = 'savedForLater';
  static const String wishlists = 'wishlists';
  static const String orders = 'orders';
  static const String addresses = 'addresses';
  static const String coupons = 'coupons';
  static const String reviews = 'reviews';
  static const String reviewVotes = 'reviewVotes';
  static const String notifications = 'notifications';
  static const String recentlyViewed = 'recentlyViewed';
  static const String searchHistory = 'searchHistory';
  static const String trendingSearches = 'trendingSearches';
  static const String admins = 'admins';
}
