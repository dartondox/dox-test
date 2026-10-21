import 'package:dox_orm/dox_orm.dart';
import 'package:dox_test/app/models/tag/tag.model.dart';

/// Thrown inside the transaction to show a rollback.
class TagRollbackException implements Exception {}

/// All database access for tags and the `post_tag` pivot table.
class TagRepository {
  Future<Tag> firstOrCreate(String name) async {
    Tag? tag = await Tag().where('name', name).getFirst();
    if (tag != null) {
      return tag;
    }
    Tag created = Tag();
    created.name = name;
    await created.save();
    return created;
  }

  /// Insert every name in one transaction.
  /// [failAtEnd] throws after the inserts, so they are rolled back.
  Future<void> createAll(List<String> names, {bool failAtEnd = false}) async {
    Future<void> insertAll() async {
      for (String name in names) {
        await firstOrCreate(name);
      }
      if (failAtEnd) {
        throw TagRollbackException();
      }
    }

    await QueryBuilder.transaction(insertAll);
  }

  /// Tags by name, without the [except] names (whereNotIn).
  Future<List<Tag>> list(int limit, List<String> except) async {
    List<dynamic> rows = await Tag()
        .whereNotIn('name', except)
        .orderBy('name')
        .limit(limit)
        .get();
    return List<Tag>.from(rows);
  }

  Future<int> count() async {
    return await Tag().count();
  }

  /// Replace the tags of a post.
  Future<void> syncPostTags(int postId, List<int> tagIds) async {
    await QueryBuilder.table('post_tag').where('post_id', postId).delete();
    if (tagIds.isEmpty) {
      return;
    }
    List<Map<String, dynamic>> rows = <Map<String, dynamic>>[];
    for (int tagId in tagIds) {
      rows.add(<String, dynamic>{'post_id': postId, 'tag_id': tagId});
    }
    await QueryBuilder.table('post_tag').insertMultiple(rows);
  }

  /// Tag with its posts (manyToMany from the other side).
  Future<Tag?> findByNameWithPosts(String name) async {
    return await Tag().preload('posts').where('name', name).getFirst();
  }
}
