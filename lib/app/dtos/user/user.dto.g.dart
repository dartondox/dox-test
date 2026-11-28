// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dto.dart';

// **************************************************************************
// DoxDtoGenerator
// **************************************************************************

// ignore_for_file: type=lint

/// The checks, the converter and the JSON Schema of [ListUsers].
const DtoSchema<ListUsers> $ListUsersDto = _$ListUsersDto();

class _$ListUsersDto extends DtoSchema<ListUsers> implements JsonObjectWriter {
  const _$ListUsersDto();

  static const Map<String, String> _messages = <String, String>{};

  @override
  Type get type => ListUsers;

  @override
  String get name => 'ListUsers';

  @override
  bool get usesRequiredWhen => false;

  @override
  ListUsers? convert(Object? input, DtoState state, List<Object> path) {
    if (input is! Map) {
      state.notObject(input, path, _messages);
      return null;
    }
    int issuesBefore = state.issues.length;
    // page: int
    Object? page = state.integer(
      state.read(input, 'page'),
      path,
      'page',
      _messages,
    );
    if (page == null) state.required(path, 'page', _messages);
    // perPage: int
    Object? perPage = state.integer(
      state.read(input, 'per_page'),
      path,
      'per_page',
      _messages,
    );
    if (perPage == null) state.required(path, 'per_page', _messages);
    // search: String?
    Object? search = state.string(
      state.read(input, 'search'),
      path,
      'search',
      _messages,
      trim: true,
    );
    if (state.issues.length != issuesBefore && !state.allErrors) return null;
    if (page is int) {
      if (!(page >= 1)) {
        state.fail(
          path,
          'page',
          IssueCodes.min,
          DefaultMessages.min,
          page,
          params: const <String, Object?>{'min': 1},
          messages: _messages,
        );
      }
    }
    if (perPage is int) {
      if (!(perPage >= 1)) {
        state.fail(
          path,
          'per_page',
          IssueCodes.min,
          DefaultMessages.min,
          perPage,
          params: const <String, Object?>{'min': 1},
          messages: _messages,
        );
      } else if (!(perPage <= 100)) {
        state.fail(
          path,
          'per_page',
          IssueCodes.max,
          DefaultMessages.max,
          perPage,
          params: const <String, Object?>{'max': 100},
          messages: _messages,
        );
      }
    }
    if (state.issues.length != issuesBefore) return null;
    return ListUsers(
      page: page is Undefined ? 1 : page as int,
      perPage: perPage is Undefined
          ? AppConstants.defaultPerPage
          : perPage as int,
      search: search is Undefined ? null : search as String?,
    );
  }

  @override
  ListUsers fromMap(Map<String, dynamic> map) {
    return ListUsers(
      page: map.containsKey('page') ? (map['page'] as num).toInt() : 1,
      perPage: map.containsKey('per_page')
          ? (map['per_page'] as num).toInt()
          : AppConstants.defaultPerPage,
      search: map['search'] == null ? null : (map['search'] as String),
    );
  }

  @override
  Map<String, dynamic> toMap(ListUsers dto) {
    return <String, dynamic>{
      'page': dto.page,
      'per_page': dto.perPage,
      'search': dto.search,
    };
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as ListUsers));

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

class _$UpdateUserDto extends DtoSchema<UpdateUser>
    implements JsonObjectWriter {
  const _$UpdateUserDto();

  static const Map<String, String> _messages = <String, String>{};

  @override
  Type get type => UpdateUser;

  @override
  String get name => 'UpdateUser';

  @override
  bool get usesRequiredWhen => false;

  @override
  bool get isAsync => true;

  @override
  UpdateUser? convert(Object? input, DtoState state, List<Object> path) {
    if (input is! Map) {
      state.notObject(input, path, _messages);
      return null;
    }
    int issuesBefore = state.issues.length;
    // name: String
    Object? name = state.string(
      state.read(input, 'name'),
      path,
      'name',
      _messages,
      trim: true,
    );
    if (name == null || name is Undefined)
      state.required(path, 'name', _messages);
    // email: String
    Object? email = state.string(
      state.read(input, 'email'),
      path,
      'email',
      _messages,
      trim: true,
      textCase: 1,
    );
    if (email == null || email is Undefined)
      state.required(path, 'email', _messages);
    if (state.issues.length != issuesBefore && !state.allErrors) return null;
    if (name is String) {
      if (!(name.runes.length >= 2 && name.runes.length <= 100)) {
        state.fail(
          path,
          'name',
          IssueCodes.lengthBetween,
          DefaultMessages.lengthBetween,
          name,
          params: const <String, Object?>{'min': 2, 'max': 100},
          messages: _messages,
        );
      }
    }
    if (email is String) {
      if (!(Patterns.email.hasMatch(email))) {
        state.fail(
          path,
          'email',
          IssueCodes.email,
          DefaultMessages.email,
          email,
          messages: _messages,
        );
      }
    }
    if (state.issues.length != issuesBefore) return null;
    return UpdateUser(name: name as String, email: email as String);
  }

  @override
  Future<void> checkAsync(
    UpdateUser dto,
    DtoState state,
    List<Object> path,
  ) async {
    {
      String value = dto.email;
      await state.asyncRule(
        const Unique('users', column: 'email', ignoreParam: 'id'),
        value,
        path,
        'email',
        _messages,
      );
    }
  }

  @override
  UpdateUser fromMap(Map<String, dynamic> map) {
    return UpdateUser(
      name: map['name'] as String,
      email: map['email'] as String,
    );
  }

  @override
  Map<String, dynamic> toMap(UpdateUser dto) {
    return <String, dynamic>{'name': dto.name, 'email': dto.email};
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as UpdateUser));

  @override
  Map<String, dynamic> toJsonSchema() {
    Map<String, dynamic> schema = <String, dynamic>{
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
      schema,
      <String>['properties', 'email'],
      const Unique('users', column: 'email', ignoreParam: 'id').toJsonSchema(),
    );
    return schema;
  }
}

