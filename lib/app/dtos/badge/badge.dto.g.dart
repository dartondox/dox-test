// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge.dto.dart';

// **************************************************************************
// DoxDtoGenerator
// **************************************************************************

// ignore_for_file: type=lint

/// The checks, the converter and the JSON Schema of [CreateBadge].
const DtoSchema<CreateBadge> $CreateBadgeDto = _$CreateBadgeDto();

class _$CreateBadgeDto extends DtoSchema<CreateBadge> {
  const _$CreateBadgeDto();

  static const Map<String, String> _m = <String, String>{};

  @override
  Type get type => CreateBadge;

  @override
  String get name => 'CreateBadge';

  @override
  bool get usesRequiredWhen => false;

  @override
  bool get isAsync => true;

  @override
  CreateBadge? convert(Object? input, DtoState s, List<Object> p) {
    if (input is! Map) {
      s.notObject(input, p, _m);
      return null;
    }
    int e = s.issues.length;
    // name: String
    Object? c0;
    c0 = s.string(s.read(input, 'name'), p, 'name', _m, trim: true);
    if (c0 == null || c0 is Undefined) s.required(p, 'name', _m);
    // code: String?
    Object? c1;
    c1 = s.string(s.read(input, 'code'), p, 'code', _m);
    // meta: String?
    Object? c2;
    c2 = s.string(s.read(input, 'meta'), p, 'meta', _m);
    // score: int
    Object? c3;
    c3 = s.integer(s.read(input, 'score'), p, 'score', _m);
    if (c3 == null) s.required(p, 'score', _m);
    // aliases: List<String>
    Object? c4;
    c4 = s.list(s.read(input, 'aliases'), p, 'aliases', _m);
    if (c4 is List) {
      List<Object> q0 = <Object>[...p, 'aliases'];
      List<String> o0 = <String>[];
      for (int i0 = 0; i0 < c4.length; i0++) {
        Object? x0;
        x0 = s.string(c4[i0], q0, i0, _m);
        if (x0 == null || x0 is Undefined) {
          s.required(q0, i0, _m);
        } else if (x0 is! Invalid) {
          o0.add(x0 as String);
        }
      }
      c4 = o0;
    }
    if (c4 == null) s.required(p, 'aliases', _m);
    // postIds: List<int>
    Object? c5;
    c5 = s.list(s.read(input, 'post_ids'), p, 'post_ids', _m);
    if (c5 is List) {
      List<Object> q0 = <Object>[...p, 'post_ids'];
      List<int> o0 = <int>[];
      for (int i0 = 0; i0 < c5.length; i0++) {
        Object? x0;
        x0 = s.integer(c5[i0], q0, i0, _m);
        if (x0 == null || x0 is Undefined) {
          s.required(q0, i0, _m);
        } else if (x0 is! Invalid) {
          o0.add(x0 as int);
        }
      }
      c5 = o0;
    }
    if (c5 == null) s.required(p, 'post_ids', _m);
    if (s.issues.length != e) return null;
    if (c0 is String) {
      if (!(c0.runes.length >= 2 && c0.runes.length <= 50)) {
        s.fail(
          p,
          'name',
          IssueCodes.lengthBetween,
          DefaultMessages.lengthBetween,
          c0,
          params: const <String, Object?>{'min': 2, 'max': 50},
          messages: _m,
        );
      }
    }
    if (c1 is String) {
      if (!(const Digits(4).check(c1, s.context(p, 'code', c1)))) {
        s.failRule(const Digits(4), p, 'code', c1, _m);
      }
    }
    if (c2 is String) {
      if (!(const Json().check(c2, s.context(p, 'meta', c2)))) {
        s.failRule(const Json(), p, 'meta', c2, _m);
      }
    }
    if (c3 is int) {
      if (!(c3 >= 0 && c3 <= 100)) {
        s.fail(
          p,
          'score',
          IssueCodes.between,
          DefaultMessages.between,
          c3,
          params: const <String, Object?>{'min': 0, 'max': 100},
          messages: _m,
        );
      }
    }
    if (c4 is List<String>) {
      if (!(c4.length <= 5)) {
        s.fail(
          p,
          'aliases',
          IssueCodes.maxItems,
          DefaultMessages.maxItems,
          c4,
          params: const <String, Object?>{'max': 5},
          messages: _m,
        );
      }
    }
    if (c5 is List<int>) {
      if (!(c5.length <= 10)) {
        s.fail(
          p,
          'post_ids',
          IssueCodes.maxItems,
          DefaultMessages.maxItems,
          c5,
          params: const <String, Object?>{'max': 10},
          messages: _m,
        );
      }
    }
    if (s.issues.length != e) return null;
    return CreateBadge(
      name: c0 as String,
      code: c1 is Undefined ? null : c1 as String?,
      meta: c2 is Undefined ? null : c2 as String?,
      score: c3 is Undefined ? 0 : c3 as int,
      aliases: c4 is Undefined ? const <String>[] : c4 as List<String>,
      postIds: c5 is Undefined ? const <int>[] : c5 as List<int>,
    );
  }

