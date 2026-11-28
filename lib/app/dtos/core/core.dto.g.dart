// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core.dto.dart';

// **************************************************************************
// DoxDtoGenerator
// **************************************************************************

// ignore_for_file: type=lint

/// The checks, the converter and the JSON Schema of [CreateToken].
const DtoSchema<CreateToken> $CreateTokenDto = _$CreateTokenDto();

class _$CreateTokenDto extends DtoSchema<CreateToken>
    implements JsonObjectWriter {
  const _$CreateTokenDto();

  static const Map<String, String> _messages = <String, String>{};

  @override
  Type get type => CreateToken;

  @override
  String get name => 'CreateToken';

  @override
  bool get usesRequiredWhen => false;

  @override
  CreateToken? convert(Object? input, DtoState state, List<Object> path) {
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
    // abilities: List<String>
    Object? abilities = state.list(
      state.read(input, 'abilities'),
      path,
      'abilities',
      _messages,
    );
    if (abilities is List) {
      int b0 = state.issues.length;
      List<Object> q0 = <Object>[...path, 'abilities'];
      List<String> o0 = <String>[];
      for (int i0 = 0; i0 < abilities.length; i0++) {
        Object? x0 = state.string(abilities[i0], q0, i0, _messages);
        if (x0 == null || x0 is Undefined) {
          state.required(q0, i0, _messages);
        } else if (x0 is! Invalid) {
          o0.add(x0 as String);
        }
      }
      abilities = state.issues.length != b0 ? invalid : o0;
    }
    if (abilities == null ||
        abilities is Undefined ||
        state.emptyList(abilities)) {
      state.required(path, 'abilities', _messages);
      abilities = invalid;
    }
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
    if (abilities is List<String>) {
      if (!(abilities.length >= 1)) {
        state.fail(
          path,
          'abilities',
          IssueCodes.minItems,
          DefaultMessages.minItems,
          abilities,
          params: const <String, Object?>{'min': 1},
          messages: _messages,
        );
      }
    }
    if (state.issues.length != issuesBefore) return null;
    return CreateToken(
      name: name as String,
      abilities: abilities as List<String>,
    );
  }

  @override
  CreateToken fromMap(Map<String, dynamic> map) {
    return CreateToken(
      name: map['name'] as String,
      abilities: <String>[
        for (Object? x0 in map['abilities'] as List<dynamic>) x0 as String,
      ],
    );
  }

  @override
  Map<String, dynamic> toMap(CreateToken dto) {
    return <String, dynamic>{'name': dto.name, 'abilities': dto.abilities};
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as CreateToken));

  @override
  Map<String, dynamic> toJsonSchema() {
    return <String, dynamic>{
      'type': 'object',
      'title': 'CreateToken',
      'properties': <String, dynamic>{
        'name': <String, dynamic>{
          'type': 'string',
          'minLength': 2,
          'maxLength': 100,
        },
        'abilities': <String, dynamic>{
          'type': 'array',
          'items': <String, dynamic>{'type': 'string'},
          'minItems': 1,
        },
      },
      'required': <dynamic>['name', 'abilities'],
    };
  }
}

/// The checks, the converter and the JSON Schema of [SaveContact].
const DtoSchema<SaveContact> $SaveContactDto = _$SaveContactDto();

