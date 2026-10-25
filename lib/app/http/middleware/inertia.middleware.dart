import 'package:dox_core/dox_core.dart';
import 'package:dox_inertia/dox_inertia.dart';
import 'package:dox_test/config/env.dart';

/// Props for every Inertia page.
class HandleInertiaRequests extends InertiaMiddleware {
  @override
  Map<String, dynamic> share(DoxRequest req) {
    return <String, dynamic>{'appName': env.appName};
  }
}
