// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.model.dart';

// **************************************************************************
// Generator: DoxModelBuilder
// **************************************************************************

// ignore_for_file: always_specify_types

class UserGenerator extends Model<User> {
  @override
  String get primaryKey => 'id';

  @override
  Map<String, dynamic> get timestampsColumn => <String, dynamic>{
    'created_at': 'created_at',
    'updated_at': 'updated_at',
  };

  @override
  String get tableName => 'users';

  int? get id => tempIdValue;

  set id(dynamic val) => tempIdValue = val;

  User query() => User();

  @override
  List<String> get tableColumns => <String>[
    'id',
    'name',
    'email',
    'password',
    'created_at',
    'updated_at',
  ];

  @override
  List<String> get preloadList => <String>[];

  @override
  Map<String, Function> get relationsResultMatcher => <String, Function>{
    'profile': getProfile,
    'posts': getPosts,
  };

  @override
  Map<String, Function> get relationsQueryMatcher => <String, Function>{
    'profile': queryProfile,
    'posts': queryPosts,
  };

  static Future<void> getProfile(List<Model<User>> list) async {
    var result = await getHasOne<User, Profile>(queryProfile(list), list);
    for (dynamic i in list) {
      if (result[i.tempIdValue.toString()] != null) {
        i.profile = result[i.tempIdValue.toString()]!;
      }
    }
  }

  static Profile? queryProfile(List<Model<User>> list) {
    return hasOne<User, Profile>(
      list,
      () => Profile(),
      foreignKey: 'user_id',
      localKey: 'id',
    );
  }

  static Future<void> getPosts(List<Model<User>> list) async {
    var result = await getHasMany<User, Post>(queryPosts(list), list);
    for (dynamic i in list) {
      if (result[i.tempIdValue.toString()] != null) {
        i.posts = result[i.tempIdValue.toString()]!;
      }
    }
  }

  static Post? queryPosts(List<Model<User>> list) {
    return hasMany<User, Post>(
      list,
      () => Post(),
      foreignKey: 'user_id',
      localKey: 'id',
    );
  }

  @override
  User fromMap(Map<String, dynamic> m) => User()
    ..id = m['id'] as int?
    ..name = m['name'] as String?
    ..email = m['email'] as String?
    ..password = m['password'] as String?
    ..createdAt = m['created_at'] == null
        ? null
        : DateTime.parse(m['created_at'] as String)
    ..updatedAt = m['updated_at'] == null
        ? null
        : DateTime.parse(m['updated_at'] as String);

  @override
  Map<String, dynamic> convertToMap(dynamic i) {
    User instance = i as User;
    Map<String, dynamic> map = <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

    List<String> preload = getPreload();
    if (preload.contains('profile')) {
      map['profile'] = toMap(instance.profile);
    }
    if (preload.contains('posts')) {
      map['posts'] = toMap(instance.posts);
    }

    return map;
  }
}
