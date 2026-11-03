// ignore_for_file: file_names
import 'package:dox_auth/dox_auth.dart';
import 'package:dox_migration/dox_migration.dart';

/// The auth_access_tokens table of dox_auth.
class CreateAccessTokensTable extends Migration {
  @override
  Future<void> up(Schema schema) async {
    await AccessTokenTables.up(schema, usersTable: 'users');
  }

  @override
  Future<void> down(Schema schema) async {
    await AccessTokenTables.down(schema);
  }
}
