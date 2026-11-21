import 'dart:async';

import 'package:dox_grpc/dox_grpc.dart';
import 'package:dox_test/generated/echo.pbgrpc.dart';

/// What the gRPC services saw, for test/e2e_33_http2_grpc.dart. The test
/// and the server run in one isolate, so the test reads it directly.
class GrpcSeen {
  /// runs of the unary method of [ProtectedEchoService]
  static int protectedRuns = 0;

  /// `call.isCanceled` when a server stream stopped early
  static Completer<bool> canceled = Completer<bool>();

  /// `call.isTimedOut` after the delay of a slow unary call
  static Completer<bool> timedOut = Completer<bool>();

  static void reset() {
    canceled = Completer<bool>();
    timedOut = Completer<bool>();
  }
}

/// The `dox.test.Echo` service. The request text picks a special case:
/// `fail` (GrpcException with details), `crash` (a plain exception),
/// `big` (an answer of `count` bytes). `delay_ms` waits first.
class EchoService extends EchoServiceBase {
  @override
  Future<EchoReply> unary(ServiceCall call, EchoRequest request) async {
    String? input = call.clientMetadata!['x-in'];
    if (input != null) {
      call.headers!['x-echo'] = input;
      call.trailers!['x-trailer'] = 'end-$input';
    }
    if (request.delayMs > 0) {
      await Future<void>.delayed(Duration(milliseconds: request.delayMs));
      if (!GrpcSeen.timedOut.isCompleted) {
        GrpcSeen.timedOut.complete(call.isTimedOut);
      }
    }
    switch (request.text) {
      case 'fail':
        throw GrpcException(
          GrpcStatus.notFound,
          'kein Buch für dich 100%',
          <EchoReply>[EchoReply(text: 'detail')],
        );
      case 'crash':
        throw Exception('e33 secret text');
    }
    return EchoReply(text: request.text, payload: request.payload);
  }

  @override
  Stream<EchoReply> serverStream(ServiceCall call, EchoRequest request) async* {
    for (int i = 0; i < request.count; i++) {
      if (call.isCanceled) {
        if (!GrpcSeen.canceled.isCompleted) GrpcSeen.canceled.complete(true);
        return;
      }
      yield EchoReply(text: '${request.text}$i');
      if (request.delayMs > 0) {
        await Future<void>.delayed(Duration(milliseconds: request.delayMs));
      }
    }
  }

  @override
  Future<EchoReply> clientStream(
    ServiceCall call,
    Stream<EchoRequest> request,
  ) async {
    List<String> texts = <String>[];
    await for (EchoRequest one in request) {
      texts.add(one.text);
    }
    return EchoReply(text: texts.join(','));
  }

  @override
  Stream<EchoReply> bidi(ServiceCall call, Stream<EchoRequest> request) async* {
    await for (EchoRequest one in request) {
      yield EchoReply(text: one.text.toUpperCase());
    }
  }
}

/// The same methods as `dox.test.ProtectedEcho`, behind AuthMiddleware.
class ProtectedEchoService extends EchoService {
  @override
  String get $name => 'dox.test.ProtectedEcho';

  @override
  Future<EchoReply> unary(ServiceCall call, EchoRequest request) {
    GrpcSeen.protectedRuns++;
    return super.unary(call, request);
  }
}

/// `dox.test.IdleEcho`: calls end after 400 ms with no message.
class IdleEchoService extends EchoService {
  @override
  String get $name => 'dox.test.IdleEcho';
}

/// `dox.test.NoIdleEcho`: no idle limit (`idleTimeout: null`).
class NoIdleEchoService extends EchoService {
  @override
  String get $name => 'dox.test.NoIdleEcho';
}
