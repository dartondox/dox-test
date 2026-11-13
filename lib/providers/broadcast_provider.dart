import 'package:dox_core/dox_core.dart';
import 'package:dox_socketio/dox_socketio.dart';
import 'package:dox_test/app/models/user/user.model.dart';

/// The channel rules of Socket.IO broadcasting
/// (`SocketIoConfig(broadcasting: true)`). It runs in `boot()`, after the
/// `setup()` of every provider.
class BroadcastProvider extends DoxProvider {
  @override
  void setup() {}

  @override
  void boot() {
    /// `private-users.{id}`: only the user with this id.
    Broadcast.channel('users.{id}', allowUser);
  }

  bool allowUser(Object? user, String id) {
    return user is User && '${user.id}' == id;
  }
}
