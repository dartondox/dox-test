import 'package:dox_orm/dox_orm.dart';
import 'package:dox_test/app/models/post/post.model.dart';

/// All database access for posts.
class PostRepository {
  /// One page of posts with author (belongsTo) and tags (manyToMany).
  Future<Pagination> paginate(
    int page,
    int perPage,
    List<String> statuses,
    int? authorId,
  ) async {
    QueryBuilder<Post> query = Post()
        .preload('author')
        .preload('tags')
        .orderBy('id', 'desc');
    if (statuses.isNotEmpty) {
      query = query.whereIn('status', statuses);
    }
    if (authorId != null) {
      query = query.where('user_id', authorId);
    }
    return await query.paginate(currentPage: page, perPage: perPage);
  }

  /// Find a post with author, comments (hasMany) and tags.
  Future<Post?> findWithRelations(int id) async {
    return await Post()
        .preload('author')
        .preload('comments')
        .preload('tags')
        .find(id);
  }

  Future<Post?> find(int id) async {
    return await Post().find(id);
  }

  Future<Post> save(Post post) async {
    await post.save();
    return post;
  }

  /// Soft delete: only sets `deleted_at`.
  Future<void> softDelete(int id) async {
    await Post().where('id', id).delete();
  }

  /// Only the soft deleted posts.
  Future<List<Post>> trashed() async {
    List<dynamic> rows = await Post()
        .withTrash()
        .whereNotNull('deleted_at')
        .orderBy('id')
        .get();
    return List<Post>.from(rows);
  }

  Future<int> countAll() async {
    return await Post().count();
  }

  Future<int> countByStatus(String status) async {
    return await Post().where('status', status).count();
  }

  /// Post count per author, with a join on users.
  Future<List<Map<String, dynamic>>> countPerAuthor() async {
    List<dynamic> rows = await QueryBuilder.table('posts')
        .select('users.name as author, count(posts.id) as total')
        .join('users', 'users.id', 'posts.user_id')
        .whereNull('posts.deleted_at')
        .groupBy('users.name')
        .orderBy('users.name')
        .get();
    return List<Map<String, dynamic>>.from(rows);
  }
}
