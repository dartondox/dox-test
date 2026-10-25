import 'package:dox_core/dox_core.dart';
import 'package:dox_orm/dox_orm.dart';
import 'package:dox_test/app/exceptions/forbidden.exception.dart';
import 'package:dox_test/app/http/dtos/user.dto.dart';
import 'package:dox_test/app/models/profile/profile.model.dart';
import 'package:dox_test/app/models/user/user.model.dart';
import 'package:dox_test/app/repositories/user.repository.dart';

/// User logic.
class UserService {
  final UserRepository users;

  UserService(this.users);

  Future<Pagination<User>> list(ListUsers query) async {
    return await users.search(query.search ?? '', query.page, query.perPage);
  }

  Future<User> show(int id) async {
    User? user = await users.findWithRelations(id);
    if (user == null) {
      throw NotFoundHttpException(message: 'user not found');
    }
    return user;
  }

  /// A user may only change itself.
  Future<User> update(int currentUserId, int id, UpdateUser input) async {
    if (currentUserId != id) {
      throw ForbiddenException('you can only update yourself');
    }
    await users.update(id, input.name, input.email);
    return await show(id);
  }

  Future<Profile?> saveProfile(int userId, SaveProfile input) async {
    Profile profile = await users.profileOf(userId) ?? Profile();
    profile.bio = input.bio;
    profile.website = input.website;
    await users.saveProfile(userId, profile);
    return await users.findProfileWithUser(userId);
  }

  /// Only the keys that were sent change.
  Future<Profile?> patchProfile(int userId, PatchProfile input) async {
    Profile profile = await users.profileOf(userId) ?? Profile();
    if (input.bio.isPresent) {
      profile.bio = input.bio.value;
    }
    if (input.website.isPresent) {
      profile.website = input.website.value;
    }
    await users.saveProfile(userId, profile);
    return await users.findProfileWithUser(userId);
  }
}
