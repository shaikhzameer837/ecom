import 'package:get/get.dart';

import '../../data/repositories/activity_repository.dart';
import '../../data/repositories/address_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/banner_repository.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/coupon_repository.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/review_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/wishlist_repository.dart';
import '../../presentation/controllers/auth_controller.dart';
import '../../presentation/controllers/cart_controller.dart';
import '../../presentation/controllers/locale_controller.dart';
import '../../presentation/controllers/theme_controller.dart';
import '../../presentation/controllers/wishlist_controller.dart';
import '../../services/analytics_service.dart';
import '../../services/connectivity_service.dart';
import '../../services/local_storage_service.dart';
import '../../services/notification_service.dart';
import '../../services/payment_service.dart';
import '../../services/remote_config_service.dart';

/// Dependency graph root. Everything app-wide is registered here once;
/// screen-scoped controllers live in their own bindings.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.put(LocalStorageService(), permanent: true);
    Get.put(AnalyticsService(), permanent: true);
    Get.put(RemoteConfigService(), permanent: true);
    Get.put(ConnectivityService(), permanent: true);

    // Repositories (stateless, created on demand, survive route disposal)
    Get.lazyPut(AuthRepository.new, fenix: true);
    Get.lazyPut(UserRepository.new, fenix: true);
    Get.lazyPut(ProductRepository.new, fenix: true);
    Get.lazyPut(CategoryRepository.new, fenix: true);
    Get.lazyPut(BannerRepository.new, fenix: true);
    Get.lazyPut(CartRepository.new, fenix: true);
    Get.lazyPut(WishlistRepository.new, fenix: true);
    Get.lazyPut(OrderRepository.new, fenix: true);
    Get.lazyPut(AddressRepository.new, fenix: true);
    Get.lazyPut(CouponRepository.new, fenix: true);
    Get.lazyPut(ReviewRepository.new, fenix: true);
    Get.lazyPut(ActivityRepository.new, fenix: true);
    Get.lazyPut(NotificationRepository.new, fenix: true);

    Get.put(
      NotificationService(
        userRepository: Get.find(),
        storage: Get.find(),
        analytics: Get.find(),
      ),
      permanent: true,
    );
    Get.lazyPut(() => PaymentService(remoteConfig: Get.find()), fenix: true);

    // App-wide controllers
    Get.put(LocaleController(storage: Get.find()), permanent: true);
    Get.put(ThemeController(storage: Get.find()), permanent: true);
    Get.put(
      AuthController(
        authRepository: Get.find(),
        userRepository: Get.find(),
        analytics: Get.find(),
        storage: Get.find(),
      ),
      permanent: true,
    );
    Get.put(
      CartController(
        cartRepository: Get.find(),
        couponRepository: Get.find(),
        analytics: Get.find(),
        remoteConfig: Get.find(),
      ),
      permanent: true,
    );
    Get.put(
      WishlistController(
        wishlistRepository: Get.find(),
        productRepository: Get.find(),
        analytics: Get.find(),
      ),
      permanent: true,
    );
  }
}
