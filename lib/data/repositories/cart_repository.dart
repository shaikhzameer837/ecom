import '../../core/constants/db_paths.dart';
import '../models/cart_item.dart';
import '../models/model_utils.dart';
import 'base_repository.dart';

/// Cart and save-for-later, synced in real time per user.
class CartRepository extends BaseRepository {
  Stream<List<CartItem>> watchCart(String uid) =>
      ref('${DbPaths.carts}/$uid').onValue.map((event) {
        final map = ModelUtils.asMap(event.snapshot.value);
        final items = map.values.map(CartItem.fromMap).toList()
          ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
        return items;
      });

  Stream<List<CartItem>> watchSavedForLater(String uid) =>
      ref('${DbPaths.savedForLater}/$uid').onValue.map((event) {
        final map = ModelUtils.asMap(event.snapshot.value);
        return map.values.map(CartItem.fromMap).toList();
      });

  Future<void> upsertItem(String uid, CartItem item) => guard(
        () => ref('${DbPaths.carts}/$uid/${item.id}').set(item.toMap()),
        'upsertItem',
      );

  Future<void> updateQuantity(String uid, String itemId, int quantity) => guard(
        () => ref('${DbPaths.carts}/$uid/$itemId/quantity').set(quantity),
        'updateQuantity',
      );

  Future<void> removeItem(String uid, String itemId) => guard(
        () => ref('${DbPaths.carts}/$uid/$itemId').remove(),
        'removeItem',
      );

  Future<void> clearCart(String uid) => guard(
        () => ref('${DbPaths.carts}/$uid').remove(),
        'clearCart',
      );

  Future<void> saveForLater(String uid, CartItem item) => guard(() async {
        await ref('${DbPaths.savedForLater}/$uid/${item.id}').set(item.toMap());
        await ref('${DbPaths.carts}/$uid/${item.id}').remove();
      }, 'saveForLater');

  Future<void> moveToCart(String uid, CartItem item) => guard(() async {
        await ref('${DbPaths.carts}/$uid/${item.id}').set(item.toMap());
        await ref('${DbPaths.savedForLater}/$uid/${item.id}').remove();
      }, 'moveToCart');

  Future<void> removeSaved(String uid, String itemId) => guard(
        () => ref('${DbPaths.savedForLater}/$uid/$itemId').remove(),
        'removeSaved',
      );
}
