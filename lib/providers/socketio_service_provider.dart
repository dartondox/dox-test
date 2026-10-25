import 'package:dox_socketio/dox_socketio.dart';
import 'package:dox_test/config/socketio.dart';

/// Starts Socket.IO on the app port in every isolate. Dox finds every
/// DoxService class, see lib/container.g.dart.
class AppSocketIoService extends SocketIoService {
  AppSocketIoService() : super(socketIoConfig);
}
