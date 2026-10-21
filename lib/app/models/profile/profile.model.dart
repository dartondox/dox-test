import 'package:dox_query_builder/dox_query_builder.dart';
import 'package:dox_test/app/models/user/user.model.dart';

part 'profile.model.g.dart';

/// One row in the `profiles` table. Each user has one profile.
@DoxModel(table: 'profiles')
class Profile extends ProfileGenerator {
  @Column()
  int? userId;

  @Column()
  String? bio;

  @Column()
  String? website;

  @BelongsTo(User, foreignKey: 'user_id', localKey: 'id')
  User? user;
}
