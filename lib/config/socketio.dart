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
  ///
  /// SOCKETIO_OPEN_ORIGIN=true turns the check off (null). Only the
  /// `Dox().isWebServer` check of test/e2e_32_packages.dart uses it.
  options: ServerOptions(
    allowedOrigins: env.socketioOpenOrigin ? null : const <String>[],
  ),
  namespaces: <NamespaceHandler>[ChatNamespace(), SecureNamespace()],

  /// Broadcast.channel rules, `subscribe` on `/` and `broadcast(event)`.
  /// The rules: lib/providers/broadcast_provider.dart.
  broadcasting: true,
);
