import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../controllers/review_controller.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/rating_stars.dart';

/// Write a review: star rating, text and up to 4 photos.
class AddReviewScreen extends GetView<ReviewController> {
  const AddReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productId = Get.arguments?.toString() ?? '';
    final textController = TextEditingController();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('write_review'.tr)),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        children: [
          Text('your_rating'.tr,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppTheme.spacingS),
          Center(
            child: Obx(() => RatingInput(
                  value: controller.rating.value,
                  onChanged: (value) => controller.rating.value = value,
                )),
          ),
          const SizedBox(height: AppTheme.spacingL),
          TextField(
            controller: textController,
            maxLines: 5,
            maxLength: 1000,
            decoration: InputDecoration(hintText: 'review_hint'.tr),
          ),
          const SizedBox(height: AppTheme.spacingM),
          OutlinedButton.icon(
            onPressed: controller.pickPhotos,
            icon: const Icon(Icons.add_a_photo_outlined),
            label: Text('add_photos'.tr),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Obx(() => controller.photos.isEmpty
              ? const SizedBox.shrink()
              : SizedBox(
                  height: 88,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.photos.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: AppTheme.spacingS),
                    itemBuilder: (context, index) {
                      final file = controller.photos[index];
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusS),
                            child: Image.file(file,
                                width: 88, height: 88, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: InkWell(
                              onTap: () => controller.removePhoto(file),
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.black54,
                                child: Icon(Icons.close_rounded,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                )),
          const SizedBox(height: AppTheme.spacingL),
          Obx(() => PrimaryButton(
                label: 'submit_review'.tr,
                isLoading: controller.isSubmitting.value,
                onPressed: controller.rating.value == 0
                    ? null
                    : () async {
                        final submitted = await controller.submit(
                            productId, textController.text);
                        if (submitted) Get.back(result: true);
                      },
              )),
        ],
      ),
    );
  }
}
