// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth.dto.dart';

// **************************************************************************
// DoxDtoGenerator
// **************************************************************************

// ignore_for_file: type=lint

/// The checks, the converter and the JSON Schema of [RegisterUser].
const DtoSchema<RegisterUser> $RegisterUserDto = _$RegisterUserDto();

class _$RegisterUserDto extends DtoSchema<RegisterUser>
    implements JsonObjectWriter {
  const _$RegisterUserDto();

  static const Map<String, String> _messages = <String, String>{
    'required': '{field} is missing',
  };

  @override
  Type get type => RegisterUser;

  @override
  String get name => 'RegisterUser';

  @override
  bool get hasChecks => true;

  @override
  bool get usesRequiredWhen => false;

  @override
  bool get isAsync => true;

  @override
  RegisterUser? convert(Object? input, DtoState state, List<Object> path) {
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
    // password: String
    Object? password = state.string(
      state.read(input, 'password'),
      path,
      'password',
      _messages,
    );
    if (password == null || password is Undefined)
      state.required(path, 'password', _messages);
    // passwordConfirmation: String
    Object? passwordConfirmation = state.string(
      state.read(input, 'password_confirmation'),
      path,
      'password_confirmation',
      _messages,
    );
    if (passwordConfirmation == null || passwordConfirmation is Undefined)
      state.required(path, 'password_confirmation', _messages);
    // firstName: String?
    Object? firstName = state.string(
      state.read(input, 'first_name'),
      path,
      'first_name',
      _messages,
      trim: true,
    );
    // lastName: String?
    Object? lastName = state.string(
      state.read(input, 'last_name'),
      path,
      'last_name',
      _messages,
      trim: true,
    );
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
    if (password is String) {
      if (!(password.runes.length >= 6)) {
        state.fail(
          path,
          'password',
          IssueCodes.minLength,
          DefaultMessages.minLength,
          password,
          params: const <String, Object?>{'min': 6},
          messages: _messages,
        );
      }
    }
    if (firstName is String) {
      if (!(firstName.runes.length <= 100)) {
        state.fail(
          path,
          'first_name',
          IssueCodes.maxLength,
          DefaultMessages.maxLength,
          firstName,
          params: const <String, Object?>{'max': 100},
          messages: _messages,
        );
      }
    }
    if (lastName is String) {
      if (!(lastName.runes.length <= 100)) {
        state.fail(
          path,
          'last_name',
          IssueCodes.maxLength,
          DefaultMessages.maxLength,
          lastName,
          params: const <String, Object?>{'max': 100},
          messages: _messages,
        );
      }
    }
    if (state.issues.length != issuesBefore) return null;
    return RegisterUser(
      name: name as String,
      email: email as String,
      password: password as String,
      passwordConfirmation: passwordConfirmation as String,
      firstName: firstName is Undefined ? null : firstName as String?,
      lastName: lastName is Undefined ? null : lastName as String?,
    );
  }

  @override
  void crossCheck(RegisterUser dto, DtoState state, List<Object> path) {
    dto.validate(DtoErrors(state, path));
  }

  @override
  Future<void> checkAsync(
    RegisterUser dto,
    DtoState state,
    List<Object> path,
  ) async {
    {
      String value = dto.email;
      await state.asyncRule(
        const Unique('users', column: 'email'),
        value,
        path,
        'email',
        _messages,
      );
    }
  }

  @override
  RegisterUser fromMap(Map<String, dynamic> map) {
    return RegisterUser(
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      passwordConfirmation: map['password_confirmation'] as String,
      firstName: map['first_name'] == null
          ? null
          : (map['first_name'] as String),
      lastName: map['last_name'] == null ? null : (map['last_name'] as String),
    );
  }

  @override
  Map<String, dynamic> toMap(RegisterUser dto) {
    return <String, dynamic>{
      'name': dto.name,
      'email': dto.email,
      'password': dto.password,
      'password_confirmation': dto.passwordConfirmation,
      'first_name': dto.firstName,
      'last_name': dto.lastName,
    };
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as RegisterUser));

  @override
  Map<String, dynamic> toJsonSchema() {
    Map<String, dynamic> schema = <String, dynamic>{
      'type': 'object',
      'title': 'RegisterUser',
      'properties': <String, dynamic>{
        'name': <String, dynamic>{
          'type': 'string',
          'minLength': 2,
          'maxLength': 100,
        },
        'email': <String, dynamic>{'type': 'string', 'format': 'email'},
        'password': <String, dynamic>{'type': 'string', 'minLength': 6},
        'password_confirmation': <String, dynamic>{
          'type': 'string',
          'description': 'Must be the same as `password`.',
        },
        'first_name': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
          'maxLength': 100,
        },
        'last_name': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
          'maxLength': 100,
        },
      },
      'required': <dynamic>[
        'name',
        'email',
        'password',
        'password_confirmation',
      ],
    };
    JsonSchemaTools.merge(schema, <String>[
      'properties',
      'email',
    ], const Unique('users', column: 'email').toJsonSchema());
    return schema;
  }
}

/// The checks, the converter and the JSON Schema of [LoginUser].
const DtoSchema<LoginUser> $LoginUserDto = _$LoginUserDto();

class _$LoginUserDto extends DtoSchema<LoginUser> implements JsonObjectWriter {
  const _$LoginUserDto();

  static const Map<String, String> _messages = <String, String>{};

  @override
  Type get type => LoginUser;

  @override
  String get name => 'LoginUser';

  @override
  bool get usesRequiredWhen => false;

  @override
  LoginUser? convert(Object? input, DtoState state, List<Object> path) {
    if (input is! Map) {
      state.notObject(input, path, _messages);
      return null;
    }
    int issuesBefore = state.issues.length;
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
    // password: String
    Object? password = state.string(
      state.read(input, 'password'),
      path,
      'password',
      _messages,
    );
    if (password == null || password is Undefined)
      state.required(path, 'password', _messages);
    if (state.issues.length != issuesBefore && !state.allErrors) return null;
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
    return LoginUser(email: email as String, password: password as String);
  }

  @override
  LoginUser fromMap(Map<String, dynamic> map) {
    return LoginUser(
      email: map['email'] as String,
      password: map['password'] as String,
    );
  }

  @override
  Map<String, dynamic> toMap(LoginUser dto) {
    return <String, dynamic>{'email': dto.email, 'password': dto.password};
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as LoginUser));

  @override
  Map<String, dynamic> toJsonSchema() {
    return <String, dynamic>{
      'type': 'object',
      'title': 'LoginUser',
      'properties': <String, dynamic>{
        'email': <String, dynamic>{'type': 'string', 'format': 'email'},
        'password': <String, dynamic>{'type': 'string'},
      },
      'required': <dynamic>['email', 'password'],
    };
  }
}
