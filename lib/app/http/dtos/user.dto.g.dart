// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dto.dart';

// **************************************************************************
// DoxDtoGenerator
// **************************************************************************

// ignore_for_file: type=lint

/// The checks, the converter and the JSON Schema of [ListUsers].
const DtoSchema<ListUsers> $ListUsersDto = _$ListUsersDto();

class _$ListUsersDto extends DtoSchema<ListUsers> {
  const _$ListUsersDto();

  static const Map<String, String> _m = <String, String>{};

  @override
  Type get type => ListUsers;

  @override
  String get name => 'ListUsers';

  @override
  ListUsers? convert(Object? input, DtoState s, List<Object> p) {
    if (input is! Map) {
      s.notObject(input, p, _m);
      return null;
    }
    int e = s.issues.length;
    // page: int
    Object? c0;
    c0 = s.integer(s.read(input, 'page'), p, 'page', _m);
    if (c0 == null) s.required(p, 'page', _m);
    // perPage: int
    Object? c1;
    c1 = s.integer(s.read(input, 'per_page'), p, 'per_page', _m);
    if (c1 == null) s.required(p, 'per_page', _m);
    // search: String?
    Object? c2;
    c2 = s.string(s.read(input, 'search'), p, 'search', _m, trim: true);
    if (s.issues.length != e) return null;
    if (c0 is int) {
      if (!(c0 >= 1)) {
        s.fail(
          p,
          'page',
          IssueCodes.min,
          DefaultMessages.min,
          c0,
          params: const <String, Object?>{'min': 1},
          messages: _m,
        );
      }
    }
    if (c1 is int) {
      if (!(c1 >= 1)) {
        s.fail(
          p,
          'per_page',
          IssueCodes.min,
          DefaultMessages.min,
          c1,
          params: const <String, Object?>{'min': 1},
          messages: _m,
        );
      } else if (!(c1 <= 100)) {
        s.fail(
          p,
          'per_page',
          IssueCodes.max,
          DefaultMessages.max,
          c1,
          params: const <String, Object?>{'max': 100},
          messages: _m,
        );
      }
    }
    if (s.issues.length != e) return null;
    return ListUsers(
      page: c0 is Undefined ? 1 : c0 as int,
      perPage: c1 is Undefined ? AppConstants.defaultPerPage : c1 as int,
      search: c2 is Undefined ? null : c2 as String?,
    );
  }

  @override
  ListUsers fromMap(Map<String, dynamic> m) {
    return ListUsers(
      page: m.containsKey('page') ? (m['page'] as num).toInt() : 1,
      perPage: m.containsKey('per_page')
          ? (m['per_page'] as num).toInt()
          : AppConstants.defaultPerPage,
      search: m['search'] == null ? null : (m['search'] as String),
    );
  }

  @override
  Map<String, dynamic> toMap(ListUsers o) {
    int f0 = o.page;
    int f1 = o.perPage;
    String? f2 = o.search;
    return <String, dynamic>{'page': f0, 'per_page': f1, 'search': f2};
  }

  @override
  Map<String, dynamic> toJsonSchema() {
    return <String, dynamic>{
      'type': 'object',
      'title': 'ListUsers',
      'properties': <String, dynamic>{
        'page': <String, dynamic>{
          'type': 'integer',
          'minimum': 1,
          'default': 1,
        },
        'per_page': <String, dynamic>{
          'type': 'integer',
          'minimum': 1,
          'maximum': 100,
          'default': 10,
        },
        'search': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
          'description': 'Part of the name or the email.',
        },
      },
    };
  }
}

/// The checks, the converter and the JSON Schema of [UpdateUser].
const DtoSchema<UpdateUser> $UpdateUserDto = _$UpdateUserDto();

class _$UpdateUserDto extends DtoSchema<UpdateUser> {
  const _$UpdateUserDto();

  static const Map<String, String> _m = <String, String>{};

  @override
  Type get type => UpdateUser;

  @override
  String get name => 'UpdateUser';

  @override
  bool get isAsync => true;

