/// Global application constants. Never hardcode these values elsewhere.
class AppConstants {
  AppConstants._();

  static const String appName = 'The Ramp';

  // Pagination
  static const int pageSize = 20;
  static const int homeSectionSize = 10;
  static const int reviewPageSize = 10;

  // OTP
  static const int otpLength = 6;
  static const int otpResendSeconds = 30;
  static const int otpTimeoutSeconds = 60;

  // Cart / pricing
  static const double freeShippingThreshold = 999.0;
  static const double shippingCharge = 49.0;
  static const double taxRate = 0.05; // 5% GST on apparel below threshold
  static const int maxQuantityPerItem = 10;

  // Delivery
  static const int minDeliveryDays = 3;
  static const int maxDeliveryDays = 7;

  // Search
  static const int maxRecentSearches = 10;
  static const int maxRecentlyViewed = 20;

  // Misc
  static const String currencySymbol = '₹';
  static const String defaultCountryCode = '+91';

  /// Phone numbers (last 10 digits) granted admin-panel access. In production
  /// this should be backed by the `admins/{uid}` node + server-side checks;
  /// this client list is the dev/bootstrap mechanism.
  static const Set<String> adminPhones = {'9876543210'};
  static const String supportEmail = 'support@stylemart.app';
  static const String razorpayKeyRemoteConfigKey = 'razorpay_key_id';

  // Storage keys (GetStorage)
  static const String keyLanguage = 'language_code';
  static const String keyThemeMode = 'theme_mode';
  static const String keyOnboarded = 'onboarded';
  static const String keyRecentSearches = 'recent_searches';
  static const String keyFcmToken = 'fcm_token';
  // Dev OTP-bypass session (no Firebase Auth).
  static const String keyBypassUid = 'bypass_uid';
  static const String keyBypassPhone = 'bypass_phone';
}
