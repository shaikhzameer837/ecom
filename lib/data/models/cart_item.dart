import 'model_utils.dart';

class CartItem {
  const CartItem({
    required this.productId,
    required this.name,
    required this.brand,
    required this.image,
    required this.price,
    required this.mrp,
    this.size = '',
    this.color = '',
    this.quantity = 1,
    this.maxStock = 99,
    this.addedAt = 0,
  });

  final String productId;
  final String name;
  final String brand;
  final String image;
  final double price;
  final double mrp;
  final String size;
  final String color;
  final int quantity;
  final int maxStock;
  final int addedAt;

  /// Unique cart entry key: same product in a different size/color is a
  /// separate line item.
  String get id => [productId, size, color].where((e) => e.isNotEmpty).join('_');

  double get lineTotal => price * quantity;
  double get lineMrpTotal => mrp * quantity;

  factory CartItem.fromMap(Object? raw) {
    final map = ModelUtils.asMap(raw);
    return CartItem(
      productId: ModelUtils.asString(map['productId']),
      name: ModelUtils.asString(map['name']),
      brand: ModelUtils.asString(map['brand']),
      image: ModelUtils.asString(map['image']),
      price: ModelUtils.asDouble(map['price']),
      mrp: ModelUtils.asDouble(map['mrp']),
      size: ModelUtils.asString(map['size']),
      color: ModelUtils.asString(map['color']),
      quantity: ModelUtils.asInt(map['quantity'], 1),
      maxStock: ModelUtils.asInt(map['maxStock'], 99),
      addedAt: ModelUtils.asInt(map['addedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'name': name,
        'brand': brand,
        'image': image,
        'price': price,
        'mrp': mrp,
        'size': size,
        'color': color,
        'quantity': quantity,
        'maxStock': maxStock,
        'addedAt': addedAt,
      };

  CartItem copyWith({int? quantity}) => CartItem(
        productId: productId,
        name: name,
        brand: brand,
        image: image,
        price: price,
        mrp: mrp,
        size: size,
        color: color,
        quantity: quantity ?? this.quantity,
        maxStock: maxStock,
        addedAt: addedAt,
      );
}
