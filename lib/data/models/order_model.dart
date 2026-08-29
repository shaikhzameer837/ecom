import 'address.dart';
import 'cart_item.dart';
import 'model_utils.dart';

enum OrderStatus {
  pending,
  confirmed,
  shipped,
  outForDelivery,
  delivered,
  cancelled,
  returnRequested,
  returned;

  bool get isActive =>
      this == pending || this == confirmed || this == shipped || this == outForDelivery;

  bool get canCancel => this == pending || this == confirmed;

  bool get canReturn => this == delivered;

  String get localizationKey => switch (this) {
        pending => 'order_status_pending',
        confirmed => 'order_status_confirmed',
        shipped => 'order_status_shipped',
        outForDelivery => 'order_status_out_for_delivery',
        delivered => 'order_status_delivered',
        cancelled => 'order_status_cancelled',
        returnRequested => 'order_status_return_requested',
        returned => 'order_status_returned',
      };
}

enum PaymentMethod { razorpay, upi, cod }

enum DeliveryOption { standard, express }

class OrderModel {
  const OrderModel({
    required this.id,
    required this.items,
    required this.address,
    required this.subtotal,
    required this.discount,
    this.couponCode = '',
    this.couponDiscount = 0,
    required this.deliveryCharge,
    required this.tax,
    required this.total,
    required this.paymentMethod,
    this.paymentId = '',
    this.status = OrderStatus.pending,
    this.deliveryOption = DeliveryOption.standard,
    required this.createdAt,
    this.statusTimeline = const {},
    this.returnReason = '',
    this.estimatedDeliveryAt = 0,
  });

  final String id;
  final List<CartItem> items;
  final Address address;
  final double subtotal;
  final double discount;
  final String couponCode;
  final double couponDiscount;
  final double deliveryCharge;
  final double tax;
  final double total;
  final PaymentMethod paymentMethod;
  final String paymentId;
  final OrderStatus status;
  final DeliveryOption deliveryOption;
  final int createdAt;

  /// status name -> epoch millis when it was reached.
  final Map<String, int> statusTimeline;
  final String returnReason;
  final int estimatedDeliveryAt;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  factory OrderModel.fromMap(String id, Object? raw) {
    final map = ModelUtils.asMap(raw);
    final itemsRaw = ModelUtils.asMap(map['items']);
    final timelineRaw = ModelUtils.asMap(map['statusTimeline']);
    return OrderModel(
      id: id,
      items: itemsRaw.values.map(CartItem.fromMap).toList(),
      address: Address.fromMap('', map['address']),
      subtotal: ModelUtils.asDouble(map['subtotal']),
      discount: ModelUtils.asDouble(map['discount']),
      couponCode: ModelUtils.asString(map['couponCode']),
      couponDiscount: ModelUtils.asDouble(map['couponDiscount']),
      deliveryCharge: ModelUtils.asDouble(map['deliveryCharge']),
      tax: ModelUtils.asDouble(map['tax']),
      total: ModelUtils.asDouble(map['total']),
      paymentMethod: PaymentMethod.values
              .asNameMap()[ModelUtils.asString(map['paymentMethod'])] ??
          PaymentMethod.cod,
      paymentId: ModelUtils.asString(map['paymentId']),
      status: OrderStatus.values.asNameMap()[ModelUtils.asString(map['status'])] ??
          OrderStatus.pending,
      deliveryOption: DeliveryOption.values
              .asNameMap()[ModelUtils.asString(map['deliveryOption'])] ??
          DeliveryOption.standard,
      createdAt: ModelUtils.asInt(map['createdAt']),
      statusTimeline:
          timelineRaw.map((k, v) => MapEntry(k, ModelUtils.asInt(v))),
      returnReason: ModelUtils.asString(map['returnReason']),
      estimatedDeliveryAt: ModelUtils.asInt(map['estimatedDeliveryAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'items': {for (final item in items) item.id: item.toMap()},
        'address': address.toMap(),
        'subtotal': subtotal,
        'discount': discount,
        'couponCode': couponCode,
        'couponDiscount': couponDiscount,
        'deliveryCharge': deliveryCharge,
        'tax': tax,
        'total': total,
        'paymentMethod': paymentMethod.name,
        'paymentId': paymentId,
        'status': status.name,
        'deliveryOption': deliveryOption.name,
        'createdAt': createdAt,
        'statusTimeline': statusTimeline,
        'returnReason': returnReason,
        'estimatedDeliveryAt': estimatedDeliveryAt,
      };
}
