import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/exceptions/forbidden.exception.dart';
import 'package:dox_test/config/env.dart';
import 'package:dox_test/constants/app_constants.dart';

/// Route middleware: the request must send the right API key header.
class ApiKeyMiddleware implements IDoxMiddleware {
  @override
  IDoxRequest handle(IDoxRequest req) {
    if (req.header(AppConstants.apiKeyHeader) != env.apiKey) {
      throw ForbiddenException('invalid api key');
    }
    return req;
  }
}
