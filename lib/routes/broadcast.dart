import 'package:dox_auth/dox_auth.dart';
import 'package:dox_core/dox_core.dart';
import 'package:dox_socketio/dox_socketio.dart';

/// `POST /broadcasting/auth`: gives a token to subscribe to a private
/// channel. The rules are in lib/providers/broadcast_provider.dart.
/// No session and no CSRF: the client sends a JWT.
class BroadcastRouter extends Router {
  @override
  void register() {
    Broadcast.routes(middleware: <dynamic>[AuthMiddleware()]);
  }
}
