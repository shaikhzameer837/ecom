import 'package:ecom/core/utils/formatters.dart';
import 'package:ecom/data/models/cart_item.dart';
import 'package:ecom/data/models/coupon.dart';
import 'package:ecom/data/models/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Product', () {
    test('computes discount percent from mrp and price', () {
      const product = Product(
        id: 'p1',
        name: 'Tee',
        brand: 'Brand',
        categoryId: 'men',
        price: 750,
        mrp: 1000,
      );
      expect(product.discountPercent, 25);
      expect(product.inStock, isFalse);
    });

    test('parses loosely typed RTDB map safely', () {
      final product = Product.fromMap('p2', {
        'name': 'Shirt',
        'price': '499',
        'mrp': 999,
        'stock': 3,
        'images': {'0': 'a.jpg', '1': 'b.jpg'},
      });
      expect(product.price, 499);
      expect(product.images, ['a.jpg', 'b.jpg']);
      expect(product.lowStock, isTrue);
    });
  });

  group('CartItem', () {
    test('builds a variant-aware id and line totals', () {
      const item = CartItem(
        productId: 'p1',
        name: 'Tee',
        brand: 'Brand',
        image: '',
        price: 500,
        mrp: 700,
        size: 'M',
        color: 'Blue',
        quantity: 2,
      );
      expect(item.id, 'p1_M_Blue');
      expect(item.lineTotal, 1000);
      expect(item.lineMrpTotal, 1400);
    });
  });

  group('Coupon', () {
    test('percent coupon respects cap and minimum order', () {
      const coupon = Coupon(
        code: 'SAVE20',
        type: CouponType.percent,
        value: 20,
        minOrderValue: 500,
        maxDiscount: 150,
      );
      expect(coupon.discountFor(400), 0); // below minimum
      expect(coupon.discountFor(600), 120);
      expect(coupon.discountFor(2000), 150); // capped
    });
  });

  group('Formatters', () {
    test('formats INR prices', () {
      expect(Formatters.price(1499), contains('1,499'));
      expect(Formatters.discountPercent(1000, 750), '25%');
    });
  });
}
