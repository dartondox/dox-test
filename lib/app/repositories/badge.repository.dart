import 'package:dox_orm/dox_orm.dart';
import 'package:dox_test/app/models/badge/badge.model.dart';
import 'package:dox_test/app/models/reaction/reaction.model.dart';

/// All database access for badges, their pivot rows and reactions.
@Inject()
class BadgeRepository {
  /// `create()` takes only the `fillable` keys of the map.
  Future<Badge> create(Map<String, dynamic> data) async {
    return await Badge().create(data);
  }

  Future<Badge?> find(int id) async {
    return await Badge().find(id);
  }

  /// A badge with its posts (and pivot values), its reactions, how many
  /// reactions it has, and if it has a post.
  Future<Badge?> findWithRelations(int id) async {
    return await Badge()
        .preload('posts')
        .preload('reactions')
        .withCount('reactions')
        .withExists('posts')
        .find(id);
  }

  /// Highest score first. The id is added to the order, so badges with
  /// the same score are never skipped.
  Future<CursorPagination<Badge>> cursorPage(int perPage, String? cursor) {
    return Badge()
        .orderBy('score', 'desc')
        .cursorPaginate(perPage: perPage, cursor: cursor);
  }

  /// A page without the total count (one query).
  Future<SimplePagination<Badge>> simplePage(int page, int perPage) {
    return Badge()
        .orderBy('id')
        .simplePaginate(currentPage: page, perPage: perPage);
  }

  Future<void> attachPosts(Badge badge, List<int> ids, String note) async {
    await badge.attach('posts', ids, <String, dynamic>{'note': note});
  }

  /// Makes the pivot rows match [values] (post id => pivot values).
  Future<PivotSyncResult> syncPosts(
    Badge badge,
    Map<int, Map<String, dynamic>> values, {
    required bool detaching,
  }) async {
    return await badge.sync('posts', values, detaching: detaching);
  }

  Future<Reaction> addReaction(Badge badge, String emoji) async {
    return await Reaction().create(<String, dynamic>{
      'emoji': emoji,
      'reactable_id': badge.id,
      'reactable_type': Model.morphTypeOf(badge),
    });
  }

  /// Every reaction with the badge or post it points to (@MorphTo).
  Future<List<Reaction>> reactions() async {
    return await Reaction().preload('reactable').orderBy('id').get();
  }

  /// Soft delete: only sets `deleted_at` (and `updated_at`).
  Future<void> delete(Badge badge) async {
    await badge.delete();
  }

  /// Only the soft deleted badges.
  Future<List<Badge>> trashed() async {
    return await Badge().onlyTrashed().orderBy('id').get();
  }

  /// Restores a soft deleted badge. False when it was not deleted.
  /// `restore()` is on the model, not on `QueryBuilder`, so the query
  /// needs a cast back to [Badge].
  Future<bool> restore(int id) async {
    Badge query = Badge().where('id', id) as Badge;
    return await query.restore();
  }
}
