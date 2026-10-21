import 'package:dox_query_builder/dox_query_builder.dart';
import 'package:dox_test/app/models/post/post.model.dart';
import 'package:dox_test/app/models/profile/profile.model.dart';

part 'user.model.g.dart';

/// One row in the `users` table.
@DoxModel(table: 'users')
class User extends UserGenerator {
  /// Never send the password hash in a response.
  @override
  List<String> get hidden => <String>['password'];

  @Column()
  String? name;

  @Column()
  String? email;

  @Column()
  String? password;

  @HasOne(Profile, foreignKey: 'user_id', localKey: 'id')
  Profile? profile;

  @HasMany(Post, foreignKey: 'user_id', localKey: 'id')
  List<Post> posts = <Post>[];
}
