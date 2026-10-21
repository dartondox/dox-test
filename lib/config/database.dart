import 'dart:io';

import 'package:dox_orm/dox_orm.dart';
import 'package:dox_test/config/env.dart';

/// Pick the database with `DB_CONNECTION` = postgres, mysql or sqlite.
DatabaseConfig databaseConfig = DatabaseConfig(
  connection: env.dbConnection.name,
  connections: <String, ConnectionConfig>{
    DbConnection.postgres.name: ConnectionConfig(
      driver: Driver.postgres,
      host: env.dbHost ?? 'localhost',
      port: env.dbPort ?? 5452,
      user: env.dbUsername ?? 'postgres',
      password: env.dbPassword ?? 'postgres',
      database: env.dbName,
      extra: <String, dynamic>{'maxConnectionCount': 10},
      debug: env.dbDebug,
      printer: ConsoleQueryPrinter(),
    ),
    DbConnection.mysql.name: ConnectionConfig(
      driver: Driver.mysql,
      host: env.dbHost ?? '127.0.0.1',
      port: env.dbPort ?? 3326,
      user: env.dbUsername ?? 'root',
      password: env.dbPassword ?? 'password',
      database: env.dbName,
      debug: env.dbDebug,
      printer: ConsoleQueryPrinter(),
    ),
    DbConnection.sqlite.name: ConnectionConfig(
      driver: Driver.sqlite,
      // A file, not :memory:, so every isolate sees the same database.
      database:
          env.dbDatabase ?? '${Directory.systemTemp.path}/dox_test.sqlite',
      debug: env.dbDebug,
      printer: ConsoleQueryPrinter(),
    ),
  },
);
