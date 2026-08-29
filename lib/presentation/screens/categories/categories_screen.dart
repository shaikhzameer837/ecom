import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/category_model.dart';
import '../../controllers/categories_controller.dart';
import '../../widgets/cached_image.dart';
import '../../widgets/shimmer_widgets.dart';
import '../../widgets/state_views.dart';

/// Categories tab: expandable tree of categories and subcategories.
class CategoriesScreen extends GetView<CategoriesController> {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('categories_title'.tr)),
      body: Obx(() {
        if (controller.isLoading.value) {
          return ListView(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            children: List.generate(
              6,
              (_) => const Padding(
                padding: EdgeInsets.only(bottom: AppTheme.spacingM),
                child: ShimmerBox(height: 72, radius: AppTheme.radiusM),
              ),
            ),
          );
        }
        if (controller.hasError.value) {
          return ErrorState(onRetry: controller.load);
        }
        if (controller.categories.isEmpty) {
          return EmptyState(
            icon: Icons.category_outlined,
            title: 'empty_generic'.tr,
          );
        }
        return RefreshIndicator(
          onRefresh: () => controller.load(forceRefresh: true),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppTheme.spacingM),
            itemCount: controller.categories.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppTheme.spacingS),
            itemBuilder: (context, index) =>
                _CategoryTile(category: controller.categories[index]),
          ),
        );
      }),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category});

  final CategoryModel category;

  void _openListing({String? subcategoryId, String? title}) {
    Get.toNamed(AppRoutes.productList, arguments: {
      'categoryId': category.id,
      'subcategoryId': ?subcategoryId,
      'title': title ?? category.name,
    });
  }

  @override
  Widget build(BuildContext context) {
    final leading = ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusS),
      child: category.image.isEmpty
          ? Container(
              width: 48,
              height: 48,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Icon(Icons.checkroom_outlined),
            )
          : CachedImage(url: category.image, width: 48, height: 48),
    );
    final title = Text(
      category.name,
      style: Theme.of(context)
          .textTheme
          .titleSmall
          ?.copyWith(fontWeight: FontWeight.w600),
    );

    if (category.subcategories.isEmpty) {
      return Card(
        child: ListTile(
          leading: leading,
          title: title,
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: _openListing,
        ),
      );
    }
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: leading,
        title: title,
        children: [
          ListTile(
            dense: true,
            title: Text('see_all'.tr),
            trailing: const Icon(Icons.chevron_right_rounded, size: 18),
            onTap: _openListing,
          ),
          ...category.subcategories.map(
            (sub) => ListTile(
              dense: true,
              title: Text(sub.name),
              trailing: const Icon(Icons.chevron_right_rounded, size: 18),
              onTap: () => _openListing(subcategoryId: sub.id, title: sub.name),
            ),
          ),
        ],
      ),
    );
  }
}
