import 'package:dox_orm/dox_orm.dart';
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

  @Column(name: 'first_name')
  String? firstName;

  @Column(name: 'last_name')
  String? lastName;

  /// Not a column. Added to the JSON as `full_name`.
  @Computed()
  String? get fullName {
    if (firstName == null && lastName == null) {
      return null;
    }
    return <String?>[firstName, lastName].whereType<String>().join(' ');
  }

  @HasOne(Profile, foreignKey: 'user_id', localKey: 'id')
  Profile? profile;

  @HasMany(Post, foreignKey: 'user_id', localKey: 'id')
  List<Post> posts = <Post>[];
}
