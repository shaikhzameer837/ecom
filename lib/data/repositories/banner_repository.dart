import '../../core/constants/db_paths.dart';
import '../models/banner_item.dart';
import '../models/model_utils.dart';
import 'base_repository.dart';

class BannerRepository extends BaseRepository {
  Future<List<BannerItem>> fetchBanners() => guard(() async {
        final snapshot = await ref(DbPaths.banners).get();
        final map = ModelUtils.asMap(snapshot.value);
        return map.entries
            .map((e) => BannerItem.fromMap(e.key, e.value))
            .where((b) => b.active)
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      }, 'fetchBanners');

  // ---- Admin CRUD (includes inactive banners) ----

  Future<List<BannerItem>> fetchAll() => guard(() async {
        final snapshot = await ref(DbPaths.banners).get();
        final map = ModelUtils.asMap(snapshot.value);
        return map.entries
            .map((e) => BannerItem.fromMap(e.key, e.value))
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      }, 'fetchAllBanners');

  Future<String> upsertBanner(BannerItem banner, {String? id}) =>
      guard(() async {
        final bid = id ?? ref(DbPaths.banners).push().key!;
        await ref('${DbPaths.banners}/$bid').set(banner.toMap());
        return bid;
      }, 'upsertBanner');

  Future<void> deleteBanner(String id) =>
      guard(() => ref('${DbPaths.banners}/$id').remove(), 'deleteBanner');
}
