import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/analytics_events.dart';
import '../../core/utils/app_logger.dart';
import '../../data/models/review.dart';
import '../../data/repositories/review_repository.dart';
import '../../services/analytics_service.dart';
import 'auth_controller.dart';

/// Review submission (rating, text, photos) and helpful votes.
class ReviewController extends GetxController {
  ReviewController({
    required this.reviewRepository,
    required this.analytics,
  });

  final ReviewRepository reviewRepository;
  final AnalyticsService analytics;

  final RxDouble rating = 0.0.obs;
  final RxList<File> photos = <File>[].obs;
  final RxBool isSubmitting = false.obs;

  static const int maxPhotos = 4;

  Future<void> pickPhotos() async {
    final picked = await ImagePicker().pickMultiImage(
      imageQuality: 70,
      maxWidth: 1200,
      limit: maxPhotos,
    );
    photos.value =
        picked.take(maxPhotos).map((file) => File(file.path)).toList();
  }

  void removePhoto(File file) => photos.remove(file);

  Future<bool> submit(String productId, String text) async {
    final auth = Get.find<AuthController>();
    final uid = auth.uid;
    if (uid == null || rating.value == 0) return false;
    isSubmitting.value = true;
    try {
      final review = Review(
        id: '',
        uid: uid,
        userName: auth.user.value?.name.isNotEmpty == true
            ? auth.user.value!.name
            : 'guest'.tr,
        rating: rating.value,
        text: text.trim(),
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      await reviewRepository.submitReview(
        productId: productId,
        review: review,
        photos: photos.toList(),
      );
      analytics.logEvent(AnalyticsEvents.reviewSubmitted, {
        AnalyticsEvents.pProductId: productId,
        'rating': rating.value,
      });
      Get.snackbar('app_name'.tr, 'review_submitted'.tr);
      return true;
    } catch (error, stackTrace) {
      AppLogger.e('Review submit failed', error: error, stackTrace: stackTrace);
      Get.snackbar('app_name'.tr, 'error_generic'.tr);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> voteHelpful(String productId, String reviewId) async {
    final uid = Get.find<AuthController>().uid;
    if (uid == null) return;
    final counted = await reviewRepository.voteHelpful(productId, reviewId, uid);
    if (counted) {
      analytics.logEvent(AnalyticsEvents.reviewHelpfulVote,
          {AnalyticsEvents.pProductId: productId});
    }
  }
}
