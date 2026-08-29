import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/product.dart';
import 'cached_image.dart';
import 'price_text.dart';
import 'rating_stars.dart';
import 'wishlist_button.dart';

/// Grid product card used in listings, wishlist and home sections.
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, this.onTap, this.width});

  final Product product;
  final VoidCallback? onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: width,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap ??
              () => Get.toNamed(AppRoutes.productDetail, arguments: product.id),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedImage(url: product.thumbnail),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: WishlistButton(product: product, size: 18),
                    ),
                    if (product.discountPercent > 0)
                      Positioned(
                        top: 8,
                        left: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.badgeBg(context),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(6),
                              bottomRight: Radius.circular(6),
                            ),
                          ),
                          child: Text(
                            '${product.discountPercent}% ${'off_label'.tr}',
                            style: TextStyle(
                              color: AppTheme.badgeFg(context),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    if (!product.inStock)
                      Container(
                        color: Colors.black45,
                        alignment: Alignment.center,
                        child: Text(
                          'out_of_stock'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.brand.isNotEmpty)
                      Text(
                        product.brand,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.outline),
                      ),
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    if (product.ratingCount > 0)
                      RatingStars(
                          rating: product.rating, count: product.ratingCount),
                    const SizedBox(height: 2),
                    PriceText(price: product.price, mrp: product.mrp),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Horizontally scrolling strip of product cards (home sections,
/// related/similar products).
class ProductStrip extends StatelessWidget {
  const ProductStrip({
    super.key,
    required this.products,
    this.onProductTap,
    this.height = 250,
  });

  final List<Product> products;
  final void Function(Product product)? onProductTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppTheme.spacingS),
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            width: 150,
            onTap: () {
              onProductTap?.call(product);
              Get.toNamed(AppRoutes.productDetail, arguments: product.id);
            },
          );
        },
      ),
    );
  }
}
