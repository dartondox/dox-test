// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dto.dart';

// **************************************************************************
// DoxDtoGenerator
// **************************************************************************

// ignore_for_file: type=lint

/// The checks, the converter and the JSON Schema of [ListPosts].
const DtoSchema<ListPosts> $ListPostsDto = _$ListPostsDto();

class _$ListPostsDto extends DtoSchema<ListPosts> {
  const _$ListPostsDto();

  static const Map<String, String> _m = <String, String>{};

  @override
  Type get type => ListPosts;

  @override
  String get name => 'ListPosts';

  @override
  bool get isAsync => true;

  @override
  ListPosts? convert(Object? input, DtoState s, List<Object> p) {
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
    // status: List<PostStatus>
    Object? c2;
    c2 = s.list(s.read(input, 'status'), p, 'status', _m);
    if (c2 is List) {
      List<Object> q0 = <Object>[...p, 'status'];
      List<PostStatus> o0 = <PostStatus>[];
      for (int i0 = 0; i0 < c2.length; i0++) {
        Object? x0;
        x0 = s.enumName(c2[i0], q0, i0, _m, const <String>[
          'draft',
          'published',
        ]);
        if (x0 is String) {
          x0 = switch (x0) {
            'draft' => PostStatus.draft,
            _ => PostStatus.published,
          };
        }
        if (x0 == null || x0 is Undefined) {
          s.required(q0, i0, _m);
        } else if (x0 is! Invalid) {
          o0.add(x0 as PostStatus);
        }
      }
      c2 = o0;
    }
    if (c2 == null) s.required(p, 'status', _m);
    // authorId: int?
    Object? c3;
    c3 = s.integer(s.read(input, 'author_id'), p, 'author_id', _m);
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
    if (c2 is List<PostStatus>) {
      if (!(!DtoChecks.hasDuplicates(c2))) {
        s.fail(
          p,
          'status',
          IssueCodes.uniqueItems,
          DefaultMessages.uniqueItems,
          c2,
          messages: _m,
        );
      }
    }
    if (s.issues.length != e) return null;
    return ListPosts(
      page: c0 is Undefined ? 1 : c0 as int,
      perPage: c1 is Undefined ? AppConstants.defaultPerPage : c1 as int,
      status: c2 is Undefined ? const <PostStatus>[] : c2 as List<PostStatus>,
      authorId: c3 is Undefined ? null : c3 as int?,
    );
  }

  @override
  Future<void> checkAsync(ListPosts o, DtoState s, List<Object> p) async {
    {
      int? f = o.authorId;
      if (f != null) {
        await s.asyncRule(const Exists('users'), f, p, 'author_id', _m);
      }
    }
  }

  @override
  ListPosts fromMap(Map<String, dynamic> m) {
    return ListPosts(
      page: m.containsKey('page') ? (m['page'] as num).toInt() : 1,
      perPage: m.containsKey('per_page')
          ? (m['per_page'] as num).toInt()
          : AppConstants.defaultPerPage,
      status: m.containsKey('status')
          ? <PostStatus>[
              for (Object? x0 in m['status'] as List<dynamic>)
                PostStatus.values.byName(x0 as String),
            ]
          : const <PostStatus>[],
      authorId: m['author_id'] == null
          ? null
          : ((m['author_id'] as num).toInt()),
    );
  }

  @override
  Map<String, dynamic> toMap(ListPosts o) {
    int f0 = o.page;
    int f1 = o.perPage;
    List<PostStatus> f2 = o.status;
    int? f3 = o.authorId;
    return <String, dynamic>{
      'page': f0,
      'per_page': f1,
      'status': <dynamic>[for (PostStatus x0 in f2) x0.name],
      'author_id': f3,
    };
  }

  @override
  Map<String, dynamic> toJsonSchema() {
    Map<String, dynamic> j = <String, dynamic>{
      'type': 'object',
      'title': 'ListPosts',
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
        'status': <String, dynamic>{
          'type': 'array',
          'items': <String, dynamic>{
            'type': 'string',
            'enum': <dynamic>['draft', 'published'],
          },
          'uniqueItems': true,
          'description': '`status=draft&status=published`. Empty means all.',
          'default': <dynamic>[],
        },
        'author_id': <String, dynamic>{
          'type': <dynamic>['integer', 'null'],
          'description': 'Only posts of this user. The user must exist.',
        },
      },
    };
    JsonSchemaTools.merge(j, <String>[
      'properties',
      'author_id',
    ], const Exists('users').toJsonSchema());
    return j;
  }
}

/// The checks, the converter and the JSON Schema of [SavePost].
const DtoSchema<SavePost> $SavePostDto = _$SavePostDto();

class _$SavePostDto extends DtoSchema<SavePost> {
  const _$SavePostDto();

  static const Map<String, String> _m = <String, String>{};

  @override
  Type get type => SavePost;

  @override
  String get name => 'SavePost';

