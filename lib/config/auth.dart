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
    /// JWT login. `revocation: true` lets POST /api/auth/logout stop a
    /// token before it expires. The deny-list lives in Redis.
    'api': AuthGuard(
      driver: JwtAuthDriver(
        secret: SecretKey(env.appKey),
        revocation: true,
        revocationStore: 'redis',
      ),
      provider: AuthProvider(model: makeAuthUser),
    ),

    /// Session login for browser pages (/web-auth and /inertia).
    'web': AuthGuard(
      driver: SessionAuthDriver(),
      provider: AuthProvider(model: makeAuthUser),
    ),

    /// Access tokens (`oat_<id>.<secret>`) for /api/tokens. The table
    /// comes from `dox auth:tokens-table --users-table=users`.
    'tokens': AuthGuard(
      driver: AccessTokenAuthDriver(),
      provider: AuthProvider(model: makeAuthUser),
    ),
  },
);

/// Too many failed logins for one email and ip give 429.
/// The default: 5 failed tries a minute.
LoginThrottle loginThrottle = LoginThrottle();
