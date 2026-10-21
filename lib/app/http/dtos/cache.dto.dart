import 'package:dox_core/dox_core.dart';

part 'cache.dto.g.dart';

/// Body of PUT /api/cache/{store}/items/{key} and .../tags/{tag}/{key}.
@Dto()
class PutCacheItem {
  /// Any JSON value. Not checked.
  final Object? value;

  /// Seconds. Empty means forever.
  @Positive()
  final int? ttl;

  const PutCacheItem({this.value, this.ttl});

  static const DtoSchema<PutCacheItem> schema = $PutCacheItemDto;
}

/// Body of POST /api/cache/{store}/increment/{key}.
@Dto()
class IncrementCache {
  final int by;

  const IncrementCache({this.by = 1});

  static const DtoSchema<IncrementCache> schema = $IncrementCacheDto;
}

/// Body of POST /api/cache/{store}/locks/{name}.
@Dto()
class TakeLock {
  /// Seconds.
  @Positive()
  final int ttl;

  const TakeLock({this.ttl = 30});

  static const DtoSchema<TakeLock> schema = $TakeLockDto;
}

/// Query of DELETE /api/cache/{store}/locks/{name}.
@Dto()
class ReleaseLock {
  /// The `owner` from the lock call.
  final String owner;

  const ReleaseLock({required this.owner});

  static const DtoSchema<ReleaseLock> schema = $ReleaseLockDto;
}