  @override
  Future<void> checkAsync(CreateBadge o, DtoState s, List<Object> p) async {
    {
      String f = o.name;
      await s.asyncRule(
        const Unique('badges', column: 'name'),
        f,
        p,
        'name',
        _m,
      );
    }
    {
      List<String> f = o.aliases;
      await s.asyncItems(
        const Unique('badges', column: 'name'),
        f,
        p,
        'aliases',
        _m,
      );
    }
    {
      List<int> f = o.postIds;
      await s.asyncItems(const Exists('posts'), f, p, 'post_ids', _m);
    }
  }

  @override
  CreateBadge fromMap(Map<String, dynamic> m) {
    return CreateBadge(
      name: m['name'] as String,
      code: m['code'] == null ? null : (m['code'] as String),
      meta: m['meta'] == null ? null : (m['meta'] as String),
      score: m.containsKey('score') ? (m['score'] as num).toInt() : 0,
      aliases: m.containsKey('aliases')
          ? <String>[
              for (Object? x0 in m['aliases'] as List<dynamic>) x0 as String,
            ]
          : const <String>[],
      postIds: m.containsKey('post_ids')
          ? <int>[
              for (Object? x0 in m['post_ids'] as List<dynamic>)
                (x0 as num).toInt(),
            ]
          : const <int>[],
    );
  }

  @override
  Map<String, dynamic> toMap(CreateBadge o) {
    String f0 = o.name;
    String? f1 = o.code;
    String? f2 = o.meta;
    int f3 = o.score;
    List<String> f4 = o.aliases;
    List<int> f5 = o.postIds;
    return <String, dynamic>{
      'name': f0,
      'code': f1,
      'meta': f2,
      'score': f3,
      'aliases': f4,
      'post_ids': f5,
    };
  }

  @override
  Map<String, dynamic> toJsonSchema() {
    Map<String, dynamic> j = <String, dynamic>{
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
    JsonSchemaTools.merge(j, <String>[
      'properties',
      'name',
    ], const Unique('badges', column: 'name').toJsonSchema());
    JsonSchemaTools.merge(j, <String>[
      'properties',
      'code',
    ], const Digits(4).toJsonSchema());
    JsonSchemaTools.merge(j, <String>[
      'properties',
      'meta',
    ], const Json().toJsonSchema());
    JsonSchemaTools.merge(j, <String>[
      'properties',
      'aliases',
      'items',
    ], const Unique('badges', column: 'name').toJsonSchema());
    JsonSchemaTools.merge(j, <String>[
      'properties',
      'post_ids',
      'items',
    ], const Exists('posts').toJsonSchema());
    return j;
  }
}

/// The checks, the converter and the JSON Schema of [ListBadges].
const DtoSchema<ListBadges> $ListBadgesDto = _$ListBadgesDto();

class _$ListBadgesDto extends DtoSchema<ListBadges> {
  const _$ListBadgesDto();

