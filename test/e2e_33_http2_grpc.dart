import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dox_grpc/dox_grpc.dart';
// ignore: implementation_imports
import 'package:dox_grpc/src/generated/grpc/health/v1/health.pbgrpc.dart'
    show HealthClient;
import 'package:dox_test/app/grpc/echo.service.dart';
import 'package:dox_test/config/app.dart';
import 'package:dox_test/generated/echo.pbgrpc.dart';
import 'package:dox_test/routes/e32x.dart';
import 'package:dox_test/routes/grpc.dart';
import 'package:grpc/grpc.dart';
import 'package:http/http.dart' as http;
import 'package:http2/http2.dart';
import 'package:test/test.dart';

import 'e2e_310_core.dart' show PortApi, registerUser;
import 'e2e_test.dart' show Api;
import 'raw_client.dart';

/// HTTP/2 (h2c) on the app port, the HTTP/2 limits of the native server,
/// and gRPC with dox_grpc. e2e_test.dart calls it, so it shares the
/// server and the database of that file. The app runs with
/// `APP_HTTP2=true` (the default of lib/config/env.dart).
void http2GrpcTests(Api api) {
  int port = appConfig.serverPort;

  group('3.3 HTTP/2: requests on the app port', () {
    late H2 h2;
    setUpAll(() async => h2 = await H2.connect(port));
    tearDownAll(() => h2.close());

    test('h2c GET is HTTP/2, the same port still speaks HTTP/1.1', () async {
      H2Res res = await h2.send('GET', '/core/e33/proto');
      expect(res.status, 200, reason: res.text);
      expect(res.json['version'], '2.0');
      http.Response one = await api.get('/core/e33/proto');
      expect(api.json(one)['version'], '1.1');
    });

    test('50 streams on one connection all get their answer', () async {
      List<Future<H2Res>> calls = <Future<H2Res>>[
        for (int i = 0; i < 50; i++) h2.send('GET', '/core/e33/slow?ms=50'),
      ];
      List<H2Res> all = await Future.wait(calls);
      for (H2Res res in all) {
        expect(res.status, 200, reason: '${res.error}');
      }
    });

    test('a 500 KB JSON body comes back whole', () async {
      String data = 'y' * (500 * 1024);
      H2Res res = await h2.send(
        'POST',
        '/core/e33/echo',
        headers: json,
        body: utf8.encode(jsonEncode(<String, String>{'data': data})),
      );
      expect(res.status, 200);
      expect(res.json['data'], data);
    });

    test('1 MiB + 1 gets 413 on its stream, a sibling gets 200', () async {
      int size = 1024 * 1024 + 1;
      String body = '{"d":"${'z' * (size - 8)}"}';
      expect(body.length, size);
      Future<H2Res> sibling = h2.send('GET', '/core/e33/slow?ms=300');
      H2Res big = await h2.send(
        'POST',
        '/core/e33/echo',
        headers: json,
        body: utf8.encode(body),
      );
      expect(big.status, 413);
      expect((await sibling).status, 200);
      expect((await h2.send('GET', '/core/e33/proto')).status, 200);
    });

    test('a multipart form with a file', () async {
      http.MultipartRequest form = http.MultipartRequest(
        'POST',
        api.uri('/core/e33/form'),
      );
      form.fields['note'] = 'über h2';
      form.files.add(
        http.MultipartFile.fromBytes(
          'file',
          List<int>.filled(70000, 7),
          filename: 'a.bin',
        ),
      );
      List<int> bytes = await form.finalize().toBytes();
      H2Res res = await h2.send(
        'POST',
        '/core/e33/form',
        headers: <(String, String)>[
          ('content-type', form.headers['content-type']!),
        ],
        body: bytes,
      );
      expect(res.status, 200, reason: res.text);
      expect(res.json, <String, dynamic>{
        'note': 'über h2',
        'name': 'a.bin',
        'size': 70000,
      });
    });

    test('HEAD, 204 and 304 answers have no DATA', () async {
      H2Res head = await h2.send('HEAD', '/core/e33/proto');
      expect(head.status, 200);
      expect(head.dataFrames, 0);
      H2Res empty = await h2.send('GET', '/core/e33/empty');
      expect(empty.status, 204);
      expect(empty.dataFrames, 0);
      H2Res same = await h2.send('GET', '/core/e33/not-modified');
      expect(same.status, 304);
      expect(same.dataFrames, 0);
    });

    test('many cookie fields reach the app as one Cookie header', () async {
      H2Res res = await h2.send(
        'GET',
        '/core/e33/cookie',
        headers: <(String, String)>[('cookie', 'a=1'), ('cookie', 'b=2')],
      );
      expect(res.json['cookie'], 'a=1; b=2');
    });

    test('a session login works over HTTP/2', () async {
      await registerUser(api, 'H2 Session', 'h2.session@mail.com');
      H2Browser browser = H2Browser(h2);
      H2Res me = await browser.send('GET', '/web-auth/me');
      expect(me.status, 401);
      expect(browser.cookies.keys, contains('XSRF-TOKEN'));
      H2Res login = await browser.send(
        'POST',
        '/web-auth/login',
        body: <String, String>{
          'email': 'h2.session@mail.com',
          'password': 'secret123',
        },
      );
      expect(login.status, 200, reason: login.text);
      me = await browser.send('GET', '/web-auth/me');
      expect(me.status, 200, reason: me.text);
      expect(me.text, contains('h2.session@mail.com'));
    });

    test('_method=PUT in a form is the same as on HTTP/1.1', () async {
      List<(String, String)> form = <(String, String)>[
        ('content-type', 'application/x-www-form-urlencoded'),
      ];
      H2Res two = await h2.send(
        'POST',
        '/core/override',
        headers: form,
        body: utf8.encode('_method=PUT&a=1'),
      );
      http.Response one = await api.send(
        'POST',
        '/core/override',
        headers: <String, String>{
          'content-type': 'application/x-www-form-urlencoded',
        },
        body: '_method=PUT&a=1',
      );
      expect(one.statusCode, 200, reason: one.body);
      expect(two.status, one.statusCode);
      expect(two.text, one.body);
      expect(two.text, contains('PUT'));
    });

    test('a CORS preflight is the same as on HTTP/1.1', () async {
      List<(String, String)> headers = <(String, String)>[
        ('origin', 'x.com'),
        ('access-control-request-method', 'POST'),
      ];
      H2Res res = await h2.send('OPTIONS', '/api/posts', headers: headers);
      expect(res.status, 204);
      expect(res.header('access-control-allow-origin'), '*');
    });

    test('RateLimit counts the same as on HTTP/1.1', () async {
      String key = 'h2-${DateTime.now().microsecondsSinceEpoch}';
      List<int> two = <int>[];
      for (int i = 0; i < 3; i++) {
        H2Res res = await h2.send(
          'GET',
          '/core/e32x/limit',
          headers: <(String, String)>[('x-e32x-key', key)],
        );
        two.add(res.status);
      }
      List<int> one = <int>[];
      for (int i = 0; i < 3; i++) {
        http.Response res = await api.get(
          '/core/e32x/limit',
          headers: <String, String>{'X-E32x-Key': '$key-1'},
        );
        one.add(res.statusCode);
      }
      expect(one, <int>[200, 200, 429]);
      expect(two, one);
    });

    test('a reset SSE stream completes response.done', () async {
      E32xRoutes.sseDone = false;
      ClientTransportStream stream = h2.open('GET', '/e32x-sse');
      Completer<String> first = Completer<String>();
      stream.incomingMessages.listen((StreamMessage m) {
        if (m is DataStreamMessage && !first.isCompleted) {
          first.complete(utf8.decode(m.bytes));
        }
      }, onError: (Object _) {});
      expect(
        await first.future.timeout(Duration(seconds: 5)),
        contains('hello'),
      );
      stream.terminate();
      expect(await eventually(() => E32xRoutes.sseDone), true);
    });

    test('a 512 KiB answer to a client with a 1 KB window', () async {
      H2 small = await H2.connect(
        port,
        settings: const ClientSettings(streamWindowSize: 1024),
      );
      try {
        H2Res res = await small.send('GET', '/core/e33/big?kb=512');
        expect(res.status, 200);
        expect(res.body.length, 512 * 1024);
      } finally {
        await small.close();
      }
    });

    test('trailers go out on HTTP/2 and are dropped on HTTP/1.1', () async {
      H2Res two = await h2.send('GET', '/core/e33/trailers');
      expect(two.text, 'with trailers');
      expect(two.trailers['x-e33-trailer'], 'yes');
      http.Response one = await api.get('/core/e33/trailers');
      expect(one.statusCode, 200);
      expect(one.body, 'with trailers');
      expect(one.headers.containsKey('x-e33-trailer'), false);
    });

    test('a taken over response: normal, throw before, throw after', () async {
      H2Res normal = await h2.send('GET', '/core/e33/takeover');
      expect(normal.status, 200);
      expect(normal.header('x-e33'), 'mine');
      expect(normal.text, 'taken over');
      H2Res before = await h2.send('GET', '/core/e33/takeover?throw=before');
      expect(before.status, 500);
      http.Response one = await api.get('/core/e33/takeover?throw=before');
      expect(one.statusCode, 500);
    });

    // bug: dox_core never ends a taken over answer that throws after it
    // started: http_response_handler.dart returns early for it, and
    // http_error_handler.dart gives null. The client waits forever (on
    // HTTP/1.1 too).
    test('a taken over response that throws after its first write still '
        'ends', () async {
      H2Res after = await h2.send(
        'GET',
        '/core/e33/takeover?throw=after',
        timeout: Duration(seconds: 5),
      );
      expect(after.status, 200);
      expect(after.text, startsWith('taken over'));
      // nothing more was sent: no error body after the part
      expect(after.text, isNot(contains('error')));
      expect(after.error, isNot(isA<TimeoutException>()), reason: 'hangs');
      expect((await h2.send('GET', '/core/e33/proto')).status, 200);
    });

    test('renderErrorsWith renders the error of its route', () async {
      H2Res two = await h2.send(
        'POST',
        '/core/e33/rpc',
        headers: json,
        body: utf8.encode('{}'),
      );
      expect(two.status, 400);
      expect(two.json['rpc_error'], contains('e33 rpc failed'));
      http.Response one = await api.post('/core/e33/rpc', <String, dynamic>{});
      expect(one.statusCode, 400);
      expect(api.json(one)['rpc_error'], contains('e33 rpc failed'));
    });

    test('Route.fallback(when:) answers any method behind its check', () async {
      H2Res hit = await h2.send(
        'POST',
        '/core/e33/nothing',
        headers: <(String, String)>[('x-e33-fallback', '1')],
      );
      expect(hit.status, 200, reason: hit.text);
      expect(hit.json, <String, dynamic>{
        'fallback': '/core/e33/nothing',
        'method': 'POST',
      });
      H2Res miss = await h2.send('POST', '/core/e33/nothing');
      expect(miss.status, 404);
    });
  });

  group('3.3 HTTP/2: floods and limits (raw frames)', () {
    test('a rapid reset flood drains with GOAWAY NO_ERROR, an open '
        'sibling stream still gets its answer', () async {
      RawH2 raw = await RawH2.connect(port);
      try {
        raw.request(1, 'GET', '/core/e33/slow?ms=1500');
        int last = await raw.rapidResets(3, until: RawH2.noError);
        expect(raw.goAwayCode, RawH2.noError, reason: 'resets: $last');
        RawFrame? answer = await raw.waitFor(
          (RawFrame f) => f.type == RawH2.headersType && f.id == 1,
          timeout: Duration(seconds: 5),
        );
        expect(answer, isNotNull);
        expect(raw.status(1), 200);
      } finally {
        raw.close();
      }
    });

    test(
      'a flood that goes on after the drain gets ENHANCE_YOUR_CALM',
      () async {
        RawH2 raw = await RawH2.connect(port);
        try {
          // keeps the connection open after the GOAWAY NO_ERROR
          raw.request(1, 'GET', '/core/e33/slow?ms=5000');
          int last = await raw.rapidResets(3, until: RawH2.noError);
          expect(raw.goAwayCode, RawH2.noError);
          await raw.rapidResets(last, until: RawH2.calm);
          expect(raw.goAwayCodes, contains(RawH2.calm));
        } finally {
          raw.close();
        }
      },
    );

    test(
      'RST_STREAM for a closed stream does not cut the connection',
      () async {
        RawH2 raw = await RawH2.connect(port);
        try {
          raw.request(1, 'GET', '/core/e33/proto');
          expect(await raw.answered(1), true);
          for (int i = 0; i < 1500; i++) {
            raw.rst(1, RawH2.cancel);
          }
          raw.request(3, 'GET', '/core/e33/proto');
          expect(await raw.answered(3), true);
          expect(raw.status(3), 200);
          expect(raw.goAwayCodes, isEmpty);
        } finally {
          raw.close();
        }
      },
    );

    test('a CONTINUATION flood gets ENHANCE_YOUR_CALM', () async {
      RawH2 raw = await RawH2.connect(port);
      try {
        raw.frame(
          RawH2.headersType,
          RawH2.endStream,
          1,
          RawH2.block('GET', '/core/e33/proto', port),
        );
        for (int i = 0; i < 200; i++) {
          raw.frame(RawH2.continuationType, 0, 1, const <int>[]);
        }
        expect(await raw.goAway(), RawH2.calm);
      } finally {
        raw.close();
      }
    });

    test('200 PINGs and 200 SETTINGS get ENHANCE_YOUR_CALM', () async {
      RawH2 pings = await RawH2.connect(port);
      RawH2 settings = await RawH2.connect(port);
      try {
        for (int i = 0; i < 200; i++) {
          pings.frame(RawH2.pingType, 0, 0, Uint8List(8));
          settings.frame(RawH2.settingsType, 0, 0, const <int>[]);
        }
        expect(await pings.goAway(), RawH2.calm);
        expect(await settings.goAway(), RawH2.calm);
      } finally {
        pings.close();
        settings.close();
      }
    });

    test('101 empty DATA frames get ENHANCE_YOUR_CALM', () async {
      RawH2 raw = await RawH2.connect(port);
      try {
        raw.request(
          1,
          'POST',
          '/core/e33/hold?ms=10',
          endStream: false,
          extra: <(String, String)>[('content-type', 'application/json')],
        );
        for (int i = 0; i < 101; i++) {
          raw.frame(RawH2.dataType, 0, 1, const <int>[]);
        }
        expect(await raw.goAway(), RawH2.calm);
      } finally {
        raw.close();
      }
    });

    test('a 20 KB header gets 431, the connection stays up', () async {
      RawH2 raw = await RawH2.connect(port);
      try {
        List<int> block = RawH2.block(
          'GET',
          '/core/e33/proto',
          port,
          extra: <(String, String)>[('x-big', 'a' * 20000)],
        );
        // over one 16 KB frame: HEADERS, then CONTINUATION
        raw.frame(
          RawH2.headersType,
          RawH2.endStream,
          1,
          block.sublist(0, 16000),
        );
        raw.frame(
          RawH2.continuationType,
          RawH2.endHeaders,
          1,
          block.sublist(16000),
        );
        expect(await raw.answered(1), true);
        expect(raw.status(1), 431);
        raw.request(3, 'GET', '/core/e33/proto');
        expect(await raw.answered(3), true);
        expect(raw.status(3), 200);
        expect(raw.goAwayCodes, isEmpty);
      } finally {
        raw.close();
      }
    });

    test('a bad HPACK index gets COMPRESSION_ERROR', () async {
      RawH2 raw = await RawH2.connect(port);
      try {
        // index 70: past the static table, and the dynamic table is empty
        raw.frame(
          RawH2.headersType,
          RawH2.endStream | RawH2.endHeaders,
          1,
          <int>[0xbf, 0x07],
        );
        expect(await raw.goAway(), RawH2.compressionError);
      } finally {
        raw.close();
      }
    });

    test('a :path without a slash is a stream error only', () async {
      RawH2 raw = await RawH2.connect(port);
      try {
        raw.request(1, 'GET', 'core/e33/proto');
        RawFrame? rst = await raw.waitFor(
          (RawFrame f) => f.id == 1 && f.type == RawH2.rstType,
        );
        expect(rst, isNotNull, reason: 'status ${raw.status(1)}');
        expect(rst!.code, RawH2.protocolError);
        raw.request(3, 'GET', '/core/e33/proto');
        expect(await raw.answered(3), true);
        expect(raw.status(3), 200);
      } finally {
        raw.close();
      }
    });

    test('16+ unread 1 MiB gRPC bodies: a JSON POST still completes, '
        'the biggest holder is reset', () async {
      H2 h2 = await H2.connect(port);
      try {
        List<int> mib = Uint8List(1024 * 1024);
        List<Future<H2Res>> holders = <Future<H2Res>>[];
        for (int i = 0; i < 18; i++) {
          holders.add(
            h2.send(
              'POST',
              '/core/e33/hold?ms=3000',
              headers: <(String, String)>[('content-type', 'application/grpc')],
              body: mib,
              endStream: false,
              timeout: Duration(seconds: 15),
            ),
          );
        }
        await Future<void>.delayed(Duration(milliseconds: 500));
        H2Res post = await h2.send(
          'POST',
          '/core/e33/echo',
          headers: json,
          body: utf8.encode('{"after":"holders"}'),
        );
        expect(post.status, 200, reason: '${post.error}');
        expect(post.json['after'], 'holders');
        List<H2Res> all = await Future.wait(holders);
        int resets = all.where((H2Res r) => r.error != null).length;
        expect(resets, greaterThanOrEqualTo(1));
        expect(resets, lessThan(all.length));
      } finally {
        await h2.close();
      }
    });

    group('a server with small limits (production)', () {
      ChildServer child = ChildServer(<String, String>{
        'H2_MAX_STREAMS': '4',
        'H2_BODY_TIMEOUT_MS': '1000',
        'H2_IDLE_TIMEOUT_MS': '2000',
        'APP_ENV': 'production',
      });
      setUpAll(child.start);
      tearDownAll(child.stop);

      test(
        'maxConcurrentStreams 4: the 5th stream is REFUSED_STREAM',
        () async {
          RawH2 raw = await RawH2.connect(child.port);
          try {
            for (int id = 1; id <= 9; id += 2) {
              raw.request(id, 'GET', '/core/e33/slow?ms=800');
            }
            RawFrame? rst = await raw.waitFor(
              (RawFrame f) => f.id == 9 && f.type == RawH2.rstType,
            );
            expect(rst, isNotNull);
            expect(rst!.code, RawH2.refusedStream);
            for (int id = 1; id <= 7; id += 2) {
              expect(await raw.answered(id), true, reason: 'stream $id');
              expect(raw.status(id), 200);
            }
          } finally {
            raw.close();
          }
        },
      );

      test(
        'a POST with no DATA gets 408 on its stream, a sibling 200',
        () async {
          RawH2 raw = await RawH2.connect(child.port);
          try {
            raw.request(
              1,
              'POST',
              '/core/e33/echo',
              endStream: false,
              extra: <(String, String)>[('content-type', 'application/json')],
            );
            raw.request(3, 'GET', '/core/e33/proto');
            expect(await raw.answered(3), true);
            expect(raw.status(3), 200);
            expect(await raw.answered(1, Duration(seconds: 5)), true);
            expect(raw.status(1), 408);
          } finally {
            raw.close();
          }
        },
      );

      test('an idle connection gets GOAWAY NO_ERROR', () async {
        RawH2 raw = await RawH2.connect(child.port);
        try {
          expect(await raw.goAway(Duration(seconds: 6)), RawH2.noError);
        } finally {
          raw.close();
        }
      });

      test(
        'a plain exception is INTERNAL with no text in production',
        () async {
          ClientChannel channel = grpcChannel(child.port);
          try {
            await EchoClient(channel).unary(EchoRequest(text: 'crash'));
            fail('no error');
          } on GrpcError catch (e) {
            expect(e.code, StatusCode.internal);
            expect(e.message, isNot(contains('e33 secret text')));
          } finally {
            await channel.shutdown();
          }
        },
      );
    });

    group('a server with http2: false', () {
      ChildServer child = ChildServer(<String, String>{'APP_HTTP2': 'false'});
      setUpAll(child.start);
      tearDownAll(child.stop);

      test('the HTTP/2 preface is not HTTP/2, HTTP/1.1 still works', () async {
        Socket socket = await Socket.connect('127.0.0.1', child.port);
        socket.add(RawH2.preface);
        socket.add(RawH2.encodeFrame(RawH2.settingsType, 0, 0, const <int>[]));
        List<int> answer = <int>[];
        try {
          await socket
              .listen(answer.addAll)
              .asFuture<void>()
              .timeout(Duration(seconds: 5));
        } on TimeoutException {
          // the server waits for more: also fine, as long as it is not h2
        } finally {
          socket.destroy();
        }
        // an HTTP/2 server answers with a SETTINGS frame (type 4 at byte 3)
        bool h2 = answer.length >= 9 && answer[3] == RawH2.settingsType;
        expect(h2, false, reason: latin1.decode(answer, allowInvalid: true));
        http.Response res = await child.api.get('/core/e33/proto');
        expect(res.statusCode, 200);
        expect(child.api.json(res)['version'], '1.1');
      });
    });
  }, timeout: Timeout(Duration(minutes: 4)));

  group('3.3 gRPC (dox_grpc) on the app port', () {
    late ClientChannel channel;
    late EchoClient echo;
    late PathClient paths;
    setUpAll(() {
      channel = grpcChannel(port);
      echo = EchoClient(channel);
      paths = PathClient(channel);
    });
    tearDownAll(() => channel.shutdown());

    Matcher code(int c) {
      return isA<GrpcError>().having((GrpcError e) => e.code, 'code', c);
    }

    test('unary, server stream, client stream and bidi', () async {
      expect((await echo.unary(EchoRequest(text: 'hi'))).text, 'hi');
      List<EchoReply> stream = await echo
          .serverStream(EchoRequest(text: 's', count: 5))
          .toList();
      expect(stream.map((EchoReply r) => r.text), <String>[
        's0',
        's1',
        's2',
        's3',
        's4',
      ]);
      EchoReply joined = await echo.clientStream(
        Stream<EchoRequest>.fromIterable(<EchoRequest>[
          EchoRequest(text: 'a'),
          EchoRequest(text: 'b'),
          EchoRequest(text: 'c'),
        ]),
      );
      expect(joined.text, 'a,b,c');
      List<EchoReply> bidi = await echo
          .bidi(
            Stream<EchoRequest>.fromIterable(<EchoRequest>[
              EchoRequest(text: 'x'),
              EchoRequest(text: 'y'),
            ]),
          )
          .toList();
      expect(bidi.map((EchoReply r) => r.text), <String>['X', 'Y']);
    });

    test('100 unary calls at once', () async {
      List<Future<EchoReply>> calls = <Future<EchoReply>>[
        for (int i = 0; i < 100; i++) echo.unary(EchoRequest(text: 'n$i')),
      ];
      List<EchoReply> all = await Future.wait(calls);
      for (int i = 0; i < 100; i++) {
        expect(all[i].text, 'n$i');
      }
    });

    test('metadata in, headers and trailers out', () async {
      ResponseFuture<EchoReply> call = echo.unary(
        EchoRequest(text: 'm'),
        options: CallOptions(metadata: <String, String>{'x-in': 'v1'}),
      );
      expect((await call).text, 'm');
      expect((await call.headers)['x-echo'], 'v1');
      expect((await call.trailers)['x-trailer'], 'end-v1');
    });

    test('GrpcException: code, UTF-8 message and details', () async {
      try {
        await echo.unary(EchoRequest(text: 'fail'));
        fail('no error');
      } on GrpcError catch (e) {
        expect(e.code, StatusCode.notFound);
        expect(e.message, 'kein Buch für dich 100%');
        expect(e.details, hasLength(1));
      }
    });

    test(
      'a plain exception is INTERNAL, with its text in development',
      () async {
        try {
          await echo.unary(EchoRequest(text: 'crash'));
          fail('no error');
        } on GrpcError catch (e) {
          expect(e.code, StatusCode.internal);
          expect(e.message, contains('e33 secret text'));
        }
      },
    );

    test('an unknown method or service is UNIMPLEMENTED', () async {
      await expectLater(
        paths.unary('/dox.test.Echo/Nope', EchoRequest()),
        throwsA(code(StatusCode.unimplemented)),
      );
      await expectLater(
        paths.unary('/dox.test.Nope/Unary', EchoRequest()),
        throwsA(code(StatusCode.unimplemented)),
      );
    });

    test('a POST that is not gRPC to an unknown path is a JSON 404', () async {
      http.Response res = await api.post(
        '/dox.test.Nope/Unary',
        <String, dynamic>{},
      );
      expect(res.statusCode, 404);
      expect(res.headers['content-type'], contains('json'));
      expect(res.headers.containsKey('grpc-status'), false);
      H2 h2 = await H2.connect(port);
      try {
        H2Res two = await h2.send(
          'POST',
          '/dox.test.Nope/Unary',
          headers: json,
          body: utf8.encode('{}'),
        );
        expect(two.status, 404);
        expect(two.header('grpc-status'), isNull);
        expect(two.json, isA<Map<String, dynamic>>());
      } finally {
        await h2.close();
      }
    });

    test('application/json to a service path is 415', () async {
      H2 h2 = await H2.connect(port);
      try {
        H2Res res = await h2.send(
          'POST',
          '/dox.test.Echo/Unary',
          headers: json,
          body: utf8.encode('{}'),
        );
        expect(res.status, 415);
      } finally {
        await h2.close();
      }
    });

    test('application/grpc over HTTP/1.1 is 505', () async {
      http.Response res = await api.send(
        'POST',
        '/dox.test.Echo/Unary',
        headers: <String, String>{'content-type': 'application/grpc'},
        body: latin1.decode(
          GrpcWire.frame(EchoRequest(text: 'h1').writeToBuffer()),
        ),
      );
      expect(res.statusCode, 505);
    });

    test('the protected service needs a token, the handler does not run '
        'without one', () async {
      ProtectedEchoClient guarded = ProtectedEchoClient(channel);
      int runs = GrpcSeen.protectedRuns;
      await expectLater(
        guarded.unary(EchoRequest(text: 'x')),
        throwsA(code(StatusCode.unauthenticated)),
      );
      expect(GrpcSeen.protectedRuns, runs);
      await registerUser(api, 'Grpc User', 'grpc.user@mail.com');
      http.Response login = await api.post('/api/auth/login', <String, dynamic>{
        'email': 'grpc.user@mail.com',
        'password': 'secret123',
      });
      String token = api.json(login)['token'];
      EchoReply ok = await guarded.unary(
        EchoRequest(text: 'x'),
        options: CallOptions(
          metadata: <String, String>{'authorization': 'Bearer $token'},
        ),
      );
      expect(ok.text, 'x');
      expect(GrpcSeen.protectedRuns, runs + 1);
    });

    test('grpc-timeout 200m on a slow call is DEADLINE_EXCEEDED', () async {
      GrpcSeen.reset();
      RawCall call = await RawCall.open(
        port,
        '/dox.test.Echo/Unary',
        headers: <String, String>{'grpc-timeout': '200m'},
      );
      call.send(
        rawFrame(EchoRequest(text: 'slow', delayMs: 800).writeToBuffer()),
        end: true,
      );
      RawResult res = await call.finish();
      await call.close();
      expect(res.status, StatusCode.deadlineExceeded);
      expect(
        await GrpcSeen.timedOut.future.timeout(Duration(seconds: 5)),
        true,
      );
    });

    test('a client cancel: the handler sees isCanceled', () async {
      GrpcSeen.reset();
      ResponseStream<EchoReply> call = echo.serverStream(
        EchoRequest(text: 'c', count: 1000, delayMs: 20),
      );
      StreamIterator<EchoReply> it = StreamIterator<EchoReply>(call);
      expect(await it.moveNext(), true);
      await call.cancel();
      expect(
        await GrpcSeen.canceled.future.timeout(Duration(seconds: 5)),
        true,
      );
    });

    test('a 5 MiB message is RESOURCE_EXHAUSTED', () async {
      await expectLater(
        echo.unary(EchoRequest(payload: Uint8List(5 * 1024 * 1024))),
        throwsA(code(StatusCode.resourceExhausted)),
      );
      expect((await echo.unary(EchoRequest(text: 'up'))).text, 'up');
    });

    test(
      'a gzip request works, a gzip bomb is RESOURCE_EXHAUSTED fast',
      () async {
        EchoReply zipped = await echo.unary(
          EchoRequest(text: 'z', payload: Uint8List(10000)),
          options: CallOptions(compression: const GzipCodec()),
        );
        expect(zipped.text, 'z');
        expect(zipped.payload.length, 10000);
        List<int> bomb = gzip.encode(Uint8List(8 * 1024 * 1024));
        Stopwatch watch = Stopwatch()..start();
        RawCall call = await RawCall.open(
          port,
          '/dox.test.Echo/Unary',
          headers: <String, String>{'grpc-encoding': 'gzip'},
        );
        call.send(rawFrame(bomb, flag: 1), end: true);
        RawResult res = await call.finish();
        await call.close();
        expect(res.status, StatusCode.resourceExhausted);
        expect(watch.elapsedMilliseconds, lessThan(2000));
      },
    );

    test('idleTimeout: 5 minutes by default, a short one ends a quiet call, '
        'null does not', () async {
      expect(const GrpcOptions().idleTimeout, Duration(minutes: 5));
      await expectLater(
        paths
            .serverStream(
              '/dox.test.IdleEcho/ServerStream',
              EchoRequest(text: 'i', count: 3, delayMs: 1000),
            )
            .toList(),
        throwsA(code(StatusCode.deadlineExceeded)),
      );
      List<EchoReply> quiet = await paths
          .serverStream(
            '/dox.test.NoIdleEcho/ServerStream',
            EchoRequest(text: 'q', count: 2, delayMs: 700),
          )
          .toList();
      expect(quiet, hasLength(2));
    });

    test('health: Check, NOT_FOUND and Watch', () async {
      HealthClient health = HealthClient(channel);
      expect(
        (await health.check(HealthCheckRequest())).status,
        ServingStatus.SERVING,
      );
      await expectLater(
        health.check(HealthCheckRequest(service: 'dox.test.Nope')),
        throwsA(code(StatusCode.notFound)),
      );
      ResponseStream<HealthCheckResponse> watch = health.watch(
        HealthCheckRequest(service: 'dox.test.Echo'),
      );
      StreamIterator<HealthCheckResponse> it =
          StreamIterator<HealthCheckResponse>(watch);
      expect(await it.moveNext(), true);
      expect(it.current.status, ServingStatus.SERVICE_UNKNOWN);
      GrpcRouter.health.setStatus('dox.test.Echo', ServingStatus.SERVING);
      expect(await it.moveNext(), true);
      expect(it.current.status, ServingStatus.SERVING);
      await watch.cancel();
      expect(
        (await health.check(HealthCheckRequest(service: 'dox.test.Echo')))
            .status,
        ServingStatus.SERVING,
      );
    });
  });
}

