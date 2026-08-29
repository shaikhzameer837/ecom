import 'model_utils.dart';

enum BannerTarget { category, product, none }

class BannerItem {
  const BannerItem({
    required this.id,
    required this.image,
    this.title = '',
    this.target = BannerTarget.none,
    this.targetId = '',
    this.sortOrder = 0,
    this.active = true,
  });

  final String id;
  final String image;
  final String title;
  final BannerTarget target;
  final String targetId;
  final int sortOrder;
  final bool active;

  factory BannerItem.fromMap(String id, Object? raw) {
    final map = ModelUtils.asMap(raw);
    return BannerItem(
      id: id,
      image: ModelUtils.asString(map['image']),
      title: ModelUtils.asString(map['title']),
      target: BannerTarget.values.asNameMap()[ModelUtils.asString(map['target'])] ??
          BannerTarget.none,
      targetId: ModelUtils.asString(map['targetId']),
      sortOrder: ModelUtils.asInt(map['sortOrder']),
      active: ModelUtils.asBool(map['active'], true),
    );
  }

  Map<String, dynamic> toMap() => {
        'image': image,
        'title': title,
        'target': target.name,
        'targetId': targetId,
        'sortOrder': sortOrder,
        'active': active,
      };
}