  static const Map<String, String> _m = <String, String>{};

  @override
  Type get type => ListBadges;

  @override
  String get name => 'ListBadges';

  @override
  bool get usesRequiredWhen => false;

  @override
  ListBadges? convert(Object? input, DtoState s, List<Object> p) {
    if (input is! Map) {
      s.notObject(input, p, _m);
      return null;
    }
    int e = s.issues.length;
    // cursor: String?
    Object? c0;
    c0 = s.string(s.read(input, 'cursor'), p, 'cursor', _m);
    // page: int
    Object? c1;
    c1 = s.integer(s.read(input, 'page'), p, 'page', _m);
    if (c1 == null) s.required(p, 'page', _m);
    // perPage: int
    Object? c2;
    c2 = s.integer(s.read(input, 'per_page'), p, 'per_page', _m);
    if (c2 == null) s.required(p, 'per_page', _m);
    if (s.issues.length != e) return null;
    if (c1 is int) {
      if (!(c1 >= 1)) {
        s.fail(
          p,
          'page',
          IssueCodes.min,
          DefaultMessages.min,
          c1,
          params: const <String, Object?>{'min': 1},
          messages: _m,
        );
      }
    }
    if (c2 is int) {
      if (!(c2 >= 1 && c2 <= 50)) {
        s.fail(
          p,
          'per_page',
          IssueCodes.between,
          DefaultMessages.between,
          c2,
          params: const <String, Object?>{'min': 1, 'max': 50},
          messages: _m,
        );
      }
    }
    if (s.issues.length != e) return null;
    return ListBadges(
      cursor: c0 is Undefined ? null : c0 as String?,
      page: c1 is Undefined ? 1 : c1 as int,
      perPage: c2 is Undefined ? 2 : c2 as int,
    );
  }

  @override
  ListBadges fromMap(Map<String, dynamic> m) {
    return ListBadges(
      cursor: m['cursor'] == null ? null : (m['cursor'] as String),
      page: m.containsKey('page') ? (m['page'] as num).toInt() : 1,
      perPage: m.containsKey('per_page') ? (m['per_page'] as num).toInt() : 2,
    );
  }

  @override
  Map<String, dynamic> toMap(ListBadges o) {
    String? f0 = o.cursor;
    int f1 = o.page;
    int f2 = o.perPage;
    return <String, dynamic>{'cursor': f0, 'page': f1, 'per_page': f2};
  }

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

class _$SyncBadgePostsDto extends DtoSchema<SyncBadgePosts> {
  const _$SyncBadgePostsDto();

  static const Map<String, String> _m = <String, String>{};

  @override
  Type get type => SyncBadgePosts;

  @override
  String get name => 'SyncBadgePosts';

  @override
  bool get usesRequiredWhen => false;

  @override
  bool get isAsync => true;

  @override
  SyncBadgePosts? convert(Object? input, DtoState s, List<Object> p) {
    if (input is! Map) {
      s.notObject(input, p, _m);
      return null;
    }
    int e = s.issues.length;
    // postIds: List<int>
    Object? c0;
    c0 = s.list(s.read(input, 'post_ids'), p, 'post_ids', _m);
    if (c0 is List) {
      List<Object> q0 = <Object>[...p, 'post_ids'];
      List<int> o0 = <int>[];
      for (int i0 = 0; i0 < c0.length; i0++) {
        Object? x0;
        x0 = s.integer(c0[i0], q0, i0, _m);
        if (x0 == null || x0 is Undefined) {
          s.required(q0, i0, _m);
        } else if (x0 is! Invalid) {
          o0.add(x0 as int);
        }
      }
      c0 = o0;
    }
    if (c0 == null || c0 is Undefined) s.required(p, 'post_ids', _m);
    // note: String?
    Object? c1;
    c1 = s.string(s.read(input, 'note'), p, 'note', _m);
    // detaching: bool
    Object? c2;
    c2 = s.boolean(s.read(input, 'detaching'), p, 'detaching', _m);
    if (c2 == null) s.required(p, 'detaching', _m);
    if (s.issues.length != e) return null;
    if (c0 is List<int>) {
      if (!(c0.length <= 10)) {
        s.fail(
          p,
          'post_ids',
          IssueCodes.maxItems,
          DefaultMessages.maxItems,
          c0,
          params: const <String, Object?>{'max': 10},
          messages: _m,
        );
      }
    }
    if (c1 is String) {
      if (!(c1.runes.length <= 50)) {
        s.fail(
          p,
          'note',
          IssueCodes.maxLength,
          DefaultMessages.maxLength,
          c1,
          params: const <String, Object?>{'max': 50},
          messages: _m,
        );
      }
    }
    if (s.issues.length != e) return null;
    return SyncBadgePosts(
      postIds: c0 as List<int>,
      note: c1 is Undefined ? null : c1 as String?,
      detaching: c2 is Undefined ? true : c2 as bool,
    );
  }