const List<(String, String)> json = <(String, String)>[
  ('content-type', 'application/json'),
  ('accept', 'application/json'),
];

/// True once [check] is true, within 5 seconds.
Future<bool> eventually(bool Function() check) async {
  for (int i = 0; i < 100; i++) {
    if (check()) return true;
    await Future<void>.delayed(Duration(milliseconds: 50));
  }
  return check();
}

ClientChannel grpcChannel(int port) {
  return ClientChannel(
    '127.0.0.1',
    port: port,
    options: ChannelOptions(
      credentials: const ChannelCredentials.insecure(),
      codecRegistry: CodecRegistry(
        codecs: const <Codec>[GzipCodec(), IdentityCodec()],
      ),
    ),
  );
}

/// A client for any method path, eg. one the server does not have.
class PathClient extends Client {
  PathClient(super.channel);

  static ClientMethod<EchoRequest, EchoReply> method(String path) {
    return ClientMethod<EchoRequest, EchoReply>(
      path,
      (EchoRequest r) => r.writeToBuffer(),
      EchoReply.fromBuffer,
    );
  }

  ResponseFuture<EchoReply> unary(String path, EchoRequest request) {
    return $createUnaryCall(method(path), request);
  }

  ResponseStream<EchoReply> serverStream(String path, EchoRequest request) {
    return $createStreamingCall(
      method(path),
      Stream<EchoRequest>.value(request),
    );
  }
}

