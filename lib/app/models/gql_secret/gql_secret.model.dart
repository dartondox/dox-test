import 'package:dox_auth/dox_auth.dart' show Ability;
import 'package:dox_graphql/dox_graphql.dart';
import 'package:dox_orm/dox_orm.dart';
import 'package:dox_test/app/dtos/graphql/graphql.dto.dart';
import 'package:dox_test/app/models/post/post.model.dart';

part 'gql_secret.model.g.dart';

/// A private row of test/e2e_33_graphql.dart. Only its owner sees it.
@DoxModel(table: 'gql_secrets')
@GraphQLType(guard: true, filter: Ability.view)
@GraphQLAll(can: Ability.viewAny)
@GraphQLFind(can: Ability.view)
@GraphQLCreate(dto: GqlSecretInput, owner: 'userId')
class GqlSecret extends GqlSecretGenerator {
  @Column()
  int? userId;

  @Column()
  int? postId;

  @Column()
  String? body;

  /// a single relation to Post: the `filter:` of Post makes it null
  @BelongsTo(Post, foreignKey: 'post_id', localKey: 'id')
  Post? post;
}