  @override
  Future<void> checkAsync(SyncBadgePosts o, DtoState s, List<Object> p) async {
    {
      List<int> f = o.postIds;
      await s.asyncItems(const Exists('posts'), f, p, 'post_ids', _m);
    }
  }

  @override
  SyncBadgePosts fromMap(Map<String, dynamic> m) {
    return SyncBadgePosts(
      postIds: <int>[
        for (Object? x0 in m['post_ids'] as List<dynamic>) (x0 as num).toInt(),
      ],
      note: m['note'] == null ? null : (m['note'] as String),
      detaching: m.containsKey('detaching') ? m['detaching'] as bool : true,
    );
  }

  @override
  Map<String, dynamic> toMap(SyncBadgePosts o) {
    List<int> f0 = o.postIds;
    String? f1 = o.note;
    bool f2 = o.detaching;
    return <String, dynamic>{'post_ids': f0, 'note': f1, 'detaching': f2};
  }

  @override
  Map<String, dynamic> toJsonSchema() {
    Map<String, dynamic> j = <String, dynamic>{
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
    JsonSchemaTools.merge(j, <String>[
      'properties',
      'post_ids',
      'items',
    ], const Exists('posts').toJsonSchema());
    return j;
  }
}

/// The checks, the converter and the JSON Schema of [AddReaction].
const DtoSchema<AddReaction> $AddReactionDto = _$AddReactionDto();

class _$AddReactionDto extends DtoSchema<AddReaction> {
  const _$AddReactionDto();

  static const Map<String, String> _m = <String, String>{};

  @override
  Type get type => AddReaction;

  @override
  String get name => 'AddReaction';

  @override
  bool get usesRequiredWhen => false;

  @override
  AddReaction? convert(Object? input, DtoState s, List<Object> p) {
    if (input is! Map) {
      s.notObject(input, p, _m);
      return null;
    }
    int e = s.issues.length;
    // emoji: String
    Object? c0;
    c0 = s.string(s.read(input, 'emoji'), p, 'emoji', _m, trim: true);
    if (c0 == null || c0 is Undefined) s.required(p, 'emoji', _m);
    if (s.issues.length != e) return null;
    if (c0 is String) {
      if (!(c0.runes.length >= 1 && c0.runes.length <= 20)) {
        s.fail(
          p,
          'emoji',
          IssueCodes.lengthBetween,
          DefaultMessages.lengthBetween,
          c0,
          params: const <String, Object?>{'min': 1, 'max': 20},
          messages: _m,
        );
      }
    }
    if (s.issues.length != e) return null;
    return AddReaction(emoji: c0 as String);
  }

  @override
  AddReaction fromMap(Map<String, dynamic> m) {
    return AddReaction(emoji: m['emoji'] as String);
  }

  @override
  Map<String, dynamic> toMap(AddReaction o) {
    String f0 = o.emoji;
    return <String, dynamic>{'emoji': f0};
  }

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
