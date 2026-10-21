import 'package:dox_core/dox_core.dart';
import 'package:dox_test/config/env.dart';

LoggerConfig logger = LoggerConfig(
  name: env.appName,
  enabled: true,
  level: env.logLevel,
);
