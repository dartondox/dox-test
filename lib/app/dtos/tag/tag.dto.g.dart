// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag.dto.dart';

// **************************************************************************
// DoxDtoGenerator
// **************************************************************************

// ignore_for_file: type=lint

/// The checks, the converter and the JSON Schema of [ListTags].
const DtoSchema<ListTags> $ListTagsDto = _$ListTagsDto();

class _$ListTagsDto extends DtoSchema<ListTags> implements JsonObjectWriter {
  const _$ListTagsDto();

  static const Map<String, String> _messages = <String, String>{};

  @override
  Type get type => ListTags;

  @override
  String get name => 'ListTags';

  @override
  bool get usesRequiredWhen => false;

  @override
  ListTags? convert(Object? input, DtoState state, List<Object> path) {
    if (input is! Map) {
      state.notObject(input, path, _messages);
      return null;
    }
    int issuesBefore = state.issues.length;
    // limit: int
    Object? limit = state.integer(
      state.read(input, 'limit'),
      path,
      'limit',
      _messages,
    );
    if (limit == null) state.required(path, 'limit', _messages);
    // except: String?
    Object? except = state.string(
      state.read(input, 'except'),
      path,
      'except',
      _messages,
    );
    if (state.issues.length != issuesBefore && !state.allErrors) return null;
    if (limit is int) {
      if (!(limit >= 1 && limit <= 100)) {
        state.fail(
          path,
          'limit',
          IssueCodes.between,
          DefaultMessages.between,
          limit,
          params: const <String, Object?>{'min': 1, 'max': 100},
          messages: _messages,
        );
      }
    }
    if (state.issues.length != issuesBefore) return null;
    return ListTags(
      limit: limit is Undefined ? 10 : limit as int,
      except: except is Undefined ? null : except as String?,
    );
  }

  @override
  ListTags fromMap(Map<String, dynamic> map) {
    return ListTags(
      limit: map.containsKey('limit') ? (map['limit'] as num).toInt() : 10,
      except: map['except'] == null ? null : (map['except'] as String),
    );
  }

  @override
  Map<String, dynamic> toMap(ListTags dto) {
    return <String, dynamic>{'limit': dto.limit, 'except': dto.except};
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as ListTags));

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

class _$CreateTagsDto extends DtoSchema<CreateTags>
    implements JsonObjectWriter {
  const _$CreateTagsDto();

  static const Map<String, String> _messages = <String, String>{};

  @override
  Type get type => CreateTags;

  @override
  String get name => 'CreateTags';

  @override
  bool get usesRequiredWhen => false;

  @override
  CreateTags? convert(Object? input, DtoState state, List<Object> path) {
    if (input is! Map) {
      state.notObject(input, path, _messages);
      return null;
    }
    int issuesBefore = state.issues.length;
    // names: List<String>
    Object? names = state.list(
      state.read(input, 'names'),
      path,
      'names',
      _messages,
    );
    if (names is List) {
      int b0 = state.issues.length;
      List<Object> q0 = <Object>[...path, 'names'];
      List<String> o0 = <String>[];
      for (int i0 = 0; i0 < names.length; i0++) {
        Object? x0 = state.string(
          names[i0],
          q0,
          i0,
          _messages,
          trim: true,
          textCase: 1,
        );
        if (x0 == null || x0 is Undefined) {
          state.required(q0, i0, _messages);
        } else if (x0 is! Invalid) {
          o0.add(x0 as String);
        }
      }
      names = state.issues.length != b0 ? invalid : o0;
    }
    if (names == null || names is Undefined || state.emptyList(names)) {
      state.required(path, 'names', _messages);
      names = invalid;
    }
    // fail: bool
    Object? fail = state.boolean(
      state.read(input, 'fail'),
      path,
      'fail',
      _messages,
    );
    if (fail == null) state.required(path, 'fail', _messages);
    if (state.issues.length != issuesBefore && !state.allErrors) return null;
    if (names is List<String>) {
      if (!(names.length >= 1)) {
        state.fail(
          path,
          'names',
          IssueCodes.minItems,
          DefaultMessages.minItems,
          names,
          params: const <String, Object?>{'min': 1},
          messages: _messages,
        );
      } else if (!(names.length <= 10)) {
        state.fail(
          path,
          'names',
          IssueCodes.maxItems,
          DefaultMessages.maxItems,
          names,
          params: const <String, Object?>{'max': 10},
          messages: _messages,
        );
      } else {
        List<Object> q = <Object>[...path, 'names'];
        for (int i = 0; i < names.length; i++) {
          String v = names[i];
          if (!(v.runes.length >= 2 && v.runes.length <= 100)) {
            state.fail(
              q,
              i,
              IssueCodes.lengthBetween,
              DefaultMessages.lengthBetween,
              v,
              params: const <String, Object?>{'min': 2, 'max': 100},
              messages: _messages,
            );
          }
        }
      }
    }
    if (state.issues.length != issuesBefore) return null;
    return CreateTags(
      names: names as List<String>,
      fail: fail is Undefined ? false : fail as bool,
    );
  }

  @override
  CreateTags fromMap(Map<String, dynamic> map) {
    return CreateTags(
      names: <String>[
        for (Object? x0 in map['names'] as List<dynamic>) x0 as String,
      ],
      fail: map.containsKey('fail') ? map['fail'] as bool : false,
    );
  }

  @override
  Map<String, dynamic> toMap(CreateTags dto) {
    return <String, dynamic>{'names': dto.names, 'fail': dto.fail};
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as CreateTags));

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
