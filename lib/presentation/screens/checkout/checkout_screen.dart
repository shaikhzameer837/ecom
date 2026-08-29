import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/order_model.dart';
import '../../controllers/address_controller.dart';
import '../../controllers/checkout_controller.dart';
import '../../widgets/cached_image.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/state_views.dart';

/// Single-page checkout: address, delivery option, payment method and
/// order review.
class CheckoutScreen extends GetView<CheckoutController> {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final addressController = Get.find<AddressController>();
    return Scaffold(
      appBar: AppBar(title: Text('checkout_title'.tr)),
      body: Obx(() {
        if (controller.cart.items.isEmpty) {
          return EmptyState(
            icon: Icons.shopping_cart_outlined,
            title: 'cart_empty'.tr,
          );
        }
        return ListView(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          children: [
            _sectionTitle(context, 'delivery_address'.tr),
            _AddressSection(addressController: addressController),
            const SizedBox(height: AppTheme.spacingL),
            _sectionTitle(context, 'delivery_options'.tr),
            _DeliverySection(),
            const SizedBox(height: AppTheme.spacingL),
            _sectionTitle(context, 'payment_method'.tr),
            _PaymentSection(),
            const SizedBox(height: AppTheme.spacingL),
            _sectionTitle(context, 'order_review'.tr),
            _OrderReviewSection(),
            const SizedBox(height: 90),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.cart.items.isEmpty) return const SizedBox.shrink();
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: PrimaryButton(
              label: controller.paymentMethod.value == PaymentMethod.cod
                  ? 'place_order'.tr
                  : 'pay_now'.trParams(
                      {'amount': Formatters.price(controller.payableTotal)}),
              isLoading: controller.isPlacingOrder.value,
              onPressed:
                  controller.selectedAddress.value == null ? null : controller.placeOrder,
            ),
          ),
        );
      }),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) => Padding(
        padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
        child: Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      );
}

class _AddressSection extends GetView<CheckoutController> {
  const _AddressSection({required this.addressController});

  final AddressController addressController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final addresses = addressController.addresses;
      return Column(
        children: [
          if (addresses.isEmpty && !addressController.isLoading.value)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: Text('no_addresses_desc'.tr),
              ),
            ),
          RadioGroup<String>(
            groupValue: controller.selectedAddress.value?.id,
            onChanged: (id) {
              final address =
                  addresses.firstWhereOrNull((a) => a.id == id);
              if (address != null) controller.selectAddress(address);
            },
            child: Column(
              children: [
                for (final address in addresses)
                  Card(
                    margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
                    child: RadioListTile<String>(
                      value: address.id,
                      title: Text(
                        '${address.name}  ·  ${'address_${address.type.name}'.tr}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle:
                          Text('${address.formatted}\n${address.phone}'),
                      isThreeLine: true,
                    ),
                  ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => Get.toNamed(AppRoutes.addressForm),
            icon: const Icon(Icons.add_rounded),
            label: Text('add_new_address'.tr),
          ),
        ],
      );
    });
  }
}

class _DeliverySection extends GetView<CheckoutController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => RadioGroup<DeliveryOption>(
          groupValue: controller.deliveryOption.value,
          onChanged: (option) {
            if (option != null) controller.selectDelivery(option);
          },
          child: Column(
            children: [
              Card(
                margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
                child: RadioListTile<DeliveryOption>(
                  value: DeliveryOption.standard,
                  title: Text('delivery_standard'.tr),
                  subtitle: Text('delivery_standard_desc'.tr),
                ),
              ),
              Card(
                child: RadioListTile<DeliveryOption>(
                  value: DeliveryOption.express,
                  title: Text('delivery_express'.tr),
                  subtitle: Text('delivery_express_desc'.tr),
                ),
              ),
            ],
          ),
        ));
  }
}

class _PaymentSection extends GetView<CheckoutController> {
  @override
  Widget build(BuildContext context) {
    final options = [
      (PaymentMethod.razorpay, Icons.credit_card_rounded, 'pay_razorpay'.tr),
      (PaymentMethod.upi, Icons.qr_code_rounded, 'pay_upi'.tr),
      (PaymentMethod.cod, Icons.payments_outlined, 'pay_cod'.tr),
    ];
    return Obx(() => RadioGroup<PaymentMethod>(
          groupValue: controller.paymentMethod.value,
          onChanged: (method) {
            if (method != null) controller.selectPayment(method);
          },
          child: Column(
            children: [
              for (final (method, icon, label) in options)
                Card(
                  margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
                  child: RadioListTile<PaymentMethod>(
                    value: method,
                    title: Row(
                      children: [
                        Icon(icon, size: 20),
                        const SizedBox(width: AppTheme.spacingS),
                        Expanded(child: Text(label)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ));
  }
}

class _OrderReviewSection extends GetView<CheckoutController> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = controller.cart;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Obx(() => Column(
              children: [
                ...cart.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
                    child: Row(
                      children: [
                        CachedImage(
                          url: item.image,
                          width: 44,
                          height: 52,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusS),
                        ),
                        const SizedBox(width: AppTheme.spacingS),
                        Expanded(
                          child: Text(
                            '${item.name} × ${item.quantity}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        Text(Formatters.price(item.lineTotal),
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                _row(theme, 'subtotal'.tr, Formatters.price(cart.subtotal)),
                if (cart.couponDiscount > 0)
                  _row(theme, 'coupon_discount'.tr,
                      '- ${Formatters.price(cart.couponDiscount)}'),
                _row(
                    theme,
                    'delivery_charges'.tr,
                    (cart.deliveryCharge + controller.deliveryExtra) == 0
                        ? 'free'.tr
                        : Formatters.price(
                            cart.deliveryCharge + controller.deliveryExtra)),
                _row(theme, 'taxes'.tr, Formatters.price(cart.tax)),
                const Divider(),
                _row(theme, 'total_amount'.tr,
                    Formatters.price(controller.payableTotal),
                    bold: true),
              ],
            )),
      ),
    );
  }

  Widget _row(ThemeData theme, String label, String value,
      {bool bold = false}) {
    final style = bold
        ? theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)
        : theme.textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}
