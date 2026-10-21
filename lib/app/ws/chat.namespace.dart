import 'package:dox_socketio/dox_socketio.dart';

/// Socket.IO namespace /chat on the app port.
/// Client: `io('http://127.0.0.1:3100/chat')`.
class ChatNamespace extends NamespaceHandler {
  @override
  String get path => '/chat';

  /// A client may send `auth: {name: '...'}`. Empty names are refused.
  @override
  List<Middleware> get middleware => <Middleware>[checkName];

  void checkName(Socket socket) {
    Object? name = socket.handshake.auth['name'];
    if (name != null && name.toString().trim().isEmpty) {
      throw SocketIoException('name is empty');
    }
  }

  @override
  void onConnection(Socket socket) {
    socket.emit('welcome', <String, dynamic>{'id': socket.id});
    socket.on('ping', onPing);
    socket.on('join', onJoin);
    socket.on('message', onMessage);
  }

  /// Ack only: the client callback gets 'pong'.
  void onPing(SocketEvent event) {
    event.ack('pong');
  }

  /// `join('lobby')`: join a room, ack with the room name.
  void onJoin(SocketEvent event) {
    String room = event.data.toString();
    event.socket.join(room);
    event.ack(<String, String>{'joined': room});
  }

  /// `message({room, text})`: send to the others in the room, ack 'sent'.
  void onMessage(SocketEvent event) {
    Map<dynamic, dynamic> data = event.data as Map<dynamic, dynamic>;
    event.socket.to(data['room'].toString()).emit('message', <String, dynamic>{
      'from': event.socket.id,
      'text': data['text'],
    });
    event.ack('sent');
  }
}