class _$SaveContactDto extends DtoSchema<SaveContact>
    implements JsonObjectWriter {
  const _$SaveContactDto();

  static const Map<String, String> _messages = <String, String>{};

  @override
  Type get type => SaveContact;

  @override
  String get name => 'SaveContact';

  @override
  SaveContact? convert(Object? input, DtoState state, List<Object> path) {
    if (input is! Map) {
      state.notObject(input, path, _messages);
      return null;
    }
    int issuesBefore = state.issues.length;
    // accountType: String
    Object? accountType = state.string(
      state.read(input, 'account_type'),
      path,
      'account_type',
      _messages,
    );
    if (accountType == null || accountType is Undefined)
      state.required(path, 'account_type', _messages);
    // companyName: String?
    Object? companyName = state.string(
      state.read(input, 'company_name'),
      path,
      'company_name',
      _messages,
    );
    // phone: String?
    Object? phone = state.string(
      state.read(input, 'phone'),
      path,
      'phone',
      _messages,
    );
    // countryCode: String?
    Object? countryCode = state.string(
      state.read(input, 'country_code'),
      path,
      'country_code',
      _messages,
    );
    state.requiredWhen(
      const RequiredIf('account_type', 'company'),
      companyName,
      input,
      path,
      'company_name',
      _messages,
    );
    state.requiredWhen(
      const RequiredWith(<String>['phone']),
      countryCode,
      input,
      path,
      'country_code',
      _messages,
    );
    if (state.issues.length != issuesBefore && !state.allErrors) return null;
    if (accountType is String) {
      if (!(const <String>{'person', 'company'}.contains(accountType))) {
        state.fail(
          path,
          'account_type',
          IssueCodes.inList,
          DefaultMessages.inList,
          accountType,
          params: const <String, Object?>{'values': 'person, and company'},
          messages: _messages,
        );
      }
    }
    if (state.issues.length != issuesBefore) return null;
    return SaveContact(
      accountType: accountType as String,
      companyName: companyName is Undefined ? null : companyName as String?,
      phone: phone is Undefined ? null : phone as String?,
      countryCode: countryCode is Undefined ? null : countryCode as String?,
    );
  }

  @override
  SaveContact fromMap(Map<String, dynamic> map) {
    return SaveContact(
      accountType: map['account_type'] as String,
      companyName: map['company_name'] == null
          ? null
          : (map['company_name'] as String),
      phone: map['phone'] == null ? null : (map['phone'] as String),
      countryCode: map['country_code'] == null
          ? null
          : (map['country_code'] as String),
    );
  }

  @override
  Map<String, dynamic> toMap(SaveContact dto) {
    return <String, dynamic>{
      'account_type': dto.accountType,
      'company_name': dto.companyName,
      'phone': dto.phone,
      'country_code': dto.countryCode,
    };
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as SaveContact));

  @override
  Map<String, dynamic> toJsonSchema() {
    return <String, dynamic>{
      'type': 'object',
      'title': 'SaveContact',
      'properties': <String, dynamic>{
        'account_type': <String, dynamic>{
          'type': 'string',
          'enum': <dynamic>['person', 'company'],
        },
        'company_name': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
        },
        'phone': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
        },
        'country_code': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
        },
      },
      'required': <dynamic>['account_type'],
    };
  }
}

/// The checks, the converter and the JSON Schema of [UploadBanner].
const DtoSchema<UploadBanner> $UploadBannerDto = _$UploadBannerDto();

class _$UploadBannerDto extends DtoSchema<UploadBanner>
    implements JsonObjectWriter {
  const _$UploadBannerDto();

  static const Map<String, String> _messages = <String, String>{};

  @override
  Type get type => UploadBanner;

  @override
  String get name => 'UploadBanner';

  @override
  bool get usesRequiredWhen => false;

  @override
  UploadBanner? convert(Object? input, DtoState state, List<Object> path) {
    if (input is! Map) {
      state.notObject(input, path, _messages);
      return null;
    }
    int issuesBefore = state.issues.length;
    // banner: RequestFile
    Object? banner = state.file(
      state.read(input, 'banner'),
      path,
      'banner',
      _messages,
    );
    if (banner == null || banner is Undefined)
      state.required(path, 'banner', _messages);
    if (state.issues.length != issuesBefore && !state.allErrors) return null;
    if (banner is RequestFile) {
      if (!(FileTypes.matchesMimeTypes(banner, const <String>['image/png']))) {
        state.fail(
          path,
          'banner',
          IssueCodes.mimeTypes,
          DefaultMessages.mimes,
          banner,
          params: const <String, Object?>{'types': 'image/png'},
          messages: _messages,
        );
      } else if (!(banner.length >= 100)) {
        state.fail(
          path,
          'banner',
          IssueCodes.minSize,
          DefaultMessages.minSize,
          banner,
          params: const <String, Object?>{'min': '100B'},
          messages: _messages,
        );
      } else if (!(ImageSize.fits(banner, minWidth: 2, minHeight: 2))) {
        state.fail(
          path,
          'banner',
          IssueCodes.dimensions,
          DefaultMessages.dimensions,
          banner,
          messages: _messages,
        );
      }
    }
    if (state.issues.length != issuesBefore) return null;
    return UploadBanner(banner: banner as RequestFile);
  }

  @override
  UploadBanner fromMap(Map<String, dynamic> map) {
    return UploadBanner(banner: map['banner'] as RequestFile);
  }

  @override
  Map<String, dynamic> toMap(UploadBanner dto) {
    return <String, dynamic>{'banner': dto.banner};
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as UploadBanner));

  @override
  Map<String, dynamic> toJsonSchema() {
    return <String, dynamic>{
      'type': 'object',
      'title': 'UploadBanner',
      'properties': <String, dynamic>{
        'banner': <String, dynamic>{
          'type': 'string',
          'format': 'binary',
          'contentMediaType': 'image/*',
          'minLength': 100,
        },
      },
      'required': <dynamic>['banner'],
    };
  }
}
