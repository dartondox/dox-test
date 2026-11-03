import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/dtos/badge/badge.dto.dart';
import 'package:dox_test/app/models/badge/badge.model.dart';
import 'package:dox_test/app/models/reaction/reaction.model.dart';
import 'package:dox_test/app/services/badge.service.dart';

/// /api/badges: many to many with pivot values, polymorphic reactions,
/// cursor and simple pages, soft delete and restore.
@Tags(<String>['Badge', 'ORM'])
@Inject()
class BadgeController {
  final BadgeService service;

  BadgeController(this.service);

  /// Badges by score, a cursor page
  Future<Map<String, dynamic>> index(ListBadges query) async {
    return await service.cursorPage(query);
  }

  /// Badges by id, a page without the total
  Future<Map<String, dynamic>> simple(ListBadges query) async {
    return await service.simplePage(query);
  }

  /// Create a badge
  Future<DoxResponse> store(CreateBadge body) async {
    return response(await service.create(body)).statusCode(201);
  }

  /// Get a badge with its posts and reactions
  Future<Badge> show(int id) async {
    return await service.show(id);
  }

  /// Set the posts of a badge (sync)
  Future<Map<String, dynamic>> syncPosts(int id, SyncBadgePosts body) async {
    return await service.syncPosts(id, body);
  }

  /// React to a badge
  Future<DoxResponse> react(int id, AddReaction body) async {
    Reaction reaction = await service.addReaction(id, body);
    return response(reaction).statusCode(201);
  }

  /// Every reaction, with the badge or post it is on
  Future<List<Map<String, dynamic>>> reactions() async {
    return await service.reactions();
  }

  /// Delete a badge (soft)
  Future<Map<String, String>> destroy(int id) async {
    await service.delete(id);
    return <String, String>{'message': 'deleted'};
  }

  /// Deleted badges
  Future<List<Badge>> trashed() async {
    return await service.trashed();
  }

  /// Bring back a deleted badge
  Future<Map<String, bool>> restore(int id) async {
    return <String, bool>{'restored': await service.restore(id)};
  }
}
