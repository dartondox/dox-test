import 'package:dox_core/dox_core.dart';
import 'package:dox_orm/dox_orm.dart';
import 'package:dox_test/app/http/dtos/post/post.dto.dart';
import 'package:dox_test/app/http/serializers/post.serializer.dart';
import 'package:dox_test/app/models/comment/comment.model.dart';
import 'package:dox_test/app/models/post/post.model.dart';
import 'package:dox_test/app/models/user/user.model.dart';
import 'package:dox_test/app/services/post.service.dart';

@Inject()
class PostController {
  final PostService service;

  PostController(this.service);

  /// List posts
  ///
  /// Newest first. Filter by status and author.
  Future<Pagination<Post>> index(ListPosts query) async {
    return await service.list(query);
  }

  /// Get one post
  Future<Post> show(int id) async {
    return await service.show(id);
  }

  /// Get one post, short form (serializer)
  Future<PostSerializer> summary(int id) async {
    return PostSerializer(await service.show(id));
  }

  /// Create a post (needs token)
  Future<DoxResponse> store(DoxRequest req, SavePost body) async {
    Post post = await service.create(_user(req), body);
    return response(post).statusCode(201);
  }

  /// Update a post (needs token, only the owner)
  Future<Post> update(DoxRequest req, int id, SavePost body) async {
    return await service.update(_user(req), id, body);
  }

  /// Delete a post (needs token, only the owner)
  Future<Map<String, String>> destroy(DoxRequest req, int id) async {
    await service.delete(_user(req), id);
    return <String, String>{'message': 'deleted'};
  }

  /// Deleted posts
  Future<List<Post>> trashed() async {
    return await service.trashed();
  }

  /// Post stats (cached)
  Future<Map<String, dynamic>> stats() async {
    return await service.stats();
  }

  /// Add a comment (needs token)
  Future<DoxResponse> addComment(
    DoxRequest req,
    int id,
    AddComment body,
  ) async {
    Comment comment = await service.addComment(_user(req), id, body.body);
    return response(comment).statusCode(201);
  }

  /// Get one comment of a post
  Future<Comment> showComment(int postId, int commentId) async {
    return await service.showComment(postId, commentId);
  }

  User _user(DoxRequest req) {
    return req.auth!.user<User>()!;
  }
}
