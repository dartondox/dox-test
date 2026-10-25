import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/models/comment/comment.model.dart';

/// All database access for comments.
@Inject()
class CommentRepository {
  Future<Comment> create(int postId, int userId, String body) async {
    Comment comment = Comment();
    comment.postId = postId;
    comment.userId = userId;
    comment.body = body;
    await comment.save();
    return comment;
  }

  /// Comment of one post. The user is loaded eagerly by the model.
  Future<Comment?> findForPost(int postId, int commentId) async {
    return await Comment()
        .where('post_id', postId)
        .where('id', commentId)
        .getFirst();
  }
}
