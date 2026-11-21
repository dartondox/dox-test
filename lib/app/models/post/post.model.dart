import 'package:dox_auth/dox_auth.dart' show Ability;
import 'package:dox_graphql/dox_graphql.dart';
import 'package:dox_orm/dox_orm.dart';
import 'package:dox_test/app/dtos/graphql/graphql.dto.dart';
import 'package:dox_test/app/models/comment/comment.model.dart';
import 'package:dox_test/app/models/tag/tag.model.dart';
import 'package:dox_test/app/models/user/user.model.dart';

part 'post.model.g.dart';

/// One row in the `posts` table. Delete only sets `deleted_at`.
/// GraphQL: public reads, PostPolicy checks, the owner is the caller.
@DoxModel(table: 'posts', softDelete: true)
@GraphQL(filter: Ability.view)
@GraphQLAll(can: Ability.viewAny)
@GraphQLFind(can: Ability.view)
@GraphQLCreate(dto: GqlPostInput, can: Ability.create, owner: 'userId')
@GraphQLUpdate(dto: GqlPostInput, can: Ability.update, guard: true)
@GraphQLDelete(can: Ability.delete, guard: true)
class Post extends PostGenerator {
  @Column()
  int? userId;

  @Column()
  String? title;

  @Column()
  String? body;

  @Column()
  String? status;

  /// how many times the post was viewed. `increment('views')` adds 1.
  @Column()
  int? views;

  @Column()
  DateTime? deletedAt;

  @BelongsTo(User, foreignKey: 'user_id', localKey: 'id')
  User? author;

  @HasMany(Comment, foreignKey: 'post_id', localKey: 'id')
  List<Comment> comments = <Comment>[];

  @ManyToMany(
    Tag,
    pivotTable: 'post_tag',
    localKey: 'id',
    relatedKey: 'id',
    pivotForeignKey: 'post_id',
    pivotRelatedForeignKey: 'tag_id',
  )
  List<Tag> tags = <Tag>[];
}
