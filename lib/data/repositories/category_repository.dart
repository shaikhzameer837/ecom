import '../../core/constants/db_paths.dart';
import '../models/category_model.dart';
import '../models/model_utils.dart';
import 'base_repository.dart';

class CategoryRepository extends BaseRepository {
  List<CategoryModel>? _cache;

  Future<List<CategoryModel>> fetchCategories({bool forceRefresh = false}) =>
      guard(() async {
        if (!forceRefresh && _cache != null) return _cache!;
        final snapshot = await ref(DbPaths.categories).get();
        final map = ModelUtils.asMap(snapshot.value);
        final categories = map.entries
            .map((e) => CategoryModel.fromMap(e.key, e.value))
            .where((c) => c.isTopLevel)
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        _cache = categories;
        return categories;
      }, 'fetchCategories');

  // ---- Admin CRUD ----

  /// Creates (when [id] is null) or updates a top-level category.
  Future<String> upsertCategory(CategoryModel category, {String? id}) =>
      guard(() async {
        final cid = id ?? ref(DbPaths.categories).push().key!;
        await ref('${DbPaths.categories}/$cid').set(category.toMap());
        _cache = null; // invalidate
        return cid;
      }, 'upsertCategory');

  Future<void> deleteCategory(String id) => guard(() async {
        await ref('${DbPaths.categories}/$id').remove();
        _cache = null;
      }, 'deleteCategory');

  /// Adds/updates a subcategory under [parentId].
  Future<String> upsertSubcategory(
          String parentId, CategoryModel subcategory, {String? id}) =>
      guard(() async {
        final sid = id ??
            ref('${DbPaths.categories}/$parentId/subcategories').push().key!;
        await ref('${DbPaths.categories}/$parentId/subcategories/$sid')
            .set(subcategory.toMap());
        _cache = null;
        return sid;
      }, 'upsertSubcategory');

  Future<void> deleteSubcategory(String parentId, String id) => guard(() async {
        await ref('${DbPaths.categories}/$parentId/subcategories/$id').remove();
        _cache = null;
      }, 'deleteSubcategory');
}
