import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/product.dart';
import '../controllers/auth_controller.dart';
import '../controllers/wishlist_controller.dart';

/// Heart toggle backed by the realtime wishlist.
class WishlistButton extends StatelessWidget {
  const WishlistButton({super.key, required this.product, this.size = 22});

  final Product product;
  final double size;

  @override
  Widget build(BuildContext context) {
    final wishlist = Get.find<WishlistController>();
    return Obx(() {
      final active = wishlist.isWishlisted(product.id);
      return IconButton(
        onPressed: () {
          if (!Get.find<AuthController>().requireLogin()) return;
          wishlist.toggle(product);
        },
        style: IconButton.styleFrom(
          backgroundColor:
              Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
        ),
        icon: Icon(
          active ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
          size: size,
          color: active
              ? Colors.redAccent
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    });
  }
}
