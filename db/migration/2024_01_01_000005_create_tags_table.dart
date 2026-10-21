// ignore_for_file: file_names
import 'package:dox_migration/dox_migration.dart';

/// `tags` and the `post_tag` pivot table.
class CreateTagsTable extends Migration {
  @override
  Future<void> up(Schema schema) async {
    await schema.create('tags', (Table table) {
      table.id();
      table.string('name', 100).unique();
      table.timestamps();
    });
    await schema.create('post_tag', (Table table) {
      table.id();
      table.foreignId('post_id').constrained('posts');
      table.foreignId('tag_id').constrained('tags');
    });
  }

  @override
  Future<void> down(Schema schema) async {
    await schema.dropIfExists('post_tag');
    await schema.dropIfExists('tags');
  }
}
