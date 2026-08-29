import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/order_model.dart';
import '../../controllers/orders_controller.dart';
import '../../widgets/cached_image.dart';
import '../../widgets/state_views.dart';

/// Live order detail: tracking timeline, items, invoice-style price
/// breakdown, cancel / return / reorder actions.
class OrderDetailScreen extends GetView<OrdersController> {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderId = Get.arguments?.toString() ?? '';
    return Scaffold(
      appBar: AppBar(title: Text('order_details'.tr)),
      body: StreamBuilder<OrderModel?>(
        stream: controller.watchOrder(orderId),
        initialData: controller.byId(orderId),
        builder: (context, snapshot) {
          final order = snapshot.data;
          if (order == null) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return ErrorState(message: 'error_generic'.tr);
          }
          return _OrderDetailBody(order: order);
        },
      ),
    );
  }
}

class _OrderDetailBody extends GetView<OrdersController> {
  const _OrderDetailBody({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      children: [
        // Order meta
        Card(
          child: ListTile(
            title: Text('${'order_id'.tr}: ${order.id}',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            subtitle: Text(
              '${'ordered_on'.trParams({
                    'date': Formatters.dateFromMillis(order.createdAt)
                  })}\n'
              '${'paid_via'.trParams({'method': 'pay_${order.paymentMethod.name}'.tr})}',
            ),
            isThreeLine: true,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),

        // Tracking timeline
        Text('order_tracking'.tr,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppTheme.spacingS),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: _Timeline(order: order),
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),

        // Items
        Text('items_count'.trParams({'count': '${order.itemCount}'}),
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppTheme.spacingS),
        Card(
          child: Column(
            children: [
              for (final item in order.items)
                ListTile(
                  leading: CachedImage(
                    url: item.image,
                    width: 44,
                    height: 52,
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  title: Text(item.name,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text([
                    if (item.size.isNotEmpty) item.size,
                    if (item.color.isNotEmpty) item.color,
                    '${'quantity'.tr}: ${item.quantity}',
                  ].join('  ·  ')),
                  trailing: Text(Formatters.price(item.lineTotal)),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),

        // Shipping address
        Text('shipping_address'.tr,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppTheme.spacingS),
        Card(
          child: ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: Text(order.address.name),
            subtitle:
                Text('${order.address.formatted}\n${order.address.phone}'),
            isThreeLine: true,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),

        // Invoice
        Row(
          children: [
            Expanded(
              child: Text('invoice'.tr,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ),
            TextButton.icon(
              onPressed: () => controller.logInvoiceViewed(order.id),
              icon: const Icon(Icons.receipt_long_outlined, size: 18),
              label: Text('invoice'.tr),
            ),
          ],
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Column(
              children: [
                _row(theme, 'subtotal'.tr, Formatters.price(order.subtotal)),
                if (order.couponDiscount > 0)
                  _row(
                      theme,
                      '${'coupon_discount'.tr} (${order.couponCode})',
                      '- ${Formatters.price(order.couponDiscount)}'),
                _row(
                    theme,
                    'delivery_charges'.tr,
                    order.deliveryCharge == 0
                        ? 'free'.tr
                        : Formatters.price(order.deliveryCharge)),
                _row(theme, 'taxes'.tr, Formatters.price(order.tax)),
                const Divider(),
                _row(theme, 'total_amount'.tr, Formatters.price(order.total),
                    bold: true),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingL),

        // Actions
        if (order.status.canCancel)
          OutlinedButton.icon(
            onPressed: () => _confirmCancel(context),
            icon: const Icon(Icons.cancel_outlined),
            label: Text('cancel_order'.tr),
          ),
        if (order.status.canReturn) ...[
          OutlinedButton.icon(
            onPressed: () => _requestReturn(context),
            icon: const Icon(Icons.keyboard_return_rounded),
            label: Text('return_order'.tr),
          ),
          const SizedBox(height: AppTheme.spacingS),
        ],
        if (!order.status.isActive) ...[
          const SizedBox(height: AppTheme.spacingS),
          FilledButton.tonalIcon(
            onPressed: () => controller.reorder(order),
            icon: const Icon(Icons.replay_rounded),
            label: Text('reorder'.tr),
          ),
        ],
        const SizedBox(height: AppTheme.spacingXl),
      ],
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

  void _confirmCancel(BuildContext context) {
    Get.defaultDialog(
      title: 'cancel_order'.tr,
      middleText: 'cancel_order_confirm'.tr,
      textConfirm: 'yes'.tr,
      textCancel: 'no'.tr,
      onConfirm: () {
        Get.back();
        controller.cancelOrder(order);
      },
    );
  }

  void _requestReturn(BuildContext context) {
    final reasonController = TextEditingController();
    Get.bottomSheet(
      SafeArea(
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          padding: EdgeInsets.only(
            left: AppTheme.spacingM,
            right: AppTheme.spacingM,
            top: AppTheme.spacingM,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppTheme.spacingM,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('return_reason'.tr,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: AppTheme.spacingM),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(hintText: 'return_reason'.tr),
              ),
              const SizedBox(height: AppTheme.spacingM),
              FilledButton(
                onPressed: () {
                  Get.back();
                  controller.requestReturn(
                      order, reasonController.text.trim());
                },
                child: Text('return_order'.tr),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

/// Vertical status timeline built from the order's statusTimeline map.
class _Timeline extends StatelessWidget {
  const _Timeline({required this.order});

  final OrderModel order;

  static const List<OrderStatus> _happyPath = [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.shipped,
    OrderStatus.outForDelivery,
    OrderStatus.delivered,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Cancelled/returned orders show their actual recorded path.
    final steps = order.status.isActive || order.status == OrderStatus.delivered
        ? _happyPath
        : _happyPath
            .where((s) => order.statusTimeline.containsKey(s.name))
            .toList()
          ..add(order.status);
    final reachedIndex = steps.lastIndexWhere(
        (s) => order.statusTimeline.containsKey(s.name) || s == order.status);

    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Icon(
                    i <= reachedIndex
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 20,
                    color: i <= reachedIndex
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.outlineVariant,
                  ),
                  if (i < steps.length - 1)
                    Container(
                      width: 2,
                      height: 28,
                      color: i < reachedIndex
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.outlineVariant,
                    ),
                ],
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        steps[i].localizationKey.tr,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: i <= reachedIndex
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                      if (order.statusTimeline.containsKey(steps[i].name))
                        Text(
                          Formatters.dateTime(
                              DateTime.fromMillisecondsSinceEpoch(
                                  order.statusTimeline[steps[i].name]!)),
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.colorScheme.outline),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        if (order.estimatedDeliveryAt > 0 && order.status.isActive) ...[
          const Divider(height: AppTheme.spacingL),
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined, size: 18),
              const SizedBox(width: AppTheme.spacingS),
              Expanded(
                child: Text(
                  'estimated_delivery'.trParams({
                    'date':
                        Formatters.dateFromMillis(order.estimatedDeliveryAt),
                  }),
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
