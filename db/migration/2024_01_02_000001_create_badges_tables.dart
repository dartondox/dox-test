// ignore_for_file: file_names
import 'package:dox_migration/dox_migration.dart';

/// `badges`, the `badge_post` pivot table (with extra columns) and
/// `reactions`, which point to a badge or a post (polymorphic).
class CreateBadgesTables extends Migration {
  @override
  Future<void> up(Schema schema) async {
    await schema.create('badges', (Table table) {
      table.id();
      table.string('name', 50).unique();
      table.string('code', 10).nullable();
      table.json('meta').nullable();
      table.integer('score').withDefault(0);
      table.softDeletes();
      table.timestamps();
    });
    await schema.create('badge_post', (Table table) {
      table.id();
      table.foreignId('badge_id').constrained('badges');
      table.foreignId('post_id').constrained('posts');
      table.string('note', 50).nullable();
      table.timestamps();
    });
    await schema.create('reactions', (Table table) {
      table.id();
      table.string('emoji', 20);
      table.morphs('reactable');
      table.timestamps();
    });
  }

  @override
  Future<void> down(Schema schema) async {
    await schema.dropIfExists('reactions');
    await schema.dropIfExists('badge_post');
    await schema.dropIfExists('badges');
  }
}
