import 'package:dox_test/config/view.dart';
import 'package:dox_view/dox_view.dart';

/// Sets up dox_view in every isolate. Dox finds every DoxService class,
/// see lib/container.g.dart.
class AppViewService extends ViewService {
  AppViewService() : super(viewConfig);
}
