// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.model.dart';

// **************************************************************************
// Generator: DoxModelBuilder
// **************************************************************************

// ignore_for_file: always_specify_types

class UserGenerator extends Model<User> implements JsonWritable {
  @override
  String get primaryKey => 'id';

  @override
  Map<String, dynamic> get timestampsColumn => const <String, dynamic>{
    'created_at': 'created_at',
    'updated_at': 'updated_at',
  };

  @override
  String get tableName => 'users';

  int? get id => tempIdValue as int?;

  set id(int? val) => tempIdValue = val;

  User query() => User();

  @override
  bool get readsRowDates => true;

  @override
  List<String> get tableColumns => const <String>[
    'id',
    'name',
    'email',
    'password',
    'first_name',
    'last_name',
    'created_at',
    'updated_at',
  ];

  @override
  List<String> get preloadList => const <String>[];

  @override
  Map<String, Function> get relationsResultMatcher => const <String, Function>{
    'profile': getProfile,
    'posts': getPosts,
  };

  @override
  Map<String, Function> get relationsQueryMatcher => const <String, Function>{
    'profile': queryProfile,
    'posts': queryPosts,
  };

  static Future<void> getProfile(List<Model<User>> list) async {
    var result = await getHasOne<User, Profile>(queryProfile(list), list);
    for (dynamic i in list) {
      i.profile = result[i.tempIdValue.toString()];
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
      i.posts = result[i.tempIdValue.toString()] ?? <Post>[];
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
    ..firstName = m['first_name'] as String?
    ..lastName = m['last_name'] as String?
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
    User instance = this as User;
    Map<String, dynamic> map = <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

    return map;
  }

  @override
  dynamic $columnValue(String column) {
    User instance = this as User;
    switch (column) {
      case 'id':
        return instance.id;
      case 'name':
        return instance.name;
      case 'email':
        return instance.email;
      case 'password':
        return instance.password;
      case 'first_name':
        return instance.firstName;
      case 'last_name':
        return instance.lastName;
      case 'created_at':
        return instance.createdAt?.toIso8601String();
      case 'updated_at':
        return instance.updatedAt?.toIso8601String();
    }
    return super.$columnValue(column);
  }

  @override
  Map<String, dynamic> convertToMap(dynamic i) {
    User instance = i as User;
    Map<String, dynamic> map = instance.columnsToMap();

    List<String> preload = getPreload();
    if (preload.contains('profile')) {
      map['profile'] = toMap(instance.profile);
    }
    if (preload.contains('posts')) {
      map['posts'] = toMap(instance.posts);
    }

    return map;
  }

  @override
  bool setColumnValue(String column, dynamic value) {
    User instance = this as User;
    switch (column) {
      case 'id':
        if (value is! int?) return false;
        instance.id = value;
        return true;
      case 'name':
        if (value is! String?) return false;
        instance.name = value;
        return true;
      case 'email':
        if (value is! String?) return false;
        instance.email = value;
        return true;
      case 'password':
        if (value is! String?) return false;
        instance.password = value;
        return true;
      case 'first_name':
        if (value is! String?) return false;
        instance.firstName = value;
        return true;
      case 'last_name':
        if (value is! String?) return false;
        instance.lastName = value;
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
  bool $copyColumnsFrom(Model<User> other) {
    User o = other as User;
    (this as User)
      ..id = o.id
      ..name = o.name
      ..email = o.email
      ..password = o.password
      ..firstName = o.firstName
      ..lastName = o.lastName
      ..createdAt = o.createdAt
      ..updatedAt = o.updatedAt;
    return true;
  }

  @override
  void setComputedValues(Map<String, dynamic> map) {
    User instance = this as User;
    map['full_name'] = instance.fullName;
  }

  @override
  void writeJson(JsonWriter w) {
    List<String>? hide = $jsonHidden;
    // a class that extends the model can have its own toJson()
    if (hide == null || runtimeType != User) {
      w.value(toJson());
      return;
    }
    bool all = hide.isEmpty;
    User instance = this as User;
    w.startObject();
    if (all || !hide.contains('id')) {
      w.key('id');
      w.integer(instance.id);
    }
    if (all || !hide.contains('name')) {
      w.key('name');
      w.string(instance.name);
    }
    if (all || !hide.contains('email')) {
      w.key('email');
      w.string(instance.email);
    }
    if (all || !hide.contains('password')) {
      w.key('password');
      w.string(instance.password);
    }
    if (all || !hide.contains('first_name')) {
      w.key('first_name');
      w.string(instance.firstName);
    }
    if (all || !hide.contains('last_name')) {
      w.key('last_name');
      w.string(instance.lastName);
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
    if (preload.contains('profile') && (all || !hide.contains('profile'))) {
      w.key('profile');
      w.value(instance.profile);
    }
    if (preload.contains('posts') && (all || !hide.contains('posts'))) {
      w.key('posts');
      w.value(instance.posts);
    }
    if (all || !hide.contains('full_name')) {
      w.key('full_name');
      w.value(instance.fullName);
    }
    w.endObject();
  }
}
