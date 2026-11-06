import 'dart:io';

import 'package:dox_auth/dox_auth.dart';
import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/http/controllers/core.controller.dart';
import 'package:dox_test/app/ws/echo.socket.dart';
import 'package:dox_test/routes/e2e_core.dart';
import 'package:dox_test/routes/e2e_core_b.dart';
import 'package:dox_test/routes/e2e310b_orm.dart';

/// The dox_core features of 3.1.0. All routes here start with /core.
/// No session here: only the /core/flash routes have one.
class CoreRouter extends Router {
  @override
  String get prefix => 'core';

  @override
  void register() {
    Route.match(
      <String>['GET', 'POST'],
      '/match',
      (CoreController c) => c.method,
    );
    Route.any('/any', (CoreController c) => c.method);

    /// a plain form reaches these with POST and `_method` (MethodOverride)
    Route.match(
      <String>['PUT', 'PATCH', 'DELETE'],
      '/override',
      (CoreController c) => c.method,
    );

    Route.redirect('/old', '/core/new');
    Route.permanentRedirect('/moved', '/core/new');
    Route.get('/new', (CoreController c) => c.newPage);

    /// digits go to itemById, the rest to itemBySlug
    Route.get(
      '/items/{id}',
      (CoreController c) => c.itemById,
    ).where('id', r'^[0-9]+$');
    Route.get('/items/{slug}', (CoreController c) => c.itemBySlug);

    Route.post(
      '/request/{id}',
      (CoreController c) => c.inspect,
    ).name('core.inspect');
    Route.get('/headers', (CoreController c) => c.headers);
    Route.get('/download', (CoreController c) => c.download);

    Route.get('/whoami', <dynamic>[
      AuthMiddleware(optional: true),
      (CoreController c) => c.whoami,
    ]);
    Route.get('/guest-only', <dynamic>[
      GuestMiddleware(),
      (CoreController c) => c.guestOnly,
    ]);

    Route.post('/contacts', (CoreController c) => c.saveContact);
    Route.post('/banner', (CoreController c) => c.banner);
    Route.get('/plain-view', (CoreController c) => c.plainView);

    Route.middleware(<dynamic>[const SessionMiddleware()], registerFlash);

    /// public/core at /core/assets. A route wins over a file.
    Route.get('/assets/route.txt', routeText);
    Route.staticFiles('/assets', 'public/core');

    Route.websocket(
      '/echo',
      EchoSocket().handle,
      allowedOrigins: <String>[],
      maxMessageSize: 64,
    );

    /// A mount does not take the router prefix.
    Route.mount('/core-mount', mountOuter);
    Route.mount('/core-mount/inner', mountInner, middleware: true);

    /// A param in the group prefix: the fallback still matches, and
    /// req.param has `tenant`.
    Route.group('/t/{tenant}', registerTenant);

    Route.group('/e2e', E2eCoreRoutes().register);
    Route.group('/e2eb', E2eCoreBRoutes().register);
    Route.group('/e310b', E310bOrmRoutes().register);

    /// GET /core/<no route> gets this, not the plain 404.
    Route.fallback((CoreController c) => c.notFound);
  }

  void registerTenant() {
    Route.get('/home', tenantPage);
    Route.fallback(tenantPage);
  }

  /// GET /core/t/{tenant}/...: the tenant and the path.
  Map<String, dynamic> tenantPage(DoxRequest req) {
    return <String, dynamic>{'tenant': req.param['tenant'], 'path': req.path()};
  }

  void registerFlash() {
    Route.get('/flash/set', (CoreController c) => c.flashSet);
    Route.get('/flash/keep', (CoreController c) => c.flashKeep);
    Route.get('/flash/read', (CoreController c) => c.flashRead);
  }

  String routeText(DoxRequest req) {
    return 'from the route';
  }

  /// Raw handlers: they write the answer themselves.
  Future<void> mountOuter(HttpRequest req) async {
    req.response.write('outer ${req.uri.path}');
    await req.response.close();
  }

  Future<void> mountInner(HttpRequest req) async {
    req.response.write('inner ${req.uri.path}');
    await req.response.close();
  }
}
