// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'env.dart';

// **************************************************************************
// Generator: DoxEnvBuilder
// **************************************************************************

class _$AppEnv extends AppEnv {
  _$AppEnv._({
    required this.appName,
    required this.appEnv,
    required this.appKey,
    required this.appPort,
    required this.appTotalIsolate,
    required this.appUrl,
    required this.apiKey,
    required this.logRequests,
    required this.logLevel,
    required this.maxBodySize,
    required this.maxMultipartSize,
    required this.trustedProxies,
    required this.dbConnection,
    required this.dbHost,
    required this.dbPort,
    required this.dbUsername,
    required this.dbPassword,
    required this.dbName,
    required this.dbDatabase,
    required this.dbDebug,
    required this.cacheStore,
    required this.redisHost,
    required this.redisPort,
    required this.storageDisk,
    required this.awsBucket,
    required this.awsDefaultRegion,
    required this.awsAccessKeyId,
    required this.awsSecretAccessKey,
    required this.awsEndpoint,
    required this.socketioEnabled,
  });

  @override
  final String appName;
  @override
  final String appEnv;
  @override
  final String appKey;
  @override
  final int appPort;
  @override
  final int appTotalIsolate;
  @override
  final String appUrl;
  @override
  final String apiKey;
  @override
  final bool logRequests;
  @override
  final String logLevel;
  @override
  final int maxBodySize;
  @override
  final int maxMultipartSize;
  @override
  final List<String> trustedProxies;
  @override
  final DbConnection dbConnection;
  @override
  final String? dbHost;
  @override
  final int? dbPort;
  @override
  final String? dbUsername;
  @override
  final String? dbPassword;
  @override
  final String dbName;
  @override
  final String? dbDatabase;
  @override
  final bool dbDebug;
  @override
  final String cacheStore;
  @override
  final String redisHost;
  @override
  final int redisPort;
  @override
  final String storageDisk;
  @override
  final String awsBucket;
  @override
  final String awsDefaultRegion;
  @override
  final String awsAccessKeyId;
  @override
  final String awsSecretAccessKey;
  @override
  final String awsEndpoint;
  @override
  final bool socketioEnabled;

  /// reads and checks every key once. Throws `EnvException` with all
  /// missing or bad keys.
  static AppEnv load([EnvReader? reader]) {
    EnvReader r = reader ?? EnvReader();
    _$AppEnvDefaults d = _$AppEnvDefaults();
    String appName = r.string('APP_NAME') ?? d.appName;
    String appEnv = r.string('APP_ENV') ?? d.appEnv;
    String? appKey = r.string('APP_KEY');
    r.need('APP_KEY');
    int appPort = r.integer('APP_PORT') ?? d.appPort;
    int appTotalIsolate = r.integer('APP_TOTAL_ISOLATE') ?? d.appTotalIsolate;
    String appUrl = r.string('APP_URL') ?? d.appUrl;
    String? apiKey = r.string('API_KEY');
    r.need('API_KEY');
    bool logRequests = r.boolean('LOG_REQUESTS') ?? d.logRequests;
    String logLevel = r.string('LOG_LEVEL') ?? d.logLevel;
    int maxBodySize = r.integer('MAX_BODY_SIZE') ?? d.maxBodySize;
    int maxMultipartSize =
        r.integer('MAX_MULTIPART_SIZE') ?? d.maxMultipartSize;
    List<String> trustedProxies = r.list('TRUSTED_PROXIES') ?? d.trustedProxies;
    DbConnection dbConnection =
        r.enumByName('DB_CONNECTION', DbConnection.values) ?? d.dbConnection;
    String? dbHost = r.string('DB_HOST');
    int? dbPort = r.integer('DB_PORT');
    String? dbUsername = r.string('DB_USERNAME');
    String? dbPassword = r.string('DB_PASSWORD');
    String dbName = r.string('DB_NAME') ?? d.dbName;
    String? dbDatabase = r.string('DB_DATABASE');
    bool dbDebug = r.boolean('DB_DEBUG') ?? d.dbDebug;
    String cacheStore = r.string('CACHE_STORE') ?? d.cacheStore;
    String redisHost = r.string('REDIS_HOST') ?? d.redisHost;
    int redisPort = r.integer('REDIS_PORT') ?? d.redisPort;
    String storageDisk = r.string('STORAGE_DISK') ?? d.storageDisk;
    String awsBucket = r.string('AWS_BUCKET') ?? d.awsBucket;
    String awsDefaultRegion =
        r.string('AWS_DEFAULT_REGION') ?? d.awsDefaultRegion;
    String awsAccessKeyId = r.string('AWS_ACCESS_KEY_ID') ?? d.awsAccessKeyId;
    String awsSecretAccessKey =
        r.string('AWS_SECRET_ACCESS_KEY') ?? d.awsSecretAccessKey;
    String awsEndpoint = r.string('AWS_ENDPOINT') ?? d.awsEndpoint;
    bool socketioEnabled = r.boolean('SOCKETIO_ENABLED') ?? d.socketioEnabled;

    r.check();
    return _$AppEnv._(
      appName: appName,
      appEnv: appEnv,
      appKey: appKey!,
      appPort: appPort,
      appTotalIsolate: appTotalIsolate,
      appUrl: appUrl,
      apiKey: apiKey!,
      logRequests: logRequests,
      logLevel: logLevel,
      maxBodySize: maxBodySize,
      maxMultipartSize: maxMultipartSize,
      trustedProxies: trustedProxies,
      dbConnection: dbConnection,
      dbHost: dbHost,
      dbPort: dbPort,
      dbUsername: dbUsername,
      dbPassword: dbPassword,
      dbName: dbName,
      dbDatabase: dbDatabase,
      dbDebug: dbDebug,
      cacheStore: cacheStore,
      redisHost: redisHost,
      redisPort: redisPort,
      storageDisk: storageDisk,
      awsBucket: awsBucket,
      awsDefaultRegion: awsDefaultRegion,
      awsAccessKeyId: awsAccessKeyId,
      awsSecretAccessKey: awsSecretAccessKey,
      awsEndpoint: awsEndpoint,
      socketioEnabled: socketioEnabled,
    );
  }
}

/// gives the getter bodies of [AppEnv] (the defaults)
class _$AppEnvDefaults extends AppEnv {
  @override
  String get appKey => throw StateError('APP_KEY has no default');
  @override
  String get apiKey => throw StateError('API_KEY has no default');
  @override
  String? get dbHost => throw StateError('DB_HOST has no default');
  @override
  int? get dbPort => throw StateError('DB_PORT has no default');
  @override
  String? get dbUsername => throw StateError('DB_USERNAME has no default');
  @override
  String? get dbPassword => throw StateError('DB_PASSWORD has no default');
  @override
  String? get dbDatabase => throw StateError('DB_DATABASE has no default');
}
