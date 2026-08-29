import 'model_utils.dart';

enum CouponType { percent, flat }

class Coupon {
  const Coupon({
    required this.code,
    required this.type,
    required this.value,
    this.minOrderValue = 0,
    this.maxDiscount = 0,
    this.expiresAt = 0,
    this.active = true,
    this.description = '',
  });

  final String code;
  final CouponType type;
  final double value;
  final double minOrderValue;

  /// Cap for percent coupons; 0 means no cap.
  final double maxDiscount;
  final int expiresAt;
  final bool active;
  final String description;

  bool get isExpired =>
      expiresAt > 0 && expiresAt < DateTime.now().millisecondsSinceEpoch;

  bool get isValid => active && !isExpired;

  double discountFor(double subtotal) {
    if (!isValid || subtotal < minOrderValue) return 0;
    var discount = type == CouponType.percent ? subtotal * value / 100 : value;
    if (maxDiscount > 0 && discount > maxDiscount) discount = maxDiscount;
    return discount.clamp(0, subtotal);
  }

  factory Coupon.fromMap(String code, Object? raw) {
    final map = ModelUtils.asMap(raw);
    return Coupon(
      code: code,
      type: CouponType.values.asNameMap()[ModelUtils.asString(map['type'])] ??
          CouponType.flat,
      value: ModelUtils.asDouble(map['value']),
      minOrderValue: ModelUtils.asDouble(map['minOrderValue']),
      maxDiscount: ModelUtils.asDouble(map['maxDiscount']),
      expiresAt: ModelUtils.asInt(map['expiresAt']),
      active: ModelUtils.asBool(map['active'], true),
      description: ModelUtils.asString(map['description']),
    );
  }

  Map<String, dynamic> toMap() => {
        'type': type.name,
        'value': value,
        'minOrderValue': minOrderValue,
        'maxDiscount': maxDiscount,
        'expiresAt': expiresAt,
        'active': active,
        'description': description,
      };
}
