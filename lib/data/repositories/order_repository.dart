import '../../core/constants/db_paths.dart';
import '../models/model_utils.dart';
import '../models/order_model.dart';
import 'base_repository.dart';

class OrderRepository extends BaseRepository {
  /// Creates the order and returns its generated id.
  Future<String> placeOrder(String uid, OrderModel order) => guard(() async {
        final orderRef = ref('${DbPaths.orders}/$uid').push();
        await orderRef.set(order.toMap());
        return orderRef.key!;
      }, 'placeOrder');

  Stream<List<OrderModel>> watchOrders(String uid) =>
      ref('${DbPaths.orders}/$uid').onValue.map((event) {
        final map = ModelUtils.asMap(event.snapshot.value);
        final orders =
            map.entries.map((e) => OrderModel.fromMap(e.key, e.value)).toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return orders;
      });

  Stream<OrderModel?> watchOrder(String uid, String orderId) =>
      ref('${DbPaths.orders}/$uid/$orderId').onValue.map((event) {
        if (!event.snapshot.exists) return null;
        return OrderModel.fromMap(orderId, event.snapshot.value);
      });

  Future<void> updateStatus(String uid, String orderId, OrderStatus status,
          {String returnReason = ''}) =>
      guard(() async {
        await ref('${DbPaths.orders}/$uid/$orderId').update({
          'status': status.name,
          'statusTimeline/${status.name}':
              DateTime.now().millisecondsSinceEpoch,
          if (returnReason.isNotEmpty) 'returnReason': returnReason,
        });
      }, 'updateStatus');

  Future<void> attachPayment(String uid, String orderId, String paymentId) =>
      guard(() async {
        await ref('${DbPaths.orders}/$uid/$orderId').update({
          'paymentId': paymentId,
          'status': OrderStatus.confirmed.name,
          'statusTimeline/${OrderStatus.confirmed.name}':
              DateTime.now().millisecondsSinceEpoch,
        });
      }, 'attachPayment');
}
