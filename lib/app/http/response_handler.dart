import 'package:dox_core/dox_core.dart';

/// Last step before every response. Nothing to change for now.
class ResponseHandler extends ResponseHandlerInterface {
  @override
  DoxResponse handle(DoxResponse res) {
    return res;
  }
}
