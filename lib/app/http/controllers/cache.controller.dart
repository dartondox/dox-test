import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/http/dtos/cache/cache.dto.dart';
import 'package:dox_test/app/services/cache.service.dart';

/// /api/cache/{store}/... where store is memory, file or redis.
@Tags(<String>['Cache'])
@Inject()
class CacheController {
  final CacheService service;

  CacheController(this.service);

  /// Put a value
  ///
  /// Body: `{"value": any JSON, "ttl": seconds (optional)}`.
  Future<Map<String, dynamic>> put(
    String store,
    String key,
    PutCacheItem body,
  ) async {
    return await service.put(store, key, body.value, body.ttl);
  }

  /// Get a value
  Future<Map<String, dynamic>> get(String store, String key) async {
    return await service.get(store, key);
  }

  /// Forget a value
  Future<Map<String, dynamic>> forget(String store, String key) async {
    return await service.forget(store, key);
  }

  /// Remember: compute once, then read from the cache
  Future<Map<String, dynamic>> remember(String store, String key) async {
    return await service.remember(store, key);
  }

  /// Increment a number (body `{"by": 1}`)
  Future<Map<String, dynamic>> increment(
    String store,
    String key,
    IncrementCache body,
  ) async {
    return await service.increment(store, key, body.by);
  }

  /// Put a tagged value
  Future<Map<String, dynamic>> putTagged(
    String store,
    String tag,
    String key,
    PutCacheItem body,
  ) async {
    return await service.putTagged(store, tag, key, body.value);
  }

  /// Get a tagged value
  Future<Map<String, dynamic>> getTagged(
    String store,
    String tag,
    String key,
  ) async {
    return await service.getTagged(store, tag, key);
  }

  /// Flush one tag
  Future<Map<String, dynamic>> flushTag(String store, String tag) async {
    return await service.flushTag(store, tag);
  }

  /// Take a lock (memory and redis only)
  @Response(200, Map<String, dynamic>, description: '{got, owner}')
  @Response(422, null, description: 'This store has no locks')
  Future<Map<String, dynamic>> lock(
    String store,
    String name,
    TakeLock body,
  ) async {
    return await service.lock(store, name, body.ttl);
  }

  /// Release a lock (`?owner=` from the lock call)
  Future<Map<String, dynamic>> release(
    String store,
    String name,
    ReleaseLock query,
  ) async {
    return await service.release(store, name, query.owner);
  }
}
