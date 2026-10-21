// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag.model.dart';

// **************************************************************************
// Generator: DoxModelBuilder
// **************************************************************************

// ignore_for_file: always_specify_types

class TagGenerator extends Model<Tag> {
  @override
  String get primaryKey => 'id';

  @override
  Map<String, dynamic> get timestampsColumn => <String, dynamic>{
    'created_at': 'created_at',
    'updated_at': 'updated_at',
  };

  @override
  String get tableName => 'tags';

  int? get id => tempIdValue;

  set id(dynamic val) => tempIdValue = val;

  Tag query() => Tag();

  @override
  List<String> get tableColumns => <String>[
    'id',
    'name',
    'created_at',
    'updated_at',
  ];

  @override
  List<String> get preloadList => <String>[];

  @override
  Map<String, Function> get relationsResultMatcher => <String, Function>{
    'posts': getPosts,
  };

  @override
  Map<String, Function> get relationsQueryMatcher => <String, Function>{
    'posts': queryPosts,
  };

  static Future<void> getPosts(List<Model<Tag>> list) async {
    var result = await getManyToMany<Tag, Post>(queryPosts(list), list);
    for (dynamic i in list) {
      if (result[i.tempIdValue.toString()] != null) {
        i.posts = result[i.tempIdValue.toString()]!;
      }
    }
  }

  static Post? queryPosts(List<Model<Tag>> list) {
    return manyToMany<Tag, Post>(
      list,
      () => Post(),
      localKey: 'id',
      relatedKey: 'id',
      pivotForeignKey: 'tag_id',
      pivotRelatedForeignKey: 'post_id',
      pivotTable: 'post_tag',
    );
  }

  @override
  Tag fromMap(Map<String, dynamic> m) => Tag()
    ..id = m['id'] as int?
    ..name = m['name'] as String?
    ..createdAt = m['created_at'] == null
        ? null
        : DateTime.parse(m['created_at'] as String)
    ..updatedAt = m['updated_at'] == null
        ? null
        : DateTime.parse(m['updated_at'] as String);

  @override
  Map<String, dynamic> convertToMap(dynamic i) {
    Tag instance = i as Tag;
    Map<String, dynamic> map = <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

    List<String> preload = getPreload();
    if (preload.contains('posts')) {
      map['posts'] = toMap(instance.posts);
    }

    return map;
  }
}
