// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gql_secret.model.dart';

// **************************************************************************
// Generator: DoxModelBuilder
// **************************************************************************

// ignore_for_file: always_specify_types

class GqlSecretGenerator extends Model<GqlSecret> implements JsonWritable {
  @override
  String get primaryKey => 'id';

  @override
  Map<String, dynamic> get timestampsColumn => const <String, dynamic>{
    'created_at': 'created_at',
    'updated_at': 'updated_at',
  };

  @override
  String get tableName => 'gql_secrets';

  int? get id => tempIdValue as int?;

  set id(int? val) => tempIdValue = val;

  GqlSecret query() => GqlSecret();

  @override
  bool get readsRowDates => true;

  @override
  List<String> get tableColumns => const <String>[
    'id',
    'user_id',
    'post_id',
    'body',
    'created_at',
    'updated_at',
  ];

  @override
  List<String> get preloadList => const <String>[];

  @override
  Map<String, Function> get relationsResultMatcher => const <String, Function>{
    'post': getPost,
  };

  @override
  Map<String, Function> get relationsQueryMatcher => const <String, Function>{
    'post': queryPost,
  };

  static Future<void> getPost(List<Model<GqlSecret>> list) async {
    var result = await getBelongsTo<GqlSecret, Post>(queryPost(list), list);
    for (dynamic i in list) {
      i.post = result[i.tempIdValue.toString()];
    }
  }

  static Post? queryPost(List<Model<GqlSecret>> list) {
    return belongsTo<GqlSecret, Post>(
      list,
      () => Post(),
      foreignKey: 'post_id',
      localKey: 'id',
      relation: 'post',
    );
  }

  @override
  GqlSecret fromMap(Map<String, dynamic> m) => GqlSecret()
    ..id = m['id'] as int?
    ..userId = m['user_id'] as int?
    ..postId = m['post_id'] as int?
    ..body = m['body'] as String?
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
    GqlSecret instance = this as GqlSecret;
    Map<String, dynamic> map = <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'post_id': instance.postId,
      'body': instance.body,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

    return map;
  }

  @override
  dynamic $columnValue(String column) {
    GqlSecret instance = this as GqlSecret;
    switch (column) {
      case 'id':
        return instance.id;
      case 'user_id':
        return instance.userId;
      case 'post_id':
        return instance.postId;
      case 'body':
        return instance.body;
      case 'created_at':
        return instance.createdAt?.toIso8601String();
      case 'updated_at':
        return instance.updatedAt?.toIso8601String();
    }
    return super.$columnValue(column);
  }

  @override
  Map<String, dynamic> convertToMap(dynamic i) {
    GqlSecret instance = i as GqlSecret;
    Map<String, dynamic> map = instance.columnsToMap();

    List<String> preload = getPreload();
    if (preload.contains('post')) {
      map['post'] = toMap(instance.post);
    }

    return map;
  }

  @override
  bool setColumnValue(String column, dynamic value) {
    GqlSecret instance = this as GqlSecret;
    switch (column) {
      case 'id':
        if (value is! int?) return false;
        instance.id = value;
        return true;
      case 'user_id':
        if (value is! int?) return false;
        instance.userId = value;
        return true;
      case 'post_id':
        if (value is! int?) return false;
        instance.postId = value;
        return true;
      case 'body':
        if (value is! String?) return false;
        instance.body = value;
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
  bool $copyColumnsFrom(Model<GqlSecret> other) {
    GqlSecret o = other as GqlSecret;
    (this as GqlSecret)
      ..id = o.id
      ..userId = o.userId
      ..postId = o.postId
      ..body = o.body
      ..createdAt = o.createdAt
      ..updatedAt = o.updatedAt;
    return true;
  }

  @override
  void writeJson(JsonWriter w) {
    List<String>? hide = $jsonHidden;
    // a class that extends the model can have its own toJson()
    if (hide == null || runtimeType != GqlSecret) {
      w.value(toJson());
      return;
    }
    bool all = hide.isEmpty;
    GqlSecret instance = this as GqlSecret;
    w.startObject();
    if (all || !hide.contains('id')) {
      w.key('id');
      w.integer(instance.id);
    }
    if (all || !hide.contains('user_id')) {
      w.key('user_id');
      w.integer(instance.userId);
    }
    if (all || !hide.contains('post_id')) {
      w.key('post_id');
      w.integer(instance.postId);
    }
    if (all || !hide.contains('body')) {
      w.key('body');
      w.string(instance.body);
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
    if (preload.contains('post') && (all || !hide.contains('post'))) {
      w.key('post');
      w.value(instance.post);
    }
    w.endObject();
  }
}
