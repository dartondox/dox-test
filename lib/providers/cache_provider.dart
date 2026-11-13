import 'package:dox_cache_database/dox_cache_database.dart';
import 'package:dox_core/dox_core.dart';

/// Turns on the `database` cache driver, for the `database` store of
/// lib/config/cache.dart. The `cache` table is made by a migration.
class AppCacheProvider extends DoxProvider {
  @override
  void setup() {
    Dox().cache.extend(
      'database',
      DatabaseCacheDriverFactory(Dox().cache.config.encrypter),
    );
  }
}
