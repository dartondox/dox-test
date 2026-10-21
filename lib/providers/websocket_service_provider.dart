import 'package:dox_core/dox_core.dart';
import 'package:dox_websocket/dox_websocket.dart';

/// Turns on websocket support. No Redis adapter, so it needs one isolate.
class WebsocketServiceProvider implements DoxService {
  @override
  void setup() {
    WebsocketServer(Dox());
  }
}
