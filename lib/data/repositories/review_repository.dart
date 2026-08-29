import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../core/constants/db_paths.dart';
import '../models/model_utils.dart';
import '../models/review.dart';
import 'base_repository.dart';

class ReviewRepository extends BaseRepository {
  Future<List<Review>> fetchReviews(String productId) => guard(() async {
        final snapshot = await ref('${DbPaths.reviews}/$productId').get();
        final map = ModelUtils.asMap(snapshot.value);
        return map.entries.map((e) => Review.fromMap(e.key, e.value)).toList()
          ..sort((a, b) => b.helpfulCount.compareTo(a.helpfulCount));
      }, 'fetchReviews');

  Future<void> submitReview({
    required String productId,
    required Review review,
    List<File> photos = const [],
  }) =>
      guard(() async {
        final reviewRef = ref('${DbPaths.reviews}/$productId').push();
        final urls = <String>[];
        for (var i = 0; i < photos.length; i++) {
          final storageRef = FirebaseStorage.instance
              .ref('reviews/$productId/${reviewRef.key}_$i.jpg');
          await storageRef.putFile(photos[i]);
          urls.add(await storageRef.getDownloadURL());
        }
        await reviewRef.set({...review.toMap(), 'images': urls});
        await _recomputeAggregate(productId, review.rating);
      }, 'submitReview');

  /// Updates the product's average rating atomically via a transaction.
  Future<void> _recomputeAggregate(String productId, double newRating) async {
    final productRef = ref('${DbPaths.products}/$productId');
    await productRef.runTransaction((Object? value) {
      if (value == null) return Transaction.abort();
      final map = Map<String, dynamic>.from(
          ModelUtils.asMap(value).map((k, v) => MapEntry(k, v)));
      final count = ModelUtils.asInt(map['ratingCount']);
      final rating = ModelUtils.asDouble(map['rating']);
      map['ratingCount'] = count + 1;
      map['rating'] =
          double.parse(((rating * count + newRating) / (count + 1)).toStringAsFixed(2));
      return Transaction.success(map);
    });
  }

  /// One helpful vote per user per review; returns true if the vote counted.
  Future<bool> voteHelpful(String productId, String reviewId, String uid) =>
      guard(() async {
        final voteRef = ref('${DbPaths.reviewVotes}/$reviewId/$uid');
        final existing = await voteRef.get();
        if (existing.exists) return false;
        await voteRef.set(true);
        await ref('${DbPaths.reviews}/$productId/$reviewId/helpfulCount')
            .runTransaction((Object? value) =>
                Transaction.success(ModelUtils.asInt(value) + 1));
        return true;
      }, 'voteHelpful');
}
