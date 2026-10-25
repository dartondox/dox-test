import 'package:dox_auth/dox_auth.dart';
import 'package:dox_core/dox_core.dart';
import 'package:dox_test/config/auth.dart';

/// Sets up dox-auth with the JWT guard (api) and the session guard (web).
class AppAuthProvider extends DoxProvider {
  @override
  void setup() {
    Auth.initialize(authConfig);
  }
}
