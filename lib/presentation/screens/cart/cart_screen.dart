import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/cart_item.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/nav_controller.dart';
import '../../widgets/cached_image.dart';
import '../../widgets/login_required_view.dart';
import '../../widgets/price_text.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/quantity_stepper.dart';
import '../../widgets/state_views.dart';

/// Cart with quantities, save-for-later, coupon and price breakdown.
/// Used both as the cart tab and as a pushed route ([showBack]).
///
/// It owns its own [ScrollController] (with `primary: false` on the list) so
/// the tab instance and the pushed instance don't both attach to the ambient
/// PrimaryScrollController — sharing it causes the viewport to paint before
/// layout during route transitions (null-geometry sliver crash).
class CartScreen extends StatefulWidget {
  const CartScreen({super.key, this.showBack = false});

  final bool showBack;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartController controller = Get.find<CartController>();
  final ScrollController _scrollController = ScrollController();

  bool get showBack => widget.showBack;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('cart_title'.tr),
        automaticallyImplyLeading: showBack,
      ),
      body: Obx(() {
        if (Get.find<AuthController>().isGuest) {
          return LoginRequiredView(
            icon: Icons.shopping_cart_outlined,
            message: 'login_required_cart'.tr,
          );
        }
        if (controller.items.isEmpty && controller.savedItems.isEmpty) {
          return EmptyState(
            icon: Icons.shopping_cart_outlined,
            title: 'cart_empty'.tr,
            subtitle: 'cart_empty_desc'.tr,
            actionLabel: 'start_shopping'.tr,
            onAction: () {
              if (showBack) {
                Get.back();
              } else if (Get.isRegistered<NavController>()) {
                Get.find<NavController>().changeTab(0);
              }
            },
          );
        }
        return ListView(
          controller: _scrollController,
          primary: false,
          padding: const EdgeInsets.all(AppTheme.spacingM),
          children: [
            ...controller.items.map((item) => _CartItemTile(item: item)),
            if (controller.items.isNotEmpty) ...[
              _freeShippingNudge(context),
              const SizedBox(height: AppTheme.spacingM),
             // _CouponField(),
              
              const SizedBox(height: AppTheme.spacingM),
              _PriceDetails(),
            ],
            if (controller.savedItems.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingL),
              Text(
                '${'saved_for_later'.tr} (${controller.savedItems.length})',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppTheme.spacingS),
              ...controller.savedItems
                  .map((item) => _SavedItemTile(item: item)),
            ],
            const SizedBox(height: 90),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.items.isEmpty) return const SizedBox.shrink();
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('total_amount'.tr,
                        style: Theme.of(context).textTheme.bodySmall),
                    Text(
                      Formatters.price(controller.total),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: PrimaryButton(
                    label: 'proceed_to_checkout'.tr,
                    onPressed: () => Get.toNamed(AppRoutes.checkout),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _freeShippingNudge(BuildContext context) {
    final remaining = controller.amountToFreeShipping;
    if (remaining <= 0) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: AppTheme.spacingS),
      padding: const EdgeInsets.all(AppTheme.spacingS),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_shipping_outlined, size: 18),
          const SizedBox(width: AppTheme.spacingS),
          Expanded(
            child: Text(
              'free_shipping_msg'
                  .trParams({'amount': Formatters.price(remaining)}),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends GetView<CartController> {
  const _CartItemTile({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingS),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.productDetail,
                      arguments: item.productId),
                  child: CachedImage(
                    url: item.image,
                    width: 84,
                    height: 100,
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(
                        [
                          if (item.size.isNotEmpty)
                            '${'filter_size'.tr}: ${item.size}',
                          if (item.color.isNotEmpty)
                            '${'filter_color'.tr}: ${item.color}',
                        ].join('  ·  '),
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.outline),
                      ),
                      const SizedBox(height: 4),
                      PriceText(price: item.price, mrp: item.mrp),
                    ],
                  ),
                ),
                QuantityStepper(
                  quantity: item.quantity,
                  max: item.maxStock,
                  onChanged: (qty) => controller.updateQuantity(item, qty),
                ),
              ],
            ),
            const Divider(height: AppTheme.spacingM),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => controller.saveForLater(item),
                    icon: const Icon(Icons.bookmark_outline_rounded, size: 18),
                    label: Text('save_for_later'.tr,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => controller.removeItem(item),
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: Text('remove'.tr,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedItemTile extends GetView<CartController> {
  const _SavedItemTile({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      child: ListTile(
        leading: CachedImage(
          url: item.image,
          width: 48,
          height: 56,
          borderRadius: BorderRadius.circular(AppTheme.radiusS),
        ),
        title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: PriceText(price: item.price, mrp: item.mrp),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'move_back_to_cart'.tr,
              onPressed: () => controller.moveToCart(item),
              icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
            ),
            IconButton(
              tooltip: 'remove'.tr,
              onPressed: () => controller.removeSaved(item),
              icon: const Icon(Icons.close_rounded, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _CouponField extends GetView<CartController> {
  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();
    return Obx(() {
      final coupon = controller.appliedCoupon.value;
      if (coupon != null) {
        return Card(
          child: ListTile(
            leading:
                Icon(Icons.local_offer_rounded, color: AppTheme.emphasis(context)),
            title: Text(coupon.code,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(
                '- ${Formatters.price(coupon.discountFor(controller.subtotal))}'),
            trailing: IconButton(
              onPressed: controller.removeCoupon,
              icon: const Icon(Icons.close_rounded),
            ),
          ),
        );
      }
      return Row(
        children: [
          Expanded(
            child: TextField(
              controller: textController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'coupon_code'.tr,
                prefixIcon: const Icon(Icons.local_offer_outlined),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingS),
          FilledButton(
            // Keep the button's own minimum height from the theme (52) so the
            // height constraint doesn't clash with a fixed-size wrapper.
            onPressed: controller.isApplyingCoupon.value
                ? null
                : () => controller.applyCoupon(textController.text),
            child: Text('apply_coupon'.tr),
          ),
        ],
      );
    });
  }
}

/// Subtotal / discounts / delivery / taxes / total.
class _PriceDetails extends GetView<CartController> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Obx(() => Column(
              children: [
                _row(theme, 'price_details'.tr, '', isHeader: true),
                const Divider(),
                _row(theme, 'subtotal'.tr,
                    Formatters.price(controller.mrpTotal)),
                if (controller.productDiscount > 0)
                  _row(theme, 'discount'.tr,
                      '- ${Formatters.price(controller.productDiscount)}',
                      valueColor: theme.colorScheme.onSurface),
                if (controller.couponDiscount > 0)
                  _row(theme, 'coupon_discount'.tr,
                      '- ${Formatters.price(controller.couponDiscount)}',
                      valueColor: theme.colorScheme.onSurface),
                _row(
                  theme,
                  'delivery_charges'.tr,
                  controller.deliveryCharge == 0
                      ? 'free'.tr
                      : Formatters.price(controller.deliveryCharge),
                  valueColor: controller.deliveryCharge == 0
                      ? theme.colorScheme.onSurface
                      : null,
                ),
                _row(theme, 'taxes'.tr, Formatters.price(controller.tax)),
                const Divider(),
                _row(theme, 'total_amount'.tr,
                    Formatters.price(controller.total),
                    isHeader: true),
              ],
            )),
      ),
    );
  }

  Widget _row(ThemeData theme, String label, String value,
      {bool isHeader = false, Color? valueColor}) {
    final style = isHeader
        ? theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)
        : theme.textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style?.copyWith(color: valueColor)),
        ],
      ),
    );
  }
}
