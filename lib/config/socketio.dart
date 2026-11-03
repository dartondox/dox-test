import 'package:dox_socketio/dox_socketio.dart';
import 'package:dox_test/app/ws/chat.namespace.dart';
import 'package:dox_test/app/ws/secure.namespace.dart';
import 'package:dox_test/config/env.dart';

/// Socket.IO on the app port, at /socket.io/. Namespaces: /chat, /secure.
/// One isolate, so the in-memory adapter is enough.
// ponytail: no Redis adapter. Add `adapter:` when APP_TOTAL_ISOLATE > 1.
SocketIoConfig socketIoConfig = SocketIoConfig(
  enabled: env.socketioEnabled,

  /// Only pages of this host may open a socket. /secure logs in with the
  /// session cookie, so another site must not open one for the user.
  /// A client with no `Origin` header (not a browser) is still allowed.
  options: const ServerOptions(allowedOrigins: <String>[]),
  namespaces: <NamespaceHandler>[ChatNamespace(), SecureNamespace()],
);
