// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag.model.dart';

// **************************************************************************
// Generator: DoxModelBuilder
// **************************************************************************

// ignore_for_file: always_specify_types

class TagGenerator extends Model<Tag> implements JsonWritable {
  @override
  String get primaryKey => 'id';

  @override
  Map<String, dynamic> get timestampsColumn => const <String, dynamic>{
    'created_at': 'created_at',
    'updated_at': 'updated_at',
  };

  @override
  String get tableName => 'tags';

  int? get id => tempIdValue as int?;

  set id(int? val) => tempIdValue = val;

  Tag query() => Tag();

  @override
  bool get readsRowDates => true;

  @override
  List<String> get tableColumns => const <String>[
    'id',
    'name',
    'created_at',
    'updated_at',
  ];

  @override
  List<String> get preloadList => const <String>[];

  @override
  Map<String, Function> get relationsResultMatcher => const <String, Function>{
    'posts': getPosts,
  };

  @override
  Map<String, Function> get relationsQueryMatcher => const <String, Function>{
    'posts': queryPosts,
  };

  static Future<void> getPosts(List<Model<Tag>> list) async {
    var result = await getManyToMany<Tag, Post>(queryPosts(list), list);
    for (dynamic i in list) {
      i.posts = result[i.tempIdValue.toString()] ?? <Post>[];
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
    Tag instance = this as Tag;
    Map<String, dynamic> map = <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

    return map;
  }

  @override
  dynamic $columnValue(String column) {
    Tag instance = this as Tag;
    switch (column) {
      case 'id':
        return instance.id;
      case 'name':
        return instance.name;
      case 'created_at':
        return instance.createdAt?.toIso8601String();
      case 'updated_at':
        return instance.updatedAt?.toIso8601String();
    }
    return super.$columnValue(column);
  }

  @override
  Map<String, dynamic> convertToMap(dynamic i) {
    Tag instance = i as Tag;
    Map<String, dynamic> map = instance.columnsToMap();

    List<String> preload = getPreload();
    if (preload.contains('posts')) {
      map['posts'] = toMap(instance.posts);
    }

    return map;
  }

  @override
  bool setColumnValue(String column, dynamic value) {
    Tag instance = this as Tag;
    switch (column) {
      case 'id':
        if (value is! int?) return false;
        instance.id = value;
        return true;
      case 'name':
        if (value is! String?) return false;
        instance.name = value;
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
  bool $copyColumnsFrom(Model<Tag> other) {
    Tag o = other as Tag;
    (this as Tag)
      ..id = o.id
      ..name = o.name
      ..createdAt = o.createdAt
      ..updatedAt = o.updatedAt;
    return true;
  }

  @override
  void writeJson(JsonWriter w) {
    List<String>? hide = $jsonHidden;
    // a class that extends the model can have its own toJson()
    if (hide == null || runtimeType != Tag) {
      w.value(toJson());
      return;
    }
    bool all = hide.isEmpty;
    Tag instance = this as Tag;
    w.startObject();
    if (all || !hide.contains('id')) {
      w.key('id');
      w.integer(instance.id);
    }
    if (all || !hide.contains('name')) {
      w.key('name');
      w.string(instance.name);
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
    w.endObject();
  }
}
