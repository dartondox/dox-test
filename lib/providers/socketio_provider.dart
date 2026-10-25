import 'package:dox_socketio/dox_socketio.dart';
import 'package:dox_test/config/socketio.dart';

/// Starts Socket.IO on the app port in every isolate. Dox finds every
/// DoxProvider class, see lib/container.g.dart.
class AppSocketIoProvider extends SocketIoProvider {
  AppSocketIoProvider() : super(socketIoConfig);
}