/// The client of `dox.test.ProtectedEcho` (the Echo methods).
class ProtectedEchoClient extends Client {
  ProtectedEchoClient(super.channel);

  ResponseFuture<EchoReply> unary(EchoRequest request, {CallOptions? options}) {
    return $createUnaryCall(
      PathClient.method('/dox.test.ProtectedEcho/Unary'),
      request,
      options: options,
    );
  }
}

/// `bin/e2e_h2.dart` on a free port, with [env] set.
class ChildServer {
  ChildServer(this.env);

  final Map<String, String> env;
  Process? process;
  final StringBuffer log = StringBuffer();
  late int port;
  late Api api;

  Future<void> start() async {
    ServerSocket free = await ServerSocket.bind('127.0.0.1', 0);
    port = free.port;
    await free.close();
    api = PortApi(port);
    Process p = await Process.start(
      'dart',
      <String>['run', 'bin/e2e_h2.dart'],
      environment: <String, String>{
        ...env,
        'APP_PORT': '$port',
        'APP_URL': 'http://127.0.0.1:$port',
      },
    );
    process = p;
    p.stdout.transform(utf8.decoder).listen(log.write);
    p.stderr.transform(utf8.decoder).listen(log.write);
    bool up = false;
    for (int i = 0; i < 1500 && !up; i++) {
      try {
        up = (await api.get('/ping')).statusCode == 200;
      } on Exception {
        await Future<void>.delayed(Duration(milliseconds: 100));
      }
    }
    expect(up, true, reason: log.toString());
  }

