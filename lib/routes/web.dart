import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/http/controllers/system.controller.dart';

/// Routes without a prefix.
class WebRouter extends Router {
  @override
  void register() {
    Route.get('/ping', Dox().ioc.get<SystemController>().ping);
    Route.disabledCors(registerNoCors);
  }

  void registerNoCors() {
    Route.get('/no-cors', Dox().ioc.get<SystemController>().noCors);
  }
}
