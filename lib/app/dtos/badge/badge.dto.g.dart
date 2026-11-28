// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge.dto.dart';

// **************************************************************************
// DoxDtoGenerator
// **************************************************************************

// ignore_for_file: type=lint

/// The checks, the converter and the JSON Schema of [CreateBadge].
const DtoSchema<CreateBadge> $CreateBadgeDto = _$CreateBadgeDto();

class _$CreateBadgeDto extends DtoSchema<CreateBadge>
    implements JsonObjectWriter {
  const _$CreateBadgeDto();

  static const Map<String, String> _messages = <String, String>{};

  @override
  Type get type => CreateBadge;

  @override
  String get name => 'CreateBadge';

  @override
  bool get usesRequiredWhen => false;

  @override
  bool get isAsync => true;

  @override
  CreateBadge? convert(Object? input, DtoState state, List<Object> path) {
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
    // code: String?
    Object? code = state.string(
      state.read(input, 'code'),
      path,
      'code',
      _messages,
    );
    // meta: String?
    Object? meta = state.string(
      state.read(input, 'meta'),
      path,
      'meta',
      _messages,
    );
    // score: int
    Object? score = state.integer(
      state.read(input, 'score'),
      path,
      'score',
      _messages,
    );
    if (score == null) state.required(path, 'score', _messages);
    // aliases: List<String>
    Object? aliases = state.list(
      state.read(input, 'aliases'),
      path,
      'aliases',
      _messages,
    );
    if (aliases is List) {
      int b0 = state.issues.length;
      List<Object> q0 = <Object>[...path, 'aliases'];
      List<String> o0 = <String>[];
      for (int i0 = 0; i0 < aliases.length; i0++) {
        Object? x0 = state.string(aliases[i0], q0, i0, _messages);
        if (x0 == null || x0 is Undefined) {
          state.required(q0, i0, _messages);
        } else if (x0 is! Invalid) {
          o0.add(x0 as String);
        }
      }
      aliases = state.issues.length != b0 ? invalid : o0;
    }
    if (aliases == null) state.required(path, 'aliases', _messages);
    // postIds: List<int>
    Object? postIds = state.list(
      state.read(input, 'post_ids'),
      path,
      'post_ids',
      _messages,
    );
    if (postIds is List) {
      int b0 = state.issues.length;
      List<Object> q0 = <Object>[...path, 'post_ids'];
      List<int> o0 = <int>[];
      for (int i0 = 0; i0 < postIds.length; i0++) {
        Object? x0 = state.integer(postIds[i0], q0, i0, _messages);
        if (x0 == null || x0 is Undefined) {
          state.required(q0, i0, _messages);
        } else if (x0 is! Invalid) {
          o0.add(x0 as int);
        }
      }
      postIds = state.issues.length != b0 ? invalid : o0;
    }
    if (postIds == null) state.required(path, 'post_ids', _messages);
    if (state.issues.length != issuesBefore && !state.allErrors) return null;
    if (name is String) {
      if (!(name.runes.length >= 2 && name.runes.length <= 50)) {
        state.fail(
          path,
          'name',
          IssueCodes.lengthBetween,
          DefaultMessages.lengthBetween,
          name,
          params: const <String, Object?>{'min': 2, 'max': 50},
          messages: _messages,
        );
      }
    }
    if (code is String) {
      if (!(const Digits(4).check(code, state.context(path, 'code', code)))) {
        state.failRule(const Digits(4), path, 'code', code, _messages);
      }
    }
    if (meta is String) {
      if (!(const Json().check(meta, state.context(path, 'meta', meta)))) {
        state.failRule(const Json(), path, 'meta', meta, _messages);
      }
    }
    if (score is int) {
      if (!(score >= 0 && score <= 100)) {
        state.fail(
          path,
          'score',
          IssueCodes.between,
          DefaultMessages.between,
          score,
          params: const <String, Object?>{'min': 0, 'max': 100},
          messages: _messages,
        );
      }
    }
    if (aliases is List<String>) {
      if (!(aliases.length <= 5)) {
        state.fail(
          path,
          'aliases',
          IssueCodes.maxItems,
          DefaultMessages.maxItems,
          aliases,
          params: const <String, Object?>{'max': 5},
          messages: _messages,
        );
      }
    }
    if (postIds is List<int>) {
      if (!(postIds.length <= 10)) {
        state.fail(
          path,
          'post_ids',
          IssueCodes.maxItems,
          DefaultMessages.maxItems,
          postIds,
          params: const <String, Object?>{'max': 10},
          messages: _messages,
        );
      }
    }
    if (state.issues.length != issuesBefore) return null;
    return CreateBadge(
      name: name as String,
      code: code is Undefined ? null : code as String?,
      meta: meta is Undefined ? null : meta as String?,
      score: score is Undefined ? 0 : score as int,
      aliases: aliases is Undefined
          ? const <String>[]
          : aliases as List<String>,
      postIds: postIds is Undefined ? const <int>[] : postIds as List<int>,
    );
  }

  @override
  Future<void> checkAsync(
    CreateBadge dto,
    DtoState state,
    List<Object> path,
  ) async {
    {
      String value = dto.name;
      await state.asyncRule(
        const Unique('badges', column: 'name'),
        value,
        path,
        'name',
        _messages,
      );
    }
    {
      List<String> value = dto.aliases;
      await state.asyncItems(
        const Unique('badges', column: 'name'),
        value,
        path,
        'aliases',
        _messages,
      );
    }
    {
      List<int> value = dto.postIds;
      await state.asyncItems(
        const Exists('posts'),
        value,
        path,
        'post_ids',
        _messages,
      );
    }
  }

  @override
  CreateBadge fromMap(Map<String, dynamic> map) {
    return CreateBadge(
      name: map['name'] as String,
      code: map['code'] == null ? null : (map['code'] as String),
      meta: map['meta'] == null ? null : (map['meta'] as String),
      score: map.containsKey('score') ? (map['score'] as num).toInt() : 0,
      aliases: map.containsKey('aliases')
          ? <String>[
              for (Object? x0 in map['aliases'] as List<dynamic>) x0 as String,
            ]
          : const <String>[],
      postIds: map.containsKey('post_ids')
          ? <int>[
              for (Object? x0 in map['post_ids'] as List<dynamic>)
                (x0 as num).toInt(),
            ]
          : const <int>[],
    );
  }

  @override
  Map<String, dynamic> toMap(CreateBadge dto) {
    return <String, dynamic>{
      'name': dto.name,
      'code': dto.code,
      'meta': dto.meta,
      'score': dto.score,
      'aliases': dto.aliases,
      'post_ids': dto.postIds,
    };
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as CreateBadge));

  @override
  Map<String, dynamic> toJsonSchema() {
    Map<String, dynamic> schema = <String, dynamic>{
      'type': 'object',
      'title': 'CreateBadge',
      'properties': <String, dynamic>{
        'name': <String, dynamic>{
          'type': 'string',
          'minLength': 2,
          'maxLength': 50,
          'description': 'The database decides if the name is taken.',
        },
        'code': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
          'description': 'Four digits, like `0042`.',
        },
        'meta': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
          'description': 'Extra data as JSON text, like `{"color":"red"}`.',
        },
        'score': <String, dynamic>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 100,
          'default': 0,
        },
        'aliases': <String, dynamic>{
          'type': 'array',
          'items': <String, dynamic>{'type': 'string'},
          'maxItems': 5,
          'description': 'Other names this badge wants to keep free. Each one must not be taken\n(a list with `@Unique` is one query).',
          'default': <dynamic>[],
        },
        'post_ids': <String, dynamic>{
          'type': 'array',
          'items': <String, dynamic>{'type': 'integer'},
          'maxItems': 10,
          'description': 'Posts that get the badge. Each one must exist.',
          'default': <dynamic>[],
        },
      },
      'required': <dynamic>['name'],
    };
    JsonSchemaTools.merge(schema, <String>[
      'properties',
      'name',
    ], const Unique('badges', column: 'name').toJsonSchema());
    JsonSchemaTools.merge(schema, <String>[
      'properties',
      'code',
    ], const Digits(4).toJsonSchema());
    JsonSchemaTools.merge(schema, <String>[
      'properties',
      'meta',
    ], const Json().toJsonSchema());
    JsonSchemaTools.merge(schema, <String>[
      'properties',
      'aliases',
      'items',
    ], const Unique('badges', column: 'name').toJsonSchema());
    JsonSchemaTools.merge(schema, <String>[
      'properties',
      'post_ids',
      'items',
    ], const Exists('posts').toJsonSchema());
    return schema;
  }
}

