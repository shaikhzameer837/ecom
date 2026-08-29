import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/product.dart';
import '../../controllers/product_list_controller.dart';
import '../../widgets/cached_image.dart';
import '../../widgets/price_text.dart';
import '../../widgets/product_card.dart';
import '../../widgets/rating_stars.dart';
import '../../widgets/shimmer_widgets.dart';
import '../../widgets/state_views.dart';
import 'widgets/filter_sheet.dart';

/// Listing with grid/list toggle, filter + sort sheets and infinite scroll.
class ProductListScreen extends GetView<ProductListController> {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            controller.title.isEmpty ? 'app_name'.tr : controller.title),
        actions: [
          Obx(() => IconButton(
                tooltip: 'sort_by'.tr,
                onPressed: controller.toggleView,
                icon: Icon(controller.isGridView.value
                    ? Icons.view_list_outlined
                    : Icons.grid_view_outlined),
              )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const ProductGridShimmer();
        if (controller.hasError.value) {
          return ErrorState(onRetry: controller.load);
        }
        if (controller.visibleProducts.isEmpty) {
          return EmptyState(
            icon: Icons.search_off_rounded,
            title: 'no_products_found'.tr,
            subtitle: 'no_products_found_desc'.tr,
            actionLabel:
                controller.filters.value.isActive ? 'clear_all'.tr : null,
            onAction:
                controller.filters.value.isActive ? controller.clearFilters : null,
          );
        }
        return Column(
          children: [
            _toolbar(context),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.load(forceRefresh: true),
                child: controller.isGridView.value
                    ? _grid(context)
                    : _list(context),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _toolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM, vertical: AppTheme.spacingS),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'products_count'
                  .trParams({'count': '${controller.totalCount}'}),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          ActionChip(
            avatar: const Icon(Icons.swap_vert_rounded, size: 18),
            label: Text('sort_by'.tr),
            onPressed: () => SortSheet.show(context, controller),
          ),
          const SizedBox(width: AppTheme.spacingS),
          Obx(() => ActionChip(
                avatar: Icon(
                  Icons.tune_rounded,
                  size: 18,
                  color: controller.filters.value.isActive
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                label: Text('filters'.tr),
                onPressed: () => FilterSheet.show(context, controller),
              )),
        ],
      ),
    );
  }

  Widget _grid(BuildContext context) {
    return GridView.builder(
      controller: controller.scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppTheme.spacingM),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        mainAxisSpacing: AppTheme.spacingM,
        crossAxisSpacing: AppTheme.spacingM,
        childAspectRatio: 0.58,
      ),
      itemCount:
          controller.visibleProducts.length + (controller.hasMore.value ? 2 : 0),
      itemBuilder: (context, index) {
        if (index >= controller.visibleProducts.length) {
          return const ShimmerBox(height: double.infinity);
        }
        return ProductCard(product: controller.visibleProducts[index]);
      },
    );
  }

  Widget _list(BuildContext context) {
    return ListView.separated(
      controller: controller.scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppTheme.spacingM),
      itemCount:
          controller.visibleProducts.length + (controller.hasMore.value ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: AppTheme.spacingS),
      itemBuilder: (context, index) {
        if (index >= controller.visibleProducts.length) {
          return const ShimmerBox(height: 110, radius: AppTheme.radiusM);
        }
        return _ProductListTile(product: controller.visibleProducts[index]);
      },
    );
  }
}

class _ProductListTile extends StatelessWidget {
  const _ProductListTile({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>
            Get.toNamed(AppRoutes.productDetail, arguments: product.id),
        child: Row(
          children: [
            CachedImage(url: product.thumbnail, width: 110, height: 130),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.brand.isNotEmpty)
                      Text(product.brand,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.colorScheme.outline)),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    if (product.ratingCount > 0)
                      RatingStars(
                          rating: product.rating, count: product.ratingCount),
                    const SizedBox(height: 4),
                    PriceText(price: product.price, mrp: product.mrp),
                    if (!product.inStock)
                      Text(
                        'out_of_stock'.tr,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(AppTheme.spacingS),
              child: Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
