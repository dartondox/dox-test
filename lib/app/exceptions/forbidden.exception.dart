import 'dart:io';

import 'package:dox_core/dox_core.dart';

/// Sent as HTTP 403.
class ForbiddenException extends IHttpException {
  ForbiddenException([String text = 'Forbidden']) {
    code = HttpStatus.forbidden;
    errorCode = 'forbidden';
    message = <String, String>{'message': text};
  }
}
