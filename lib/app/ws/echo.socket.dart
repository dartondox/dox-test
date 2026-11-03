import 'dart:io';

import 'package:dox_core/dox_core.dart';

/// WebSocket at /core/echo. Sends every message back.
/// The route has `maxMessageSize: 64`, so a bigger message closes it (1009).
class EchoSocket {
  void handle(WebSocket socket, DoxRequest req) {
    socket.listen(socket.add);
  }
}
