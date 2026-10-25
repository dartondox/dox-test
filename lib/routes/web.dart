import 'dart:io';

import 'package:dox_auth/dox_auth.dart';
import 'package:dox_core/dox_core.dart';
import 'package:dox_storage/dox_storage.dart';
import 'package:dox_test/app/http/controllers/system.controller.dart';
import 'package:dox_test/app/http/controllers/web_auth.controller.dart';

/// Routes without a prefix.
class WebRouter extends Router {
  /// Session and CSRF only on browser routes, not on /api.
  @override
  List<dynamic> get middleware => <dynamic>[
    const SessionMiddleware(),
    const CsrfMiddleware(),
  ];

  @override
  void register() {
    Route.get('/ping', (SystemController c) => c.ping);
    Route.get('/playground', (SystemController c) => c.playground);

    /// Local signed URLs from Storage().signedUrl(): GET /files/{key*}
    Storage.route('files');

    /// Session login (the `web` guard), JSON answers.
    Route.group('/web-auth', registerWebAuth);

    /// The Vite build of the Inertia pages (`npm run build`).
    Route.get('/build/{path*}', buildFile);
    Route.disabledCors(registerNoCors);
  }

  /// The file names have a hash, so the browser can keep them for a year.
  DoxResponse buildFile(String path) {
    if (path.contains('..')) throw NotFoundHttpException();
    return response(File('public/build/$path')).cache(Duration(days: 365));
  }

  void registerWebAuth() {
    Route.post('/login', (WebAuthController c) => c.sessionLogin);
    Route.get('/me', <dynamic>[
      AuthMiddleware(guard: 'web'),
      (WebAuthController c) => c.sessionUser,
    ]);
    Route.post('/logout', (WebAuthController c) => c.sessionLogout);
  }

  void registerNoCors() {
    Route.get('/no-cors', (SystemController c) => c.noCors);
  }
}