/// The checks, the converter and the JSON Schema of [ListBadges].
const DtoSchema<ListBadges> $ListBadgesDto = _$ListBadgesDto();

class _$ListBadgesDto extends DtoSchema<ListBadges>
    implements JsonObjectWriter {
  const _$ListBadgesDto();

  static const Map<String, String> _messages = <String, String>{};

  @override
  Type get type => ListBadges;

  @override
  String get name => 'ListBadges';

  @override
  bool get usesRequiredWhen => false;

  @override
  ListBadges? convert(Object? input, DtoState state, List<Object> path) {
    if (input is! Map) {
      state.notObject(input, path, _messages);
      return null;
    }
    int issuesBefore = state.issues.length;
    // cursor: String?
    Object? cursor = state.string(
      state.read(input, 'cursor'),
      path,
      'cursor',
      _messages,
    );
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
      if (!(perPage >= 1 && perPage <= 50)) {
        state.fail(
          path,
          'per_page',
          IssueCodes.between,
          DefaultMessages.between,
          perPage,
          params: const <String, Object?>{'min': 1, 'max': 50},
          messages: _messages,
        );
      }
    }
    if (state.issues.length != issuesBefore) return null;
    return ListBadges(
      cursor: cursor is Undefined ? null : cursor as String?,
      page: page is Undefined ? 1 : page as int,
      perPage: perPage is Undefined ? 2 : perPage as int,
    );
  }

  @override
  ListBadges fromMap(Map<String, dynamic> map) {
    return ListBadges(
      cursor: map['cursor'] == null ? null : (map['cursor'] as String),
      page: map.containsKey('page') ? (map['page'] as num).toInt() : 1,
      perPage: map.containsKey('per_page')
          ? (map['per_page'] as num).toInt()
          : 2,
    );
  }

  @override
  Map<String, dynamic> toMap(ListBadges dto) {
    return <String, dynamic>{
      'cursor': dto.cursor,
      'page': dto.page,
      'per_page': dto.perPage,
    };
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as ListBadges));

  @override
  Map<String, dynamic> toJsonSchema() {
    return <String, dynamic>{
      'type': 'object',
      'title': 'ListBadges',
      'properties': <String, dynamic>{
        'cursor': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
          'description':
              'The `next_cursor` or `prev_cursor` of the page before.',
        },
        'page': <String, dynamic>{
          'type': 'integer',
          'minimum': 1,
          'default': 1,
        },
        'per_page': <String, dynamic>{
          'type': 'integer',
          'minimum': 1,
          'maximum': 50,
          'default': 2,
        },
      },
    };
  }
}

