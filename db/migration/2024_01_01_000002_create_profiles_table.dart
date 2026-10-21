// ignore_for_file: file_names
import 'package:dox_migration/dox_migration.dart';

class CreateProfilesTable extends Migration {
  @override
  Future<void> up(Schema schema) async {
    await schema.create('profiles', (Table table) {
      table.id();
      table.foreignId('user_id').constrained('users');
      table.text('bio').nullable();
      table.string('website').nullable();
      table.timestamps();
    });
  }

  @override
  Future<void> down(Schema schema) async {
    await schema.dropIfExists('profiles');
  }
}
