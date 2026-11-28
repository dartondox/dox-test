// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge.model.dart';

// **************************************************************************
// Generator: DoxModelBuilder
// **************************************************************************

// ignore_for_file: always_specify_types

class BadgeGenerator extends Model<Badge>
    with SoftDeletes<Badge>
    implements JsonWritable {
  @override
  String get primaryKey => 'id';

  @override
  Map<String, dynamic> get timestampsColumn => const <String, dynamic>{
    'created_at': 'created_at',
    'updated_at': 'updated_at',
  };

  @override
  String get tableName => 'badges';

  int? get id => tempIdValue as int?;

  set id(int? val) => tempIdValue = val;

  Badge query() => Badge();

  @override
  bool get readsRowDates => true;

  @override
  List<String> get tableColumns => const <String>[
    'id',
    'name',
    'code',
    'meta',
    'score',
    'deleted_at',
    'created_at',
    'updated_at',
  ];

  @override
  List<String> get preloadList => const <String>[];

  @override
  Map<String, Function> get relationsResultMatcher => const <String, Function>{
    'posts': getPosts,
    'reactions': getReactions,
  };

  @override
  Map<String, Function> get relationsQueryMatcher => const <String, Function>{
    'posts': queryPosts,
    'reactions': queryReactions,
  };

  static Future<void> getPosts(List<Model<Badge>> list) async {
    var result = await getManyToMany<Badge, Post>(queryPosts(list), list);
    for (dynamic i in list) {
      i.posts = result[i.tempIdValue.toString()] ?? <Post>[];
    }
  }

  static Post? queryPosts(List<Model<Badge>> list) {
    return manyToMany<Badge, Post>(
      list,
      () => Post(),
      localKey: 'id',
      relatedKey: 'id',
      pivotForeignKey: 'badge_id',
      pivotRelatedForeignKey: 'post_id',
      pivotTable: 'badge_post',
      withPivot: const <String>['note'],
      withTimestamps: true,
    );
  }

  static Future<void> getReactions(List<Model<Badge>> list) async {
    var result = await getMorphMany<Badge, Reaction>(
      queryReactions(list),
      list,
    );
    for (dynamic i in list) {
      i.reactions = result[i.tempIdValue.toString()] ?? <Reaction>[];
    }
  }

  static Reaction? queryReactions(List<Model<Badge>> list) {
    return morphMany<Badge, Reaction>(
      list,
      () => Reaction(),
      name: 'reactable',
    );
  }

  @override
  Badge fromMap(Map<String, dynamic> m) => Badge()
    ..id = m['id'] as int?
    ..name = m['name'] as String?
    ..code = m['code'] as String?
    ..meta = m['meta'] as Map<String, dynamic>?
    ..score = m['score'] as int?
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
    Badge instance = this as Badge;
    Map<String, dynamic> map = <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'meta': instance.meta,
      'score': instance.score,
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

    return map;
  }

  @override
  dynamic $columnValue(String column) {
    Badge instance = this as Badge;
    switch (column) {
      case 'id':
        return instance.id;
      case 'name':
        return instance.name;
      case 'code':
        return instance.code;
      case 'meta':
        return instance.meta;
      case 'score':
        return instance.score;
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
    Badge instance = i as Badge;
    Map<String, dynamic> map = instance.columnsToMap();

    List<String> preload = getPreload();
    if (preload.contains('posts')) {
      map['posts'] = toMap(instance.posts);
    }
    if (preload.contains('reactions')) {
      map['reactions'] = toMap(instance.reactions);
    }

    return map;
  }

  @override
  bool setColumnValue(String column, dynamic value) {
    Badge instance = this as Badge;
    switch (column) {
      case 'id':
        if (value is! int?) return false;
        instance.id = value;
        return true;
      case 'name':
        if (value is! String?) return false;
        instance.name = value;
        return true;
      case 'code':
        if (value is! String?) return false;
        instance.code = value;
        return true;
      case 'meta':
        if (value is! Map<String, dynamic>?) return false;
        instance.meta = value;
        return true;
      case 'score':
        if (value is! int?) return false;
        instance.score = value;
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
  bool $copyColumnsFrom(Model<Badge> other) {
    Badge o = other as Badge;
    (this as Badge)
      ..id = o.id
      ..name = o.name
      ..code = o.code
      ..meta = o.meta
      ..score = o.score
      ..deletedAt = o.deletedAt
      ..createdAt = o.createdAt
      ..updatedAt = o.updatedAt;
    return true;
  }

  @override
  void writeJson(JsonWriter w) {
    List<String>? hide = $jsonHidden;
    // a class that extends the model can have its own toJson()
    if (hide == null || runtimeType != Badge) {
      w.value(toJson());
      return;
    }
    bool all = hide.isEmpty;
    Badge instance = this as Badge;
    w.startObject();
    if (all || !hide.contains('id')) {
      w.key('id');
      w.integer(instance.id);
    }
    if (all || !hide.contains('name')) {
      w.key('name');
      w.string(instance.name);
    }
    if (all || !hide.contains('code')) {
      w.key('code');
      w.string(instance.code);
    }
    if (all || !hide.contains('meta')) {
      w.key('meta');
      w.value(instance.meta);
    }
    if (all || !hide.contains('score')) {
      w.key('score');
      w.integer(instance.score);
    }
    if (all || !hide.contains('deleted_at')) {
      w.key('deleted_at');
      w.dateTime(instance.deletedAt);
    }
    if (all || !hide.contains('created_at')) {
      w.key('created_at');
      w.dateTime(instance.createdAt);
    }
    if (all || !hide.contains('updated_at')) {
      w.key('updated_at');
      w.dateTime(instance.updatedAt);
    }
    List<String> preload = getPreload();
    if (preload.contains('posts') && (all || !hide.contains('posts'))) {
      w.key('posts');
      w.value(instance.posts);
    }
    if (preload.contains('reactions') && (all || !hide.contains('reactions'))) {
      w.key('reactions');
      w.value(instance.reactions);
    }
    w.endObject();
  }
}
