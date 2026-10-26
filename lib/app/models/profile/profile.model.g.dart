// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.model.dart';

// **************************************************************************
// Generator: DoxModelBuilder
// **************************************************************************

// ignore_for_file: always_specify_types

class ProfileGenerator extends Model<Profile> {
  @override
  String get primaryKey => 'id';

  @override
  Map<String, dynamic> get timestampsColumn => const <String, dynamic>{
    'created_at': 'created_at',
    'updated_at': 'updated_at',
  };

  @override
  String get tableName => 'profiles';

  int? get id => tempIdValue as int?;

  set id(int? val) => tempIdValue = val;

  Profile query() => Profile();

  @override
  bool get readsRowDates => true;

  @override
  List<String> get tableColumns => const <String>[
    'id',
    'user_id',
    'bio',
    'website',
    'created_at',
    'updated_at',
  ];

  @override
  List<String> get preloadList => const <String>[];

  @override
  Map<String, Function> get relationsResultMatcher => const <String, Function>{
    'user': getUser,
  };

  @override
  Map<String, Function> get relationsQueryMatcher => const <String, Function>{
    'user': queryUser,
  };

  static Future<void> getUser(List<Model<Profile>> list) async {
    var result = await getBelongsTo<Profile, User>(queryUser(list), list);
    for (dynamic i in list) {
      if (result[i.tempIdValue.toString()] != null) {
        i.user = result[i.tempIdValue.toString()]!;
      }
    }
  }

  static User? queryUser(List<Model<Profile>> list) {
    return belongsTo<Profile, User>(
      list,
      () => User(),
      foreignKey: 'user_id',
      localKey: 'id',
    );
  }

  @override
  Profile fromMap(Map<String, dynamic> m) => Profile()
    ..id = m['id'] as int?
    ..userId = m['user_id'] as int?
    ..bio = m['bio'] as String?
    ..website = m['website'] as String?
    ..createdAt = m['created_at'] is DateTime?
        ? m['created_at'] as DateTime?
        : DateTime.parse(m['created_at'] as String)
    ..updatedAt = m['updated_at'] is DateTime?
        ? m['updated_at'] as DateTime?
        : DateTime.parse(m['updated_at'] as String);
  @override
  Map<String, dynamic> columnsToMap() {
    Profile instance = this as Profile;
    Map<String, dynamic> map = <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'bio': instance.bio,
      'website': instance.website,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

    return map;
  }

  @override
  Map<String, dynamic> convertToMap(dynamic i) {
    Profile instance = i as Profile;
    Map<String, dynamic> map = instance.columnsToMap();

    List<String> preload = getPreload();
    if (preload.contains('user')) {
      map['user'] = toMap(instance.user);
    }

    return map;
  }

  @override
  bool setColumnValue(String column, dynamic value) {
    Profile instance = this as Profile;
    switch (column) {
      case 'id':
        if (value is! int?) return false;
        instance.id = value;
        return true;
      case 'user_id':
        if (value is! int?) return false;
        instance.userId = value;
        return true;
      case 'bio':
        if (value is! String?) return false;
        instance.bio = value;
        return true;
      case 'website':
        if (value is! String?) return false;
        instance.website = value;
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
