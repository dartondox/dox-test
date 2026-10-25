import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/http/middleware/app_header.middleware.dart';
import 'package:dox_test/app/http/response_handler.dart';
import 'package:dox_test/config/cache.dart';
import 'package:dox_test/config/cors.dart';
import 'package:dox_test/config/env.dart';
import 'package:dox_test/config/logger.dart';
import 'package:dox_test/config/openapi.dart';
import 'package:dox_test/config/socketio.dart';
import 'package:dox_test/config/storage.dart';
import 'package:dox_test/generated/container.g.dart';
import 'package:dox_test/generated/dtos.g.dart';

AppConfig appConfig = AppConfig(
  appKey: env.appKey,
  serverPort: env.appPort,

  /// One isolate: Socket.IO rooms work without a Redis adapter.
  totalIsolate: env.appTotalIsolate,

  /// Every @Dto class, from lib/dtos.g.dart (`dart run build_runner build`).
  dtos: dtos,

  /// Runs on every route.
  globalMiddleware: <dynamic>[
    LogMiddleware(enabled: env.logRequests),
    AppHeaderMiddleware(),
  ],

  container: registerContainer,
  responseHandler: ResponseHandler(),
  cache: cache,
  storage: storage,
  cors: cors,
  logger: logger,
  openApi: openApi,
  socketIo: socketIo,

  /// Sessions live in Redis, so a logout ends the old session cookie too.
  /// The default `cookie` driver keeps all data in the cookie: a copy of
  /// an old cookie still works after logout.
  session: SessionConfig(driver: 'cache', store: 'redis'),

  /// Bigger bodies get 413. Small on purpose, so it is easy to try.
  maxBodySize: env.maxBodySize,
  maxMultipartSize: env.maxMultipartSize,

  /// Only these clients may set X-Forwarded-For and X-Forwarded-Proto.
  trustedProxies: env.trustedProxies,
);