  Future<void> stop() async {
    Process? p = process;
    if (p == null) return;
    p.kill();
    await p.exitCode.timeout(
      Duration(seconds: 10),
      onTimeout: () {
        p.kill(ProcessSignal.sigkill);
        return -1;
      },
    );
  }
}

/// An h2c connection of package:http2.
class H2 {
  H2._(this.port, this.socket, this.connection);

  final int port;
  final Socket socket;
  final ClientTransportConnection connection;

  static Future<H2> connect(int port, {ClientSettings? settings}) async {
    Socket socket = await Socket.connect('127.0.0.1', port);
    return H2._(
      port,
      socket,
      ClientTransportConnection.viaSocket(
        socket,
        settings: settings ?? const ClientSettings(),
      ),
    );
  }

  ClientTransportStream open(
    String method,
    String path, {
    List<(String, String)> headers = const <(String, String)>[],
    bool endStream = true,
  }) {
    return connection.makeRequest(<Header>[
      Header.ascii(':method', method),
      Header.ascii(':scheme', 'http'),
      Header.ascii(':path', path),
      Header.ascii(':authority', '127.0.0.1:$port'),
      for ((String, String) h in headers)
        Header(ascii.encode(h.$1), utf8.encode(h.$2)),
    ], endStream: endStream);
  }

