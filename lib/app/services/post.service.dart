import 'dart:convert';

import 'package:dox_core/dox_core.dart';
import 'package:dox_orm/dox_orm.dart';
import 'package:dox_test/app/exceptions/forbidden.exception.dart';
import 'package:dox_test/app/http/requests/post.request.dart';
import 'package:dox_test/app/models/comment/comment.model.dart';
import 'package:dox_test/app/models/post/post.model.dart';
import 'package:dox_test/app/models/tag/tag.model.dart';
import 'package:dox_test/app/models/user/user.model.dart';
import 'package:dox_test/app/repositories/comment.repository.dart';
import 'package:dox_test/app/repositories/post.repository.dart';
import 'package:dox_test/app/repositories/tag.repository.dart';
import 'package:dox_test/constants/app_constants.dart';

/// Post and comment logic.
class PostService {
  final PostRepository posts;
  final TagRepository tags;
  final CommentRepository comments;

  PostService(this.posts, this.tags, this.comments);

  /// `statusCsv` is like "draft,published". Empty means all.
  Future<Pagination> list(int page, int perPage, String statusCsv) async {
    List<String> statuses = statusCsv.isEmpty
        ? <String>[]
        : statusCsv.split(',');
    return await posts.paginate(page, perPage, statuses);
  }

  Future<Post> show(dynamic id) async {
    Post? post = await posts.findWithRelations(id);
    if (post == null) {
      throw NotFoundHttpException(message: 'post not found');
    }
    return post;
  }

  Future<Post> create(User author, PostRequest req) async {
    Post post = Post();
    post.userId = author.id;
    _fill(post, req);
    await posts.save(post);
    await _syncTags(post.id!, req.tags);
    await _clearStats();
    return await show(post.id);
  }

  Future<Post> update(User user, dynamic id, PostRequest req) async {
    Post post = await _findOwned(user, id);
    _fill(post, req);
    await posts.save(post);
    await _syncTags(post.id!, req.tags);
    await _clearStats();
    return await show(post.id);
  }

  Future<void> delete(User user, dynamic id) async {
    await _findOwned(user, id);
    await posts.softDelete(id);
    await _clearStats();
  }

  Future<List<Post>> trashed() async {
    return await posts.trashed();
  }

  /// Stats are cached until a post changes.
  Future<Map<String, dynamic>> stats() async {
    Cache cache = Cache();
    if (await cache.has(AppConstants.postStatsCacheKey)) {
      Map<String, dynamic> cached = jsonDecode(
        await cache.get(AppConstants.postStatsCacheKey),
      );
      cached['cached'] = true;
      return cached;
    }
    Map<String, dynamic> result = <String, dynamic>{
      'total': await posts.countAll(),
      'published': await posts.countByStatus(AppConstants.statusPublished),
      'per_author': await posts.countPerAuthor(),
    };
    await cache.put(AppConstants.postStatsCacheKey, jsonEncode(result));
    result['cached'] = false;
    return result;
  }

  Future<Comment> addComment(User user, dynamic postId, String body) async {
    Post? post = await posts.find(postId);
    if (post == null) {
      throw NotFoundHttpException(message: 'post not found');
    }
    Comment comment = await comments.create(post.id!, user.id!, body);
    return (await comments.findForPost(post.id, comment.id))!;
  }

  Future<Comment> showComment(dynamic postId, dynamic commentId) async {
    Comment? comment = await comments.findForPost(postId, commentId);
    if (comment == null) {
      throw NotFoundHttpException(message: 'comment not found');
    }
    return comment;
  }

  void _fill(Post post, PostRequest req) {
    post.title = req.title;
    post.body = req.content;
    post.status = req.status;
  }

  Future<Post> _findOwned(User user, dynamic id) async {
    Post? post = await posts.find(id);
    if (post == null) {
      throw NotFoundHttpException(message: 'post not found');
    }
    if (post.userId != user.id) {
      throw ForbiddenException('not your post');
    }
    return post;
  }

  Future<void> _syncTags(int postId, List<String> names) async {
    List<int> ids = <int>[];
    for (String name in names) {
      Tag tag = await tags.firstOrCreate(name);
      ids.add(tag.id!);
    }
    await tags.syncPostTags(postId, ids);
  }

  Future<void> _clearStats() async {
    await Cache().forget(AppConstants.postStatsCacheKey);
  }
}
