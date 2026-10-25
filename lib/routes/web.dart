import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/http/controllers/system.controller.dart';

/// Routes without a prefix.
class WebRouter extends Router {
  @override
  void register() {
    Route.get('/ping', (SystemController c) => c.ping);
    Route.get(
      '/playground',
      (SystemController c) => c.playground,
    );

    /// Local signed URLs from Storage().signedUrl(): GET /files/{key*}
    Route.files('files');
    Route.disabledCors(registerNoCors);
  }

  void registerNoCors() {
    Route.get('/no-cors', (SystemController c) => c.noCors);
  }
}
