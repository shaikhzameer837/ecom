import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/coupon.dart';
import '../../controllers/admin_controller.dart';
import '../../widgets/cached_image.dart';
import '../../widgets/state_views.dart';
import 'banner_form_screen.dart';
import 'category_form_screen.dart';
import 'coupon_form_screen.dart';
import 'product_form_screen.dart';

/// Admin panel: four tabs (Products, Categories, Banners, Coupons) each with
/// list + add/edit/delete. Reachable only for admin phone numbers.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  final AdminController controller = Get.find<AdminController>();
  late final TabController _tabs = TabController(length: 4, vsync: this)
    ..addListener(() => setState(() {}));

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _onAdd() {
    switch (_tabs.index) {
      case 0:
        Get.to(() => const ProductFormScreen());
      case 1:
        Get.to(() => const CategoryFormScreen());
      case 2:
        Get.to(() => const BannerFormScreen());
      case 3:
        Get.to(() => const CouponFormScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('admin_panel'.tr),
        actions: [
          IconButton(
            onPressed: controller.refreshAll,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            Tab(text: 'admin_products'.tr),
            Tab(text: 'admin_categories'.tr),
            Tab(text: 'admin_banners'.tr),
            Tab(text: 'admin_coupons'.tr),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAdd,
        child: const Icon(Icons.add_rounded),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _ProductsTab(),
          _CategoriesTab(),
          _BannersTab(),
          _CouponsTab(),
        ],
      ),
    );
  }
}

/// Shared confirm-then-delete helper.
Future<void> _confirmDelete(VoidCallback onConfirm) async {
  Get.defaultDialog(
    title: 'delete'.tr,
    middleText: 'delete_confirm_generic'.tr,
    textConfirm: 'yes'.tr,
    textCancel: 'no'.tr,
    onConfirm: () {
      Get.back();
      onConfirm();
    },
  );
}

class _ProductsTab extends StatelessWidget {
  const _ProductsTab();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();
    return Obx(() {
      if (controller.loadingProducts.value && controller.products.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.products.isEmpty) {
        return EmptyState(
            icon: Icons.inventory_2_outlined, title: 'no_items_yet'.tr);
      }
      return RefreshIndicator(
        onRefresh: controller.loadProducts,
        child: ListView.separated(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          itemCount: controller.products.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppTheme.spacingS),
          itemBuilder: (context, index) {
            final product = controller.products[index];
            return Card(
              child: ListTile(
                leading: CachedImage(
                  url: product.thumbnail,
                  width: 44,
                  height: 52,
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                title: Text(product.name,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  '${Formatters.price(product.price)}  ·  ${'field_stock'.tr}: ${product.stock}'
                  '${product.isFeatured ? '  ·  ★' : ''}'
                  '${product.isBestSeller ? '  ·  🔥' : ''}'
                  '${product.isFlashSale ? '  ·  ⚡' : ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => Get.to(() => ProductFormScreen(product: product)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: () => _confirmDelete(
                      () => controller.deleteProduct(product.id)),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();
    return Obx(() {
      if (controller.loadingCategories.value && controller.categories.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.categories.isEmpty) {
        return EmptyState(
            icon: Icons.category_outlined, title: 'no_items_yet'.tr);
      }
      return RefreshIndicator(
        onRefresh: controller.loadCategories,
        child: ListView.separated(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          itemCount: controller.categories.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppTheme.spacingS),
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            return Card(
              child: ListTile(
                leading: category.image.isEmpty
                    ? const Icon(Icons.category_outlined)
                    : CachedImage(
                        url: category.image,
                        width: 44,
                        height: 44,
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                      ),
                title: Text(category.name),
                subtitle: Text('${category.subcategories.length} '
                    '${'admin_categories'.tr.toLowerCase()}'),
                onTap: () =>
                    Get.to(() => CategoryFormScreen(category: category)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: () => _confirmDelete(
                      () => controller.deleteCategory(category.id)),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

class _BannersTab extends StatelessWidget {
  const _BannersTab();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();
    return Obx(() {
      if (controller.loadingBanners.value && controller.banners.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.banners.isEmpty) {
        return EmptyState(
            icon: Icons.image_outlined, title: 'no_items_yet'.tr);
      }
      return RefreshIndicator(
        onRefresh: controller.loadBanners,
        child: ListView.separated(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          itemCount: controller.banners.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppTheme.spacingS),
          itemBuilder: (context, index) {
            final banner = controller.banners[index];
            return Card(
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                leading: CachedImage(
                  url: banner.image,
                  width: 64,
                  height: 44,
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                title: Text(banner.title.isEmpty ? banner.id : banner.title,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(banner.active ? 'field_active'.tr : '—'),
                onTap: () => Get.to(() => BannerFormScreen(banner: banner)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: () =>
                      _confirmDelete(() => controller.deleteBanner(banner.id)),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

class _CouponsTab extends StatelessWidget {
  const _CouponsTab();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();
    return Obx(() {
      if (controller.loadingCoupons.value && controller.coupons.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.coupons.isEmpty) {
        return EmptyState(
            icon: Icons.local_offer_outlined, title: 'no_items_yet'.tr);
      }
      return RefreshIndicator(
        onRefresh: controller.loadCoupons,
        child: ListView.separated(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          itemCount: controller.coupons.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppTheme.spacingS),
          itemBuilder: (context, index) {
            final coupon = controller.coupons[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.local_offer_outlined),
                title: Text(coupon.code,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(
                  coupon.type == CouponType.percent
                      ? '${coupon.value.toStringAsFixed(0)}%  ·  min ${Formatters.price(coupon.minOrderValue)}'
                      : '${Formatters.price(coupon.value)}  ·  min ${Formatters.price(coupon.minOrderValue)}',
                ),
                onTap: () => Get.to(() => CouponFormScreen(coupon: coupon)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: () =>
                      _confirmDelete(() => controller.deleteCoupon(coupon.code)),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
