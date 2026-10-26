import 'package:dox_orm/dox_orm.dart';
import 'package:dox_test/app/models/post/post.model.dart';

/// All database access for posts.
@Inject()
class PostRepository {
  /// One page of posts with author (belongsTo) and tags (manyToMany).
  Future<Pagination<Post>> paginate(
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

  /// Soft delete: only sets `deleted_at`. It returns the rows it changed:
  /// 0 when the post is not there (or already deleted).
  Future<int> softDelete(int id) async {
    return await Post().where('id', id).delete();
  }

  /// Add 1 to `views` in one query. `post.views` is the new value after it.
  Future<int> addView(Post post) async {
    return await post.increment('views');
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
        .selectRaw('users.name as author, count(posts.id) as total')
        .join('users', 'users.id', 'posts.user_id')
        .whereNull('posts.deleted_at')
        .groupBy('users.name')
        .orderBy('users.name')
        .get();
    return List<Map<String, dynamic>>.from(rows);
  }
}