  /// Sends a request, reads the whole answer. [endStream] false sends
  /// [body] but does not end the request.
  Future<H2Res> send(
    String method,
    String path, {
    List<(String, String)> headers = const <(String, String)>[],
    List<int>? body,
    bool endStream = true,
    Duration timeout = const Duration(seconds: 10),
  }) {
    ClientTransportStream stream = open(
      method,
      path,
      headers: headers,
      endStream: body == null && endStream,
    );
    if (body != null) stream.sendData(body, endStream: endStream);
    return H2Res.read(stream, timeout);
  }

  Future<void> close() async {
    try {
      await connection.finish().timeout(Duration(seconds: 2));
    } on Object {
      // the server may have closed it already
    }
    socket.destroy();
  }
}

/// One HTTP/2 answer.
class H2Res {
  int status = 0;
  final Map<String, List<String>> headers = <String, List<String>>{};
  final Map<String, String> trailers = <String, String>{};
  final BytesBuilder _body = BytesBuilder();
  int dataFrames = 0;

  /// set when the stream was reset or the connection failed
  Object? error;

  Uint8List get body => _body.toBytes();
  String get text => utf8.decode(body, allowMalformed: true);
  dynamic get json => jsonDecode(text);

  String? header(String name) => headers[name]?.first;

  static Future<H2Res> read(
    ClientTransportStream stream,
    Duration timeout,
  ) async {
    H2Res res = H2Res();
    bool head = false;
    try {
      await for (StreamMessage m in stream.incomingMessages.timeout(timeout)) {
        if (m is HeadersStreamMessage) {
          for (Header h in m.headers) {
            String name = ascii.decode(h.name);
            String value = utf8.decode(h.value, allowMalformed: true);
            if (head) {
              res.trailers[name] = value;
            } else if (name == ':status') {
              res.status = int.parse(value);
            } else {
              res.headers.putIfAbsent(name, () => <String>[]).add(value);
            }
          }
          head = true;
        } else if (m is DataStreamMessage) {
          res.dataFrames++;
          res._body.add(m.bytes);
        }
      }
    } on Object catch (e) {
      res.error = e;
    }
    return res;
  }
}