  @override
  UpdateUser? convert(Object? input, DtoState s, List<Object> p) {
    if (input is! Map) {
      s.notObject(input, p, _m);
      return null;
    }
    int e = s.issues.length;
    // name: String
    Object? c0;
    c0 = s.string(s.read(input, 'name'), p, 'name', _m, trim: true);
    if (c0 == null || c0 is Undefined) s.required(p, 'name', _m);
    // email: String
    Object? c1;
    c1 = s.string(
      s.read(input, 'email'),
      p,
      'email',
      _m,
      trim: true,
      textCase: 1,
    );
    if (c1 == null || c1 is Undefined) s.required(p, 'email', _m);
    if (s.issues.length != e) return null;
    if (c0 is String) {
      if (!(c0.runes.length >= 2 && c0.runes.length <= 100)) {
        s.fail(
          p,
          'name',
          IssueCodes.lengthBetween,
          DefaultMessages.lengthBetween,
          c0,
          params: const <String, Object?>{'min': 2, 'max': 100},
          messages: _m,
        );
      }
    }
    if (c1 is String) {
      if (!(Patterns.email.hasMatch(c1))) {
        s.fail(
          p,
          'email',
          IssueCodes.email,
          DefaultMessages.email,
          c1,
          messages: _m,
        );
      }
    }
    if (s.issues.length != e) return null;
    return UpdateUser(name: c0 as String, email: c1 as String);
  }

  @override
  Future<void> checkAsync(UpdateUser o, DtoState s, List<Object> p) async {
    {
      String f = o.email;
      await s.asyncRule(
        const Unique('users', column: 'email', ignoreParam: 'id'),
        f,
        p,
        'email',
        _m,
      );
    }
  }

  @override
  UpdateUser fromMap(Map<String, dynamic> m) {
    return UpdateUser(name: m['name'] as String, email: m['email'] as String);
  }

  @override
  Map<String, dynamic> toMap(UpdateUser o) {
    String f0 = o.name;
    String f1 = o.email;
    return <String, dynamic>{'name': f0, 'email': f1};
  }

  @override
  Map<String, dynamic> toJsonSchema() {
    Map<String, dynamic> j = <String, dynamic>{
      'type': 'object',
      'title': 'UpdateUser',
      'properties': <String, dynamic>{
        'name': <String, dynamic>{
          'type': 'string',
          'minLength': 2,
          'maxLength': 100,
        },
        'email': <String, dynamic>{
          'type': 'string',
          'format': 'email',
          'description': 'Must be free, but the user may keep its own email.',
        },
      },
      'required': <dynamic>['name', 'email'],
    };
    JsonSchemaTools.merge(
      j,
      <String>['properties', 'email'],
      const Unique('users', column: 'email', ignoreParam: 'id').toJsonSchema(),
    );
    return j;
  }
}

/// The checks, the converter and the JSON Schema of [SaveProfile].
const DtoSchema<SaveProfile> $SaveProfileDto = _$SaveProfileDto();

class _$SaveProfileDto extends DtoSchema<SaveProfile> {
  const _$SaveProfileDto();

  static const Map<String, String> _m = <String, String>{};

  @override
  Type get type => SaveProfile;

  @override
  String get name => 'SaveProfile';

  @override
  SaveProfile? convert(Object? input, DtoState s, List<Object> p) {
    if (input is! Map) {
      s.notObject(input, p, _m);
      return null;
    }
    int e = s.issues.length;
    // bio: String?
    Object? c0;
    c0 = s.string(s.read(input, 'bio'), p, 'bio', _m);
    // website: String?
    Object? c1;
    c1 = s.string(s.read(input, 'website'), p, 'website', _m);
    if (s.issues.length != e) return null;
    if (c0 is String) {
      if (!(c0.runes.length <= 500)) {
        s.fail(
          p,
          'bio',
          IssueCodes.maxLength,
          DefaultMessages.maxLength,
          c0,
          params: const <String, Object?>{'max': 500},
          messages: _m,
        );
      }
    }
    if (c1 is String) {
      if (!(DtoChecks.url(c1))) {
        s.fail(
          p,
          'website',
          IssueCodes.url,
          DefaultMessages.url,
          c1,
          messages: _m,
        );
      }
    }
    if (s.issues.length != e) return null;
    return SaveProfile(
      bio: c0 is Undefined ? null : c0 as String?,
      website: c1 is Undefined ? null : c1 as String?,
    );
  }

