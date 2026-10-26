import 'package:dox_test/config/view.dart';
import 'package:dox_view/dox_view.dart';

/// Sets up dox_view in every isolate. Dox finds every DoxProvider class,
/// see lib/container.g.dart.
class AppViewProvider extends ViewProvider {
  AppViewProvider() : super(viewConfig);
}
