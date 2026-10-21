import 'dart:io';

import 'package:dox_migration/dox_migration.dart';
import 'package:dox_test/bootstrap.dart';

import '../db/migration/migrations.dart';

/// Run the migrations of db/migration:
/// `dart run bin/migrate.dart <run|rollback [--step=n]|reset|refresh|status>`.
/// `dox migration:*` commands run this file.
/// The database comes from lib/config/database.dart (`DB_CONNECTION`, ...).
Future<void> main(List<String> args) async {
  Migrator migrator = await Bootstrap(migrations).migrator();
  // exit() also closes the open database pool.
  exit(await migrator.run(args));
}
