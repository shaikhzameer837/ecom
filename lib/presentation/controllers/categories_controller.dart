import 'package:get/get.dart';

import '../../core/utils/app_logger.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository.dart';

/// Categories tab: top-level categories with expandable subcategories.
class CategoriesController extends GetxController {
  CategoriesController({required this.categoryRepository});

  final CategoryRepository categoryRepository;

  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load({bool forceRefresh = false}) async {
    isLoading.value = true;
    hasError.value = false;
    try {
      categories.value =
          await categoryRepository.fetchCategories(forceRefresh: forceRefresh);
    } catch (error, stackTrace) {
      AppLogger.e('Categories load failed', error: error, stackTrace: stackTrace);
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }
}
