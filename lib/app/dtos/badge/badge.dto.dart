import 'package:dox_core/dox_core.dart';
import 'package:dox_orm/dox_orm.dart' hide Schema;

part 'badge.dto.g.dart';

/// Body of POST /api/badges.
@Dto()
class CreateBadge {
  /// The database decides if the name is taken.
  @Trim()
  @Length(min: 2, max: 50)
  @Unique('badges', column: 'name')
  final String name;

  /// Four digits, like `0042`.
  @Digits(4)
  final String? code;

  /// Extra data as JSON text, like `{"color":"red"}`.
  @Json()
  final String? meta;

  @Range(0, 100)
  final int score;

  /// Other names this badge wants to keep free. Each one must not be taken
  /// (a list with `@Unique` is one query).
  @MaxItems(5)
  @Unique('badges', column: 'name')
  final List<String> aliases;

  /// Posts that get the badge. Each one must exist.
  @MaxItems(10)
  @Exists('posts')
  final List<int> postIds;

  const CreateBadge({
    required this.name,
    this.code,
    this.meta,
    this.score = 0,
    this.aliases = const <String>[],
    this.postIds = const <int>[],
  });

  static const DtoSchema<CreateBadge> schema = $CreateBadgeDto;
}

/// Query of GET /api/badges (cursor pages) and /api/badges/simple.
@Dto()
class ListBadges {
  /// The `next_cursor` or `prev_cursor` of the page before.
  final String? cursor;

  @Min(1)
  final int page;

  @Range(1, 50)
  final int perPage;

  const ListBadges({this.cursor, this.page = 1, this.perPage = 2});

  static const DtoSchema<ListBadges> schema = $ListBadgesDto;
}

/// Body of PUT /api/badges/{id}/posts.
@Dto()
class SyncBadgePosts {
  @MaxItems(10)
  @Exists('posts')
  final List<int> postIds;

  /// Saved in the pivot row of every given post.
  @MaxLength(50)
  final String? note;

  /// `false` keeps the posts that are not in the list.
  final bool detaching;

  const SyncBadgePosts({
    required this.postIds,
    this.note,
    this.detaching = true,
  });

  static const DtoSchema<SyncBadgePosts> schema = $SyncBadgePostsDto;
}

/// Body of POST /api/badges/{id}/reactions.
@Dto()
class AddReaction {
  @Trim()
  @Length(min: 1, max: 20)
  final String emoji;

  const AddReaction({required this.emoji});

  static const DtoSchema<AddReaction> schema = $AddReactionDto;
}
