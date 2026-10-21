// ignore_for_file: file_names
import 'package:dox_migration/dox_migration.dart';

class CreateCommentsTable extends Migration {
  @override
  Future<void> up(Schema schema) async {
    await schema.create('comments', (Table table) {
      table.id();
      table.foreignId('post_id').constrained('posts');
      table.foreignId('user_id').constrained('users');
      table.text('body');
      table.timestamps();
    });
  }

  @override
  Future<void> down(Schema schema) async {
    await schema.dropIfExists('comments');
  }
}
