import 'package:dox_core/dox_core.dart';
import 'package:dox_socketio/dox_socketio.dart';
import 'package:dox_test/app/ws/chat.namespace.dart';
import 'package:dox_test/config/env.dart';

/// Socket.IO on the app port, at /socket.io/. Namespace: /chat.
/// One isolate, so the in-memory adapter is enough.
// ponytail: no Redis adapter. Add `adapter:` when APP_TOTAL_ISOLATE > 1.
SocketIoConfig socketIo = SocketIoConfig(
  enabled: env.socketioEnabled,
  namespaces: <NamespaceHandler>[ChatNamespace()],
);
