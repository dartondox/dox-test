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
  Map<String, dynamic> get timestampsColumn => <String, dynamic>{
    'created_at': 'created_at',
    'updated_at': 'updated_at',
  };

  @override
  String get tableName => 'profiles';

  int? get id => tempIdValue;

  set id(dynamic val) => tempIdValue = val;

  Profile query() => Profile();

  @override
  List<String> get tableColumns => <String>[
    'id',
    'user_id',
    'bio',
    'website',
    'created_at',
    'updated_at',
  ];

  @override
  List<String> get preloadList => <String>[];

  @override
  Map<String, Function> get relationsResultMatcher => <String, Function>{
    'user': getUser,
  };

  @override
  Map<String, Function> get relationsQueryMatcher => <String, Function>{
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
    ..createdAt = m['created_at'] == null
        ? null
        : DateTime.parse(m['created_at'] as String)
    ..updatedAt = m['updated_at'] == null
        ? null
        : DateTime.parse(m['updated_at'] as String);

  @override
  Map<String, dynamic> convertToMap(dynamic i) {
    Profile instance = i as Profile;
    Map<String, dynamic> map = <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'bio': instance.bio,
      'website': instance.website,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

    List<String> preload = getPreload();
    if (preload.contains('user')) {
      map['user'] = toMap(instance.user);
    }

    return map;
  }
}
