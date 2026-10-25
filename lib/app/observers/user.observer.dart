import 'package:dox_core/utils/logger.dart';
import 'package:dox_orm/dox_orm.dart';
import 'package:dox_test/app/jobs/welcome_user.job.dart';
import 'package:dox_test/app/models/user/user.model.dart';

/// Listens to User model events. Added in ORMProvider.
class UserObserver extends ModelObserver<User> {
  /// Runs before every insert and update.
  @override
  void onSaving(User user) {
    user.email = user.email?.trim().toLowerCase();
  }

  /// Runs after a new user is saved. A queue worker makes the profile.
  @override
  Future<void> onCreated(User user) async {
    Logger.info('user created', <String, dynamic>{'id': user.id});
    await WelcomeUser(userId: user.id!).dispatch();
  }
}
