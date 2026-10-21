import 'dart:io';

import 'package:dox_core/dox_core.dart';

/// Reads a setting. A shell variable wins over the `.env` file,
/// so `DB_CONNECTION=mysql dart test` works without editing `.env`.
class AppEnv {
  static String get(String key, [String fallback = '']) {
    String? fromShell = Platform.environment[key];
    if (fromShell != null && fromShell.isNotEmpty) {
      return fromShell;
    }
    return Env.get<String>(key, fallback);
  }

  static int getInt(String key, int fallback) {
    return int.parse(get(key, fallback.toString()));
  }
}
