import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/http/controllers/view.controller.dart';

/// Server-rendered pages (dox_view). All routes here start with /views
class ViewsRouter extends Router {
  @override
  String get prefix => 'views';

  /// Session and CSRF only on browser routes, not on /api.
  @override
  List<dynamic> get middleware => <dynamic>[
    const SessionMiddleware(),
    const CsrfMiddleware(),
  ];

  @override
  void register() {
    Route.get('/', (ViewController c) => c.index);
    Route.post('/notes', (ViewController c) => c.store);
  }
}
