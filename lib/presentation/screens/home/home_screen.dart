import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/analytics_events.dart';
import '../../../core/theme/app_theme.dart';
import '../../controllers/home_controller.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/cached_image.dart';
import '../../widgets/product_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/shimmer_widgets.dart';
import '../../widgets/state_views.dart';
import 'widgets/banner_carousel.dart';
import 'widgets/category_strip.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppTheme.spacingM,
        title: Row(
          children: [
            const AppLogo(size: 32),
            const SizedBox(width: AppTheme.spacingS),
            Text(
              'app_name'.tr,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.notifications),
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingM, 0, AppTheme.spacingM, AppTheme.spacingM),
            child: _SearchBarButton(),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const HomeShimmer();
        if (controller.hasError.value) {
          return ErrorState(onRetry: controller.loadHome);
        }
        return RefreshIndicator(
          onRefresh: controller.refreshHome,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: AppTheme.spacingM),
              BannerCarousel(
                banners: controller.banners,
                onBannerTap: controller.logBannerClick,
              ),
              if (controller.categories.isNotEmpty) ...[
                SectionHeader(title: 'featured_categories'.tr),
                CategoryStrip(
                  categories: controller.categories,
                  onCategoryTap: controller.logCategoryClick,
                ),
              ],
              if (controller.flashSale.isNotEmpty) ...[
                SectionHeader(
                  title: '⚡ ${'flash_sale'.tr}',
                  trailing: _FlashSaleCountdown(),
                ),
                ProductStrip(
                  products: controller.flashSale,
                  onProductTap: (p) => controller.logSectionClick(
                      AnalyticsEvents.flashSaleClick, p),
                ),
              ],
              if (controller.continueShopping.isNotEmpty) ...[
                SectionHeader(title: 'continue_shopping'.tr),
                _ContinueShoppingStrip(),
              ],
              if (controller.newArrivals.isNotEmpty) ...[
                SectionHeader(title: 'new_arrivals'.tr),
                ProductStrip(products: controller.newArrivals),
              ],
              if (controller.topDeals.isNotEmpty) ...[
                SectionHeader(title: 'top_deals'.tr),
                ProductStrip(products: controller.topDeals),
              ],
              if (controller.bestSellers.isNotEmpty) ...[
                SectionHeader(title: 'best_sellers'.tr),
                ProductStrip(products: controller.bestSellers),
              ],
              if (controller.recommended.isNotEmpty) ...[
                SectionHeader(title: 'recommended'.tr),
                ProductStrip(
                  products: controller.recommended,
                  onProductTap: (p) => controller.logSectionClick(
                      AnalyticsEvents.recommendationClick, p),
                ),
              ],
              if (controller.recentlyViewed.isNotEmpty) ...[
                SectionHeader(title: 'recently_viewed'.tr),
                ProductStrip(
                  products: controller.recentlyViewed,
                  onProductTap: (p) => controller.logSectionClick(
                      AnalyticsEvents.recentlyViewedClick, p),
                ),
              ],
              const SizedBox(height: AppTheme.spacingXl),
            ],
          ),
        );
      }),
    );
  }
}

class _SearchBarButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.search),
      borderRadius: BorderRadius.circular(AppTheme.radiusM),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: scheme.outline),
            const SizedBox(width: AppTheme.spacingS),
            Expanded(
              child: Text(
                'search_hint'.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: scheme.outline),
              ),
            ),
            Icon(Icons.mic_none_rounded, color: scheme.outline),
          ],
        ),
      ),
    );
  }
}

class _FlashSaleCountdown extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final remaining = controller.flashSaleRemaining.value;
      if (remaining == Duration.zero) return const SizedBox.shrink();
      String pad(int n) => n.toString().padLeft(2, '0');
      final text =
          '${pad(remaining.inHours)}:${pad(remaining.inMinutes % 60)}:${pad(remaining.inSeconds % 60)}';
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.badgeBg(context),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '${'ends_in'.tr} $text',
          style: TextStyle(
            color: AppTheme.badgeFg(context),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      );
    });
  }
}

/// Items still in the cart, shown as small resume cards.
class _ContinueShoppingStrip extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    final items = controller.continueShopping;
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppTheme.spacingS),
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                controller.analytics.logEvent(
                    AnalyticsEvents.continueShoppingClick,
                    {AnalyticsEvents.pProductId: item.productId});
                Get.toNamed(AppRoutes.productDetail, arguments: item.productId);
              },
              child: SizedBox(
                width: 220,
                child: Row(
                  children: [
                    CachedImage(url: item.image, width: 84, height: 84),
                    const SizedBox(width: AppTheme.spacingS),
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(AppTheme.spacingS),
                      child: Icon(Icons.chevron_right_rounded),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
