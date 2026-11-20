import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dox_grpc/dox_grpc.dart';
import 'package:http2/http2.dart';

/// What a [RawCall] got back.
class RawResult {
  RawResult(this.headers, this.body, this.reset);

  /// the headers and trailers, names in lower case
  final Map<String, String> headers;
  final Uint8List body;

  /// true when the server reset the stream
  final bool reset;

  int? get status => int.tryParse(headers['grpc-status'] ?? '');

  /// `grpc-message`, percent-decoded
  String? get message {
    String? raw = headers['grpc-message'];
    return raw == null ? null : Uri.decodeComponent(raw);
  }

  /// the message bytes of the body, frame heads removed
  List<Uint8List> get messages {
    List<Uint8List> out = <Uint8List>[];
    int i = 0;
    while (i + 5 <= body.length) {
      int length = ByteData.sublistView(body).getUint32(i + 1);
      out.add(Uint8List.sublistView(body, i + 5, i + 5 + length));
      i += 5 + length;
    }
    return out;
  }
}

/// A gRPC call written by hand on HTTP/2 (h2c). It can send what a normal
/// client never sends: no `te`, a bad flag, a half message, a reset.
class RawCall {
  RawCall._(this._socket, this._connection, this._stream) {
    _sub = _stream.incomingMessages.listen(
      _onMessage,
      onError: _onError,
      onDone: _finishDone,
    );
  }

  final Socket _socket;
  final ClientTransportConnection _connection;
  final ClientTransportStream _stream;
  late final StreamSubscription<StreamMessage> _sub;
  final Completer<void> _done = Completer<void>();
  final Map<String, String> _headers = <String, String>{};
  final BytesBuilder _body = BytesBuilder(copy: false);
  bool _reset = false;

  /// Opens the stream. [te] null sends no `te` header. [headers] are added.
  static Future<RawCall> open(
    int port,
    String path, {
    String? te = 'trailers',
    Map<String, String> headers = const <String, String>{},
  }) async {
    Socket socket = await Socket.connect('127.0.0.1', port);
    ClientTransportConnection connection = ClientTransportConnection.viaSocket(
      socket,
    );
    List<Header> list = <Header>[
      Header.ascii(':method', 'POST'),
      Header.ascii(':scheme', 'http'),
      Header.ascii(':path', path),
      Header.ascii(':authority', '127.0.0.1:$port'),
      Header.ascii('content-type', 'application/grpc'),
      if (te != null) Header.ascii('te', te),
      for (MapEntry<String, String> e in headers.entries)
        Header.ascii(e.key, e.value),
    ];
    return RawCall._(socket, connection, connection.makeRequest(list));
  }

  void _onMessage(StreamMessage message) {
    if (message is HeadersStreamMessage) {
      for (Header h in message.headers) {
        _headers[String.fromCharCodes(h.name)] = String.fromCharCodes(h.value);
      }
    } else if (message is DataStreamMessage) {
      _body.add(message.bytes);
    }
  }

  void _onError(Object error) {
    _reset = true;
    _finishDone();
  }

  void _finishDone() {
    if (!_done.isCompleted) _done.complete();
  }

  /// sends [bytes], and ends the request when [end] is true
  void send(List<int> bytes, {bool end = false}) {
    _stream.sendData(bytes, endStream: end);
  }

  /// ends the request with no more data
  void end() => _stream.outgoingMessages.close();

  /// stops reading: the flow control window then fills up
  void pauseReading() => _sub.pause();

  /// reads again after [pauseReading]
  void resumeReading() => _sub.resume();

  /// resets the stream, like a client that gives up
  void reset() => _stream.terminate();

  /// the bytes of the body so far
  int get received => _body.length;

  /// Waits until the answer ended, then gives it.
  Future<RawResult> finish({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    await _done.future.timeout(timeout);
    return RawResult(Map<String, String>.of(_headers), _body.toBytes(), _reset);
  }

  Future<void> close() async {
    await _connection.finish();
    _socket.destroy();
  }
}

/// the 5 byte head + [message]. [flag] is the compressed flag byte.
Uint8List rawFrame(List<int> message, {int flag = 0}) {
  Uint8List out = GrpcWire.frame(message);
  out[0] = flag;
  return out;
}
