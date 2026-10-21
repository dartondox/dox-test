import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/ws/chat.socket_controller.dart';

/// Websocket route: ws://host/ws
class WebsocketRouter extends Router {
  @override
  void register() {
    Route.websocket('ws', Dox().ioc.get<ChatSocketController>().register);
  }
}
