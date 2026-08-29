import 'model_utils.dart';

/// Lightweight product used in listings and cards.
/// Heavy fields (description, specs, offers) live in [ProductDetails].
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.categoryId,
    this.subcategoryId = '',
    required this.price,
    required this.mrp,
    this.images = const [],
    this.colors = const [],
    this.sizes = const [],
    this.stock = 0,
    this.rating = 0,
    this.ratingCount = 0,
    this.soldCount = 0,
    this.createdAt = 0,
    this.isFeatured = false,
    this.isBestSeller = false,
    this.flashSaleEndsAt = 0,
    this.keywords = const [],
  });

  final String id;
  final String name;
  final String brand;
  final String categoryId;
  final String subcategoryId;
  final double price;
  final double mrp;
  final List<String> images;
  final List<String> colors;
  final List<String> sizes;
  final int stock;
  final double rating;
  final int ratingCount;
  final int soldCount;
  final int createdAt;
  final bool isFeatured;
  final bool isBestSeller;
  final int flashSaleEndsAt;
  final List<String> keywords;

  bool get inStock => stock > 0;
  bool get lowStock => stock > 0 && stock <= 5;
  String get thumbnail => images.isNotEmpty ? images.first : '';
  int get discountPercent =>
      mrp > 0 && price < mrp ? ((mrp - price) / mrp * 100).round() : 0;
  bool get isFlashSale =>
      flashSaleEndsAt > DateTime.now().millisecondsSinceEpoch;

  factory Product.fromMap(String id, Object? raw) {
    final map = ModelUtils.asMap(raw);
    return Product(
      id: id,
      name: ModelUtils.asString(map['name']),
      brand: ModelUtils.asString(map['brand']),
      categoryId: ModelUtils.asString(map['categoryId']),
      subcategoryId: ModelUtils.asString(map['subcategoryId']),
      price: ModelUtils.asDouble(map['price']),
      mrp: ModelUtils.asDouble(map['mrp']),
      images: ModelUtils.asStringList(map['images']),
      colors: ModelUtils.asStringList(map['colors']),
      sizes: ModelUtils.asStringList(map['sizes']),
      stock: ModelUtils.asInt(map['stock']),
      rating: ModelUtils.asDouble(map['rating']),
      ratingCount: ModelUtils.asInt(map['ratingCount']),
      soldCount: ModelUtils.asInt(map['soldCount']),
      createdAt: ModelUtils.asInt(map['createdAt']),
      isFeatured: ModelUtils.asBool(map['isFeatured']),
      isBestSeller: ModelUtils.asBool(map['isBestSeller']),
      flashSaleEndsAt: ModelUtils.asInt(map['flashSaleEndsAt']),
      keywords: ModelUtils.asStringList(map['keywords']),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'brand': brand,
        'categoryId': categoryId,
        'subcategoryId': subcategoryId,
        'price': price,
        'mrp': mrp,
        'images': images,
        'colors': colors,
        'sizes': sizes,
        'stock': stock,
        'rating': rating,
        'ratingCount': ratingCount,
        'soldCount': soldCount,
        'createdAt': createdAt,
        'isFeatured': isFeatured,
        'isBestSeller': isBestSeller,
        'flashSaleEndsAt': flashSaleEndsAt,
        'keywords': keywords,
      };
}

/// Heavy product fields loaded only on the product detail screen.
class ProductDetails {
  const ProductDetails({
    this.description = '',
    this.specifications = const {},
    this.offers = const [],
  });

  final String description;
  final Map<String, String> specifications;
  final List<String> offers;

  factory ProductDetails.fromMap(Object? raw) {
    final map = ModelUtils.asMap(raw);
    return ProductDetails(
      description: ModelUtils.asString(map['description']),
      specifications: ModelUtils.asStringMap(map['specifications']),
      offers: ModelUtils.asStringList(map['offers']),
    );
  }

  Map<String, dynamic> toMap() => {
        'description': description,
        'specifications': specifications,
        'offers': offers,
      };
}