/// The checks, the converter and the JSON Schema of [SyncBadgePosts].
const DtoSchema<SyncBadgePosts> $SyncBadgePostsDto = _$SyncBadgePostsDto();

class _$SyncBadgePostsDto extends DtoSchema<SyncBadgePosts>
    implements JsonObjectWriter {
  const _$SyncBadgePostsDto();

  static const Map<String, String> _messages = <String, String>{};

  @override
  Type get type => SyncBadgePosts;

  @override
  String get name => 'SyncBadgePosts';

  @override
  bool get usesRequiredWhen => false;

  @override
  bool get isAsync => true;

  @override
  SyncBadgePosts? convert(Object? input, DtoState state, List<Object> path) {
    if (input is! Map) {
      state.notObject(input, path, _messages);
      return null;
    }
    int issuesBefore = state.issues.length;
    // postIds: List<int>
    Object? postIds = state.list(
      state.read(input, 'post_ids'),
      path,
      'post_ids',
      _messages,
    );
    if (postIds is List) {
      int b0 = state.issues.length;
      List<Object> q0 = <Object>[...path, 'post_ids'];
      List<int> o0 = <int>[];
      for (int i0 = 0; i0 < postIds.length; i0++) {
        Object? x0 = state.integer(postIds[i0], q0, i0, _messages);
        if (x0 == null || x0 is Undefined) {
          state.required(q0, i0, _messages);
        } else if (x0 is! Invalid) {
          o0.add(x0 as int);
        }
      }
      postIds = state.issues.length != b0 ? invalid : o0;
    }
    if (postIds == null || postIds is Undefined || state.emptyList(postIds)) {
      state.required(path, 'post_ids', _messages);
      postIds = invalid;
    }
    // note: String?
    Object? note = state.string(
      state.read(input, 'note'),
      path,
      'note',
      _messages,
    );
    // detaching: bool
    Object? detaching = state.boolean(
      state.read(input, 'detaching'),
      path,
      'detaching',
      _messages,
    );
    if (detaching == null) state.required(path, 'detaching', _messages);
    if (state.issues.length != issuesBefore && !state.allErrors) return null;
    if (postIds is List<int>) {
      if (!(postIds.length <= 10)) {
        state.fail(
          path,
          'post_ids',
          IssueCodes.maxItems,
          DefaultMessages.maxItems,
          postIds,
          params: const <String, Object?>{'max': 10},
          messages: _messages,
        );
      }
    }
    if (note is String) {
      if (!(note.runes.length <= 50)) {
        state.fail(
          path,
          'note',
          IssueCodes.maxLength,
          DefaultMessages.maxLength,
          note,
          params: const <String, Object?>{'max': 50},
          messages: _messages,
        );
      }
    }
    if (state.issues.length != issuesBefore) return null;
    return SyncBadgePosts(
      postIds: postIds as List<int>,
      note: note is Undefined ? null : note as String?,
      detaching: detaching is Undefined ? true : detaching as bool,
    );
  }

  @override
  Future<void> checkAsync(
    SyncBadgePosts dto,
    DtoState state,
    List<Object> path,
  ) async {
    {
      List<int> value = dto.postIds;
      await state.asyncItems(
        const Exists('posts'),
        value,
        path,
        'post_ids',
        _messages,
      );
    }
  }

  @override
  SyncBadgePosts fromMap(Map<String, dynamic> map) {
    return SyncBadgePosts(
      postIds: <int>[
        for (Object? x0 in map['post_ids'] as List<dynamic>)
          (x0 as num).toInt(),
      ],
      note: map['note'] == null ? null : (map['note'] as String),
      detaching: map.containsKey('detaching') ? map['detaching'] as bool : true,
    );
  }

  @override
  Map<String, dynamic> toMap(SyncBadgePosts dto) {
    return <String, dynamic>{
      'post_ids': dto.postIds,
      'note': dto.note,
      'detaching': dto.detaching,
    };
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as SyncBadgePosts));

  @override
  Map<String, dynamic> toJsonSchema() {
    Map<String, dynamic> schema = <String, dynamic>{
      'type': 'object',
      'title': 'SyncBadgePosts',
      'properties': <String, dynamic>{
        'post_ids': <String, dynamic>{
          'type': 'array',
          'items': <String, dynamic>{'type': 'integer'},
          'maxItems': 10,
        },
        'note': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
          'maxLength': 50,
          'description': 'Saved in the pivot row of every given post.',
        },
        'detaching': <String, dynamic>{
          'type': 'boolean',
          'description': '`false` keeps the posts that are not in the list.',
          'default': true,
        },
      },
      'required': <dynamic>['post_ids'],
    };
    JsonSchemaTools.merge(schema, <String>[
      'properties',
      'post_ids',
      'items',
    ], const Exists('posts').toJsonSchema());
    return schema;
  }
}

