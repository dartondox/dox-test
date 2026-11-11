import 'package:dox_inertia/dox_inertia.dart';
import 'package:dox_test/config/inertia.dart';

/// Sets up Inertia in every isolate. Dox finds every DoxProvider class,
/// see lib/container.g.dart.
class AppInertiaProvider extends InertiaProvider {
  AppInertiaProvider() : super(inertiaConfig);

  @override
  void setup() {
    super.setup();
    // Global props for test/e2e_310b_packages.dart. They are set here at
    // boot, not in the test: dox_inertia can not remove a global, so a
    // test that sets one would change the pages of every later test.
    Inertia.shareGlobal('e310b_pkg_global', 'global value');
    Inertia.shareGlobal('e310b_pkg_who', 'global');
  }
}
