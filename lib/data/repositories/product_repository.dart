import '../../core/constants/app_constants.dart';
import '../../core/constants/db_paths.dart';
import '../models/model_utils.dart';
import '../models/product.dart';
import 'base_repository.dart';

/// Product reads with an in-memory cache.
///
/// The full catalog is loaded once per session and home feeds, category
/// filtering and search are computed in memory. This keeps the app working
/// without any `.indexOn` rules. For catalogs beyond a few thousand SKUs,
/// switch these to indexed RTDB queries (indexes live in
/// firebase/database.rules.json) or a search service (Algolia / Typesense fed
/// by Cloud Functions) without touching the controllers.
class ProductRepository extends BaseRepository {
  final Map<String, Product> _cache = {};

  List<Product> _cacheAll(Object? raw) {
    final map = ModelUtils.asMap(raw);
    final products = map.entries.map((e) => Product.fromMap(e.key, e.value)).toList();
    for (final product in products) {
      _cache[product.id] = product;
    }
    return products;
  }

  Future<Product?> fetchProduct(String id, {bool useCache = true}) =>
      guard(() async {
        if (useCache && _cache.containsKey(id)) return _cache[id];
        final snapshot = await ref('${DbPaths.products}/$id').get();
        if (!snapshot.exists) return null;
        final product = Product.fromMap(id, snapshot.value);
        _cache[id] = product;
        return product;
      }, 'fetchProduct');

  Future<ProductDetails> fetchProductDetails(String id) => guard(() async {
        final snapshot = await ref('${DbPaths.productDetails}/$id').get();
        return ProductDetails.fromMap(snapshot.value);
      }, 'fetchProductDetails');

  bool _catalogLoaded = false;

  /// Loads the full products node once per session and caches it. Home feed
  /// sections and category filtering are computed from this in memory, so the
  /// app needs no `.indexOn` rules to work. For catalogs beyond a few thousand
  /// SKUs, switch the home/category feeds back to indexed queries (and add the
  /// indexes from firebase/database.rules.json) or a search service.
  Future<List<Product>> _ensureCatalog({bool forceRefresh = false}) async {
    if (_catalogLoaded && !forceRefresh) return _cache.values.toList();
    final snapshot = await ref(DbPaths.products).get();
    _cacheAll(snapshot.value);
    _catalogLoaded = true;
    return _cache.values.toList();
  }

  /// All products of a category (top-level or subcategory).
  Future<List<Product>> fetchByCategory(String categoryId,
      {bool forceRefresh = false}) =>
      guard(() async {
        final all = await _ensureCatalog(forceRefresh: forceRefresh);
        return all.where((p) => p.categoryId == categoryId).toList();
      }, 'fetchByCategory');

  Future<List<Product>> fetchNewArrivals({int limit = AppConstants.homeSectionSize}) =>
      guard(() async {
        final all = await _ensureCatalog()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return all.take(limit).toList();
      }, 'fetchNewArrivals');

  Future<List<Product>> fetchBestSellers({int limit = AppConstants.homeSectionSize}) =>
      guard(() async {
        final all = await _ensureCatalog();
        final sellers = all.where((p) => p.isBestSeller).toList()
          ..sort((a, b) => b.soldCount.compareTo(a.soldCount));
        // Fall back to top sellers by volume if none are flagged.
        if (sellers.isEmpty) {
          final byVolume = all.toList()
            ..sort((a, b) => b.soldCount.compareTo(a.soldCount));
          return byVolume.take(limit).toList();
        }
        return sellers.take(limit).toList();
      }, 'fetchBestSellers');

  Future<List<Product>> fetchFeatured({int limit = AppConstants.homeSectionSize}) =>
      guard(() async {
        final all = await _ensureCatalog();
        final featured = all.where((p) => p.isFeatured).toList();
        return (featured.isEmpty ? all : featured).take(limit).toList();
      }, 'fetchFeatured');

  Future<List<Product>> fetchFlashSale({int limit = AppConstants.homeSectionSize}) =>
      guard(() async {
        final now = DateTime.now().millisecondsSinceEpoch;
        final all = await _ensureCatalog();
        return all
            .where((p) => p.flashSaleEndsAt > now)
            .take(limit)
            .toList();
      }, 'fetchFlashSale');

  Future<List<Product>> fetchByIds(List<String> ids) => guard(() async {
        final results = await Future.wait(ids.map((id) => fetchProduct(id)));
        return results.whereType<Product>().toList();
      }, 'fetchByIds');

  /// Related = same subcategory; similar = same top-level category.
  Future<List<Product>> fetchRelated(Product product,
      {int limit = AppConstants.homeSectionSize}) =>
      guard(() async {
        final all = await fetchByCategory(product.categoryId);
        return all
            .where((p) =>
                p.id != product.id && p.subcategoryId == product.subcategoryId)
            .take(limit)
            .toList();
      }, 'fetchRelated');

  Future<List<Product>> fetchSimilar(Product product,
      {int limit = AppConstants.homeSectionSize}) =>
      guard(() async {
        final all = await fetchByCategory(product.categoryId);
        return all.where((p) => p.id != product.id).take(limit).toList();
      }, 'fetchSimilar');

  /// Client-side keyword search over the cached catalog. Fetches the full
  /// catalog once per session (fine for a boutique catalog; see class note
  /// for the scale-up path).
  // ---- Admin CRUD ----

  /// Full catalog for the admin list (always fresh).
  Future<List<Product>> fetchAll() =>
      guard(() => _ensureCatalog(forceRefresh: true), 'fetchAll');

  /// Creates (when [id] is null) or updates a product and its detail record.
  /// Returns the product id.
  Future<String> upsertProduct(Product product, ProductDetails details,
          {String? id}) =>
      guard(() async {
        final pid = id ?? ref(DbPaths.products).push().key!;
        await ref('${DbPaths.products}/$pid').set(product.toMap());
        await ref('${DbPaths.productDetails}/$pid').set(details.toMap());
        _cache[pid] = Product.fromMap(pid, product.toMap());
        _catalogLoaded = false; // force home/listing feeds to reload
        return pid;
      }, 'upsertProduct');

  Future<void> deleteProduct(String id) => guard(() async {
        await ref('${DbPaths.products}/$id').remove();
        await ref('${DbPaths.productDetails}/$id').remove();
        _cache.remove(id);
        _catalogLoaded = false;
      }, 'deleteProduct');

  Future<List<Product>> search(String query) => guard(() async {
        await _ensureCatalog();
        final terms = query.toLowerCase().split(RegExp(r'\s+'));
        return _cache.values.where((product) {
          final haystack = '${product.name} ${product.brand} '
                  '${product.keywords.join(' ')}'
              .toLowerCase();
          return terms.every(haystack.contains);
        }).toList();
      }, 'search');
}
