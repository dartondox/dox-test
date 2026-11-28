// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'graphql.dto.dart';

// **************************************************************************
// DoxDtoGenerator
// **************************************************************************

// ignore_for_file: type=lint

/// The checks, the converter and the JSON Schema of [GqlPostInput].
const DtoSchema<GqlPostInput> $GqlPostInputDto = _$GqlPostInputDto();

class _$GqlPostInputDto extends DtoSchema<GqlPostInput>
    implements JsonObjectWriter {
  const _$GqlPostInputDto();

  static const Map<String, String> _messages = <String, String>{};

  @override
  Type get type => GqlPostInput;

  @override
  String get name => 'GqlPostInput';

  @override
  bool get usesRequiredWhen => false;

  @override
  GqlPostInput? convert(Object? input, DtoState state, List<Object> path) {
    if (input is! Map) {
      state.notObject(input, path, _messages);
      return null;
    }
    int issuesBefore = state.issues.length;
    // title: String
    Object? title = state.string(
      state.read(input, 'title'),
      path,
      'title',
      _messages,
    );
    if (title == null || title is Undefined)
      state.required(path, 'title', _messages);
    // body: String
    Object? body = state.string(
      state.read(input, 'body'),
      path,
      'body',
      _messages,
    );
    if (body == null) state.required(path, 'body', _messages);
    // status: String
    Object? status = state.string(
      state.read(input, 'status'),
      path,
      'status',
      _messages,
    );
    if (status == null) state.required(path, 'status', _messages);
    if (state.issues.length != issuesBefore && !state.allErrors) return null;
    if (title is String) {
      if (!(title.runes.length >= 3)) {
        state.fail(
          path,
          'title',
          IssueCodes.minLength,
          DefaultMessages.minLength,
          title,
          params: const <String, Object?>{'min': 3},
          messages: _messages,
        );
      }
    }
    if (state.issues.length != issuesBefore) return null;
    return GqlPostInput(
      title: title as String,
      body: body is Undefined ? '' : body as String,
      status: status is Undefined ? 'draft' : status as String,
    );
  }

  @override
  GqlPostInput fromMap(Map<String, dynamic> map) {
    return GqlPostInput(
      title: map['title'] as String,
      body: map.containsKey('body') ? map['body'] as String : '',
      status: map.containsKey('status') ? map['status'] as String : 'draft',
    );
  }

  @override
  Map<String, dynamic> toMap(GqlPostInput dto) {
    return <String, dynamic>{
      'title': dto.title,
      'body': dto.body,
      'status': dto.status,
    };
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as GqlPostInput));

  @override
  Map<String, dynamic> toJsonSchema() {
    return <String, dynamic>{
      'type': 'object',
      'title': 'GqlPostInput',
      'properties': <String, dynamic>{
        'title': <String, dynamic>{'type': 'string', 'minLength': 3},
        'body': <String, dynamic>{'type': 'string', 'default': ''},
        'status': <String, dynamic>{'type': 'string', 'default': 'draft'},
      },
      'required': <dynamic>['title'],
    };
  }
}

/// The checks, the converter and the JSON Schema of [GqlSecretInput].
const DtoSchema<GqlSecretInput> $GqlSecretInputDto = _$GqlSecretInputDto();

class _$GqlSecretInputDto extends DtoSchema<GqlSecretInput>
    implements JsonObjectWriter {
  const _$GqlSecretInputDto();

  static const Map<String, String> _messages = <String, String>{};

  @override
  Type get type => GqlSecretInput;

  @override
  String get name => 'GqlSecretInput';

  @override
  bool get usesRequiredWhen => false;

  @override
  GqlSecretInput? convert(Object? input, DtoState state, List<Object> path) {
    if (input is! Map) {
      state.notObject(input, path, _messages);
      return null;
    }
    int issuesBefore = state.issues.length;
    // body: String
    Object? body = state.string(
      state.read(input, 'body'),
      path,
      'body',
      _messages,
    );
    if (body == null || body is Undefined)
      state.required(path, 'body', _messages);
    // postId: int
    Object? postId = state.integer(
      state.read(input, 'post_id'),
      path,
      'post_id',
      _messages,
    );
    if (postId == null || postId is Undefined)
      state.required(path, 'post_id', _messages);
    if (state.issues.length != issuesBefore && !state.allErrors) return null;
    if (state.issues.length != issuesBefore) return null;
    return GqlSecretInput(body: body as String, postId: postId as int);
  }

  @override
  GqlSecretInput fromMap(Map<String, dynamic> map) {
    return GqlSecretInput(
      body: map['body'] as String,
      postId: (map['post_id'] as num).toInt(),
    );
  }

  @override
  Map<String, dynamic> toMap(GqlSecretInput dto) {
    return <String, dynamic>{'body': dto.body, 'post_id': dto.postId};
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as GqlSecretInput));

  @override
  Map<String, dynamic> toJsonSchema() {
    return <String, dynamic>{
      'type': 'object',
      'title': 'GqlSecretInput',
      'properties': <String, dynamic>{
        'body': <String, dynamic>{'type': 'string'},
        'post_id': <String, dynamic>{'type': 'integer'},
      },
      'required': <dynamic>['body', 'post_id'],
    };
  }
}
