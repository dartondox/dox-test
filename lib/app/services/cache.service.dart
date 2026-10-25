import 'package:dox_core/dox_core.dart';
import 'package:dox_test/constants/app_constants.dart';

/// Tries every `Cache()` feature on one store: memory, file or redis.
@Inject()
class CacheService {
  /// The cache of one store. Unknown names give 404.
  Cache store(String name) {
    if (!AppConstants.cacheStores.contains(name)) {
      throw NotFoundHttpException(message: 'unknown cache store "$name"');
    }
    return Cache().store(name);
  }

  Future<Map<String, dynamic>> put(
    String name,
    String key,
    Object? value,
    int? ttlSeconds,
  ) async {
    Duration? ttl = ttlSeconds == null ? null : Duration(seconds: ttlSeconds);
    await store(name).put(key, value, duration: ttl);
    return <String, dynamic>{'key': key, 'value': value, 'ttl': ttlSeconds};
  }

  Future<Map<String, dynamic>> get(String name, String key) async {
    Cache cache = store(name);
    return <String, dynamic>{
      'key': key,
      'value': await cache.get(key),
      'has': await cache.has(key),
    };
  }

  Future<Map<String, dynamic>> forget(String name, String key) async {
    return <String, dynamic>{'forgot': await store(name).forget(key)};
  }

  /// `computed` is true only on the first call (a cache miss).
  Future<Map<String, dynamic>> remember(String name, String key) async {
    bool computed = false;
    String compute() {
      computed = true;
      return DateTime.now().toUtc().toIso8601String();
    }

    String value = await store(name)
        .remember(key, Duration(minutes: 10), compute);
    return <String, dynamic>{'value': value, 'computed': computed};
  }

  Future<Map<String, dynamic>> increment(
    String name,
    String key,
    int by,
  ) async {
    return <String, dynamic>{'value': await store(name).increment(key, by)};
  }

  Future<Map<String, dynamic>> putTagged(
    String name,
    String tag,
    String key,
    Object? value,
  ) async {
    await store(name).tag(tag).put(key, value);
    return <String, dynamic>{'tag': tag, 'key': key, 'value': value};
  }

  Future<Map<String, dynamic>> getTagged(
    String name,
    String tag,
    String key,
  ) async {
    return <String, dynamic>{'value': await store(name).tag(tag).get(key)};
  }

  /// Removes only the items of this tag.
  Future<Map<String, dynamic>> flushTag(String name, String tag) async {
    await store(name).tag(tag).flush();
    return <String, dynamic>{'flushed': tag};
  }

  /// `got` is false while someone else holds the lock.
  Future<Map<String, dynamic>> lock(String name, String lock, int ttl) async {
    CacheLock cacheLock = _lock(name, lock, Duration(seconds: ttl), null);
    return <String, dynamic>{
      'got': await cacheLock.get(),
      'owner': cacheLock.owner,
    };
  }

  /// Only the owner from `lock()` can release it.
  Future<Map<String, dynamic>> release(
    String name,
    String lock,
    String owner,
  ) async {
    CacheLock cacheLock = _lock(name, lock, null, owner);
    return <String, dynamic>{'released': await cacheLock.release()};
  }

  CacheLock _lock(String name, String lock, Duration? ttl, String? owner) {
    try {
      return store(name).lock(lock, ttl, owner);
    } on UnsupportedError {
      throw ValidationException(
        message: <String, String>{'store': 'the $name store has no locks'},
      );
    }
  }
}
