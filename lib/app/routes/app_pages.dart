import 'package:get/get.dart';

import '../../presentation/screens/admin/admin_dashboard_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/otp_screen.dart';
import '../../presentation/screens/cart/cart_screen.dart';
import '../../presentation/screens/checkout/address_form_screen.dart';
import '../../presentation/screens/checkout/checkout_screen.dart';
import '../../presentation/screens/checkout/order_success_screen.dart';
import '../../presentation/screens/main/main_screen.dart';
import '../../presentation/screens/orders/order_detail_screen.dart';
import '../../presentation/screens/orders/orders_screen.dart';
import '../../presentation/screens/products/product_detail_screen.dart';
import '../../presentation/screens/products/product_list_screen.dart';
import '../../presentation/screens/profile/addresses_screen.dart';
import '../../presentation/screens/profile/edit_profile_screen.dart';
import '../../presentation/screens/profile/language_screen.dart';
import '../../presentation/screens/profile/notifications_screen.dart';
import '../../presentation/screens/reviews/add_review_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../bindings/screen_bindings.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final List<GetPage<dynamic>> pages = [
    GetPage(name: AppRoutes.splash, page: SplashScreen.new),
    GetPage(
      name: AppRoutes.login,
      page: LoginScreen.new,
      transition: Transition.fadeIn,
    ),
    GetPage(name: AppRoutes.otp, page: OtpScreen.new),
    GetPage(
      name: AppRoutes.main,
      page: MainScreen.new,
      binding: MainBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.productList,
      page: ProductListScreen.new,
      binding: ProductListBinding(),
    ),
    GetPage(
      name: AppRoutes.productDetail,
      page: ProductDetailScreen.new,
      binding: ProductDetailBinding(),
      // Allow stacking multiple product pages (related product taps).
      preventDuplicates: false,
    ),
    GetPage(name: AppRoutes.search, page: SearchScreen.new),
    GetPage(name: AppRoutes.cart, page: () => const CartScreen(showBack: true)),
    GetPage(
      name: AppRoutes.checkout,
      page: CheckoutScreen.new,
      binding: CheckoutBinding(),
    ),
    GetPage(
      name: AppRoutes.addressForm,
      page: AddressFormScreen.new,
      binding: AddressBinding(),
    ),
    GetPage(
      name: AppRoutes.orderSuccess,
      page: OrderSuccessScreen.new,
      binding: OrdersBinding(),
    ),
    GetPage(
      name: AppRoutes.orders,
      page: OrdersScreen.new,
      binding: OrdersBinding(),
    ),
    GetPage(
      name: AppRoutes.orderDetail,
      page: OrderDetailScreen.new,
      binding: OrdersBinding(),
    ),
    GetPage(name: AppRoutes.editProfile, page: EditProfileScreen.new),
    GetPage(
      name: AppRoutes.addresses,
      page: AddressesScreen.new,
      binding: AddressBinding(),
    ),
    GetPage(name: AppRoutes.language, page: LanguageScreen.new),
    GetPage(
      name: AppRoutes.notifications,
      page: NotificationsScreen.new,
      binding: NotificationsBinding(),
    ),
    GetPage(
      name: AppRoutes.addReview,
      page: AddReviewScreen.new,
      binding: ReviewBinding(),
    ),
    GetPage(
      name: AppRoutes.admin,
      page: AdminDashboardScreen.new,
      binding: AdminBinding(),
    ),
  ];
}
