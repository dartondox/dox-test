import 'package:dox_core/dox_core.dart';
import 'package:dox_migration/dox_migration.dart';
import 'package:dox_query_builder/dox_query_builder.dart';
import 'package:dox_test/config/app.dart';
import 'package:dox_test/config/database.dart';

/// Starts the app. Used by bin/server.dart and by the tests.
class Bootstrap {
  /// Run the SQL files in db/migration.
  /// `fresh: true` rolls back all tables first, so tests start empty.
  Future<void> migrate({bool fresh = false}) async {
    Env().load();
    ConnectionConfig config = databaseConfig.getConnectionConfig();
    Migration migration = Migration();
    if (fresh) {
      await migration.rollback(await config.getDatabaseConnection());
    }
    await migration.migrate(await config.getDatabaseConnection());
  }

  Future<void> start({bool freshDatabase = false}) async {
    Dox().initialize(appConfig);
    await migrate(fresh: freshDatabase);
    await Dox().startServer();
  }
}
