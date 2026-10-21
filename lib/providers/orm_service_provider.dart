import 'package:dox_core/dox_core.dart';
import 'package:dox_orm/dox_orm.dart';
import 'package:dox_test/config/database.dart';

/// Connects the query builder to the database.
class OrmServiceProvider implements DoxService {
  @override
  void setup() {
    SqlQueryBuilder.initializeWithDatabaseConfig(databaseConfig);
  }
}
