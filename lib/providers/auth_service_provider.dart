import 'package:dox_auth/dox_auth.dart';
import 'package:dox_core/dox_core.dart';
import 'package:dox_test/config/auth.dart';

/// Sets up dox-auth with the JWT guard.
class AuthServiceProvider implements DoxService {
  @override
  void setup() {
    Auth.initialize(authConfig);
  }
}