/// The checks, the converter and the JSON Schema of [SaveProfile].
const DtoSchema<SaveProfile> $SaveProfileDto = _$SaveProfileDto();

class _$SaveProfileDto extends DtoSchema<SaveProfile>
    implements JsonObjectWriter {
  const _$SaveProfileDto();

  static const Map<String, String> _messages = <String, String>{};

  @override
  Type get type => SaveProfile;

  @override
  String get name => 'SaveProfile';

  @override
  bool get usesRequiredWhen => false;

  @override
  SaveProfile? convert(Object? input, DtoState state, List<Object> path) {
    if (input is! Map) {
      state.notObject(input, path, _messages);
      return null;
    }
    int issuesBefore = state.issues.length;
    // bio: String?
    Object? bio = state.string(
      state.read(input, 'bio'),
      path,
      'bio',
      _messages,
    );
    // website: String?
    Object? website = state.string(
      state.read(input, 'website'),
      path,
      'website',
      _messages,
    );
    if (state.issues.length != issuesBefore && !state.allErrors) return null;
    if (bio is String) {
      if (!(bio.runes.length <= 500)) {
        state.fail(
          path,
          'bio',
          IssueCodes.maxLength,
          DefaultMessages.maxLength,
          bio,
          params: const <String, Object?>{'max': 500},
          messages: _messages,
        );
      }
    }
    if (website is String) {
      if (!(DtoChecks.url(website))) {
        state.fail(
          path,
          'website',
          IssueCodes.url,
          DefaultMessages.url,
          website,
          messages: _messages,
        );
      }
    }
    if (state.issues.length != issuesBefore) return null;
    return SaveProfile(
      bio: bio is Undefined ? null : bio as String?,
      website: website is Undefined ? null : website as String?,
    );
  }

  @override
  SaveProfile fromMap(Map<String, dynamic> map) {
    return SaveProfile(
      bio: map['bio'] == null ? null : (map['bio'] as String),
      website: map['website'] == null ? null : (map['website'] as String),
    );
  }

  @override
  Map<String, dynamic> toMap(SaveProfile dto) {
    return <String, dynamic>{'bio': dto.bio, 'website': dto.website};
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as SaveProfile));

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

class _$PatchProfileDto extends DtoSchema<PatchProfile>
    implements JsonObjectWriter {
  const _$PatchProfileDto();

  static const Map<String, String> _messages = <String, String>{};

  @override
  Type get type => PatchProfile;

  @override
  String get name => 'PatchProfile';

  @override
  bool get usesRequiredWhen => false;

  @override
  PatchProfile? convert(Object? input, DtoState state, List<Object> path) {
    if (input is! Map) {
      state.notObject(input, path, _messages);
      return null;
    }
    int issuesBefore = state.issues.length;
    // bio: Maybe<String?>
    Object? bio = state.string(
      state.read(input, 'bio'),
      path,
      'bio',
      _messages,
    );
    // website: Maybe<String?>
    Object? website = state.string(
      state.read(input, 'website'),
      path,
      'website',
      _messages,
    );
    if (state.issues.length != issuesBefore && !state.allErrors) return null;
    if (bio is String) {
      if (!(bio.runes.length <= 500)) {
        state.fail(
          path,
          'bio',
          IssueCodes.maxLength,
          DefaultMessages.maxLength,
          bio,
          params: const <String, Object?>{'max': 500},
          messages: _messages,
        );
      }
    }
    if (website is String) {
      if (!(DtoChecks.url(website))) {
        state.fail(
          path,
          'website',
          IssueCodes.url,
          DefaultMessages.url,
          website,
          messages: _messages,
        );
      }
    }
    if (state.issues.length != issuesBefore) return null;
    return PatchProfile(
      bio: bio is Undefined
          ? const Maybe<String?>.missing()
          : Maybe<String?>(bio as String?),
      website: website is Undefined
          ? const Maybe<String?>.missing()
          : Maybe<String?>(website as String?),
    );
  }

  @override
  PatchProfile fromMap(Map<String, dynamic> map) {
    return PatchProfile(
      bio: map.containsKey('bio')
          ? Maybe<String?>(map['bio'] == null ? null : (map['bio'] as String))
          : const Maybe<String?>.missing(),
      website: map.containsKey('website')
          ? Maybe<String?>(
              map['website'] == null ? null : (map['website'] as String),
            )
          : const Maybe<String?>.missing(),
    );
  }

  @override
  Map<String, dynamic> toMap(PatchProfile dto) {
    return <String, dynamic>{
      if (dto.bio case Maybe<String?>(isPresent: true, value: String? bio))
        'bio': bio,
      if (dto.website case Maybe<String?>(
        isPresent: true,
        value: String? website,
      ))
        'website': website,
    };
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as PatchProfile));

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
