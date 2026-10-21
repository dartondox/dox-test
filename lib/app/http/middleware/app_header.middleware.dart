import 'package:dox_core/dox_core.dart';
import 'package:dox_test/config/env.dart';
import 'package:dox_test/constants/app_constants.dart';

/// Global middleware: adds the app name header to every response.
class AppHeaderMiddleware implements IDoxMiddleware {
  @override
  IDoxRequest handle(IDoxRequest req) {
    req.httpRequest.response.headers.set(AppConstants.appHeader, env.appName);
    return req;
  }
}
