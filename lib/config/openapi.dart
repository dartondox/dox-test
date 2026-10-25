import 'package:dox_core/dox_core.dart';
import 'package:dox_test/constants/app_constants.dart';
import 'package:dox_test/generated/openapi.g.dart';

/// Docs at /docs, /openapi.json and /openapi.yaml.
/// On when APP_ENV is development or local.
/// `openApiRegistry` comes from `dart run build_runner build`.
OpenApiConfig openApi = OpenApiConfig(
  info: const Info(title: 'dox-test API', version: '1.0.0'),
  registry: openApiRegistry,
  securitySchemes: <String, SecurityScheme>{
    'apiKey': SecurityScheme.apiKey(name: AppConstants.apiKeyHeader),
  },
  securityByMiddleware: <String, List<Map<String, List<String>>>>{
    'ApiKeyMiddleware': <Map<String, List<String>>>[
      <String, List<String>>{'apiKey': <String>[]},
    ],
  },
);
