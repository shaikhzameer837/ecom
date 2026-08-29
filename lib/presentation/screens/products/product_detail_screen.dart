import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/product.dart';
import '../../../data/models/review.dart';
import '../../controllers/product_detail_controller.dart';
import '../../controllers/review_controller.dart';
import '../../widgets/cached_image.dart';
import '../../widgets/price_text.dart';
import '../../widgets/product_card.dart';
import '../../widgets/rating_stars.dart';
import '../../widgets/section_header.dart';
import '../../widgets/shimmer_widgets.dart';
import '../../widgets/state_views.dart';
import '../../widgets/wishlist_button.dart';

class ProductDetailScreen extends GetView<ProductDetailController> {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const SafeArea(child: HomeShimmer());
        }
        final product = controller.product.value;
        if (controller.hasError.value || product == null) {
          return SafeArea(child: ErrorState(onRetry: controller.load));
        }
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 420,
              actions: [
                IconButton(
                  onPressed: controller.shareProduct,
                  icon: const Icon(Icons.share_outlined),
                ),
                WishlistButton(product: product),
                const SizedBox(width: AppTheme.spacingS),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: _ImageGallery(product: product),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(context, product),
                    const SizedBox(height: AppTheme.spacingM),
                    if (product.colors.isNotEmpty) ...[
                      _ColorSelector(product: product),
                      const SizedBox(height: AppTheme.spacingM),
                    ],
                    if (product.sizes.isNotEmpty) ...[
                      _SizeSelector(product: product),
                      const SizedBox(height: AppTheme.spacingM),
                    ],
                    _deliveryAndOffers(context),
                    const SizedBox(height: AppTheme.spacingM),
                    _DescriptionAndSpecs(),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: _ReviewsSection()),
            SliverToBoxAdapter(
              child: Obx(() => controller.related.isEmpty
                  ? const SizedBox.shrink()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(title: 'related_products'.tr),
                        ProductStrip(
                          products: controller.related,
                          onProductTap: controller.logRelatedClick,
                        ),
                      ],
                    )),
            ),
            SliverToBoxAdapter(
              child: Obx(() => controller.similar.isEmpty
                  ? const SizedBox.shrink()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(title: 'similar_products'.tr),
                        ProductStrip(
                          products: controller.similar,
                          onProductTap: controller.logRelatedClick,
                        ),
                      ],
                    )),
            ),
            const SliverToBoxAdapter(
                child: SizedBox(height: AppTheme.spacingXl)),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        final product = controller.product.value;
        if (product == null) return const SizedBox.shrink();
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: product.inStock
                        ? () {
                            if (controller.addToCart()) {
                              Get.toNamed(AppRoutes.cart);
                            }
                          }
                        : null,
                    icon: const Icon(Icons.flash_on_rounded, size: 20),
                    label: Text('buy_now'.tr),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: FilledButton.icon(
                    onPressed:
                        product.inStock ? () => controller.addToCart() : null,
                    icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                    label: Text(product.inStock
                        ? 'add_to_cart'.tr
                        : 'out_of_stock'.tr),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _header(BuildContext context, Product product) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (product.brand.isNotEmpty)
          Text(product.brand,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.outline)),
        Text(product.name, style: theme.textTheme.titleLarge),
        const SizedBox(height: AppTheme.spacingS),
        if (product.ratingCount > 0)
          Row(
            children: [
              RatingStars(rating: product.rating, count: product.ratingCount),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                'based_on_reviews'
                    .trParams({'count': '${product.ratingCount}'}),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        const SizedBox(height: AppTheme.spacingS),
        PriceText(price: product.price, mrp: product.mrp, large: true),
        const SizedBox(height: AppTheme.spacingXs),
        if (product.lowStock)
          Text(
            'only_left'.trParams({'count': '${product.stock}'}),
            style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error, fontWeight: FontWeight.w600),
          )
        else
          Text(
            product.inStock ? 'in_stock'.tr : 'out_of_stock'.tr,
            style: theme.textTheme.bodySmall?.copyWith(
              color: product.inStock
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _deliveryAndOffers(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final offers = controller.details.value.offers;
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.local_shipping_outlined,
                      size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: AppTheme.spacingS),
                  Expanded(
                    child: Text(
                      'estimated_delivery'.trParams({
                        'date': Formatters.date(controller.estimatedDelivery),
                      }),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              if (offers.isNotEmpty) ...[
                const Divider(height: AppTheme.spacingL),
                Text('available_offers'.tr,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppTheme.spacingS),
                for (final offer in offers)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.spacingXs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.local_offer_outlined,
                            size: 16, color: theme.colorScheme.onSurface),
                        const SizedBox(width: AppTheme.spacingS),
                        Expanded(
                            child: Text(offer,
                                style: theme.textTheme.bodySmall)),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      );
    });
  }
}

