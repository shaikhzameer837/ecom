import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_theme.dart';

/// Shimmer building blocks for all skeleton states.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.radius = AppTheme.radiusS,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: scheme.surfaceContainerHighest,
      highlightColor: scheme.surfaceContainerLow,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// Skeleton for a product grid while a listing loads.
class ProductGridShimmer extends StatelessWidget {
  const ProductGridShimmer({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        mainAxisSpacing: AppTheme.spacingM,
        crossAxisSpacing: AppTheme.spacingM,
        childAspectRatio: 0.62,
      ),
      itemCount: itemCount,
      itemBuilder: (_, _) => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: ShimmerBox(height: double.infinity)),
          SizedBox(height: 8),
          ShimmerBox(width: 120, height: 14),
          SizedBox(height: 6),
          ShimmerBox(width: 80, height: 14),
        ],
      ),
    );
  }
}

/// Skeleton for the whole home feed.
class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(height: 160, radius: AppTheme.radiusM),
          const SizedBox(height: AppTheme.spacingL),
          const ShimmerBox(width: 140, height: 18),
          const SizedBox(height: AppTheme.spacingM),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              itemBuilder: (_, _) => const Padding(
                padding: EdgeInsets.only(right: AppTheme.spacingM),
                child: ShimmerBox(width: 72, height: 90),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          const ShimmerBox(width: 140, height: 18),
          const SizedBox(height: AppTheme.spacingM),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              itemBuilder: (_, _) => const Padding(
                padding: EdgeInsets.only(right: AppTheme.spacingM),
                child: ShimmerBox(width: 150, height: 220),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
