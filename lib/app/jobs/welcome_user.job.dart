import 'package:dox_core/dox_core.dart';
import 'package:dox_queue/dox_queue.dart';
import 'package:dox_test/app/models/profile/profile.model.dart';
import 'package:dox_test/app/repositories/user.repository.dart';

/// Gives a new user a profile with a welcome bio.
/// UserObserver puts it on the queue when a user is created.
@Job()
class WelcomeUser extends DoxJob {
  WelcomeUser({required this.userId});

  final int userId;

  static const String bio = 'Welcome to dox-test';

  @override
  Future<void> handle() async {
    UserRepository users = Dox().ioc.get<UserRepository>();
    // The user may have made a profile already, keep it.
    if (await users.profileOf(userId) != null) {
      return;
    }
    Profile profile = Profile();
    profile.bio = bio;
    await users.saveProfile(userId, profile);
  }
}