/// Keeps cookies over HTTP/2 like test/e2e_test.dart `Browser`: JSON
/// requests with the XSRF-TOKEN cookie sent back as X-XSRF-TOKEN.
class H2Browser {
  H2Browser(this.h2);

  final H2 h2;
  final Map<String, String> cookies = <String, String>{};

  Future<H2Res> send(String method, String path, {Object? body}) async {
    List<(String, String)> headers = <(String, String)>[...json];
    for (MapEntry<String, String> c in cookies.entries) {
      headers.add(('cookie', '${c.key}=${c.value}'));
    }
    String? token = cookies['XSRF-TOKEN'];
    if (token != null) {
      headers.add(('x-xsrf-token', Uri.decodeComponent(token)));
    }
    H2Res res = await h2.send(
      method,
      path,
      headers: headers,
      body: body == null ? null : utf8.encode(jsonEncode(body)),
    );
    for (String one in res.headers['set-cookie'] ?? <String>[]) {
      Cookie c = Cookie.fromSetCookieValue(one);
      if (c.value.isEmpty || c.maxAge == 0) {
        cookies.remove(c.name);
      } else {
        cookies[c.name] = c.value;
      }
    }
    return res;
  }
}

/// One frame the server sent.
class RawFrame {
  RawFrame(this.type, this.flags, this.id, this.payload);

