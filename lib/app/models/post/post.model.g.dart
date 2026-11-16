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
  Map<String, dynamic> get timestampsColumn => const <String, dynamic>{
    'created_at': 'created_at',
    'updated_at': 'updated_at',
  };

  @override
  String get tableName => 'posts';

  int? get id => tempIdValue as int?;

  set id(int? val) => tempIdValue = val;

  Post query() => Post();

  @override
  bool get readsRowDates => true;

  @override
  List<String> get tableColumns => const <String>[
    'id',
    'user_id',
    'title',
    'body',
    'status',
    'views',
    'deleted_at',
    'created_at',
    'updated_at',
  ];

  @override
  List<String> get preloadList => const <String>[];

  @override
  Map<String, Function> get relationsResultMatcher => const <String, Function>{
    'author': getAuthor,
    'comments': getComments,
    'tags': getTags,
  };

  @override
  Map<String, Function> get relationsQueryMatcher => const <String, Function>{
    'author': queryAuthor,
    'comments': queryComments,
    'tags': queryTags,
  };

  static Future<void> getAuthor(List<Model<Post>> list) async {
    var result = await getBelongsTo<Post, User>(queryAuthor(list), list);
    for (dynamic i in list) {
      i.author = result[i.tempIdValue.toString()];
    }
  }

  static User? queryAuthor(List<Model<Post>> list) {
    return belongsTo<Post, User>(
      list,
      () => User(),
      foreignKey: 'user_id',
      localKey: 'id',
      relation: 'author',
    );
  }

  static Future<void> getComments(List<Model<Post>> list) async {
    var result = await getHasMany<Post, Comment>(queryComments(list), list);
    for (dynamic i in list) {
      i.comments = result[i.tempIdValue.toString()] ?? <Comment>[];
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
      i.tags = result[i.tempIdValue.toString()] ?? <Tag>[];
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
    ..views = m['views'] as int?
    ..deletedAt = switch (m['deleted_at']) {
      DateTime? v => v,
      Object? v => DateTime.parse(v as String),
    }
    ..createdAt = switch (m['created_at']) {
      DateTime? v => v,
      Object? v => DateTime.parse(v as String),
    }
    ..updatedAt = switch (m['updated_at']) {
      DateTime? v => v,
      Object? v => DateTime.parse(v as String),
    };
  @override
  Map<String, dynamic> columnsToMap() {
    Post instance = this as Post;
    Map<String, dynamic> map = <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'title': instance.title,
      'body': instance.body,
      'status': instance.status,
      'views': instance.views,
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

    return map;
  }

  @override
  dynamic $columnValue(String column) {
    Post instance = this as Post;
    switch (column) {
      case 'id':
        return instance.id;
      case 'user_id':
        return instance.userId;
      case 'title':
        return instance.title;
      case 'body':
        return instance.body;
      case 'status':
        return instance.status;
      case 'views':
        return instance.views;
      case 'deleted_at':
        return instance.deletedAt?.toIso8601String();
      case 'created_at':
        return instance.createdAt?.toIso8601String();
      case 'updated_at':
        return instance.updatedAt?.toIso8601String();
    }
    return super.$columnValue(column);
  }

  @override
  Map<String, dynamic> convertToMap(dynamic i) {
    Post instance = i as Post;
    Map<String, dynamic> map = instance.columnsToMap();

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

  @override
  bool setColumnValue(String column, dynamic value) {
    Post instance = this as Post;
    switch (column) {
      case 'id':
        if (value is! int?) return false;
        instance.id = value;
        return true;
      case 'user_id':
        if (value is! int?) return false;
        instance.userId = value;
        return true;
      case 'title':
        if (value is! String?) return false;
        instance.title = value;
        return true;
      case 'body':
        if (value is! String?) return false;
        instance.body = value;
        return true;
      case 'status':
        if (value is! String?) return false;
        instance.status = value;
        return true;
      case 'views':
        if (value is! int?) return false;
        instance.views = value;
        return true;
      case 'deleted_at':
        if (value is! DateTime?) return false;
        instance.deletedAt = value;
        return true;
      case 'created_at':
        if (value is! DateTime?) return false;
        instance.createdAt = value;
        return true;
      case 'updated_at':
        if (value is! DateTime?) return false;
        instance.updatedAt = value;
        return true;
    }
    return false;
  }

  @override
  bool $copyColumnsFrom(Model<Post> other) {
    Post o = other as Post;
    (this as Post)
      ..id = o.id
      ..userId = o.userId
      ..title = o.title
      ..body = o.body
      ..status = o.status
      ..views = o.views
      ..deletedAt = o.deletedAt
      ..createdAt = o.createdAt
      ..updatedAt = o.updatedAt;
    return true;
  }
}
