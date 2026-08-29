import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/nav_controller.dart';
import '../../controllers/wishlist_controller.dart';
import '../../widgets/login_required_view.dart';
import '../../widgets/product_card.dart';
import '../../widgets/shimmer_widgets.dart';
import '../../widgets/state_views.dart';

class WishlistScreen extends GetView<WishlistController> {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('wishlist_title'.tr)),
      body: Obx(() {
        if (Get.find<AuthController>().isGuest) {
          return LoginRequiredView(
            icon: Icons.favorite_outline_rounded,
            message: 'login_required_wishlist'.tr,
          );
        }
        if (controller.isLoading.value) return const ProductGridShimmer();
        if (controller.products.isEmpty) {
          return EmptyState(
            icon: Icons.favorite_outline_rounded,
            title: 'wishlist_empty'.tr,
            subtitle: 'wishlist_empty_desc'.tr,
            actionLabel: 'start_shopping'.tr,
            onAction: () {
              if (Get.isRegistered<NavController>()) {
                Get.find<NavController>().changeTab(0);
              }
            },
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 240,
            mainAxisSpacing: AppTheme.spacingM,
            crossAxisSpacing: AppTheme.spacingM,
            childAspectRatio: 0.58,
          ),
          itemCount: controller.products.length,
          itemBuilder: (context, index) =>
              ProductCard(product: controller.products[index]),
        );
      }),
    );
  }
}
