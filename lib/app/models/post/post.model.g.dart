// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.model.dart';

// **************************************************************************
// Generator: DoxModelBuilder
// **************************************************************************

// ignore_for_file: always_specify_types

class PostGenerator extends Model<Post> with SoftDeletes<Post> {
  @override
  String get primaryKey => 'id';

  @override
  Map<String, dynamic> get timestampsColumn => <String, dynamic>{
    'created_at': 'created_at',
    'updated_at': 'updated_at',
  };

  @override
  String get tableName => 'posts';

  int? get id => tempIdValue;

  set id(dynamic val) => tempIdValue = val;

  Post query() => Post();

  @override
  List<String> get tableColumns => <String>[
    'id',
    'user_id',
    'title',
    'body',
    'status',
    'deleted_at',
    'created_at',
    'updated_at',
  ];

  @override
  List<String> get preloadList => <String>[];

  @override
  Map<String, Function> get relationsResultMatcher => <String, Function>{
    'author': getAuthor,
    'comments': getComments,
    'tags': getTags,
  };

  @override
  Map<String, Function> get relationsQueryMatcher => <String, Function>{
    'author': queryAuthor,
    'comments': queryComments,
    'tags': queryTags,
  };

  static Future<void> getAuthor(List<Model<Post>> list) async {
    var result = await getBelongsTo<Post, User>(queryAuthor(list), list);
    for (dynamic i in list) {
      if (result[i.tempIdValue.toString()] != null) {
        i.author = result[i.tempIdValue.toString()]!;
      }
    }
  }

  static User? queryAuthor(List<Model<Post>> list) {
    return belongsTo<Post, User>(
      list,
      () => User(),
      foreignKey: 'user_id',
      localKey: 'id',
    );
  }

  static Future<void> getComments(List<Model<Post>> list) async {
    var result = await getHasMany<Post, Comment>(queryComments(list), list);
    for (dynamic i in list) {
      if (result[i.tempIdValue.toString()] != null) {
        i.comments = result[i.tempIdValue.toString()]!;
      }
    }
  }

  static Comment? queryComments(List<Model<Post>> list) {
    return hasMany<Post, Comment>(
      list,
      () => Comment(),
      foreignKey: 'post_id',
      localKey: 'id',
    );
  }

  static Future<void> getTags(List<Model<Post>> list) async {
    var result = await getManyToMany<Post, Tag>(queryTags(list), list);
    for (dynamic i in list) {
      if (result[i.tempIdValue.toString()] != null) {
        i.tags = result[i.tempIdValue.toString()]!;
      }
    }
  }

  static Tag? queryTags(List<Model<Post>> list) {
    return manyToMany<Post, Tag>(
      list,
      () => Tag(),
      localKey: 'id',
      relatedKey: 'id',
      pivotForeignKey: 'post_id',
      pivotRelatedForeignKey: 'tag_id',
      pivotTable: 'post_tag',
    );
  }

  @override
  Post fromMap(Map<String, dynamic> m) => Post()
    ..id = m['id'] as int?
    ..userId = m['user_id'] as int?
    ..title = m['title'] as String?
    ..body = m['body'] as String?
    ..status = m['status'] as String?
    ..deletedAt = m['deleted_at'] == null
        ? null
        : DateTime.parse(m['deleted_at'] as String)
    ..createdAt = m['created_at'] == null
        ? null
        : DateTime.parse(m['created_at'] as String)
    ..updatedAt = m['updated_at'] == null
        ? null
        : DateTime.parse(m['updated_at'] as String);

  @override
  Map<String, dynamic> convertToMap(dynamic i) {
    Post instance = i as Post;
    Map<String, dynamic> map = <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'title': instance.title,
      'body': instance.body,
      'status': instance.status,
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

    List<String> preload = getPreload();
    if (preload.contains('author')) {
      map['author'] = toMap(instance.author);
    }
    if (preload.contains('comments')) {
      map['comments'] = toMap(instance.comments);
    }
    if (preload.contains('tags')) {
      map['tags'] = toMap(instance.tags);
    }

    return map;
  }
}
