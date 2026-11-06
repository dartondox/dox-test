import 'package:dox_auth/dox_auth.dart';
import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/dtos/e2e310b/e2e310b.dto.dart';

/// Routes for test/e2e_310b_core.dart. CoreRouter adds them in the group
/// `/e2eb`, so they all start with /core/e2eb. Plain functions, so they
/// need no container entry.
class E2eCoreBRoutes {
  /// the OpenAPI `body:` schema of the GET and DELETE /search routes
  static const Map<String, dynamic> searchSchema = <String, dynamic>{
    'type': 'object',
    'properties': <String, dynamic>{
      'q': <String, dynamic>{'type': 'string'},
      'page': <String, dynamic>{'type': 'integer'},
    },
  };

  void register() {
    /// `.*` must match a decoded `%0A` too (dox#334)
    Route.get('/docs/{page}', page).where('page', '.*');
    Route.get('/path-is/{rest*}', pathIs);

    /// Crypt.decrypt of the `value` field
    Route.post('/decrypt', decrypt);

    /// a DTO whose rule reads a later field (dox#334)
    Route.post('/plan', plan);

    /// optional params for the OpenAPI checks (dox-openapi#4)
    Route.get('/opt/{x?}/b', optional);
    Route.get('/hi/{name?}', hello);

    /// GET and DELETE with a `body` schema: query params in the docs.
    /// `Route.get` has no `body:` option, so it is set on the route data.
    Route.get('/search', search);
    Route().routes.last.body = searchSchema;
    Route.delete('/search', search);
    Route().routes.last.body = searchSchema;

    /// a JWT guard and the tokens guard can not log out (dox-auth#16)
    Route.post('/logout/{guard}', logout);

    Route.middleware(<dynamic>[const SessionMiddleware()], registerSession);
  }

  void registerSession() {
    /// a session user or a JWT user, tried in order (dox-auth#16)
    Route.get('/multi', <dynamic>[
      AuthMiddleware(guards: <String>['web', 'api']),
      whoami,
    ]);
    Route.post('/once', once);
  }

  Map<String, dynamic> page(DoxRequest req) {
    return <String, dynamic>{'page': req.param['page']};
  }

  Map<String, dynamic> pathIs(DoxRequest req) {
    return <String, dynamic>{
      'exact': req.pathIs('core/e2eb/path-is/a'),
      'slash': req.pathIs('/core/e2eb/path-is/a/'),
      'wild': req.pathIs('core/e2eb/*'),
      'other': req.pathIs('api/*'),
      // the second call uses the cached regex
      'again': req.pathIs('core/e2eb/path-is/a'),
    };
  }

  Map<String, dynamic> decrypt(DoxRequest req) {
    return <String, dynamic>{'value': Crypt.decrypt('${req.input('value')}')};
  }

  Map<String, dynamic> plan(E2ePlanForm form) {
    return <String, dynamic>{'plan': form.plan, 'card': form.card};
  }

  Map<String, dynamic> optional(DoxRequest req) {
    return <String, dynamic>{'x': req.param['x']};
  }

  Map<String, dynamic> hello(DoxRequest req) {
    return <String, dynamic>{'name': req.param['name']};
  }

  Map<String, dynamic> search(DoxRequest req) {
    return <String, dynamic>{'q': req.input('q')};
  }

  /// the error text of `logout` on a guard with no session driver
  Map<String, dynamic> logout(DoxRequest req) {
    try {
      Auth(guard: req.param['guard']).logout(req);
      return <String, dynamic>{'error': null};
    } on StateError catch (error) {
      return <String, dynamic>{'error': error.message};
    }
  }

  Map<String, dynamic> whoami(DoxRequest req) {
    return <String, dynamic>{'id': req.auth?.id()};
  }

  /// `Auth.once` on the web guard: no session login is kept.
  Future<Map<String, dynamic>> once(DoxRequest req) async {
    Auth auth = Auth(guard: 'web');
    bool ok = await auth.once(<String, dynamic>{
      'email': req.input('email'),
      'password': req.input('password'),
    });
    return <String, dynamic>{
      'ok': ok,
      'id': auth.id(),
      'session': req.session.get(SessionAuthDriver.sessionKey('web')),
    };
  }
}
