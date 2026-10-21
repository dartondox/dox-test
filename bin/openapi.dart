import 'dart:io';

import 'package:dox_core/dox_core.dart';
import 'package:dox_test/config/app.dart';

/// `dox openapi:generate [dir]` runs this file.
/// Writes openapi.json and openapi.yaml (default storage/openapi).
Future<void> main(List<String> args) async {
  Dox().initialize(appConfig);
  await Dox().writeOpenApi(args.isEmpty ? 'storage/openapi' : args.first);
  exit(0);
}
