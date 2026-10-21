// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache.dto.dart';

// **************************************************************************
// DoxDtoGenerator
// **************************************************************************

// ignore_for_file: type=lint

/// The checks, the converter and the JSON Schema of [PutCacheItem].
const DtoSchema<PutCacheItem> $PutCacheItemDto = _$PutCacheItemDto();

class _$PutCacheItemDto extends DtoSchema<PutCacheItem> {
  const _$PutCacheItemDto();

  static const Map<String, String> _m = <String, String>{};

  @override
  Type get type => PutCacheItem;

  @override
  String get name => 'PutCacheItem';

  @override
  PutCacheItem? convert(Object? input, DtoState s, List<Object> p) {
    if (input is! Map) {
      s.notObject(input, p, _m);
      return null;
    }
    int e = s.issues.length;
    // value: Object?
    Object? c0;
    c0 = s.read(input, 'value');
    // ttl: int?
    Object? c1;
    c1 = s.integer(s.read(input, 'ttl'), p, 'ttl', _m);
    if (s.issues.length != e) return null;
    if (c1 is int) {
      if (!(c1 > 0)) {
        s.fail(
          p,
          'ttl',
          IssueCodes.greaterThan,
          DefaultMessages.greaterThan,
          c1,
          params: const <String, Object?>{'min': 0},
          messages: _m,
        );
      }
    }
    if (s.issues.length != e) return null;
    return PutCacheItem(
      value: c0 is Undefined ? null : c0,
      ttl: c1 is Undefined ? null : c1 as int?,
    );
  }

  @override
  PutCacheItem fromMap(Map<String, dynamic> m) {
    return PutCacheItem(
      value: m['value'],
      ttl: m['ttl'] == null ? null : ((m['ttl'] as num).toInt()),
    );
  }

  @override
  Map<String, dynamic> toMap(PutCacheItem o) {
    Object? f0 = o.value;
    int? f1 = o.ttl;
    return <String, dynamic>{'value': f0, 'ttl': f1};
  }

  @override
  Map<String, dynamic> toJsonSchema() {
    return <String, dynamic>{
      'type': 'object',
      'title': 'PutCacheItem',
      'properties': <String, dynamic>{
        'value': <String, dynamic>{
          'anyOf': <dynamic>[
            <String, dynamic>{'description': 'Any JSON value. Not checked.'},
            <String, dynamic>{'type': 'null'},
          ],
        },
        'ttl': <String, dynamic>{
          'type': <dynamic>['integer', 'null'],
          'exclusiveMinimum': 0,
          'description': 'Seconds. Empty means forever.',
        },
      },
    };
  }
}

/// The checks, the converter and the JSON Schema of [IncrementCache].
const DtoSchema<IncrementCache> $IncrementCacheDto = _$IncrementCacheDto();

class _$IncrementCacheDto extends DtoSchema<IncrementCache> {
  const _$IncrementCacheDto();

  static const Map<String, String> _m = <String, String>{};

  @override
  Type get type => IncrementCache;

  @override
  String get name => 'IncrementCache';

  @override
  IncrementCache? convert(Object? input, DtoState s, List<Object> p) {
    if (input is! Map) {
      s.notObject(input, p, _m);
      return null;
    }
    int e = s.issues.length;
    // by: int
    Object? c0;
    c0 = s.integer(s.read(input, 'by'), p, 'by', _m);
    if (c0 == null) s.required(p, 'by', _m);
    if (s.issues.length != e) return null;
    return IncrementCache(by: c0 is Undefined ? 1 : c0 as int);
  }

  @override
  IncrementCache fromMap(Map<String, dynamic> m) {
    return IncrementCache(
      by: m.containsKey('by') ? (m['by'] as num).toInt() : 1,
    );
  }

  @override
  Map<String, dynamic> toMap(IncrementCache o) {
    int f0 = o.by;
    return <String, dynamic>{'by': f0};
  }

