import 'package:dox_core/dox_core.dart';
import 'package:dox_websocket/dox_websocket.dart';

/// Turns on websocket support. No Redis adapter, so it needs one isolate.
class WebsocketServiceProvider implements DoxService {
  /// rooms anyone may join. the e2e test and public/playground.html use
  /// `lobby`.
  static const Set<String> publicRooms = <String>{'lobby'};

  @override
  void setup() {
    WebsocketServer(Dox()).authorizeJoin = canJoin;
  }

  /// a client may only join a public room. without this, every join is
  /// refused.
  bool canJoin(IDoxRequest req, String room) {
    return publicRooms.contains(room);
  }
}
