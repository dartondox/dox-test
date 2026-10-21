import 'package:dox_query_builder/dox_query_builder.dart';
import 'package:dox_test/config/env.dart';

/// Pick the database with `DB_CONNECTION` = postgres or mysql.
String dbConnection = AppEnv.get('DB_CONNECTION', 'postgres');

bool get isMysql => dbConnection == 'mysql';

DatabaseConfig databaseConfig = DatabaseConfig(
  connection: dbConnection,
  connections: <String, ConnectionConfig>{
    'postgres': ConnectionConfig(
      driver: Driver.postgres,
      host: AppEnv.get('DB_HOST', 'localhost'),
      port: AppEnv.getInt('DB_PORT', 5452),
      user: AppEnv.get('DB_USERNAME', 'postgres'),
      password: AppEnv.get('DB_PASSWORD', 'postgres'),
      database: AppEnv.get('DB_NAME', 'dox_test'),
      extra: <String, dynamic>{'maxConnectionCount': 10},
      debug: AppEnv.get('DB_DEBUG', 'false') == 'true',
      printer: ConsoleQueryPrinter(),
    ),
    'mysql': ConnectionConfig(
      driver: Driver.mysql,
      host: AppEnv.get('DB_HOST', '127.0.0.1'),
      port: AppEnv.getInt('DB_PORT', 3326),
      user: AppEnv.get('DB_USERNAME', 'root'),
      password: AppEnv.get('DB_PASSWORD', 'password'),
      database: AppEnv.get('DB_NAME', 'dox_test'),
      debug: AppEnv.get('DB_DEBUG', 'false') == 'true',
      printer: ConsoleQueryPrinter(),
    ),
  },
);
