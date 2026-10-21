import 'package:dox_core/dox_core.dart';
import 'package:dox_websocket/dox_websocket.dart';

/// Websocket events for ws://host/ws
class ChatSocketController {
  /// Called by the router to add all events.
  void register(WebsocketEvent event) {
    event.on('echo', echo);
    event.on('broadcast', broadcast);
    event.on('chat', chat);
  }

  /// Send the message back to the sender only.
  void echo(WebsocketEmitter emitter, dynamic message) {
    emitter.emitToSender('echo', message);
  }

  /// Send to everyone on this route except the sender.
  void broadcast(WebsocketEmitter emitter, dynamic message) {
    emitter.emitExceptSender('broadcast', message);
  }

  /// Send to everyone in a room. Message: {"room": "lobby", "text": "hi"}
  void chat(WebsocketEmitter emitter, dynamic message) {
    emitter.room(message['room']).emit('chat', message['text']);
  }
}