  final int type;
  final int flags;
  final int id;
  final Uint8List payload;

  /// the error code of RST_STREAM and GOAWAY
  int? get code {
    ByteData data = ByteData.sublistView(payload);
    if (type == RawH2.rstType && payload.length >= 4) return data.getUint32(0);
    if (type == RawH2.goAwayType && payload.length >= 8) {
      return data.getUint32(4);
    }
    return null;
  }
}

/// HTTP/2 written frame by frame, for what no real client sends: floods,
/// bad HPACK, a cut header block. HPACK out is plain literals; HPACK in
/// reads only `:status` (the native server sends no Huffman and no
/// dynamic table entries).
class RawH2 {
  RawH2._(this.socket) {
    socket.listen(_onData, onDone: _onDone, onError: (Object _) => _onDone());
  }

  static final List<int> preface = ascii.encode(
    'PRI * HTTP/2.0\r\n\r\nSM\r\n\r\n',
  );

  static const int dataType = 0;
  static const int headersType = 1;
  static const int rstType = 3;
  static const int settingsType = 4;
  static const int pingType = 6;
  static const int goAwayType = 7;
  static const int windowUpdateType = 8;
  static const int continuationType = 9;

  static const int endStream = 0x1;
  static const int endHeaders = 0x4;

  static const int noError = 0x0;
  static const int protocolError = 0x1;
  static const int refusedStream = 0x7;
  static const int cancel = 0x8;
  static const int compressionError = 0x9;
  static const int calm = 0xb;

  final Socket socket;
  final List<RawFrame> frames = <RawFrame>[];
  final BytesBuilder _in = BytesBuilder();
  bool closed = false;

  static Future<RawH2> connect(int port) async {
    RawH2 raw = RawH2._(await Socket.connect('127.0.0.1', port));
    raw.socket.add(preface);
    raw.frame(settingsType, 0, 0, const <int>[]);
    return raw;
  }

  void _onData(Uint8List data) {
    _in.add(data);
    Uint8List all = _in.takeBytes();
    int i = 0;
    while (all.length - i >= 9) {
      int length = (all[i] << 16) | (all[i + 1] << 8) | all[i + 2];
      if (all.length - i < 9 + length) break;
      int type = all[i + 3];
      int flags = all[i + 4];
      int id =
          ByteData.sublistView(all, i + 5, i + 9).getUint32(0) & 0x7fffffff;
      Uint8List payload = Uint8List.fromList(
        all.sublist(i + 9, i + 9 + length),
      );
      frames.add(RawFrame(type, flags, id, payload));
      _answer(type, flags, id, length);
      i += 9 + length;
    }
    _in.add(all.sublist(i));
  }

  /// ACKs SETTINGS and PING, gives the window back for DATA
  void _answer(int type, int flags, int id, int length) {
    if (closed) return;
    if (type == settingsType && flags & 1 == 0) {
      frame(settingsType, 1, 0, const <int>[]);
    } else if (type == dataType && length > 0) {
      Uint8List inc = Uint8List(4);
      ByteData.sublistView(inc).setUint32(0, length);
      frame(windowUpdateType, 0, 0, inc);
      frame(windowUpdateType, 0, id, inc);
    }
  }

