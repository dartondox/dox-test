import 'package:dox_core/utils/logger.dart';
import 'package:dox_orm/dox_orm.dart';
import 'package:dox_test/app/models/user/user.model.dart';

/// Listens to User model events. Added in OrmServiceProvider.
class UserObserver extends ModelObserver<User> {
  /// Runs before every insert and update.
  @override
  void saving(User user) {
    user.email = user.email?.trim().toLowerCase();
  }

  /// Runs after a new user is saved.
  @override
  void created(User user) {
    Logger.info('user created', <String, dynamic>{'id': user.id});
  }
}
