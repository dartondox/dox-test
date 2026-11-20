import 'dart:io';

import 'package:dox_core/dox_core.dart';
import 'package:dox_test/config/app.dart';

/// The app server with small HTTP/2 limits, for the limit checks of
/// test/e2e_33_http2_grpc.dart. The test starts it with `APP_PORT`, and
/// may set `APP_HTTP2`, `APP_ENV` and these (unset: the app value):
/// `H2_MAX_STREAMS`, `H2_BODY_TIMEOUT_MS`, `H2_IDLE_TIMEOUT_MS`.
/// It uses the database of the main test run, with no migrations.
void main() async {
  Map<String, String> e = Platform.environment;
  int? number(String key) => int.tryParse(e[key] ?? '');
  Duration? ms(String key) {
    int? n = number(key);
    return n == null ? null : Duration(milliseconds: n);
  }

  AppConfig old = appConfig;
  Dox().initialize(
    AppConfig(
      appKey: old.appKey,
      previousKeys: old.previousKeys,
      serverPort: old.serverPort,
      host: old.host,
      totalIsolate: old.totalIsolate,
      providers: old.providers,
      dtos: old.dtos,
      validationMessages: old.validationMessages,
      globalMiddleware: old.globalMiddleware,
      routers: old.routers,
      container: old.container,
      cors: old.cors,
      logger: old.logger,
      cache: old.cache,
      session: old.session,
      openApi: old.openApi,
      exceptionHandler: old.exceptionHandler,
      responseHandler: old.responseHandler,
      maxBodySize: old.maxBodySize,
      maxMultipartSize: old.maxMultipartSize,
      bodyTimeout: ms('H2_BODY_TIMEOUT_MS') ?? old.bodyTimeout,
      idleTimeout: ms('H2_IDLE_TIMEOUT_MS') ?? old.idleTimeout,
      maxConnections: old.maxConnections,
      http2: old.http2,
      maxConcurrentStreams:
          number('H2_MAX_STREAMS') ?? old.maxConcurrentStreams,
      trustedProxies: old.trustedProxies,
      compress: old.compress,
      shutdownTimeout: old.shutdownTimeout,
      webSocketAllowedOrigins: old.webSocketAllowedOrigins,
      flags: old.flags,
      computeWorkers: old.computeWorkers,
      strict: old.strict,
      htmlErrors: old.htmlErrors,
      errorPage: old.errorPage,
    ),
  );
  await Dox().startServer();
}
