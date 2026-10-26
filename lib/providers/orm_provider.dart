import 'package:dox_core/dox_core.dart';
import 'package:dox_orm/dox_orm.dart';
import 'package:dox_test/app/models/user/user.model.dart';
import 'package:dox_test/app/observers/user.observer.dart';
import 'package:dox_test/config/database.dart';

/// Connects the query builder to the database and adds model observers.
/// It runs on each isolate, so every isolate has the observer.
class ORMProvider extends DoxProvider {
  @override
  void setup() {
    SqlQueryBuilder.initializeWithDatabaseConfig(databaseConfig);
    Model.forgetObservers<User>();
    Model.observe<User>(UserObserver());
  }
}
