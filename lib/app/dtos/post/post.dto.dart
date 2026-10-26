import 'package:dox_core/dox_core.dart';
import 'package:dox_orm/dox_orm.dart' hide Schema;
import 'package:dox_test/app/http/rules/slug.rule.dart';
import 'package:dox_test/constants/app_constants.dart';
import 'package:dox_test/constants/post_status.dart';

part 'post.dto.g.dart';

/// Query of GET /api/posts.
@Dto()
class ListPosts {
  @Min(1)
  final int page;

  @Min(1)
  @Max(100)
  final int perPage;

  /// `status=draft&status=published`. Empty means all.
  @UniqueItems()
  final List<PostStatus> status;

  /// Only posts of this user. The user must exist.
  @Exists('users')
  final int? authorId;

  const ListPosts({
    this.page = 1,
    this.perPage = AppConstants.defaultPerPage,
    this.status = const <PostStatus>[],
    this.authorId,
  });

  static const DtoSchema<ListPosts> schema = $ListPostsDto;
}

/// Body of POST /api/posts and PUT /api/posts/{id}.
@Dto()
class SavePost {
  @Trim()
  @MaxLength(255)
  final String title;

  @Trim()
  final String body;

  final PostStatus status;

  /// Tag names. Each one must be a slug.
  @MaxItems(5)
  @Trim()
  @Lowercase()
  @Slug()
  final List<String> tags;

  const SavePost({
    required this.title,
    required this.body,
    this.status = PostStatus.draft,
    this.tags = const <String>[],
  });

  static const DtoSchema<SavePost> schema = $SavePostDto;
}

/// Body of POST /api/posts/{id}/comments.
@Dto()
class AddComment {
  @Trim()
  @MaxLength(1000)
  final String body;

  const AddComment({required this.body});

  static const DtoSchema<AddComment> schema = $AddCommentDto;
}
