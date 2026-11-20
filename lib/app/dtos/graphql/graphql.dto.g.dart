// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'graphql.dto.dart';

// **************************************************************************
// DoxDtoGenerator
// **************************************************************************

// ignore_for_file: type=lint

/// The checks, the converter and the JSON Schema of [GqlPostInput].
const DtoSchema<GqlPostInput> $GqlPostInputDto = _$GqlPostInputDto();

class _$GqlPostInputDto extends DtoSchema<GqlPostInput> {
  const _$GqlPostInputDto();

  static const Map<String, String> _m = <String, String>{};

  @override
  Type get type => GqlPostInput;

  @override
  String get name => 'GqlPostInput';

  @override
  bool get usesRequiredWhen => false;

  @override
  GqlPostInput? convert(Object? input, DtoState s, List<Object> p) {
    if (input is! Map) {
      s.notObject(input, p, _m);
      return null;
    }
    int e = s.issues.length;
    // title: String
    Object? c0;
    c0 = s.string(s.read(input, 'title'), p, 'title', _m);
    if (c0 == null || c0 is Undefined) s.required(p, 'title', _m);
    // body: String
    Object? c1;
    c1 = s.string(s.read(input, 'body'), p, 'body', _m);
    if (c1 == null) s.required(p, 'body', _m);
    // status: String
    Object? c2;
    c2 = s.string(s.read(input, 'status'), p, 'status', _m);
    if (c2 == null) s.required(p, 'status', _m);
    if (s.issues.length != e && !s.allErrors) return null;
    if (c0 is String) {
      if (!(c0.runes.length >= 3)) {
        s.fail(
          p,
          'title',
          IssueCodes.minLength,
          DefaultMessages.minLength,
          c0,
          params: const <String, Object?>{'min': 3},
          messages: _m,
        );
      }
    }
    if (s.issues.length != e) return null;
    return GqlPostInput(
      title: c0 as String,
      body: c1 is Undefined ? '' : c1 as String,
      status: c2 is Undefined ? 'draft' : c2 as String,
    );
  }

  @override
  GqlPostInput fromMap(Map<String, dynamic> m) {
    return GqlPostInput(
      title: m['title'] as String,
      body: m.containsKey('body') ? m['body'] as String : '',
      status: m.containsKey('status') ? m['status'] as String : 'draft',
    );
  }

  @override
  Map<String, dynamic> toMap(GqlPostInput o) {
    String f0 = o.title;
    String f1 = o.body;
    String f2 = o.status;
    return <String, dynamic>{'title': f0, 'body': f1, 'status': f2};
  }

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

class _$GqlSecretInputDto extends DtoSchema<GqlSecretInput> {
  const _$GqlSecretInputDto();

  static const Map<String, String> _m = <String, String>{};

  @override
  Type get type => GqlSecretInput;

  @override
  String get name => 'GqlSecretInput';

  @override
  bool get usesRequiredWhen => false;

  @override
  GqlSecretInput? convert(Object? input, DtoState s, List<Object> p) {
    if (input is! Map) {
      s.notObject(input, p, _m);
      return null;
    }
    int e = s.issues.length;
    // body: String
    Object? c0;
    c0 = s.string(s.read(input, 'body'), p, 'body', _m);
    if (c0 == null || c0 is Undefined) s.required(p, 'body', _m);
    // postId: int
    Object? c1;
    c1 = s.integer(s.read(input, 'post_id'), p, 'post_id', _m);
    if (c1 == null || c1 is Undefined) s.required(p, 'post_id', _m);
    if (s.issues.length != e && !s.allErrors) return null;
    if (s.issues.length != e) return null;
    return GqlSecretInput(body: c0 as String, postId: c1 as int);
  }

  @override
  GqlSecretInput fromMap(Map<String, dynamic> m) {
    return GqlSecretInput(
      body: m['body'] as String,
      postId: (m['post_id'] as num).toInt(),
    );
  }

  @override
  Map<String, dynamic> toMap(GqlSecretInput o) {
    String f0 = o.body;
    int f1 = o.postId;
    return <String, dynamic>{'body': f0, 'post_id': f1};
  }

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
