import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../controllers/search_controller.dart';
import '../../widgets/cached_image.dart';
import '../../widgets/price_text.dart';

/// Search with live product suggestions, recent and trending terms.
class SearchScreen extends GetView<ProductSearchController> {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'search_hint'.tr,
            border: InputBorder.none,
            filled: false,
            suffixIcon: IconButton(
              onPressed: controller.startVoiceSearch,
              icon: const Icon(Icons.mic_none_rounded),
            ),
          ),
          onChanged: controller.onQueryChanged,
          onSubmitted: controller.submit,
        ),
      ),
      body: Obx(() {
        if (controller.query.value.trim().length >= 2) {
          return _suggestions(context);
        }
        return _history(context);
      }),
    );
  }

  Widget _suggestions(BuildContext context) {
    if (controller.isSearching.value) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.suggestions.isEmpty) {
      return Center(
        child: Text(
          'no_results_for'.trParams({'query': controller.query.value}),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    return ListView.builder(
      itemCount: controller.suggestions.length,
      itemBuilder: (context, index) {
        final product = controller.suggestions[index];
        return ListTile(
          leading: CachedImage(
            url: product.thumbnail,
            width: 44,
            height: 52,
            borderRadius: BorderRadius.circular(AppTheme.radiusS),
          ),
          title:
              Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: PriceText(price: product.price, mrp: product.mrp),
          trailing: const Icon(Icons.north_west_rounded, size: 16),
          onTap: () => controller.onSuggestionTap(product),
        );
      },
    );
  }

  Widget _history(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      children: [
        if (controller.recentSearches.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: Text('recent_searches'.tr,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ),
              TextButton(
                onPressed: controller.clearHistory,
                child: Text('clear'.tr),
              ),
            ],
          ),
          Wrap(
            spacing: AppTheme.spacingS,
            runSpacing: AppTheme.spacingXs,
            children: [
              for (final term in controller.recentSearches)
                ActionChip(
                  avatar: const Icon(Icons.history_rounded, size: 16),
                  label: Text(term),
                  onPressed: () => controller.submit(term),
                ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
        ],
        if (controller.trendingSearches.isNotEmpty) ...[
          Text('trending_searches'.tr,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppTheme.spacingS),
          Wrap(
            spacing: AppTheme.spacingS,
            runSpacing: AppTheme.spacingXs,
            children: [
              for (final term in controller.trendingSearches)
                ActionChip(
                  avatar: const Icon(Icons.trending_up_rounded, size: 16),
                  label: Text(term),
                  onPressed: () => controller.submit(term),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
