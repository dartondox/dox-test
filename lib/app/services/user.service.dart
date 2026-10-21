import 'package:dox_core/dox_core.dart';
import 'package:dox_orm/dox_orm.dart';
import 'package:dox_test/app/models/profile/profile.model.dart';
import 'package:dox_test/app/models/user/user.model.dart';
import 'package:dox_test/app/repositories/user.repository.dart';

/// User logic.
class UserService {
  final UserRepository users;

  UserService(this.users);

  Future<Pagination> list(String term, int page, int perPage) async {
    return await users.search(term, page, perPage);
  }

  Future<User> show(dynamic id) async {
    User? user = await users.findWithRelations(id);
    if (user == null) {
      throw NotFoundHttpException(message: 'user not found');
    }
    return user;
  }

  Future<Profile?> saveProfile(int userId, String? bio, String? website) async {
    await users.saveProfile(userId, bio, website);
    return await users.findProfileWithUser(userId);
  }
}
