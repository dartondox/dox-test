// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dto.dart';

// **************************************************************************
// DoxDtoGenerator
// **************************************************************************

// ignore_for_file: type=lint

/// The checks, the converter and the JSON Schema of [ListPosts].
const DtoSchema<ListPosts> $ListPostsDto = _$ListPostsDto();

class _$ListPostsDto extends DtoSchema<ListPosts> implements JsonObjectWriter {
  const _$ListPostsDto();

  static const Map<String, String> _messages = <String, String>{};

  @override
  Type get type => ListPosts;

  @override
  String get name => 'ListPosts';

  @override
  bool get usesRequiredWhen => false;

  @override
  bool get isAsync => true;

  @override
  ListPosts? convert(Object? input, DtoState state, List<Object> path) {
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
    // status: List<PostStatus>
    Object? status = state.list(
      state.read(input, 'status'),
      path,
      'status',
      _messages,
    );
    if (status is List) {
      int b0 = state.issues.length;
      List<Object> q0 = <Object>[...path, 'status'];
      List<PostStatus> o0 = <PostStatus>[];
      for (int i0 = 0; i0 < status.length; i0++) {
        Object? x0 = state.enumName(
          status[i0],
          q0,
          i0,
          _messages,
          const <String>['draft', 'published'],
        );
        if (x0 is String) {
          x0 = switch (x0) {
            'draft' => PostStatus.draft,
            _ => PostStatus.published,
          };
        }
        if (x0 == null || x0 is Undefined) {
          state.required(q0, i0, _messages);
        } else if (x0 is! Invalid) {
          o0.add(x0 as PostStatus);
        }
      }
      status = state.issues.length != b0 ? invalid : o0;
    }
    if (status == null) state.required(path, 'status', _messages);
    // authorId: int?
    Object? authorId = state.integer(
      state.read(input, 'author_id'),
      path,
      'author_id',
      _messages,
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
    if (status is List<PostStatus>) {
      if (!(!DtoChecks.hasDuplicates(status))) {
        state.fail(
          path,
          'status',
          IssueCodes.uniqueItems,
          DefaultMessages.uniqueItems,
          status,
          messages: _messages,
        );
      }
    }
    if (state.issues.length != issuesBefore) return null;
    return ListPosts(
      page: page is Undefined ? 1 : page as int,
      perPage: perPage is Undefined
          ? AppConstants.defaultPerPage
          : perPage as int,
      status: status is Undefined
          ? const <PostStatus>[]
          : status as List<PostStatus>,
      authorId: authorId is Undefined ? null : authorId as int?,
    );
  }

  @override
  Future<void> checkAsync(
    ListPosts dto,
    DtoState state,
    List<Object> path,
  ) async {
    {
      int? value = dto.authorId;
      if (value != null) {
        await state.asyncRule(
          const Exists('users'),
          value,
          path,
          'author_id',
          _messages,
        );
      }
    }
  }

  @override
  ListPosts fromMap(Map<String, dynamic> map) {
    return ListPosts(
      page: map.containsKey('page') ? (map['page'] as num).toInt() : 1,
      perPage: map.containsKey('per_page')
          ? (map['per_page'] as num).toInt()
          : AppConstants.defaultPerPage,
      status: map.containsKey('status')
          ? <PostStatus>[
              for (Object? x0 in map['status'] as List<dynamic>)
                PostStatus.values.byName(x0 as String),
            ]
          : const <PostStatus>[],
      authorId: map['author_id'] == null
          ? null
          : ((map['author_id'] as num).toInt()),
    );
  }

  @override
  Map<String, dynamic> toMap(ListPosts dto) {
    return <String, dynamic>{
      'page': dto.page,
      'per_page': dto.perPage,
      'status': <dynamic>[for (PostStatus x0 in dto.status) x0.name],
      'author_id': dto.authorId,
    };
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as ListPosts));

  @override
  Map<String, dynamic> toJsonSchema() {
    Map<String, dynamic> schema = <String, dynamic>{
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
    JsonSchemaTools.merge(schema, <String>[
      'properties',
      'author_id',
    ], const Exists('users').toJsonSchema());
    return schema;
  }
}

/// The checks, the converter and the JSON Schema of [SavePost].
const DtoSchema<SavePost> $SavePostDto = _$SavePostDto();

class _$SavePostDto extends DtoSchema<SavePost> implements JsonObjectWriter {
  const _$SavePostDto();

  static const Map<String, String> _messages = <String, String>{};

  @override
  Type get type => SavePost;

  @override
  String get name => 'SavePost';

  @override
  bool get usesRequiredWhen => false;

