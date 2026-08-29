import 'model_utils.dart';

class Review {
  const Review({
    required this.id,
    required this.uid,
    required this.userName,
    required this.rating,
    this.text = '',
    this.images = const [],
    this.helpfulCount = 0,
    required this.createdAt,
  });

  final String id;
  final String uid;
  final String userName;
  final double rating;
  final String text;
  final List<String> images;
  final int helpfulCount;
  final int createdAt;

  factory Review.fromMap(String id, Object? raw) {
    final map = ModelUtils.asMap(raw);
    return Review(
      id: id,
      uid: ModelUtils.asString(map['uid']),
      userName: ModelUtils.asString(map['userName']),
      rating: ModelUtils.asDouble(map['rating']),
      text: ModelUtils.asString(map['text']),
      images: ModelUtils.asStringList(map['images']),
      helpfulCount: ModelUtils.asInt(map['helpfulCount']),
      createdAt: ModelUtils.asInt(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'userName': userName,
        'rating': rating,
        'text': text,
        'images': images,
        'helpfulCount': helpfulCount,
        'createdAt': createdAt,
      };
}
