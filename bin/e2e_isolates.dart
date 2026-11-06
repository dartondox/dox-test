import 'package:dox_core/dox_core.dart';
import 'package:dox_test/bootstrap.dart';

import '../db/migration/migrations.dart';

/// The app server for the multi isolate checks of test/e2e_310_core.dart.
/// The test starts it with `APP_PORT` and `APP_TOTAL_ISOLATE` set.
///
/// The static folder is added before `startServer()` and outside a
/// Router, so only the isolate setup brings it to the other isolates
/// (dox#332).
void main() async {
  Route.staticFiles('/e2e-static', 'public/core');
  await Bootstrap(migrations).start();
}
