import 'package:get/get.dart';

import '../../presentation/controllers/address_controller.dart';
import '../../presentation/controllers/admin_controller.dart';
import '../../presentation/controllers/categories_controller.dart';
import '../../presentation/controllers/checkout_controller.dart';
import '../../presentation/controllers/home_controller.dart';
import '../../presentation/controllers/nav_controller.dart';
import '../../presentation/controllers/notification_controller.dart';
import '../../presentation/controllers/orders_controller.dart';
import '../../presentation/controllers/product_detail_controller.dart';
import '../../presentation/controllers/product_list_controller.dart';
import '../../presentation/controllers/review_controller.dart';
import '../../presentation/controllers/search_controller.dart';

/// Screen-scoped bindings. Controllers are created when their route is
/// pushed and disposed when it is popped, keeping memory flat.
class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(NavController.new);
    Get.lazyPut(() => HomeController(
          productRepository: Get.find(),
          bannerRepository: Get.find(),
          categoryRepository: Get.find(),
          activityRepository: Get.find(),
          analytics: Get.find(),
        ));
    Get.lazyPut(() => CategoriesController(categoryRepository: Get.find()));
    Get.lazyPut(() => ProductSearchController(
          productRepository: Get.find(),
          activityRepository: Get.find(),
          storage: Get.find(),
          analytics: Get.find(),
        ));
  }
}

class ProductListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProductListController(
          productRepository: Get.find(),
          analytics: Get.find(),
        ));
  }
}

class ProductDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProductDetailController(
          productRepository: Get.find(),
          reviewRepository: Get.find(),
          activityRepository: Get.find(),
          analytics: Get.find(),
        ));
    Get.lazyPut(() => ReviewController(
          reviewRepository: Get.find(),
          analytics: Get.find(),
        ));
  }
}

class CheckoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AddressController(addressRepository: Get.find()));
    Get.lazyPut(() => CheckoutController(
          orderRepository: Get.find(),
          paymentService: Get.find(),
          analytics: Get.find(),
        ));
  }
}

class AddressBinding extends Bindings {
  @override
  void dependencies() {
    // Reuse the checkout instance when navigating from checkout.
    if (!Get.isRegistered<AddressController>()) {
      Get.lazyPut(() => AddressController(addressRepository: Get.find()));
    }
  }
}

class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<OrdersController>()) {
      Get.lazyPut(() => OrdersController(
            orderRepository: Get.find(),
            analytics: Get.find(),
          ));
    }
  }
}

class ReviewBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ReviewController>()) {
      Get.lazyPut(() => ReviewController(
            reviewRepository: Get.find(),
            analytics: Get.find(),
          ));
    }
  }
}

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NotificationController(
          notificationRepository: Get.find(),
        ));
  }
}

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AdminController(
          productRepository: Get.find(),
          categoryRepository: Get.find(),
          bannerRepository: Get.find(),
          couponRepository: Get.find(),
        ));
  }
}
