import 'model_utils.dart';

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    this.image = '',
    this.parentId = '',
    this.sortOrder = 0,
    this.subcategories = const [],
  });

  final String id;
  final String name;
  final String image;
  final String parentId;
  final int sortOrder;
  final List<CategoryModel> subcategories;

  bool get isTopLevel => parentId.isEmpty;

  factory CategoryModel.fromMap(String id, Object? raw) {
    final map = ModelUtils.asMap(raw);
    final subsRaw = ModelUtils.asMap(map['subcategories']);
    final subs = subsRaw.entries
        .map((e) => CategoryModel.fromMap(e.key, e.value))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return CategoryModel(
      id: id,
      name: ModelUtils.asString(map['name']),
      image: ModelUtils.asString(map['image']),
      parentId: ModelUtils.asString(map['parentId']),
      sortOrder: ModelUtils.asInt(map['sortOrder']),
      subcategories: subs,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'image': image,
        'parentId': parentId,
        'sortOrder': sortOrder,
        if (subcategories.isNotEmpty)
          'subcategories': {for (final s in subcategories) s.id: s.toMap()},
      };
}
