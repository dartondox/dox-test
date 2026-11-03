import 'package:dox_orm/dox_orm.dart';
import 'package:dox_test/app/models/post/post.model.dart';
import 'package:dox_test/app/models/reaction/reaction.model.dart';

part 'badge.model.g.dart';

/// One row in the `badges` table. Delete only sets `deleted_at`.
@DoxModel(table: 'badges', softDelete: true)
class Badge extends BadgeGenerator {
  /// Only these keys may come from a map, like `create(req.body)`.
  @override
  List<String> get fillable => <String>['name', 'code', 'meta', 'score'];

  @Column()
  String? name;

  @Column()
  String? code;

  @Column()
  Map<String, dynamic>? meta;

  @Column()
  int? score;

  @Column()
  DateTime? deletedAt;

  /// Posts with this badge. The pivot row keeps a `note` and its own
  /// `created_at` and `updated_at`.
  @ManyToMany(
    Post,
    pivotTable: 'badge_post',
    localKey: 'id',
    relatedKey: 'id',
    pivotForeignKey: 'badge_id',
    pivotRelatedForeignKey: 'post_id',
    withPivot: <String>['note'],
    withTimestamps: true,
  )
  List<Post> posts = <Post>[];

  /// Reactions on this badge (polymorphic).
  @MorphMany(Reaction, 'reactable')
  List<Reaction> reactions = <Reaction>[];
}
