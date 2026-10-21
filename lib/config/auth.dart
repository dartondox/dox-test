import 'package:dox_auth/dox_auth.dart';
import 'package:dox_test/app/models/user/user.model.dart';
import 'package:dox_test/config/env.dart';

/// Makes a new User model for the auth package.
User makeAuthUser() {
  return User();
}

AuthConfig authConfig = AuthConfig(
  defaultGuard: 'api',
  guards: <String, AuthGuard>{
    'api': AuthGuard(
      driver: JwtAuthDriver(secret: SecretKey(AppEnv.get('APP_KEY'))),
      provider: AuthProvider(model: makeAuthUser),
    ),
  },
);
