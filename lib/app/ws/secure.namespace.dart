import 'package:dox_auth/dox_auth.dart';
import 'package:dox_core/dox_core.dart';
import 'package:dox_socketio/dox_socketio.dart';
import 'package:dox_test/app/models/user/user.model.dart';

/// Socket.IO namespace /secure. Only logged in users may connect.
/// A JWT (`auth: {token}` or an `Authorization: Bearer` header) or the
/// session cookie of the web login works.
class SecureNamespace extends NamespaceHandler {
  @override
  String get path => '/secure';

  @override
  List<Middleware> get middleware => <Middleware>[SocketAuth(findUser).handle];

  /// The user of the JWT, else the user of the web login session.
  static Future<User?> findUser(Handshake handshake) async {
    String? token = handshake.token;
    if (token != null) {
      return await Auth(guard: 'api').userFromToken<User>(token);
    }
    Session session = await handshake.session();
    return await Auth(guard: 'web').userFromSession<User>(session);
  }

  @override
  void onConnection(Socket socket) {
    User user = socket.user as User;
    socket.emit('hello', <String, dynamic>{'id': user.id, 'name': user.name});
  }
}
