import 'package:dox_test/config/env.dart';
import 'package:dox_view/dox_view.dart';

/// The server-rendered pages under /views (resources/views/*.dox.html).
ViewConfig viewConfig = ViewConfig(
  globals: <String, Object?>{'appName': env.appName},
);
