// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core.dto.dart';

// **************************************************************************
// DoxDtoGenerator
// **************************************************************************

// ignore_for_file: type=lint

/// The checks, the converter and the JSON Schema of [CreateToken].
const DtoSchema<CreateToken> $CreateTokenDto = _$CreateTokenDto();

class _$CreateTokenDto extends DtoSchema<CreateToken> {
  const _$CreateTokenDto();

  static const Map<String, String> _m = <String, String>{};

  @override
  Type get type => CreateToken;

  @override
  String get name => 'CreateToken';

  @override
  CreateToken? convert(Object? input, DtoState s, List<Object> p) {
    if (input is! Map) {
      s.notObject(input, p, _m);
      return null;
    }
    int e = s.issues.length;
    // name: String
    Object? c0;
    c0 = s.string(s.read(input, 'name'), p, 'name', _m, trim: true);
    if (c0 == null || c0 is Undefined) s.required(p, 'name', _m);
    // abilities: List<String>
    Object? c1;
    c1 = s.list(s.read(input, 'abilities'), p, 'abilities', _m);
    if (c1 is List) {
      List<Object> q0 = <Object>[...p, 'abilities'];
      List<String> o0 = <String>[];
      for (int i0 = 0; i0 < c1.length; i0++) {
        Object? x0;
        x0 = s.string(c1[i0], q0, i0, _m);
        if (x0 == null || x0 is Undefined) {
          s.required(q0, i0, _m);
        } else if (x0 is! Invalid) {
          o0.add(x0 as String);
        }
      }
      c1 = o0;
    }
    if (c1 == null || c1 is Undefined) s.required(p, 'abilities', _m);
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
    if (c1 is List<String>) {
      if (!(c1.length >= 1)) {
        s.fail(
          p,
          'abilities',
          IssueCodes.minItems,
          DefaultMessages.minItems,
          c1,
          params: const <String, Object?>{'min': 1},
          messages: _m,
        );
      }
    }
    if (s.issues.length != e) return null;
    return CreateToken(name: c0 as String, abilities: c1 as List<String>);
  }

  @override
  CreateToken fromMap(Map<String, dynamic> m) {
    return CreateToken(
      name: m['name'] as String,
      abilities: <String>[
        for (Object? x0 in m['abilities'] as List<dynamic>) x0 as String,
      ],
    );
  }

  @override
  Map<String, dynamic> toMap(CreateToken o) {
    String f0 = o.name;
    List<String> f1 = o.abilities;
    return <String, dynamic>{'name': f0, 'abilities': f1};
  }

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

class _$SaveContactDto extends DtoSchema<SaveContact> {
  const _$SaveContactDto();

  static const Map<String, String> _m = <String, String>{};

  @override
  Type get type => SaveContact;

  @override
  String get name => 'SaveContact';

  @override
  SaveContact? convert(Object? input, DtoState s, List<Object> p) {
    if (input is! Map) {
      s.notObject(input, p, _m);
      return null;
    }
    int e = s.issues.length;
    // accountType: String
    Object? c0;
    c0 = s.string(s.read(input, 'account_type'), p, 'account_type', _m);
    if (c0 == null || c0 is Undefined) s.required(p, 'account_type', _m);
    // companyName: String?
    Object? c1;
    c1 = s.string(s.read(input, 'company_name'), p, 'company_name', _m);
    s.requiredWhen(
      const RequiredIf('account_type', 'company'),
      c1,
      input,
      p,
      'company_name',
      _m,
    );
    // phone: String?
    Object? c2;
    c2 = s.string(s.read(input, 'phone'), p, 'phone', _m);
    // countryCode: String?
    Object? c3;
    c3 = s.string(s.read(input, 'country_code'), p, 'country_code', _m);
    s.requiredWhen(
      const RequiredWith(<String>['phone']),
      c3,
      input,
      p,
      'country_code',
      _m,
    );
    if (s.issues.length != e) return null;
    if (c0 is String) {
      if (!(const <String>{'person', 'company'}.contains(c0))) {
        s.fail(
          p,
          'account_type',
          IssueCodes.inList,
          DefaultMessages.inList,
          c0,
          params: const <String, Object?>{'values': 'person, and company'},
          messages: _m,
        );
      }
    }
    if (s.issues.length != e) return null;
    return SaveContact(
      accountType: c0 as String,
      companyName: c1 is Undefined ? null : c1 as String?,
      phone: c2 is Undefined ? null : c2 as String?,
      countryCode: c3 is Undefined ? null : c3 as String?,
    );
  }

  @override
  SaveContact fromMap(Map<String, dynamic> m) {
    return SaveContact(
      accountType: m['account_type'] as String,
      companyName: m['company_name'] == null
          ? null
          : (m['company_name'] as String),
      phone: m['phone'] == null ? null : (m['phone'] as String),
      countryCode: m['country_code'] == null
          ? null
          : (m['country_code'] as String),
    );
  }

  @override
  Map<String, dynamic> toMap(SaveContact o) {
    String f0 = o.accountType;
    String? f1 = o.companyName;
    String? f2 = o.phone;
    String? f3 = o.countryCode;
    return <String, dynamic>{
      'account_type': f0,
      'company_name': f1,
      'phone': f2,
      'country_code': f3,
    };
  }

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

class _$UploadBannerDto extends DtoSchema<UploadBanner> {
  const _$UploadBannerDto();

  static const Map<String, String> _m = <String, String>{};

  @override
  Type get type => UploadBanner;

  @override
  String get name => 'UploadBanner';

  @override
  UploadBanner? convert(Object? input, DtoState s, List<Object> p) {
    if (input is! Map) {
      s.notObject(input, p, _m);
      return null;
    }
    int e = s.issues.length;
    // banner: RequestFile
    Object? c0;
    c0 = s.file(s.read(input, 'banner'), p, 'banner', _m);
    if (c0 == null || c0 is Undefined) s.required(p, 'banner', _m);
    if (s.issues.length != e) return null;
    if (c0 is RequestFile) {
      if (!(FileTypes.matchesMimeTypes(c0, const <String>['image/png']))) {
        s.fail(
          p,
          'banner',
          IssueCodes.mimeTypes,
          DefaultMessages.mimes,
          c0,
          params: const <String, Object?>{'types': 'image/png'},
          messages: _m,
        );
      } else if (!(c0.length >= 100)) {
        s.fail(
          p,
          'banner',
          IssueCodes.minSize,
          DefaultMessages.minSize,
          c0,
          params: const <String, Object?>{'min': '100B'},
          messages: _m,
        );
      } else if (!(ImageSize.fits(c0, minWidth: 2, minHeight: 2))) {
        s.fail(
          p,
          'banner',
          IssueCodes.dimensions,
          DefaultMessages.dimensions,
          c0,
          messages: _m,
        );
      }
    }
    if (s.issues.length != e) return null;
    return UploadBanner(banner: c0 as RequestFile);
  }

  @override
  UploadBanner fromMap(Map<String, dynamic> m) {
    return UploadBanner(banner: m['banner'] as RequestFile);
  }

  @override
  Map<String, dynamic> toMap(UploadBanner o) {
    RequestFile f0 = o.banner;
    return <String, dynamic>{'banner': f0};
  }

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