  @override
  SavePost? convert(Object? input, DtoState state, List<Object> path) {
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
      trim: true,
    );
    if (title == null || title is Undefined)
      state.required(path, 'title', _messages);
    // body: String
    Object? body = state.string(
      state.read(input, 'body'),
      path,
      'body',
      _messages,
      trim: true,
    );
    if (body == null || body is Undefined)
      state.required(path, 'body', _messages);
    // status: PostStatus
    Object? status = state.enumName(
      state.read(input, 'status'),
      path,
      'status',
      _messages,
      const <String>['draft', 'published'],
    );
    if (status is String) {
      status = switch (status) {
        'draft' => PostStatus.draft,
        _ => PostStatus.published,
      };
    }
    if (status == null) state.required(path, 'status', _messages);
    // tags: List<String>
    Object? tags = state.list(
      state.read(input, 'tags'),
      path,
      'tags',
      _messages,
    );
    if (tags is List) {
      int b0 = state.issues.length;
      List<Object> q0 = <Object>[...path, 'tags'];
      List<String> o0 = <String>[];
      for (int i0 = 0; i0 < tags.length; i0++) {
        Object? x0 = state.string(
          tags[i0],
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
      tags = state.issues.length != b0 ? invalid : o0;
    }
    if (tags == null) state.required(path, 'tags', _messages);
    if (state.issues.length != issuesBefore && !state.allErrors) return null;
    if (title is String) {
      if (!(title.runes.length <= 255)) {
        state.fail(
          path,
          'title',
          IssueCodes.maxLength,
          DefaultMessages.maxLength,
          title,
          params: const <String, Object?>{'max': 255},
          messages: _messages,
        );
      }
    }
    if (tags is List<String>) {
      if (!(tags.length <= 5)) {
        state.fail(
          path,
          'tags',
          IssueCodes.maxItems,
          DefaultMessages.maxItems,
          tags,
          params: const <String, Object?>{'max': 5},
          messages: _messages,
        );
      } else {
        List<Object> q = <Object>[...path, 'tags'];
        for (int i = 0; i < tags.length; i++) {
          String v = tags[i];
          if (!(const Slug().check(v, state.context(q, i, v)))) {
            state.failRule(const Slug(), q, i, v, _messages);
          }
        }
      }
    }
    if (state.issues.length != issuesBefore) return null;
    return SavePost(
      title: title as String,
      body: body as String,
      status: status is Undefined ? PostStatus.draft : status as PostStatus,
      tags: tags is Undefined ? const <String>[] : tags as List<String>,
    );
  }

  @override
  SavePost fromMap(Map<String, dynamic> map) {
    return SavePost(
      title: map['title'] as String,
      body: map['body'] as String,
      status: map.containsKey('status')
          ? PostStatus.values.byName(map['status'] as String)
          : PostStatus.draft,
      tags: map.containsKey('tags')
          ? <String>[
              for (Object? x0 in map['tags'] as List<dynamic>) x0 as String,
            ]
          : const <String>[],
    );
  }

  @override
  Map<String, dynamic> toMap(SavePost dto) {
    return <String, dynamic>{
      'title': dto.title,
      'body': dto.body,
      'status': dto.status.name,
      'tags': dto.tags,
    };
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as SavePost));

  @override
  Map<String, dynamic> toJsonSchema() {
    Map<String, dynamic> schema = <String, dynamic>{
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
    JsonSchemaTools.merge(schema, <String>[
      'properties',
      'tags',
      'items',
    ], const Slug().toJsonSchema());
    return schema;
  }
}

/// The checks, the converter and the JSON Schema of [AddComment].
const DtoSchema<AddComment> $AddCommentDto = _$AddCommentDto();

class _$AddCommentDto extends DtoSchema<AddComment>
    implements JsonObjectWriter {
  const _$AddCommentDto();

  static const Map<String, String> _messages = <String, String>{};

  @override
  Type get type => AddComment;

  @override
  String get name => 'AddComment';

  @override
  bool get usesRequiredWhen => false;

  @override
  AddComment? convert(Object? input, DtoState state, List<Object> path) {
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
      trim: true,
    );
    if (body == null || body is Undefined)
      state.required(path, 'body', _messages);
    if (state.issues.length != issuesBefore && !state.allErrors) return null;
    if (body is String) {
      if (!(body.runes.length <= 1000)) {
        state.fail(
          path,
          'body',
          IssueCodes.maxLength,
          DefaultMessages.maxLength,
          body,
          params: const <String, Object?>{'max': 1000},
          messages: _messages,
        );
      }
    }
    if (state.issues.length != issuesBefore) return null;
    return AddComment(body: body as String);
  }

  @override
  AddComment fromMap(Map<String, dynamic> map) {
    return AddComment(body: map['body'] as String);
  }

  @override
  Map<String, dynamic> toMap(AddComment dto) {
    return <String, dynamic>{'body': dto.body};
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as AddComment));

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
