import 'package:dox_auth/dox_auth.dart';
import 'package:dox_core/dox_core.dart';

/// Routes for test/e2e_310_core.dart. CoreRouter adds them in the group
/// `/e2e`, so they all start with /core/e2e. Plain functions, so they need
/// no container entry (no build_runner run).
class E2eCoreRoutes {
  void register() {
    /// `.where` checks the decoded param too (dox#333)
    Route.get('/files/{name}', fileName).where('name', r'[^/]+');
    Route.get('/letters/{word}', word).where('word', r'[a-z]+');

    /// the guard checks `req.pathIs`, the route itself has no guard
    Route.middleware(<dynamic>[PathGuard()], registerGuarded);

    /// middleware order: group, then the route list, then the handler
    Route.middleware(<dynamic>[OrderMark('group')], registerOrder);

    Route.post('/input', inputHelpers);
    Route.get('/bearer', bearer);

    Route.resource('/notes', E2eNotes(), name: 'e2e.notes');
    Route.get('/note-url/{id}', noteUrl);

    Route.get('/signed/{id}', <dynamic>[
      const ValidateSignature(absolute: false),
      signedPage,
    ]).name('e2e.signed');
    Route.get('/sign/{id}', sign);

    Route.get('/conflict', conflict);
    Route.get('/retry', retryLater);

    Route.get('/guest-redirect', <dynamic>[
      GuestMiddleware(redirectTo: '/core/new'),
      guestPage,
    ]);
    Route.get('/token-whoami', <dynamic>[
      AuthMiddleware(guard: 'tokens', optional: true),
      tokenWhoami,
    ]);

    /// a static folder with Cache-Control
    Route.staticFiles('/cached', 'public/core', maxAge: Duration(hours: 1));
  }

  void registerGuarded() {
    Route.get('/admin', adminPage);
    Route.get('/open', adminPage);
  }

  void registerOrder() {
    Route.get('/order', <dynamic>[
      OrderMark('first'),
      OrderMark('second'),
      orderPage,
    ]);
  }

  Map<String, dynamic> fileName(DoxRequest req) {
    return <String, dynamic>{'name': req.param['name']};
  }

  Map<String, dynamic> word(DoxRequest req) {
    return <String, dynamic>{'word': req.param['word']};
  }

  Map<String, dynamic> adminPage(DoxRequest req) {
    return <String, dynamic>{'path': req.path()};
  }

  String orderPage(DoxRequest req) {
    return 'ok';
  }

  /// POST /core/e2e/input: the request helpers on fixed keys.
  Map<String, dynamic> inputHelpers(DoxRequest req) {
    RequestFile? file = req.file('file');
    return <String, dynamic>{
      'name': req.input('name', 'default'),
      'filled_name': req.filled('name'),
      'exists_name': req.exists('name'),
      'missing_name': req.missing('name'),
      'has_name': req.has('name'),
      'deep': req.input('a.b.c'),
      'dotted': req.input('x.y'),
      'item': req.input('items.5.id', 'none'),
      'flag': req.boolean('flag'),
      'flag_or_true': req.boolean('flag', true),
      'n': req.integer('n', -1),
      'has_file': req.hasFile('file'),
      'file_name': file?.filename,
      'has_files': req.hasFile('files'),
      'except': req.except(<String>['name']).keys.toList(),
    };
  }

  Map<String, dynamic> bearer(DoxRequest req) {
    return <String, dynamic>{'token': req.bearerToken()};
  }

  /// GET /core/e2e/note-url/{id}: the url of a named resource route.
  Map<String, dynamic> noteUrl(DoxRequest req) {
    return <String, dynamic>{
      'show': Route.url(
        'e2e.notes.show',
        params: <String, Object>{'id': req.param['id']},
      ),
      'index': Route.url('e2e.notes.index'),
    };
  }

  /// GET /core/e2e/sign/{id}?ttl=seconds: a signed path for /signed/{id}.
  Map<String, dynamic> sign(DoxRequest req) {
    String? ttl = req.input('ttl');
    return <String, dynamic>{
      'url': Route.signedUrl(
        'e2e.signed',
        params: <String, Object>{'id': req.param['id']},
        expires: ttl == null ? null : Duration(seconds: int.parse(ttl)),
        absolute: false,
      ),
    };
  }

  Map<String, dynamic> signedPage(DoxRequest req) {
    return <String, dynamic>{'id': req.param['id']};
  }

  Never conflict(DoxRequest req) {
    abort(409, 'The name is taken');
  }

  Never retryLater(DoxRequest req) {
    throw HttpStatusException(
      503,
      headers: <String, String>{'retry-after': '60'},
    );
  }

  Map<String, String> guestPage(DoxRequest req) {
    return <String, String>{'page': 'guest'};
  }

  Map<String, dynamic> tokenWhoami(DoxRequest req) {
    return <String, dynamic>{'id': req.auth?.id()};
  }
}

/// 403 for /core/e2e/admin, found with `req.pathIs`.
class PathGuard implements IDoxMiddleware {
  @override
  IDoxRequest handle(IDoxRequest req) {
    if ((req as DoxRequest).pathIs('core/e2e/admin')) {
      throw ForbiddenHttpException(message: 'admin only');
    }
    return req;
  }
}

/// Adds its name to the `X-Order` header, to see the middleware order.
class OrderMark implements IDoxMiddleware {
  OrderMark(this.name);

  final String name;

  @override
  IDoxRequest handle(IDoxRequest req) {
    req.httpRequest.response.headers.add('x-order', name);
    return req;
  }
}

/// A resource controller object: each action says who it is.
class E2eNotes {
  Map<String, dynamic> index(DoxRequest req) => _say(req, 'index');
  Map<String, dynamic> create(DoxRequest req) => _say(req, 'create');
  Map<String, dynamic> store(DoxRequest req) => _say(req, 'store');
  Map<String, dynamic> show(DoxRequest req) => _say(req, 'show');
  Map<String, dynamic> edit(DoxRequest req) => _say(req, 'edit');
  Map<String, dynamic> update(DoxRequest req) => _say(req, 'update');
  Map<String, dynamic> destroy(DoxRequest req) => _say(req, 'destroy');

  Map<String, dynamic> _say(DoxRequest req, String action) {
    return <String, dynamic>{
      'action': action,
      'method': req.method,
      'id': req.param['id'],
    };
  }
}
