import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/banner_item.dart';
import '../../../widgets/cached_image.dart';

/// Auto-playing banner carousel with page dots.
class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key, required this.banners, this.onBannerTap});

  final List<BannerItem> banners;
  final void Function(BannerItem banner)? onBannerTap;

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final _controller = PageController();
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || widget.banners.length < 2) return;
      final next = (_page + 1) % widget.banners.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _open(BannerItem banner) {
    widget.onBannerTap?.call(banner);
    switch (banner.target) {
      case BannerTarget.product:
        Get.toNamed(AppRoutes.productDetail, arguments: banner.targetId);
      case BannerTarget.category:
        Get.toNamed(AppRoutes.productList, arguments: {
          'categoryId': banner.targetId,
          'title': banner.title,
        });
      case BannerTarget.none:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 2.2,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.banners.length,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
                child: GestureDetector(
                  onTap: () => _open(banner),
                  child: CachedImage(
                    url: banner.image,
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppTheme.spacingS),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.banners.length, (index) {
            final active = index == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}
