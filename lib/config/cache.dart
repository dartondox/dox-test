import 'package:dox_core/dox_core.dart';

CacheConfig cache = CacheConfig(
  /// default cache store
  defaultStore: Env.get('CACHE_STORE', 'file'),

  /// cache stores
  stores: <String, Map<String, dynamic>>{
    'file': <String, dynamic>{'driver': 'file', 'path': 'storage/cache'},
  },
);
