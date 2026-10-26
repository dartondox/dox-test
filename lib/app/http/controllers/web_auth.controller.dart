import 'package:dox_auth/dox_auth.dart';
import 'package:dox_core/dox_core.dart';
import 'package:dox_inertia/dox_inertia.dart';
import 'package:dox_test/app/dtos/auth/auth.dto.dart';
import 'package:dox_test/app/http/serializers/user.serializer.dart';
import 'package:dox_test/app/models/user/user.model.dart';

/// Session login (the `web` guard) for browser pages.
/// `/web-auth/*` answers JSON. `/inertia/*` shows the React pages.
///
/// ponytail: the method names differ from AuthController (login, me) on
/// purpose. dox_openapi mixes up two routes with the same method name.
@Inject()
@ApiIgnore()
class WebAuthController {
  /// The login of the `web` guard. A new one per call: Auth keeps the user.
  Auth _auth() => Auth(guard: 'web');

  /// POST /web-auth/login
  /// The session gets a new id. Wrong email or password gives 401.
  Future<DoxResponse> sessionLogin(DoxRequest req, LoginUser body) async {
    Auth auth = _auth();
    if (!await auth.attemptSession(req, _credentials(body))) {
      return response(<String, String>{'message': 'Wrong email or password'})
          .statusCode(401);
    }
    return response(UserSerializer(auth.user<User>()));
  }

  /// GET /web-auth/me
  UserSerializer sessionUser(DoxRequest req) {
    return UserSerializer(req.auth?.user<User>());
  }

  /// POST /web-auth/logout
  /// All session data is removed and the session gets a new id.
  Map<String, bool> sessionLogout(DoxRequest req) {
    _auth().logout(req);
    return <String, bool>{'logged_out': true};
  }

  /// GET /inertia/login
  Future<DoxResponse> loginPage(DoxRequest req) {
    return inertia(req, 'Login', <String, dynamic>{});
  }

  /// POST /inertia/login
  /// A bad form or a wrong password goes back with `errors`.
  Future<DoxResponse> loginForm(DoxRequest req, LoginUser body) async {
    if (!await _auth().attemptSession(req, _credentials(body))) {
      req.session.flashErrors(
        <String, String>{'email': 'Wrong email or password'},
        input: <String, dynamic>{'email': body.email},
      );
      return back(req, fallback: '/inertia/login');
    }
    return redirect('/inertia/dashboard');
  }

  /// GET /inertia/dashboard. `AuthMiddleware` sends a guest to the login.
  Future<DoxResponse> dashboard(DoxRequest req) {
    return inertia(req, 'Dashboard', <String, dynamic>{});
  }

  /// POST /inertia/logout
  DoxResponse logoutForm(DoxRequest req) {
    _auth().logout(req);
    return redirect('/inertia/login');
  }

  Map<String, dynamic> _credentials(LoginUser body) {
    return <String, dynamic>{'email': body.email, 'password': body.password};
  }
}
