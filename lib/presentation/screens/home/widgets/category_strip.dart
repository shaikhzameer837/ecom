import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/category_model.dart';
import '../../../widgets/cached_image.dart';

/// Horizontal circles of top-level categories on the home screen.
class CategoryStrip extends StatelessWidget {
  const CategoryStrip({super.key, required this.categories, this.onCategoryTap});

  final List<CategoryModel> categories;
  final void Function(CategoryModel category)? onCategoryTap;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppTheme.spacingM),
        itemBuilder: (context, index) {
          final category = categories[index];
          return InkWell(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            onTap: () {
              onCategoryTap?.call(category);
              Get.toNamed(AppRoutes.productList, arguments: {
                'categoryId': category.id,
                'title': category.name,
              });
            },
            child: SizedBox(
              width: 68,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: category.image.isEmpty
                        ? const Icon(Icons.category_outlined)
                        : ClipOval(
                            child: CachedImage(
                                url: category.image, width: 60, height: 60),
                          ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