/// The checks, the converter and the JSON Schema of [AddReaction].
const DtoSchema<AddReaction> $AddReactionDto = _$AddReactionDto();

class _$AddReactionDto extends DtoSchema<AddReaction>
    implements JsonObjectWriter {
  const _$AddReactionDto();

  static const Map<String, String> _messages = <String, String>{};

  @override
  Type get type => AddReaction;

  @override
  String get name => 'AddReaction';

  @override
  bool get usesRequiredWhen => false;

  @override
  AddReaction? convert(Object? input, DtoState state, List<Object> path) {
    if (input is! Map) {
      state.notObject(input, path, _messages);
      return null;
    }
    int issuesBefore = state.issues.length;
    // emoji: String
    Object? emoji = state.string(
      state.read(input, 'emoji'),
      path,
      'emoji',
      _messages,
      trim: true,
    );
    if (emoji == null || emoji is Undefined)
      state.required(path, 'emoji', _messages);
    if (state.issues.length != issuesBefore && !state.allErrors) return null;
    if (emoji is String) {
      if (!(emoji.runes.length >= 1 && emoji.runes.length <= 20)) {
        state.fail(
          path,
          'emoji',
          IssueCodes.lengthBetween,
          DefaultMessages.lengthBetween,
          emoji,
          params: const <String, Object?>{'min': 1, 'max': 20},
          messages: _messages,
        );
      }
    }
    if (state.issues.length != issuesBefore) return null;
    return AddReaction(emoji: emoji as String);
  }

  @override
  AddReaction fromMap(Map<String, dynamic> map) {
    return AddReaction(emoji: map['emoji'] as String);
  }

  @override
  Map<String, dynamic> toMap(AddReaction dto) {
    return <String, dynamic>{'emoji': dto.emoji};
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as AddReaction));

  @override
  Map<String, dynamic> toJsonSchema() {
    return <String, dynamic>{
      'type': 'object',
      'title': 'AddReaction',
      'properties': <String, dynamic>{
        'emoji': <String, dynamic>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 20,
        },
      },
      'required': <dynamic>['emoji'],
    };
  }
}
