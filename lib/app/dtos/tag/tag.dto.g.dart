// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag.dto.dart';

// **************************************************************************
// DoxDtoGenerator
// **************************************************************************

// ignore_for_file: type=lint

/// The checks, the converter and the JSON Schema of [ListTags].
const DtoSchema<ListTags> $ListTagsDto = _$ListTagsDto();

class _$ListTagsDto extends DtoSchema<ListTags> {
  const _$ListTagsDto();

  static const Map<String, String> _m = <String, String>{};

  @override
  Type get type => ListTags;

  @override
  String get name => 'ListTags';

  @override
  ListTags? convert(Object? input, DtoState s, List<Object> p) {
    if (input is! Map) {
      s.notObject(input, p, _m);
      return null;
    }
    int e = s.issues.length;
    // limit: int
    Object? c0;
    c0 = s.integer(s.read(input, 'limit'), p, 'limit', _m);
    if (c0 == null) s.required(p, 'limit', _m);
    // except: String?
    Object? c1;
    c1 = s.string(s.read(input, 'except'), p, 'except', _m);
    if (s.issues.length != e) return null;
    if (c0 is int) {
      if (!(c0 >= 1 && c0 <= 100)) {
        s.fail(
          p,
          'limit',
          IssueCodes.between,
          DefaultMessages.between,
          c0,
          params: const <String, Object?>{'min': 1, 'max': 100},
          messages: _m,
        );
      }
    }
    if (s.issues.length != e) return null;
    return ListTags(
      limit: c0 is Undefined ? 10 : c0 as int,
      except: c1 is Undefined ? null : c1 as String?,
    );
  }

  @override
  ListTags fromMap(Map<String, dynamic> m) {
    return ListTags(
      limit: m.containsKey('limit') ? (m['limit'] as num).toInt() : 10,
      except: m['except'] == null ? null : (m['except'] as String),
    );
  }

  @override
  Map<String, dynamic> toMap(ListTags o) {
    int f0 = o.limit;
    String? f1 = o.except;
    return <String, dynamic>{'limit': f0, 'except': f1};
  }

  @override
  Map<String, dynamic> toJsonSchema() {
    return <String, dynamic>{
      'type': 'object',
      'title': 'ListTags',
      'properties': <String, dynamic>{
        'limit': <String, dynamic>{
          'type': 'integer',
          'minimum': 1,
          'maximum': 100,
          'default': 10,
        },
        'except': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
          'description': '`alpha,beta` leaves those names out.',
        },
      },
    };
  }
}

/// The checks, the converter and the JSON Schema of [CreateTags].
const DtoSchema<CreateTags> $CreateTagsDto = _$CreateTagsDto();

class _$CreateTagsDto extends DtoSchema<CreateTags> {
  const _$CreateTagsDto();

  static const Map<String, String> _m = <String, String>{};

  @override
  Type get type => CreateTags;

  @override
  String get name => 'CreateTags';

  @override
  CreateTags? convert(Object? input, DtoState s, List<Object> p) {
    if (input is! Map) {
      s.notObject(input, p, _m);
      return null;
    }
    int e = s.issues.length;
    // names: List<String>
    Object? c0;
    c0 = s.list(s.read(input, 'names'), p, 'names', _m);
    if (c0 is List) {
      List<Object> q0 = <Object>[...p, 'names'];
      List<String> o0 = <String>[];
      for (int i0 = 0; i0 < c0.length; i0++) {
        Object? x0;
        x0 = s.string(c0[i0], q0, i0, _m, trim: true, textCase: 1);
        if (x0 == null || x0 is Undefined) {
          s.required(q0, i0, _m);
        } else if (x0 is! Invalid) {
          o0.add(x0 as String);
        }
      }
      c0 = o0;
    }
    if (c0 == null || c0 is Undefined) s.required(p, 'names', _m);
    // fail: bool
    Object? c1;
    c1 = s.boolean(s.read(input, 'fail'), p, 'fail', _m);
    if (c1 == null) s.required(p, 'fail', _m);
    if (s.issues.length != e) return null;
    if (c0 is List<String>) {
      if (!(c0.length >= 1)) {
        s.fail(
          p,
          'names',
          IssueCodes.minItems,
          DefaultMessages.minItems,
          c0,
          params: const <String, Object?>{'min': 1},
          messages: _m,
        );
      } else if (!(c0.length <= 10)) {
        s.fail(
          p,
          'names',
          IssueCodes.maxItems,
          DefaultMessages.maxItems,
          c0,
          params: const <String, Object?>{'max': 10},
          messages: _m,
        );
      } else {
        List<Object> q = <Object>[...p, 'names'];
        for (int i = 0; i < c0.length; i++) {
          String v = c0[i];
          if (!(v.runes.length >= 2 && v.runes.length <= 100)) {
            s.fail(
              q,
              i,
              IssueCodes.lengthBetween,
              DefaultMessages.lengthBetween,
              v,
              params: const <String, Object?>{'min': 2, 'max': 100},
              messages: _m,
            );
          }
        }
      }
    }
    if (s.issues.length != e) return null;
    return CreateTags(
      names: c0 as List<String>,
      fail: c1 is Undefined ? false : c1 as bool,
    );
  }

  @override
  CreateTags fromMap(Map<String, dynamic> m) {
    return CreateTags(
      names: <String>[
        for (Object? x0 in m['names'] as List<dynamic>) x0 as String,
      ],
      fail: m.containsKey('fail') ? m['fail'] as bool : false,
    );
  }

  @override
  Map<String, dynamic> toMap(CreateTags o) {
    List<String> f0 = o.names;
    bool f1 = o.fail;
    return <String, dynamic>{'names': f0, 'fail': f1};
  }

  @override
  Map<String, dynamic> toJsonSchema() {
    return <String, dynamic>{
      'type': 'object',
      'title': 'CreateTags',
      'properties': <String, dynamic>{
        'names': <String, dynamic>{
          'type': 'array',
          'items': <String, dynamic>{
            'type': 'string',
            'minLength': 2,
            'maxLength': 100,
          },
          'minItems': 1,
          'maxItems': 10,
        },
        'fail': <String, dynamic>{
          'type': 'boolean',
          'description':
              '`true` throws inside the transaction, so nothing is saved.',
          'default': false,
        },
      },
      'required': <dynamic>['names'],
    };
  }
}