  @override
  SavePost? convert(Object? input, DtoState s, List<Object> p) {
    if (input is! Map) {
      s.notObject(input, p, _m);
      return null;
    }
    int e = s.issues.length;
    // title: String
    Object? c0;
    c0 = s.string(s.read(input, 'title'), p, 'title', _m, trim: true);
    if (c0 == null || c0 is Undefined) s.required(p, 'title', _m);
    // body: String
    Object? c1;
    c1 = s.string(s.read(input, 'body'), p, 'body', _m, trim: true);
    if (c1 == null || c1 is Undefined) s.required(p, 'body', _m);
    // status: PostStatus
    Object? c2;
    c2 = s.enumName(s.read(input, 'status'), p, 'status', _m, const <String>[
      'draft',
      'published',
    ]);
    if (c2 is String) {
      c2 = switch (c2) {
        'draft' => PostStatus.draft,
        _ => PostStatus.published,
      };
    }
    if (c2 == null) s.required(p, 'status', _m);
    // tags: List<String>
    Object? c3;
    c3 = s.list(s.read(input, 'tags'), p, 'tags', _m);
    if (c3 is List) {
      List<Object> q0 = <Object>[...p, 'tags'];
      List<String> o0 = <String>[];
      for (int i0 = 0; i0 < c3.length; i0++) {
        Object? x0;
        x0 = s.string(c3[i0], q0, i0, _m, trim: true, textCase: 1);
        if (x0 == null || x0 is Undefined) {
          s.required(q0, i0, _m);
        } else if (x0 is! Invalid) {
          o0.add(x0 as String);
        }
      }
      c3 = o0;
    }
    if (c3 == null) s.required(p, 'tags', _m);
    if (s.issues.length != e) return null;
    if (c0 is String) {
      if (!(c0.runes.length <= 255)) {
        s.fail(
          p,
          'title',
          IssueCodes.maxLength,
          DefaultMessages.maxLength,
          c0,
          params: const <String, Object?>{'max': 255},
          messages: _m,
        );
      }
    }
    if (c3 is List<String>) {
      if (!(c3.length <= 5)) {
        s.fail(
          p,
          'tags',
          IssueCodes.maxItems,
          DefaultMessages.maxItems,
          c3,
          params: const <String, Object?>{'max': 5},
          messages: _m,
        );
      } else {
        List<Object> q = <Object>[...p, 'tags'];
        for (int i = 0; i < c3.length; i++) {
          String v = c3[i];
          if (!(const Slug().check(v, s.context(q, i, v)))) {
            s.failRule(const Slug(), q, i, v, _m);
          }
        }
      }
    }
    if (s.issues.length != e) return null;
    return SavePost(
      title: c0 as String,
      body: c1 as String,
      status: c2 is Undefined ? PostStatus.draft : c2 as PostStatus,
      tags: c3 is Undefined ? const <String>[] : c3 as List<String>,
    );
  }

  @override
  SavePost fromMap(Map<String, dynamic> m) {
    return SavePost(
      title: m['title'] as String,
      body: m['body'] as String,
      status: m.containsKey('status')
          ? PostStatus.values.byName(m['status'] as String)
          : PostStatus.draft,
      tags: m.containsKey('tags')
          ? <String>[
              for (Object? x0 in m['tags'] as List<dynamic>) x0 as String,
            ]
          : const <String>[],
    );
  }

  @override
  Map<String, dynamic> toMap(SavePost o) {
    String f0 = o.title;
    String f1 = o.body;
    PostStatus f2 = o.status;
    List<String> f3 = o.tags;
    return <String, dynamic>{
      'title': f0,
      'body': f1,
      'status': f2.name,
      'tags': f3,
    };
  }

  @override
  Map<String, dynamic> toJsonSchema() {
    Map<String, dynamic> j = <String, dynamic>{
      'type': 'object',
      'title': 'SavePost',
      'properties': <String, dynamic>{
        'title': <String, dynamic>{'type': 'string', 'maxLength': 255},
        'body': <String, dynamic>{'type': 'string'},
        'status': <String, dynamic>{
          'type': 'string',
          'enum': <dynamic>['draft', 'published'],
          'default': 'draft',
        },
        'tags': <String, dynamic>{
          'type': 'array',
          'items': <String, dynamic>{'type': 'string'},
          'maxItems': 5,
          'description': 'Tag names. Each one must be a slug.',
          'default': <dynamic>[],
        },
      },
      'required': <dynamic>['title', 'body'],
    };
    JsonSchemaTools.merge(j, <String>[
      'properties',
      'tags',
      'items',
    ], const Slug().toJsonSchema());
    return j;
  }
}

/// The checks, the converter and the JSON Schema of [AddComment].
const DtoSchema<AddComment> $AddCommentDto = _$AddCommentDto();

class _$AddCommentDto extends DtoSchema<AddComment> {
  const _$AddCommentDto();

  static const Map<String, String> _m = <String, String>{};

  @override
  Type get type => AddComment;

  @override
  String get name => 'AddComment';

  @override
  AddComment? convert(Object? input, DtoState s, List<Object> p) {
    if (input is! Map) {
      s.notObject(input, p, _m);
      return null;
    }
    int e = s.issues.length;
    // body: String
    Object? c0;
    c0 = s.string(s.read(input, 'body'), p, 'body', _m, trim: true);
    if (c0 == null || c0 is Undefined) s.required(p, 'body', _m);
    if (s.issues.length != e) return null;
    if (c0 is String) {
      if (!(c0.runes.length <= 1000)) {
        s.fail(
          p,
          'body',
          IssueCodes.maxLength,
          DefaultMessages.maxLength,
          c0,
          params: const <String, Object?>{'max': 1000},
          messages: _m,
        );
      }
    }
    if (s.issues.length != e) return null;
    return AddComment(body: c0 as String);
  }

  @override
  AddComment fromMap(Map<String, dynamic> m) {
    return AddComment(body: m['body'] as String);
  }

  @override
  Map<String, dynamic> toMap(AddComment o) {
    String f0 = o.body;
    return <String, dynamic>{'body': f0};
  }

  @override
  Map<String, dynamic> toJsonSchema() {
    return <String, dynamic>{
      'type': 'object',
      'title': 'AddComment',
      'properties': <String, dynamic>{
        'body': <String, dynamic>{'type': 'string', 'maxLength': 1000},
      },
      'required': <dynamic>['body'],
    };
  }
}
