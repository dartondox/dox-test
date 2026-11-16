import 'dart:async';
import 'dart:io';

import 'package:dox_core/dox_core.dart';

/// Routes for test/e2e_32x_patch.dart (the 3.2.x patch checks).
/// CoreRouter adds them in the group `/e32x`, so they all start with
/// /core/e32x. Plain methods, so they need no container entry.
class E32xRoutes {
  /// the temp file of the last big upload, and whether it was there while
  /// the handler ran
  static String? lastTempPath;

  /// true once `response.done` of the last /e32x-sse request completed
  static bool sseDone = false;

  void register() {
    Route.post('/upload-temp', uploadTemp);
    Route.post('/upload-temp-fail', uploadTempFail);
    Route.get('/body', body);
    Route.get('/flush-then-throw', flushThenThrow);
    Route.get('/v1.0/{id}', version);
    Route.get('/headers', <dynamic>[
      const RequestId(),
      const SecurityHeaders(),
      headers,
    ]);
    Route.get('/limit', <dynamic>[
      RateLimit(max: 2, store: 'redis', key: limitKey),
      headers,
    ]);
    Route.get('/limit-sliding', <dynamic>[
      RateLimit(max: 2, store: 'redis', key: limitKey, sliding: true),
      headers,
    ]);
    Route.get('/block', block);
    Route.get('/hash-sync', hashSync);
    Route.websocket('/ws-ping', pingSocket);
    Route.middleware(<dynamic>[const SessionMiddleware()], registerSession);
  }

  void registerSession() {
    Route.get('/session-count', sessionCount);
  }

  /// POST /core/e32x/upload-temp: a file over 1 MB is on disk while the
  /// handler runs.
  Future<Map<String, dynamic>> uploadTemp(DoxRequest req) async {
    RequestFile file = req.file('file')!;
    String? path = file.file?.path;
    lastTempPath = path;
    return <String, dynamic>{
      'path': path,
      'exists': path != null && File(path).existsSync(),
      'bytes': (await file.bytes).length,
    };
  }

  /// POST /core/e32x/upload-temp-fail: the handler fails after the read.
  Future<void> uploadTempFail(DoxRequest req) async {
    RequestFile file = req.file('file')!;
    lastTempPath = file.file?.path;
    await file.bytes;
    throw StateError('e32x upload failed');
  }

  /// GET /core/e32x/body?add=1: the body map of a GET. With `add`, it
  /// writes a key to it, which must not reach the next request.
  Map<String, dynamic> body(DoxRequest req) {
    Map<String, dynamic> before = Map<String, dynamic>.of(req.body);
    if (req.input('add') != null) req.add('added', 'yes');
    return <String, dynamic>{'before': before, 'all': req.all()};
  }

  /// GET /core/e32x/flush-then-throw: the head is out, then it fails.
  Future<void> flushThenThrow(DoxRequest req) async {
    HttpResponse res = req.httpRequest.response;
    res.headers.contentType = ContentType('text', 'event-stream');
    res.write('data: one\n\n');
    await res.flush();
    throw StateError('e32x late error');
  }

  Map<String, dynamic> version(DoxRequest req) {
    return <String, dynamic>{'id': req.param['id']};
  }

  Map<String, dynamic> headers(DoxRequest req) {
    return <String, dynamic>{'ok': true};
  }

  /// the client picks its rate limit count with the X-E32x-Key header
  static String limitKey(DoxRequest req) {
    return 'e32x:${req.header('X-E32x-Key')}';
  }

  /// GET /core/e32x/block: blocks the isolate for 120 ms.
  Map<String, dynamic> block(DoxRequest req) {
    Stopwatch watch = Stopwatch()..start();
    while (watch.elapsedMilliseconds < 120) {}
    return <String, dynamic>{'blocked': watch.elapsedMilliseconds};
  }

  /// GET /core/e32x/hash-sync: the sync hash, which strict mode warns about
  Map<String, dynamic> hashSync(DoxRequest req) {
    return <String, dynamic>{'ok': Hash.make('e32x').isNotEmpty};
  }

  /// the server pings a client that sends nothing for 300 ms
  void pingSocket(WebSocket socket, DoxRequest req) {
    socket.pingInterval = Duration(milliseconds: 300);
    socket.listen(socket.add);
  }

  /// GET /core/e32x/session-count: a count kept in the session, and the
  /// isolate that answered
  Map<String, dynamic> sessionCount(DoxRequest req) {
    int count = (req.session.get('e32x_count') as int? ?? 0) + 1;
    req.session.put('e32x_count', count);
    return <String, dynamic>{'count': count, 'isolate': Dox().isolateId};
  }

  /// /e32x-sse: a raw handler that sends a part every 100 ms from its own
  /// timer, like server-sent events. `done` must complete when the
  /// client is gone, so the timer stops.
  static Future<void> sse(HttpRequest req) async {
    sseDone = false;
    HttpResponse res = req.response;
    res.headers.contentType = ContentType('text', 'event-stream');
    res.write('data: hello\n\n');
    await res.flush();
    Timer timer = Timer.periodic(Duration(milliseconds: 100), (Timer t) {
      res.write('data: tick\n\n');
    });
    await res.done;
    timer.cancel();
    sseDone = true;
  }
}