  @override
  SaveProfile fromMap(Map<String, dynamic> m) {
    return SaveProfile(
      bio: m['bio'] == null ? null : (m['bio'] as String),
      website: m['website'] == null ? null : (m['website'] as String),
    );
  }

  @override
  Map<String, dynamic> toMap(SaveProfile o) {
    String? f0 = o.bio;
    String? f1 = o.website;
    return <String, dynamic>{'bio': f0, 'website': f1};
  }

  @override
  Map<String, dynamic> toJsonSchema() {
    return <String, dynamic>{
      'type': 'object',
      'title': 'SaveProfile',
      'properties': <String, dynamic>{
        'bio': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
          'maxLength': 500,
        },
        'website': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
          'format': 'uri',
        },
      },
    };
  }
}

/// The checks, the converter and the JSON Schema of [PatchProfile].
const DtoSchema<PatchProfile> $PatchProfileDto = _$PatchProfileDto();

class _$PatchProfileDto extends DtoSchema<PatchProfile> {
  const _$PatchProfileDto();

  static const Map<String, String> _m = <String, String>{};

  @override
  Type get type => PatchProfile;

  @override
  String get name => 'PatchProfile';

  @override
  PatchProfile? convert(Object? input, DtoState s, List<Object> p) {
    if (input is! Map) {
      s.notObject(input, p, _m);
      return null;
    }
    int e = s.issues.length;
    // bio: Maybe<String?>
    Object? c0;
    c0 = s.string(s.read(input, 'bio'), p, 'bio', _m);
    // website: Maybe<String?>
    Object? c1;
    c1 = s.string(s.read(input, 'website'), p, 'website', _m);
    if (s.issues.length != e) return null;
    if (c0 is String) {
      if (!(c0.runes.length <= 500)) {
        s.fail(
          p,
          'bio',
          IssueCodes.maxLength,
          DefaultMessages.maxLength,
          c0,
          params: const <String, Object?>{'max': 500},
          messages: _m,
        );
      }
    }
    if (c1 is String) {
      if (!(DtoChecks.url(c1))) {
        s.fail(
          p,
          'website',
          IssueCodes.url,
          DefaultMessages.url,
          c1,
          messages: _m,
        );
      }
    }
    if (s.issues.length != e) return null;
    return PatchProfile(
      bio: c0 is Undefined
          ? const Maybe<String?>.missing()
          : Maybe<String?>(c0 as String?),
      website: c1 is Undefined
          ? const Maybe<String?>.missing()
          : Maybe<String?>(c1 as String?),
    );
  }

  @override
  PatchProfile fromMap(Map<String, dynamic> m) {
    return PatchProfile(
      bio: m.containsKey('bio')
          ? Maybe<String?>(m['bio'] == null ? null : (m['bio'] as String))
          : const Maybe<String?>.missing(),
      website: m.containsKey('website')
          ? Maybe<String?>(
              m['website'] == null ? null : (m['website'] as String),
            )
          : const Maybe<String?>.missing(),
    );
  }

  @override
  Map<String, dynamic> toMap(PatchProfile o) {
    Maybe<String?> f0 = o.bio;
    Maybe<String?> f1 = o.website;
    return <String, dynamic>{
      if (f0 case Maybe<String?>(isPresent: true, value: String? g0)) 'bio': g0,
      if (f1 case Maybe<String?>(isPresent: true, value: String? g1))
        'website': g1,
    };
  }

  @override
  Map<String, dynamic> toJsonSchema() {
    return <String, dynamic>{
      'type': 'object',
      'title': 'PatchProfile',
      'properties': <String, dynamic>{
        'bio': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
          'maxLength': 500,
        },
        'website': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
          'format': 'uri',
        },
      },
    };
  }
}