  @override
  Map<String, dynamic> toJsonSchema() {
    return <String, dynamic>{
      'type': 'object',
      'title': 'IncrementCache',
      'properties': <String, dynamic>{
        'by': <String, dynamic>{'type': 'integer', 'default': 1},
      },
    };
  }
}

/// The checks, the converter and the JSON Schema of [TakeLock].
const DtoSchema<TakeLock> $TakeLockDto = _$TakeLockDto();

class _$TakeLockDto extends DtoSchema<TakeLock> {
  const _$TakeLockDto();

  static const Map<String, String> _m = <String, String>{};

  @override
  Type get type => TakeLock;

  @override
  String get name => 'TakeLock';

  @override
  TakeLock? convert(Object? input, DtoState s, List<Object> p) {
    if (input is! Map) {
      s.notObject(input, p, _m);
      return null;
    }
    int e = s.issues.length;
    // ttl: int
    Object? c0;
    c0 = s.integer(s.read(input, 'ttl'), p, 'ttl', _m);
    if (c0 == null) s.required(p, 'ttl', _m);
    if (s.issues.length != e) return null;
    if (c0 is int) {
      if (!(c0 > 0)) {
        s.fail(
          p,
          'ttl',
          IssueCodes.greaterThan,
          DefaultMessages.greaterThan,
          c0,
          params: const <String, Object?>{'min': 0},
          messages: _m,
        );
      }
    }
    if (s.issues.length != e) return null;
    return TakeLock(ttl: c0 is Undefined ? 30 : c0 as int);
  }

  @override
  TakeLock fromMap(Map<String, dynamic> m) {
    return TakeLock(ttl: m.containsKey('ttl') ? (m['ttl'] as num).toInt() : 30);
  }

  @override
  Map<String, dynamic> toMap(TakeLock o) {
    int f0 = o.ttl;
    return <String, dynamic>{'ttl': f0};
  }

  @override
  Map<String, dynamic> toJsonSchema() {
    return <String, dynamic>{
      'type': 'object',
      'title': 'TakeLock',
      'properties': <String, dynamic>{
        'ttl': <String, dynamic>{
          'type': 'integer',
          'exclusiveMinimum': 0,
          'description': 'Seconds.',
          'default': 30,
        },
      },
    };
  }
}

/// The checks, the converter and the JSON Schema of [ReleaseLock].
const DtoSchema<ReleaseLock> $ReleaseLockDto = _$ReleaseLockDto();

class _$ReleaseLockDto extends DtoSchema<ReleaseLock> {
  const _$ReleaseLockDto();

  static const Map<String, String> _m = <String, String>{};

  @override
  Type get type => ReleaseLock;

  @override
  String get name => 'ReleaseLock';

  @override
  ReleaseLock? convert(Object? input, DtoState s, List<Object> p) {
    if (input is! Map) {
      s.notObject(input, p, _m);
      return null;
    }
    int e = s.issues.length;
    // owner: String
    Object? c0;
    c0 = s.string(s.read(input, 'owner'), p, 'owner', _m);
    if (c0 == null || c0 is Undefined) s.required(p, 'owner', _m);
    if (s.issues.length != e) return null;
    return ReleaseLock(owner: c0 as String);
  }

  @override
  ReleaseLock fromMap(Map<String, dynamic> m) {
    return ReleaseLock(owner: m['owner'] as String);
  }

  @override
  Map<String, dynamic> toMap(ReleaseLock o) {
    String f0 = o.owner;
    return <String, dynamic>{'owner': f0};
  }

  @override
  Map<String, dynamic> toJsonSchema() {
    return <String, dynamic>{
      'type': 'object',
      'title': 'ReleaseLock',
      'properties': <String, dynamic>{
        'owner': <String, dynamic>{
          'type': 'string',
          'description': 'The `owner` from the lock call.',
        },
      },
      'required': <dynamic>['owner'],
    };
  }
}
