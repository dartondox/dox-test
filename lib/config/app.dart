import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/http/middleware/app_header.middleware.dart';
import 'package:dox_test/app/http/requests/post.request.dart';
import 'package:dox_test/app/http/requests/register.request.dart';
import 'package:dox_test/app/http/response_handler.dart';
import 'package:dox_test/config/cache.dart';
import 'package:dox_test/config/cors.dart';
import 'package:dox_test/config/env.dart';
import 'package:dox_test/config/logger.dart';
import 'package:dox_test/config/services.dart';
import 'package:dox_test/config/storage.dart';
import 'package:dox_test/routes/api.dart';
import 'package:dox_test/routes/web.dart';
import 'package:dox_test/routes/websocket.dart';

AppConfig appConfig = AppConfig(
  appKey: AppEnv.get('APP_KEY'),
  serverPort: AppEnv.getInt('APP_PORT', 3100),

  /// One isolate: websocket rooms work without a Redis adapter.
  totalIsolate: AppEnv.getInt('APP_TOTAL_ISOLATE', 1),

  /// Form requests that dox injects into controllers.
  formRequests: <Type, FormRequest Function()>{
    RegisterRequest: RegisterRequest.new,
    PostRequest: PostRequest.new,
  },

  /// Runs on every route.
  globalMiddleware: <dynamic>[
    LogMiddleware(enabled: AppEnv.get('LOG_REQUESTS', 'false') == 'true'),
    AppHeaderMiddleware(),
  ],

  routers: <Router>[WebRouter(), ApiRouter(), WebsocketRouter()],
  responseHandler: ResponseHandler(),
  cache: cache,
  storage: storage,
  cors: cors,
  services: services,
  logger: logger,
);
