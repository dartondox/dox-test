import 'package:dox_core/dox_core.dart';

part 'env.g.dart';

/// postgres, mysql or sqlite
enum DbConnection { postgres, mysql, sqlite }

/// The env of the app, typed.
///
/// Each getter reads one key: `appPort` reads `APP_PORT`.
/// A getter body is the default. A nullable getter with no body is optional.
/// Any other getter with no body is required: the app stops when it is missing.
/// A shell variable wins over the `.env` file,
/// so `DB_CONNECTION=mysql dart test` works without editing `.env`.
/// Check it with `dox env:check`.
@DoxEnv()
abstract class AppEnv {
  /// Reads and checks every key once.
  static AppEnv load([EnvReader? reader]) {
    return _$AppEnv.load(reader);
  }

  String get appName => 'dox-test';

  /// development, local or production
  String get appEnv => 'development';

  /// Encrypts cookies and signs the JWT.
  String get appKey;

  int get appPort => 3100;

  /// One isolate: Socket.IO rooms work without a Redis adapter.
  int get appTotalIsolate => 1;

  String get appUrl => 'http://127.0.0.1:3100';

  /// The header value the /api/system routes need.
  String get apiKey;

  bool get logRequests => false;

  String get logLevel => 'info';

  /// Bigger JSON bodies get 413. Small on purpose, so it is easy to try.
  int get maxBodySize => 1024 * 1024;

  /// Bigger uploads get 413.
  int get maxMultipartSize => 5 * 1024 * 1024;

  /// Only these clients may set X-Forwarded-For and X-Forwarded-Proto.
  List<String> get trustedProxies => <String>['127.0.0.1', '::1'];

  DbConnection get dbConnection => DbConnection.postgres;

  /// Empty means the default of the driver.
  String? get dbHost;

  /// Empty means 5452 (postgres) or 3326 (mysql), the docker compose ports.
  int? get dbPort;
  String? get dbUsername;
  String? get dbPassword;
  String get dbName => 'dox_test';

  /// sqlite file. Empty means a file in the system temp folder.
  String? get dbDatabase;
  bool get dbDebug => false;

  /// memory, file or redis
  String get cacheStore => 'file';
  String get redisHost => '127.0.0.1';
  int get redisPort => 6459;

  /// local, memory or s3
  String get storageDisk => 'local';
  String get awsBucket => 'dox-test';
  String get awsDefaultRegion => 'us-east-1';
  String get awsAccessKeyId => 'minioadmin';
  String get awsSecretAccessKey => 'minioadmin';
  String get awsEndpoint => 'http://127.0.0.1:9110';

  bool get socketioEnabled => true;
}

/// The env of the app. Read and checked once, on first use.
final AppEnv env = AppEnv.load();