  void _onDone() => closed = true;

  static Uint8List encodeFrame(int type, int flags, int id, List<int> payload) {
    Uint8List out = Uint8List(9 + payload.length);
    out[0] = (payload.length >> 16) & 0xff;
    out[1] = (payload.length >> 8) & 0xff;
    out[2] = payload.length & 0xff;
    out[3] = type;
    out[4] = flags;
    ByteData.sublistView(out).setUint32(5, id);
    out.setRange(9, out.length, payload);
    return out;
  }

  void frame(int type, int flags, int id, List<int> payload) {
    if (closed) return;
    try {
      socket.add(encodeFrame(type, flags, id, payload));
    } on Object {
      closed = true;
    }
  }

  void rst(int id, int code) {
    Uint8List payload = Uint8List(4);
    ByteData.sublistView(payload).setUint32(0, code);
    frame(rstType, 0, id, payload);
  }

  void request(
    int id,
    String method,
    String path, {
    bool endStream = true,
    List<(String, String)> extra = const <(String, String)>[],
  }) {
    frame(
      headersType,
      endHeaders | (endStream ? RawH2.endStream : 0),
      id,
      block(method, path, socket.remotePort, extra: extra),
    );
  }

  /// An HPACK block of literals without indexing.
  static List<int> block(
    String method,
    String path,
    int port, {
    List<(String, String)> extra = const <(String, String)>[],
  }) {
    BytesBuilder out = BytesBuilder();
    // name index from the static table: :authority 1, :method 2,
    // :path 4, :scheme 6
    _literal(out, 2, null, method);
    _literal(out, 6, null, 'http');
    _literal(out, 4, null, path);
    _literal(out, 1, null, '127.0.0.1:$port');
    for ((String, String) h in extra) {
      _literal(out, 0, h.$1, h.$2);
    }
    return out.toBytes();
  }

  static void _literal(
    BytesBuilder out,
    int index,
    String? name,
    String value,
  ) {
    _int(out, index, 4, 0x00);
    if (index == 0) _string(out, name!);
    _string(out, value);
  }

  static void _string(BytesBuilder out, String text) {
    List<int> bytes = utf8.encode(text);
    _int(out, bytes.length, 7, 0x00);
    out.add(bytes);
  }

  static void _int(BytesBuilder out, int value, int prefix, int flags) {
    int max = (1 << prefix) - 1;
    if (value < max) {
      out.addByte(flags | value);
      return;
    }
    out.addByte(flags | max);
    value -= max;
    while (value >= 128) {
      out.addByte((value & 0x7f) | 0x80);
      value >>= 7;
    }
    out.addByte(value);
  }

  /// HEADERS + RST_STREAM CANCEL pairs from stream [from] on, in bursts,
  /// until a GOAWAY with [until] comes or the socket closes. Gives the
  /// next free stream id.
  Future<int> rapidResets(int from, {required int until}) async {
    int id = from;
    List<int> head = block('GET', '/core/e33/proto', socket.remotePort);
    for (int burst = 0; burst < 60; burst++) {
      if (closed || goAwayCodes.contains(until)) break;
      for (int i = 0; i < 100; i++) {
        frame(headersType, endHeaders | endStream, id, head);
        rst(id, cancel);
        id += 2;
      }
      await Future<void>.delayed(Duration(milliseconds: 10));
    }
    await eventually(() => closed || goAwayCodes.contains(until));
    return id;
  }

  List<int> get goAwayCodes => <int>[
    for (RawFrame f in frames)
      if (f.type == goAwayType) f.code!,
  ];

  int? get goAwayCode => goAwayCodes.isEmpty ? null : goAwayCodes.first;

  /// The code of the first GOAWAY, null when none came in [timeout].
  Future<int?> goAway([Duration timeout = const Duration(seconds: 5)]) async {
    RawFrame? f = await waitFor(
      (RawFrame f) => f.type == goAwayType,
      timeout: timeout,
    );
    return f?.code;
  }

  Future<RawFrame?> waitFor(
    bool Function(RawFrame f) test, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    Stopwatch watch = Stopwatch()..start();
    while (watch.elapsed < timeout) {
      for (RawFrame f in frames) {
        if (test(f)) return f;
      }
      if (closed) break;
      await Future<void>.delayed(Duration(milliseconds: 10));
    }
    for (RawFrame f in frames) {
      if (test(f)) return f;
    }
    return null;
  }

  /// true when stream [id] got its HEADERS
  Future<bool> answered(
    int id, [
    Duration timeout = const Duration(seconds: 5),
  ]) async {
    RawFrame? f = await waitFor(
      (RawFrame f) => f.id == id && f.type == headersType,
      timeout: timeout,
    );
    return f != null;
  }

  /// `:status` of the first HEADERS of stream [id]
  int? status(int id) {
    for (RawFrame f in frames) {
      if (f.id == id && f.type == headersType) return _status(f.payload);
    }
    return null;
  }

  static const List<int> _staticStatus = <int>[
    200,
    204,
    206,
    304,
    400,
    404,
    500,
  ];

  static int? _status(Uint8List block) {
    int i = 0;
    while (i < block.length) {
      int b = block[i];
      if (b & 0x80 != 0) {
        int index = b & 0x7f;
        if (index >= 8 && index <= 14) return _staticStatus[index - 8];
        i++;
        continue;
      }
      // literal without indexing (4 bit prefix), plain strings
      int index = b & 0x0f;
      i++;
      String? name;
      if (index == 0) {
        int n = block[i++];
        name = ascii.decode(block.sublist(i, i + n));
        i += n;
      }
      int length = block[i++] & 0x7f;
      String value = ascii.decode(block.sublist(i, i + length));
      i += length;
      if (index == 8 || name == ':status') return int.parse(value);
    }
    return null;
  }

  void close() {
    closed = true;
    socket.destroy();
  }
}
