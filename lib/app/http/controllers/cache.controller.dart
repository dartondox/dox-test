import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/services/cache.service.dart';

/// /api/cache/{store}/... where store is memory, file or redis.
@Tags(<String>['Cache'])
class CacheController {
  final CacheService service;

  CacheController(this.service);

  /// Put a value
  ///
  /// Body: `{"value": any JSON, "ttl": seconds (optional)}`.
  Future<Map<String, dynamic>> put(
    DoxRequest req,
    String store,
    String key,
  ) async {
    Map<String, dynamic> data = await req.validateSchema(
      v.object(<String, Schema<Object?>>{
        'value': v.any(),
        'ttl': v.coerce.int().positive().optional(),
      }),
    );
    return await service.put(store, key, data['value'], data['ttl']);
  }

  /// Get a value
  Future<Map<String, dynamic>> get(
    DoxRequest req,
    String store,
    String key,
  ) async {
    return await service.get(store, key);
  }

  /// Forget a value
  Future<Map<String, dynamic>> forget(
    DoxRequest req,
    String store,
    String key,
  ) async {
    return await service.forget(store, key);
  }

  /// Remember: compute once, then read from the cache
  Future<Map<String, dynamic>> remember(
    DoxRequest req,
    String store,
    String key,
  ) async {
    return await service.remember(store, key);
  }

  /// Increment a number (body `{"by": 1}`)
  Future<Map<String, dynamic>> increment(
    DoxRequest req,
    String store,
    String key,
  ) async {
    int by = int.tryParse(req.input('by')?.toString() ?? '') ?? 1;
    return await service.increment(store, key, by);
  }

  /// Put a tagged value
  Future<Map<String, dynamic>> putTagged(
    DoxRequest req,
    String store,
    String tag,
    String key,
  ) async {
    return await service.putTagged(store, tag, key, req.input('value'));
  }

  /// Get a tagged value
  Future<Map<String, dynamic>> getTagged(
    DoxRequest req,
    String store,
    String tag,
    String key,
  ) async {
    return await service.getTagged(store, tag, key);
  }

  /// Flush one tag
  Future<Map<String, dynamic>> flushTag(
    DoxRequest req,
    String store,
    String tag,
  ) async {
    return await service.flushTag(store, tag);
  }

  /// Take a lock (memory and redis only)
  @Response(200, Map<String, dynamic>, description: '{got, owner}')
  @Response(422, null, description: 'This store has no locks')
  Future<Map<String, dynamic>> lock(
    DoxRequest req,
    String store,
    String name,
  ) async {
    int ttl = int.tryParse(req.input('ttl')?.toString() ?? '') ?? 30;
    return await service.lock(store, name, ttl);
  }

  /// Release a lock (`?owner=` from the lock call)
  Future<Map<String, dynamic>> release(
    DoxRequest req,
    String store,
    String name,
  ) async {
    return await service.release(
      store,
      name,
      req.input('owner')?.toString() ?? '',
    );
  }
}
