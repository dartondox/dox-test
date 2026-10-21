import 'package:dox_test/config/env.dart';
import 'package:dox_core/dox_core.dart';

/// Three cache stores. Pick one per call with `Cache().store('redis')`.
CacheConfig cache = CacheConfig(
  /// default cache store
  defaultStore: env.cacheStore,

  /// cache stores
  stores: <String, Map<String, dynamic>>{
    'file': <String, dynamic>{'driver': 'file', 'path': 'storage/cache'},
    'memory': <String, dynamic>{'driver': 'memory', 'max_size': 1000},
    'redis': <String, dynamic>{
      'driver': 'redis',
      'host': env.redisHost,
      'port': env.redisPort,
      'prefix': 'dox_test:',
    },
  },
);
