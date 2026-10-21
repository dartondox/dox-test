import 'package:dox_core/dox_core.dart';

LoggerConfig logger = LoggerConfig(
  name: Env.get('APP_NAME'),
  enabled: true,
  level: Env.get('LOG_LEVEL', 'info'),
);
