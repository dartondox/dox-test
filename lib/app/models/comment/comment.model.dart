import 'package:dox_graphql/dox_graphql.dart';
import 'package:dox_orm/dox_orm.dart';
import 'package:dox_test/app/models/user/user.model.dart';

part 'comment.model.g.dart';

/// One row in the `comments` table.
@DoxModel(table: 'comments')
@GraphQLType()
class Comment extends CommentGenerator {
  @Column()
  int? postId;

  @Column()
  int? userId;

  @Column()
  String? body;

  @BelongsTo(User, foreignKey: 'user_id', localKey: 'id', eager: true)
  User? user;
}
