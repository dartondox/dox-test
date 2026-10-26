// ignore_for_file: file_names
import 'package:dox_migration/dox_migration.dart';

/// Adds a view counter. `POST /api/posts/{id}/views` adds 1 with
/// `post.increment('views')`.
class AddViewsToPostsTable extends Migration {
  @override
  Future<void> up(Schema schema) async {
    await schema.table('posts', (Table table) {
      table.integer('views').withDefault(0);
    });
  }

  @override
  Future<void> down(Schema schema) async {
    await schema.table('posts', (Table table) {
      table.dropColumns(<String>['views']);
    });
  }
}
