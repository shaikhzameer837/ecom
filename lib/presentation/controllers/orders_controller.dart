import 'dart:async';

import 'package:get/get.dart';

import '../../core/constants/analytics_events.dart';
import '../../core/utils/app_logger.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';
import '../../services/analytics_service.dart';
import 'auth_controller.dart';
import 'cart_controller.dart';

/// Order history with live status updates, cancel/return/reorder actions.
class OrdersController extends GetxController {
  OrdersController({
    required this.orderRepository,
    required this.analytics,
  });

  final OrderRepository orderRepository;
  final AnalyticsService analytics;

  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = true.obs;

  StreamSubscription<List<OrderModel>>? _subscription;

  String? get _uid => Get.find<AuthController>().uid;

  List<OrderModel> get current =>
      orders.where((o) => o.status.isActive).toList();
  List<OrderModel> get completed =>
      orders.where((o) => o.status == OrderStatus.delivered).toList();
  List<OrderModel> get cancelled =>
      orders.where((o) => o.status == OrderStatus.cancelled).toList();
  List<OrderModel> get returned => orders
      .where((o) =>
          o.status == OrderStatus.returned ||
          o.status == OrderStatus.returnRequested)
      .toList();

  @override
  void onInit() {
    super.onInit();
    final uid = _uid;
    if (uid == null) {
      isLoading.value = false;
      return;
    }
    _subscription = orderRepository.watchOrders(uid).listen(
      (value) {
        orders.value = value;
        isLoading.value = false;
      },
      onError: (Object error) {
        AppLogger.e('Orders stream error', error: error);
        isLoading.value = false;
      },
    );
  }

  OrderModel? byId(String orderId) =>
      orders.firstWhereOrNull((o) => o.id == orderId);

  Stream<OrderModel?> watchOrder(String orderId) {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return orderRepository.watchOrder(uid, orderId);
  }

  Future<void> cancelOrder(OrderModel order) async {
    final uid = _uid;
    if (uid == null || !order.status.canCancel) return;
    await orderRepository.updateStatus(uid, order.id, OrderStatus.cancelled);
    analytics.logEvent(AnalyticsEvents.orderCancelRequested,
        {AnalyticsEvents.pOrderId: order.id});
    Get.snackbar('app_name'.tr, 'order_cancelled_msg'.tr);
  }

  Future<void> requestReturn(OrderModel order, String reason) async {
    final uid = _uid;
    if (uid == null || !order.status.canReturn) return;
    await orderRepository.updateStatus(uid, order.id, OrderStatus.returnRequested,
        returnReason: reason);
    analytics.logEvent(AnalyticsEvents.orderReturnRequested,
        {AnalyticsEvents.pOrderId: order.id});
    Get.snackbar('app_name'.tr, 'return_requested_msg'.tr);
  }

  /// Puts every line item of a past order back into the cart.
  Future<void> reorder(OrderModel order) async {
    final uid = _uid;
    if (uid == null) return;
    final cart = Get.find<CartController>();
    for (final item in order.items) {
      await cart.cartRepository.upsertItem(
          uid, item.copyWith(quantity: item.quantity));
    }
    analytics.logEvent(
        AnalyticsEvents.reorder, {AnalyticsEvents.pOrderId: order.id});
    Get.snackbar('app_name'.tr, 'added_to_cart'.tr);
  }

  void logInvoiceViewed(String orderId) => analytics.logEvent(
      AnalyticsEvents.invoiceViewed, {AnalyticsEvents.pOrderId: orderId});

  void logOrderViewed(String orderId) => analytics.logEvent(
      AnalyticsEvents.orderViewed, {AnalyticsEvents.pOrderId: orderId});

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
