import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/order_model.dart';
import '../../controllers/orders_controller.dart';
import '../../widgets/cached_image.dart';
import '../../widgets/shimmer_widgets.dart';
import '../../widgets/state_views.dart';

/// Order history split into current / completed / cancelled / returned.
class OrdersScreen extends GetView<OrdersController> {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('my_orders'.tr),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'tab_current'.tr),
              Tab(text: 'tab_completed'.tr),
              Tab(text: 'tab_cancelled'.tr),
              Tab(text: 'tab_returned'.tr),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return ListView(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              children: List.generate(
                4,
                (_) => const Padding(
                  padding: EdgeInsets.only(bottom: AppTheme.spacingM),
                  child: ShimmerBox(height: 120, radius: AppTheme.radiusM),
                ),
              ),
            );
          }
          return TabBarView(
            children: [
              _OrderList(orders: controller.current),
              _OrderList(orders: controller.completed),
              _OrderList(orders: controller.cancelled),
              _OrderList(orders: controller.returned),
            ],
          );
        }),
      ),
    );
  }
}

class _OrderList extends GetView<OrdersController> {
  const _OrderList({required this.orders});

  final List<OrderModel> orders;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'orders_empty'.tr,
        subtitle: 'orders_empty_desc'.tr,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      itemCount: orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppTheme.spacingS),
      itemBuilder: (context, index) => _OrderCard(order: orders[index]),
    );
  }
}

class _OrderCard extends GetView<OrdersController> {
  const _OrderCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstImage = order.items.firstOrNull?.image ?? '';
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          controller.logOrderViewed(order.id);
          Get.toNamed(AppRoutes.orderDetail, arguments: order.id);
        },
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Row(
            children: [
              CachedImage(
                url: firstImage,
                width: 56,
                height: 64,
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.status.localizationKey.tr,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _statusColor(theme, order.status),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'items_count'
                          .trParams({'count': '${order.itemCount}'}),
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      'ordered_on'.trParams(
                          {'date': Formatters.dateFromMillis(order.createdAt)}),
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.outline),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.price(order.total),
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(ThemeData theme, OrderStatus status) => switch (status) {
        OrderStatus.delivered => theme.colorScheme.onSurface,
        OrderStatus.cancelled ||
        OrderStatus.returned ||
        OrderStatus.returnRequested =>
          theme.colorScheme.error,
        _ => theme.colorScheme.primary,
      };
}
