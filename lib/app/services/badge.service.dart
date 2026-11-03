import 'dart:convert';

import 'package:dox_core/dox_core.dart';
import 'package:dox_orm/dox_orm.dart' hide Schema;
import 'package:dox_test/app/dtos/badge/badge.dto.dart';
import 'package:dox_test/app/models/badge/badge.model.dart';
import 'package:dox_test/app/models/reaction/reaction.model.dart';
import 'package:dox_test/app/repositories/badge.repository.dart';

/// Badge logic: pages, pivot writes, reactions, soft delete.
@Inject()
class BadgeService {
  final BadgeRepository badges;

  BadgeService(this.badges);

  /// Saves the badge and links the posts with the note `first`.
  Future<Badge> create(CreateBadge body) async {
    String? meta = body.meta;
    Badge badge = await badges.create(<String, dynamic>{
      'name': body.name,
      'code': body.code,
      'meta': meta == null ? null : jsonDecode(meta),
      'score': body.score,
    });
    if (body.postIds.isNotEmpty) {
      await badges.attachPosts(badge, body.postIds, 'first');
    }
    return await show(badge.id);
  }

  Future<Badge> show(dynamic id) async {
    Badge? badge = await badges.findWithRelations(id as int);
    if (badge == null) {
      throw NotFoundHttpException(message: 'badge not found');
    }
    return badge;
  }

  Future<Map<String, dynamic>> cursorPage(ListBadges query) async {
    return (await badges.cursorPage(query.perPage, query.cursor)).toJson();
  }

  Future<Map<String, dynamic>> simplePage(ListBadges query) async {
    return (await badges.simplePage(query.page, query.perPage)).toJson();
  }

  /// Returns the attached, detached and updated post ids.
  Future<Map<String, dynamic>> syncPosts(int id, SyncBadgePosts body) async {
    Badge badge = await _find(id);
    Map<int, Map<String, dynamic>> values = <int, Map<String, dynamic>>{};
    for (int postId in body.postIds) {
      values[postId] = <String, dynamic>{'note': body.note};
    }
    PivotSyncResult result = await badges.syncPosts(
      badge,
      values,
      detaching: body.detaching,
    );
    return <String, dynamic>{
      'attached': result.attached,
      'detached': result.detached,
      'updated': result.updated,
    };
  }

  Future<Reaction> addReaction(int id, AddReaction body) async {
    return await badges.addReaction(await _find(id), body.emoji);
  }

  /// Each reaction with the type and name (or title) of what it points to.
  Future<List<Map<String, dynamic>>> reactions() async {
    List<Map<String, dynamic>> out = <Map<String, dynamic>>[];
    for (Reaction reaction in await badges.reactions()) {
      Model<dynamic>? target = reaction.reactable;
      out.add(<String, dynamic>{
        'emoji': reaction.emoji,
        'type': reaction.reactableType,
        'target': target?.toJson(),
      });
    }
    return out;
  }

  Future<void> delete(int id) async {
    await badges.delete(await _find(id));
  }

  Future<List<Badge>> trashed() async {
    return await badges.trashed();
  }

  Future<bool> restore(int id) async {
    return await badges.restore(id);
  }

  Future<Badge> _find(int id) async {
    Badge? badge = await badges.find(id);
    if (badge == null) {
      throw NotFoundHttpException(message: 'badge not found');
    }
    return badge;
  }
}
