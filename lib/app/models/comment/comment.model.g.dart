// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.model.dart';

// **************************************************************************
// Generator: DoxModelBuilder
// **************************************************************************

// ignore_for_file: always_specify_types

class CommentGenerator extends Model<Comment> {
  @override
  String get primaryKey => 'id';

  @override
  Map<String, dynamic> get timestampsColumn => const <String, dynamic>{
    'created_at': 'created_at',
    'updated_at': 'updated_at',
  };

  @override
  String get tableName => 'comments';

  int? get id => tempIdValue as int?;

  set id(int? val) => tempIdValue = val;

  Comment query() => Comment();

  @override
  bool get readsRowDates => true;

  @override
  List<String> get tableColumns => const <String>[
    'id',
    'post_id',
    'user_id',
    'body',
    'created_at',
    'updated_at',
  ];

  @override
  List<String> get preloadList => const <String>['user'];

  @override
  Map<String, Function> get relationsResultMatcher => const <String, Function>{
    'user': getUser,
  };

  @override
  Map<String, Function> get relationsQueryMatcher => const <String, Function>{
    'user': queryUser,
  };

  static Future<void> getUser(List<Model<Comment>> list) async {
    var result = await getBelongsTo<Comment, User>(queryUser(list), list);
    for (dynamic i in list) {
      if (result[i.tempIdValue.toString()] != null) {
        i.user = result[i.tempIdValue.toString()]!;
      }
    }
  }

  static User? queryUser(List<Model<Comment>> list) {
    return belongsTo<Comment, User>(
      list,
      () => User(),
      foreignKey: 'user_id',
      localKey: 'id',
    );
  }

  @override
  Comment fromMap(Map<String, dynamic> m) => Comment()
    ..id = m['id'] as int?
    ..postId = m['post_id'] as int?
    ..userId = m['user_id'] as int?
    ..body = m['body'] as String?
    ..createdAt = m['created_at'] is DateTime?
        ? m['created_at'] as DateTime?
        : DateTime.parse(m['created_at'] as String)
    ..updatedAt = m['updated_at'] is DateTime?
        ? m['updated_at'] as DateTime?
        : DateTime.parse(m['updated_at'] as String);
  @override
  Map<String, dynamic> columnsToMap() {
    Comment instance = this as Comment;
    Map<String, dynamic> map = <String, dynamic>{
      'id': instance.id,
      'post_id': instance.postId,
      'user_id': instance.userId,
      'body': instance.body,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

    return map;
  }

  @override
  Map<String, dynamic> convertToMap(dynamic i) {
    Comment instance = i as Comment;
    Map<String, dynamic> map = instance.columnsToMap();
    map['user'] = toMap(instance.user);

    return map;
  }

  @override
  bool setColumnValue(String column, dynamic value) {
    Comment instance = this as Comment;
    switch (column) {
      case 'id':
        if (value is! int?) return false;
        instance.id = value;
        return true;
      case 'post_id':
        if (value is! int?) return false;
        instance.postId = value;
        return true;
      case 'user_id':
        if (value is! int?) return false;
        instance.userId = value;
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
}
