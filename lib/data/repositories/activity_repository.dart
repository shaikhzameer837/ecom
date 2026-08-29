import 'package:firebase_database/firebase_database.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/db_paths.dart';
import '../models/model_utils.dart';
import 'base_repository.dart';

/// Per-user activity: recently viewed products, search history, and the
/// shared trending-search counters that power suggestions.
class ActivityRepository extends BaseRepository {
  Future<void> trackProductView(String uid, String productId) =>
      guard(() async {
        final node = ref('${DbPaths.recentlyViewed}/$uid');
        await node.child(productId).set(DateTime.now().millisecondsSinceEpoch);
        // Trim to the newest N entries.
        final snapshot = await node.get();
        final map = ModelUtils.asMap(snapshot.value);
        if (map.length > AppConstants.maxRecentlyViewed) {
          final sorted = map.entries.toList()
            ..sort((a, b) =>
                ModelUtils.asInt(a.value).compareTo(ModelUtils.asInt(b.value)));
          final excess = sorted.take(map.length - AppConstants.maxRecentlyViewed);
          await node.update({for (final e in excess) e.key: null});
        }
      }, 'trackProductView');

  Future<List<String>> fetchRecentlyViewed(String uid) => guard(() async {
        final snapshot = await ref('${DbPaths.recentlyViewed}/$uid').get();
        final map = ModelUtils.asMap(snapshot.value);
        final entries = map.entries.toList()
          ..sort((a, b) =>
              ModelUtils.asInt(b.value).compareTo(ModelUtils.asInt(a.value)));
        return entries.map((e) => e.key).toList();
      }, 'fetchRecentlyViewed');

  Future<void> trackSearch(String uid, String query) => guard(() async {
        final term = query.trim().toLowerCase();
        if (term.isEmpty) return;
        await ref('${DbPaths.searchHistory}/$uid').push().set({
          'query': term,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
        // Sanitize: RTDB keys cannot contain . # $ [ ] /
        final key = term.replaceAll(RegExp(r'[.#$\[\]/]'), '_');
        await ref('${DbPaths.trendingSearches}/$key').runTransaction(
            (Object? value) => Transaction.success(ModelUtils.asInt(value) + 1));
      }, 'trackSearch');

  Future<List<String>> fetchTrendingSearches({int limit = 8}) =>
      guard(() async {
        final snapshot = await ref(DbPaths.trendingSearches)
            .orderByValue()
            .limitToLast(limit)
            .get();
        final map = ModelUtils.asMap(snapshot.value);
        final entries = map.entries.toList()
          ..sort((a, b) =>
              ModelUtils.asInt(b.value).compareTo(ModelUtils.asInt(a.value)));
        return entries.map((e) => e.key).toList();
      }, 'fetchTrendingSearches');
}
