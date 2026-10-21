import 'package:dox_query_builder/dox_query_builder.dart';
import 'package:dox_test/app/models/profile/profile.model.dart';
import 'package:dox_test/app/models/user/user.model.dart';

/// All database access for users and profiles.
class UserRepository {
  Future<User> create(String name, String email, String passwordHash) async {
    User user = User();
    user.name = name;
    user.email = email;
    user.password = passwordHash;
    await user.save();
    return user;
  }

  Future<User?> findByEmail(String email) async {
    return await User().where('email', email).getFirst();
  }

  /// Find a user with the profile (hasOne) and posts (hasMany).
  Future<User?> findWithRelations(dynamic id) async {
    return await User().preload('profile').preload('posts').find(id);
  }

  /// Search by name OR email, ordered by id, one page at a time.
  Future<Pagination> search(String term, int page, int perPage) async {
    QueryBuilder<User> query = User().orderBy('id');
    if (term.isNotEmpty) {
      query = query
          .where('name', 'like', '%$term%')
          .orWhere('email', 'like', '%$term%');
    }
    return await query.paginate(currentPage: page, perPage: perPage);
  }

  /// Create the profile, or update it when it exists.
  Future<Profile> saveProfile(int userId, String? bio, String? website) async {
    Profile? profile = await Profile().where('user_id', userId).getFirst();
    profile ??= Profile();
    profile.userId = userId;
    profile.bio = bio;
    profile.website = website;
    await profile.save();
    return profile;
  }

  Future<Profile?> findProfileWithUser(int userId) async {
    return await Profile().preload('user').where('user_id', userId).getFirst();
  }
}
