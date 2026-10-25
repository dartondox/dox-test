import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/http/controllers/inertia.controller.dart';
import 'package:dox_test/app/http/middleware/inertia.middleware.dart';

/// Inertia pages (React). All routes here start with /inertia
class InertiaRouter extends Router {
  @override
  String get prefix => 'inertia';

  /// Session and CSRF only on browser routes, not on /api.
  @override
  List<dynamic> get middleware => <dynamic>[
    const SessionMiddleware(),
    const CsrfMiddleware(),
    HandleInertiaRequests(),
  ];

  @override
  void register() {
    Route.get('/', (InertiaController c) => c.home);
    Route.get('/notes', (InertiaController c) => c.index);
    Route.post('/notes', (InertiaController c) => c.store);
    Route.delete('/notes/{id}', (InertiaController c) => c.destroy);
  }
}
