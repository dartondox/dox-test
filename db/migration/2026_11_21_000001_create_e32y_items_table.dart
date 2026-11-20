// ignore_for_file: file_names
import 'package:dox_migration/dox_migration.dart';

/// `e32y_items`: enum columns as plain text, so a test can store a value
/// the enum does not have (test/e2e_32y_patch.dart).
class CreateE32yItemsTable extends Migration {
  @override
  Future<void> up(Schema schema) async {
    await schema.create('e32y_items', (Table table) {
      table.id();
      table.string('title').nullable();
      table.string('status').nullable();
      table.string('fallback').nullable();
      table.string('kind').withDefault('draft');
    });
  }

  @override
  Future<void> down(Schema schema) async {
    await schema.dropIfExists('e32y_items');
  }
}