/// Swipeable gallery with pinch-zoom (InteractiveViewer) and dots.
class _ImageGallery extends GetView<ProductDetailController> {
  const _ImageGallery({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    if (product.images.isEmpty) {
      return const CachedImage(url: '');
    }
    return Stack(
      children: [
        PageView.builder(
          itemCount: product.images.length,
          onPageChanged: controller.onImageChanged,
          itemBuilder: (context, index) => InteractiveViewer(
            maxScale: 4,
            onInteractionStart: (details) {
              if (details.pointerCount > 1) controller.onZoomUsed();
            },
            child: CachedImage(
                url: product.images[index], fit: BoxFit.cover),
          ),
        ),
        Positioned(
          bottom: AppTheme.spacingM,
          left: 0,
          right: 0,
          child: Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(product.images.length, (index) {
                  final active = index == controller.currentImage.value;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white70,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              )),
        ),
      ],
    );
  }
}

class _ColorSelector extends GetView<ProductDetailController> {
  const _ColorSelector({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('select_color'.tr,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppTheme.spacingS),
        Obx(() => Wrap(
              spacing: AppTheme.spacingS,
              children: [
                for (final color in product.colors)
                  ChoiceChip(
                    label: Text(color),
                    selected: controller.selectedColor.value == color,
                    onSelected: (_) => controller.selectColor(color),
                  ),
              ],
            )),
      ],
    );
  }
}

class _SizeSelector extends GetView<ProductDetailController> {
  const _SizeSelector({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('select_size'.tr,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppTheme.spacingS),
        Obx(() => Wrap(
              spacing: AppTheme.spacingS,
              children: [
                for (final size in product.sizes)
                  ChoiceChip(
                    label: Text(size),
                    selected: controller.selectedSize.value == size,
                    onSelected: (_) => controller.selectSize(size),
                  ),
              ],
            )),
      ],
    );
  }
}

class _DescriptionAndSpecs extends GetView<ProductDetailController> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final details = controller.details.value;
      if (details.description.isEmpty && details.specifications.isEmpty) {
        return const SizedBox.shrink();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (details.description.isNotEmpty) ...[
            Text('description'.tr,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppTheme.spacingS),
            Text(details.description, style: theme.textTheme.bodyMedium),
            const SizedBox(height: AppTheme.spacingM),
          ],
          if (details.specifications.isNotEmpty) ...[
            Text('specifications'.tr,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppTheme.spacingS),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: Column(
                  children: [
                    for (final entry in details.specifications.entries)
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppTheme.spacingXs),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 120,
                              child: Text(
                                entry.key,
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.outline),
                              ),
                            ),
                            Expanded(
                              child: Text(entry.value,
                                  style: theme.textTheme.bodyMedium),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      );
    });
  }
}

class _ReviewsSection extends GetView<ProductDetailController> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final product = controller.product.value;
      final reviews = controller.reviews;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'ratings_reviews'.tr,
            trailing: TextButton.icon(
              onPressed: () async {
                final submitted = await Get.toNamed(
                  AppRoutes.addReview,
                  arguments: controller.productId,
                );
                if (submitted == true) controller.refreshReviews();
              },
              icon: const Icon(Icons.rate_review_outlined, size: 18),
              label: Text('write_review'.tr),
            ),
          ),
          if (product != null && product.ratingCount > 0)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
              child: Row(
                children: [
                  Text(
                    product.rating.toStringAsFixed(1),
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: AppTheme.spacingS),
                  RatingStars(rating: product.rating, size: 18),
                ],
              ),
            ),
          if (reviews.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Text('no_reviews'.tr, style: theme.textTheme.bodyMedium),
            )
          else
            ...reviews.take(5).map((review) => _ReviewTile(review: review)),
        ],
      );
    });
  }
}

class _ReviewTile extends GetView<ProductDetailController> {
  const _ReviewTile({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM, vertical: AppTheme.spacingS),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  RatingStars(rating: review.rating),
                  const SizedBox(width: AppTheme.spacingS),
                  Expanded(
                    child: Text(
                      review.userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    Formatters.dateFromMillis(review.createdAt),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.outline),
                  ),
                ],
              ),
              if (review.text.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacingS),
                Text(review.text, style: theme.textTheme.bodyMedium),
              ],
              if (review.images.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacingS),
                SizedBox(
                  height: 64,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: review.images.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: AppTheme.spacingS),
                    itemBuilder: (context, index) => CachedImage(
                      url: review.images[index],
                      width: 64,
                      height: 64,
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppTheme.spacingXs),
              TextButton.icon(
                onPressed: () => Get.find<ReviewController>()
                    .voteHelpful(controller.productId, review.id),
                icon: const Icon(Icons.thumb_up_outlined, size: 16),
                label: Text('${'helpful'.tr} (${review.helpfulCount})'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
