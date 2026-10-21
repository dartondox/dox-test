// ignore_for_file: file_names
import 'package:dox_migration/dox_migration.dart';

/// Adds first and last name. `User.fullName` (@Computed) joins them.
class AddNamesToUsersTable extends Migration {
  @override
  Future<void> up(Schema schema) async {
    await schema.table('users', (Table table) {
      table.string('first_name').nullable();
      table.string('last_name').nullable();
    });
  }

  @override
  Future<void> down(Schema schema) async {
    await schema.table('users', (Table table) {
      table.dropColumns(<String>['first_name', 'last_name']);
    });
  }
}
