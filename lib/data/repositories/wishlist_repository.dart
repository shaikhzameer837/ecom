import '../../core/constants/db_paths.dart';
import '../models/model_utils.dart';
import 'base_repository.dart';

/// Wishlist stores product ids with the added timestamp; product data is
/// resolved via [ProductRepository] so it never goes stale.
class WishlistRepository extends BaseRepository {
  Stream<List<String>> watchWishlist(String uid) =>
      ref('${DbPaths.wishlists}/$uid').onValue.map((event) {
        final map = ModelUtils.asMap(event.snapshot.value);
        final entries = map.entries.toList()
          ..sort((a, b) =>
              ModelUtils.asInt(b.value).compareTo(ModelUtils.asInt(a.value)));
        return entries.map((e) => e.key).toList();
      });

  Future<void> add(String uid, String productId) => guard(
        () => ref('${DbPaths.wishlists}/$uid/$productId')
            .set(DateTime.now().millisecondsSinceEpoch),
        'wishlistAdd',
      );

  Future<void> remove(String uid, String productId) => guard(
        () => ref('${DbPaths.wishlists}/$uid/$productId').remove(),
        'wishlistRemove',
      );
}
