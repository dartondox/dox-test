import 'package:dox_orm/dox_orm.dart';
import 'package:dox_test/app/models/profile/profile.model.dart';
import 'package:dox_test/app/models/user/user.model.dart';

/// All database access for users and profiles.
class UserRepository {
  Future<User> create(
    String name,
    String email,
    String passwordHash, {
    String? firstName,
    String? lastName,
  }) async {
    User user = User();
    user.name = name;
    user.email = email;
    user.password = passwordHash;
    user.firstName = firstName;
    user.lastName = lastName;
    await user.save();
    return user;
  }

  Future<void> update(int id, String name, String email) async {
    User? user = await User().find(id);
    user!.name = name;
    user.email = email;
    await user.save();
  }

  /// Find a user with the profile (hasOne) and posts (hasMany).
  Future<User?> findWithRelations(int id) async {
    return await User().preload('profile').preload('posts').find(id);
  }

  /// Search by name OR email, ordered by id, one page at a time.
  Future<Pagination<User>> search(String term, int page, int perPage) async {
    QueryBuilder<User> query = User().orderBy('id');
    if (term.isNotEmpty) {
      query = query
          .where('name', 'like', '%$term%')
          .orWhere('email', 'like', '%$term%');
    }
    return await query.paginate(currentPage: page, perPage: perPage);
  }

  Future<Profile?> profileOf(int userId) async {
    return await Profile().where('user_id', userId).getFirst();
  }

  /// Create the profile, or update it when it exists.
  Future<Profile> saveProfile(int userId, Profile profile) async {
    profile.userId = userId;
    await profile.save();
    return profile;
  }

  Future<Profile?> findProfileWithUser(int userId) async {
    return await Profile().preload('user').where('user_id', userId).getFirst();
  }
}
