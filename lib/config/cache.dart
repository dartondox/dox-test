import 'package:dox_test/config/env.dart';
import 'package:dox_core/dox_core.dart';

/// Three cache stores. Pick one per call with `Cache().store('redis')`.
CacheConfig cache = CacheConfig(
  /// default cache store
  defaultStore: AppEnv.get('CACHE_STORE', 'file'),

  /// cache stores
  stores: <String, Map<String, dynamic>>{
    'file': <String, dynamic>{'driver': 'file', 'path': 'storage/cache'},
    'memory': <String, dynamic>{'driver': 'memory', 'max_size': 1000},
    'redis': <String, dynamic>{
      'driver': 'redis',
      'host': AppEnv.get('REDIS_HOST', '127.0.0.1'),
      'port': AppEnv.getInt('REDIS_PORT', 6459),
      'prefix': 'dox_test:',
    },
  },
);
