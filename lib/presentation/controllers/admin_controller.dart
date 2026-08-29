import 'package:get/get.dart';

import '../../core/utils/app_logger.dart';
import '../../data/models/banner_item.dart';
import '../../data/models/category_model.dart';
import '../../data/models/coupon.dart';
import '../../data/models/product.dart';
import '../../data/repositories/banner_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/coupon_repository.dart';
import '../../data/repositories/product_repository.dart';

/// Backs the admin panel: reactive lists and CRUD for products, categories,
/// banners and coupons. Only reachable when [AuthController.isAdmin] is true.
class AdminController extends GetxController {
  AdminController({
    required this.productRepository,
    required this.categoryRepository,
    required this.bannerRepository,
    required this.couponRepository,
  });

  final ProductRepository productRepository;
  final CategoryRepository categoryRepository;
  final BannerRepository bannerRepository;
  final CouponRepository couponRepository;

  final RxList<Product> products = <Product>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<BannerItem> banners = <BannerItem>[].obs;
  final RxList<Coupon> coupons = <Coupon>[].obs;

  final RxBool loadingProducts = false.obs;
  final RxBool loadingCategories = false.obs;
  final RxBool loadingBanners = false.obs;
  final RxBool loadingCoupons = false.obs;
  final RxBool isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    refreshAll();
  }

  Future<void> refreshAll() async {
    await Future.wait([
      loadProducts(),
      loadCategories(),
      loadBanners(),
      loadCoupons(),
    ]);
  }

  // ---- Products ----
  Future<void> loadProducts() async {
    loadingProducts.value = true;
    try {
      products.value = await productRepository.fetchAll()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e, s) {
      AppLogger.e('Admin loadProducts failed', error: e, stackTrace: s);
    } finally {
      loadingProducts.value = false;
    }
  }

  Future<bool> saveProduct(Product product, ProductDetails details,
      {String? id}) async {
    return _run(() async {
      await productRepository.upsertProduct(product, details, id: id);
      await loadProducts();
    });
  }

  Future<void> deleteProduct(String id) async {
    await _run(() async {
      await productRepository.deleteProduct(id);
      products.removeWhere((p) => p.id == id);
    });
  }

  // ---- Categories ----
  Future<void> loadCategories() async {
    loadingCategories.value = true;
    try {
      categories.value =
          await categoryRepository.fetchCategories(forceRefresh: true);
    } catch (e, s) {
      AppLogger.e('Admin loadCategories failed', error: e, stackTrace: s);
    } finally {
      loadingCategories.value = false;
    }
  }

  Future<bool> saveCategory(CategoryModel category, {String? id}) async {
    return _run(() async {
      await categoryRepository.upsertCategory(category, id: id);
      await loadCategories();
    });
  }

  Future<void> deleteCategory(String id) async {
    await _run(() async {
      await categoryRepository.deleteCategory(id);
      await loadCategories();
    });
  }

  Future<bool> saveSubcategory(String parentId, CategoryModel sub,
      {String? id}) async {
    return _run(() async {
      await categoryRepository.upsertSubcategory(parentId, sub, id: id);
      await loadCategories();
    });
  }

  Future<void> deleteSubcategory(String parentId, String id) async {
    await _run(() async {
      await categoryRepository.deleteSubcategory(parentId, id);
      await loadCategories();
    });
  }

  // ---- Banners ----
  Future<void> loadBanners() async {
    loadingBanners.value = true;
    try {
      banners.value = await bannerRepository.fetchAll();
    } catch (e, s) {
      AppLogger.e('Admin loadBanners failed', error: e, stackTrace: s);
    } finally {
      loadingBanners.value = false;
    }
  }

  Future<bool> saveBanner(BannerItem banner, {String? id}) async {
    return _run(() async {
      await bannerRepository.upsertBanner(banner, id: id);
      await loadBanners();
    });
  }

  Future<void> deleteBanner(String id) async {
    await _run(() async {
      await bannerRepository.deleteBanner(id);
      banners.removeWhere((b) => b.id == id);
    });
  }

  // ---- Coupons ----
  Future<void> loadCoupons() async {
    loadingCoupons.value = true;
    try {
      coupons.value = await couponRepository.fetchAll();
    } catch (e, s) {
      AppLogger.e('Admin loadCoupons failed', error: e, stackTrace: s);
    } finally {
      loadingCoupons.value = false;
    }
  }

  Future<bool> saveCoupon(Coupon coupon) async {
    return _run(() async {
      await couponRepository.upsertCoupon(coupon);
      await loadCoupons();
    });
  }

  Future<void> deleteCoupon(String code) async {
    await _run(() async {
      await couponRepository.deleteCoupon(code);
      coupons.removeWhere((c) => c.code == code);
    });
  }

  /// Runs a mutating action with the shared saving flag and error handling.
  Future<bool> _run(Future<void> Function() action) async {
    isSaving.value = true;
    try {
      await action();
      return true;
    } catch (e, s) {
      AppLogger.e('Admin mutation failed', error: e, stackTrace: s);
      Get.snackbar('app_name'.tr, 'error_generic'.tr);
      return false;
    } finally {
      isSaving.value = false;
    }
  }
}
