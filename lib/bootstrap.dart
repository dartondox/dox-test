import 'package:dox_core/dox_core.dart';
import 'package:dox_migration/dox_migration.dart';
import 'package:dox_orm/dox_orm.dart';
import 'package:dox_test/config/app.dart';
import 'package:dox_test/config/database.dart';

/// Starts the app. Used by bin/server.dart, bin/migrate.dart and the tests.
/// The migrations come from db/migration/migrations.dart (outside lib),
/// so the caller passes them in.
class Bootstrap {
  final List<MigrationEntry> migrations;

  Bootstrap(this.migrations);

  /// A Migrator on the database picked by `DB_CONNECTION`.
  Future<Migrator> migrator() async {
    Env().load();
    ConnectionConfig config = databaseConfig.getConnectionConfig();
    return Migrator(
      migrations: migrations,
      connection: await config.getDatabaseConnection(),
    );
  }

  /// Run the migrations.
  /// `fresh: true` undoes all migrations first, so tests start empty.
  Future<void> migrate({bool fresh = false}) async {
    Migrator m = await migrator();
    if (fresh) {
      await m.reset();
    }
    await m.migrate();
  }

  Future<void> start({bool freshDatabase = false}) async {
    Dox().initialize(appConfig);
    await migrate(fresh: freshDatabase);
    await Dox().startServer();
  }
}
