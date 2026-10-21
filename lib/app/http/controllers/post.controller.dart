import 'package:dox_auth/dox_auth.dart';
import 'package:dox_core/dox_core.dart';
import 'package:dox_orm/dox_orm.dart';
import 'package:dox_test/app/http/requests/post.request.dart';
import 'package:dox_test/app/http/serializers/post.serializer.dart';
import 'package:dox_test/app/models/comment/comment.model.dart';
import 'package:dox_test/app/models/post/post.model.dart';
import 'package:dox_test/app/models/user/user.model.dart';
import 'package:dox_test/app/services/post.service.dart';
import 'package:dox_test/constants/app_constants.dart';

class PostController {
  final PostService service;

  PostController(this.service);

  /// GET /api/posts?page=&limit=&status=
  Future<Pagination> index(DoxRequest req) async {
    return await service.list(
      int.parse(req.input('page')?.toString() ?? '1'),
      int.parse(
        req.input('limit')?.toString() ?? '${AppConstants.defaultPerPage}',
      ),
      req.input('status')?.toString() ?? '',
    );
  }

  /// GET /api/posts/{id}
  Future<Post> show(DoxRequest req, String id) async {
    return await service.show(id);
  }

  /// GET /api/posts/{id}/summary (uses the serializer)
  Future<PostSerializer> summary(DoxRequest req, String id) async {
    return PostSerializer(await service.show(id));
  }

  /// POST /api/posts (needs token)
  Future<DoxResponse> store(PostRequest req) async {
    Post post = await service.create(_user(req.auth<Auth>()), req);
    return response(post).statusCode(201);
  }

  /// PUT /api/posts/{id} (needs token)
  Future<Post> update(PostRequest req, String id) async {
    return await service.update(_user(req.auth<Auth>()), id, req);
  }

  /// DELETE /api/posts/{id} (needs token)
  Future<Map<String, String>> destroy(DoxRequest req, String id) async {
    await service.delete(_user(req.auth as Auth?), id);
    return <String, String>{'message': 'deleted'};
  }

  /// GET /api/posts/trashed
  Future<List<Post>> trashed(DoxRequest req) async {
    return await service.trashed();
  }

  /// GET /api/posts/stats
  Future<Map<String, dynamic>> stats(DoxRequest req) async {
    return await service.stats();
  }

  /// POST /api/posts/{id}/comments (needs token)
  Future<DoxResponse> addComment(DoxRequest req, String id) async {
    req.validate(<String, String>{'body': 'required'});
    Comment comment = await service.addComment(
      _user(req.auth as Auth?),
      id,
      req.input('body').toString(),
    );
    return response(comment).statusCode(201);
  }

  /// GET /api/posts/{postId}/comments/{commentId}
  Future<Comment> showComment(
    DoxRequest req,
    String postId,
    String commentId,
  ) async {
    return await service.showComment(postId, commentId);
  }

  User _user(Auth? auth) {
    return auth!.user<User>()!;
  }
}
