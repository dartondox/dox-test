import 'package:dox_inertia/dox_inertia.dart';
import 'package:dox_test/config/inertia.dart';

/// Sets up Inertia in every isolate. Dox finds every DoxProvider class,
/// see lib/container.g.dart.
class AppInertiaProvider extends InertiaProvider {
  AppInertiaProvider() : super(inertiaConfig);
}
