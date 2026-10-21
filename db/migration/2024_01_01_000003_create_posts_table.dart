// ignore_for_file: file_names
import 'package:dox_migration/dox_migration.dart';

class CreatePostsTable extends Migration {
  @override
  Future<void> up(Schema schema) async {
    await schema.create('posts', (Table table) {
      table.id();
      table.foreignId('user_id').constrained('users');
      table.string('title');
      table.text('body');
      table.string('status', 20);
      table.softDeletes();
      table.timestamps();
    });
  }

  @override
  Future<void> down(Schema schema) async {
    await schema.dropIfExists('posts');
  }
}
