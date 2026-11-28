// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache.dto.dart';

// **************************************************************************
// DoxDtoGenerator
// **************************************************************************

// ignore_for_file: type=lint

/// The checks, the converter and the JSON Schema of [PutCacheItem].
const DtoSchema<PutCacheItem> $PutCacheItemDto = _$PutCacheItemDto();

class _$PutCacheItemDto extends DtoSchema<PutCacheItem>
    implements JsonObjectWriter {
  const _$PutCacheItemDto();

  static const Map<String, String> _messages = <String, String>{};

  @override
  Type get type => PutCacheItem;

  @override
  String get name => 'PutCacheItem';

  @override
  bool get usesRequiredWhen => false;

  @override
  PutCacheItem? convert(Object? input, DtoState state, List<Object> path) {
    if (input is! Map) {
      state.notObject(input, path, _messages);
      return null;
    }
    int issuesBefore = state.issues.length;
    // value: Object?
    Object? value = state.read(input, 'value');
    // ttl: int?
    Object? ttl = state.integer(
      state.read(input, 'ttl'),
      path,
      'ttl',
      _messages,
    );
    if (state.issues.length != issuesBefore && !state.allErrors) return null;
    if (ttl is int) {
      if (!(ttl > 0)) {
        state.fail(
          path,
          'ttl',
          IssueCodes.greaterThan,
          DefaultMessages.greaterThan,
          ttl,
          params: const <String, Object?>{'min': 0},
          messages: _messages,
        );
      }
    }
    if (state.issues.length != issuesBefore) return null;
    return PutCacheItem(
      value: value is Undefined ? null : value,
      ttl: ttl is Undefined ? null : ttl as int?,
    );
  }

  @override
  PutCacheItem fromMap(Map<String, dynamic> map) {
    return PutCacheItem(
      value: map['value'],
      ttl: map['ttl'] == null ? null : ((map['ttl'] as num).toInt()),
    );
  }

  @override
  Map<String, dynamic> toMap(PutCacheItem dto) {
    return <String, dynamic>{'value': dto.value, 'ttl': dto.ttl};
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as PutCacheItem));

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

class _$IncrementCacheDto extends DtoSchema<IncrementCache>
    implements JsonObjectWriter {
  const _$IncrementCacheDto();

  static const Map<String, String> _messages = <String, String>{};

  @override
  Type get type => IncrementCache;

  @override
  String get name => 'IncrementCache';

  @override
  bool get usesRequiredWhen => false;

  @override
  IncrementCache? convert(Object? input, DtoState state, List<Object> path) {
    if (input is! Map) {
      state.notObject(input, path, _messages);
      return null;
    }
    int issuesBefore = state.issues.length;
    // by: int
    Object? by = state.integer(state.read(input, 'by'), path, 'by', _messages);
    if (by == null) state.required(path, 'by', _messages);
    if (state.issues.length != issuesBefore && !state.allErrors) return null;
    if (state.issues.length != issuesBefore) return null;
    return IncrementCache(by: by is Undefined ? 1 : by as int);
  }

  @override
  IncrementCache fromMap(Map<String, dynamic> map) {
    return IncrementCache(
      by: map.containsKey('by') ? (map['by'] as num).toInt() : 1,
    );
  }

  @override
  Map<String, dynamic> toMap(IncrementCache dto) {
    return <String, dynamic>{'by': dto.by};
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as IncrementCache));

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

class _$TakeLockDto extends DtoSchema<TakeLock> implements JsonObjectWriter {
  const _$TakeLockDto();

  static const Map<String, String> _messages = <String, String>{};

  @override
  Type get type => TakeLock;

  @override
  String get name => 'TakeLock';

  @override
  bool get usesRequiredWhen => false;

  @override
  TakeLock? convert(Object? input, DtoState state, List<Object> path) {
    if (input is! Map) {
      state.notObject(input, path, _messages);
      return null;
    }
    int issuesBefore = state.issues.length;
    // ttl: int
    Object? ttl = state.integer(
      state.read(input, 'ttl'),
      path,
      'ttl',
      _messages,
    );
    if (ttl == null) state.required(path, 'ttl', _messages);
    if (state.issues.length != issuesBefore && !state.allErrors) return null;
    if (ttl is int) {
      if (!(ttl > 0)) {
        state.fail(
          path,
          'ttl',
          IssueCodes.greaterThan,
          DefaultMessages.greaterThan,
          ttl,
          params: const <String, Object?>{'min': 0},
          messages: _messages,
        );
      }
    }
    if (state.issues.length != issuesBefore) return null;
    return TakeLock(ttl: ttl is Undefined ? 30 : ttl as int);
  }

  @override
  TakeLock fromMap(Map<String, dynamic> map) {
    return TakeLock(
      ttl: map.containsKey('ttl') ? (map['ttl'] as num).toInt() : 30,
    );
  }

  @override
  Map<String, dynamic> toMap(TakeLock dto) {
    return <String, dynamic>{'ttl': dto.ttl};
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as TakeLock));

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

class _$ReleaseLockDto extends DtoSchema<ReleaseLock>
    implements JsonObjectWriter {
  const _$ReleaseLockDto();

  static const Map<String, String> _messages = <String, String>{};

  @override
  Type get type => ReleaseLock;

  @override
  String get name => 'ReleaseLock';

  @override
  bool get usesRequiredWhen => false;

  @override
  ReleaseLock? convert(Object? input, DtoState state, List<Object> path) {
    if (input is! Map) {
      state.notObject(input, path, _messages);
      return null;
    }
    int issuesBefore = state.issues.length;
    // owner: String
    Object? owner = state.string(
      state.read(input, 'owner'),
      path,
      'owner',
      _messages,
    );
    if (owner == null || owner is Undefined)
      state.required(path, 'owner', _messages);
    if (state.issues.length != issuesBefore && !state.allErrors) return null;
    if (state.issues.length != issuesBefore) return null;
    return ReleaseLock(owner: owner as String);
  }

  @override
  ReleaseLock fromMap(Map<String, dynamic> map) {
    return ReleaseLock(owner: map['owner'] as String);
  }

  @override
  Map<String, dynamic> toMap(ReleaseLock dto) {
    return <String, dynamic>{'owner': dto.owner};
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as ReleaseLock));

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
