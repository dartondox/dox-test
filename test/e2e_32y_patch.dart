import 'dart:async';
import 'dart:io';

import 'package:dox_auth/dox_auth.dart';
import 'package:dox_core/dox_core.dart';
import 'package:dox_mailer/dox_mailer.dart';
import 'package:dox_orm/dox_orm.dart' show QueryBuilder;
import 'package:dox_test/app/models/e32y/e32y.model.dart';
import 'package:dox_test/app/models/user/user.model.dart';
import 'package:dox_test/config/env.dart';
import 'package:http/http.dart' as http;
import 'package:ioredis/ioredis.dart';
import 'package:test/test.dart';

import 'e2e_310_core.dart' show registerUser;
import 'e2e_test.dart' show Api, SioClient;

/// 3.2.y patch checks: the fixes merged after 3.2.3, seen from the app.
/// e2e_test.dart calls it, so it shares the server and the database of
/// that file.
void patch32yTests(Api api) {
  _cacheTests();
  _enumTests(api);
  _openApiTests(api);
  _validationTests(api);
  _mailTests();
  _socketTests(api);
  _redisTests();
  _authTests(api);
}

void _cacheTests() {
  for (String name in <String>['memory', 'file', 'redis']) {
    group('3.2.y dox_cache ($name): user keys can not hit internal keys', () {
      late Cache cache;

      setUp(() {
        cache = Cache().store(name);
      });

      test('forget("lock:report") does not free lock("report")', () async {
        CacheLock lock = cache.lock('report', Duration(seconds: 5));
        expect(await lock.get(), true);
        try {
          expect(await cache.forget('lock:report'), false);
          expect(await cache.lock('report').get(), false);
          await cache.put('lock:report', 'x');
          expect(await cache.get('lock:report'), 'x');
          expect(await cache.lock('report').get(), false);
        } finally {
          expect(await lock.release(), true);
          await cache.forget('lock:report');
        }
      });

      test('put("tag:dart") does not break tags(["dart"])', () async {
        // a Cache of its own: without CoreFlags.cacheCopies, tags()
        // changes the Cache it is called on
        Cache tagged = Cache().store(name).tags(<String>['dart']);
        Map<String, dynamic> mine = <String, dynamic>{'a': 1};
        await cache.put('tag:dart', mine);
        await tagged.put('k', 1);
        expect(await tagged.get('k'), 1);
        await tagged.flush();
        expect(await tagged.get('k'), isNull);
        expect(await cache.get('tag:dart'), mine);
        await cache.forget('tag:dart');
      });

      test('a held lock("remember:x") does not block remember()', () async {
        CacheLock held = cache.lock('remember:x', Duration(seconds: 10));
        expect(await held.get(), true);
        try {
          int value = await cache
              .remember<int>('x', Duration(minutes: 1), five, lock: true)
              .timeout(Duration(seconds: 2));
          expect(value, 5);
        } finally {
          await held.release();
          await cache.forget('x');
        }
      });

      test('put("#a") and put("a") stay apart', () async {
        await cache.put('#a', 1);
        await cache.put('a', 2);
        expect(await cache.get('#a'), 1);
        expect(await cache.get('a'), 2);
        expect(await cache.many(<String>['#a', 'a']), <String, dynamic>{
          '#a': 1,
          'a': 2,
        });
        await cache.forget('#a');
        await cache.forget('a');
      });

      test('put("flexible:created:k") does not hit flexible("k")', () async {
        Duration fresh = Duration(minutes: 1);
        expect(await cache.flexible<int>('k', fresh, null, one), 1);
        await cache.put('flexible:created:k', 'mine');
        expect(await cache.get('flexible:created:k'), 'mine');
        Counter calls = Counter();
        int value = await cache.flexible<int>('k', fresh, null, calls.two);
        expect(value, 1);
        expect(calls.count, 0);
        await cache.forget('k');
        await cache.forget('flexible:created:k');
      });
    });
  }
}

void _enumTests(Api api) {
  group('3.2.y dox_orm: an unknown stored enum value', () {
    Future<dynamic> insert(Map<String, dynamic> values) async {
      Map<String, dynamic> row = await QueryBuilder.table('e32y_items')
          .create(values);
      return row['id'];
    }

    Future<Map<String, dynamic>?> raw(dynamic id) {
      return QueryBuilder.table('e32y_items').find(id);
    }

    test(
      'a nullable column reads null, the fallback column its value',
      () async {
        dynamic id = await insert(<String, dynamic>{
          'title': 'old',
          'status': 'archived',
          'fallback': 'archived',
        });
        http.Response res = await api.get('/core/e32y/items/$id');
        expect(res.statusCode, 200, reason: res.body);
        Map<String, dynamic> body = api.json(res);
        expect(body['status'], isNull);
        expect(body['fallback'], 'draft');
        E32yItem item = (await E32yItem().find(id))!;
        expect(item.status, isNull);
        expect(item.fallback, E32yStatus.draft);
        expect(item.kind, E32yStatus.draft);
      },
    );

    test('a column that can not be null throws a StateError', () async {
      dynamic id = await insert(<String, dynamic>{'kind': 'archived'});
      await expectLater(
        E32yItem().find(id),
        throwsA(
          isA<StateError>().having(
            (StateError e) => e.message,
            'message',
            allOf(contains('kind'), contains('archived')),
          ),
        ),
      );
      // the route gives a 500, the server keeps going
      http.Response res = await api.get('/core/e32y/items/$id');
      expect(res.statusCode, 500);
      expect((await api.get('/ping')).body, 'pong');
    });

    test('save keeps the stored value, a real value replaces it', () async {
      dynamic id = await insert(<String, dynamic>{
        'title': 'old',
        'status': 'archived',
      });
      E32yItem item = (await E32yItem().find(id))!;
      item.title = 'new';
      await item.save();
      Map<String, dynamic>? row = await raw(id);
      expect(row?['title'], 'new');
      expect(row?['status'], 'archived');

      item.status = E32yStatus.live;
      await item.save();
      expect((await raw(id))?['status'], 'live');
    });

    test('create() with a bad value throws an ArgumentError', () async {
      await expectLater(
        E32yItem().create(<String, dynamic>{'status': 'bogus'}),
        throwsA(
          isA<ArgumentError>().having(
            (ArgumentError e) => '$e',
            'text',
            allOf(contains('status'), contains('bogus')),
          ),
        ),
      );
    });
  });
}

void _openApiTests(Api api) {
  group('3.2.y dox_openapi: a colon in a route path', () {
    String email = 'e32y.books@mail.com';

    setUpAll(() async {
      await registerUser(api, 'E32y Books', email);
      http.Response res = await api.post('/api/auth/login', <String, dynamic>{
        'email': email,
        'password': 'secret123',
      });
      api.tokens['e32y'] = api.json(res)['token'];
    });

    test('GET /books:search matches the literal colon', () async {
      http.Response res = await api.get(
        '/core/e32y/books:search?q=dart',
        token: 'e32y',
      );
      expect(res.statusCode, 200, reason: res.body);
      expect(api.json(res), <String, dynamic>{
        'path': '/core/e32y/books:search',
        'q': 'dart',
      });
      http.Response guest = await api.get('/core/e32y/books:search');
      expect(guest.statusCode, 401);
      http.Response other = await api.get('/core/e32y/booksX', token: 'e32y');
      expect(other.statusCode, 404);
    });

    test('/openapi.json keeps the colon, no x-dox-middleware', () async {
      http.Response res = await api.get('/openapi.json');
      Map<String, dynamic> doc = api.json(res);
      Map<String, dynamic> paths = doc['paths'];
      expect(paths.keys, contains('/core/e32y/books:search'));
      expect(paths.keys.where((String p) => p.contains('{search}')), isEmpty);
      expect(res.body, isNot(contains('x-dox-middleware')));
      Map<String, dynamic> get = paths['/core/e32y/books:search']['get'];
      expect(get['security'], isNotEmpty);
      expect('${get['security']}', contains('bearerAuth'));
    });
  });
}

void _validationTests(Api api) {
  group('3.2.y dox_validation: number and date edge cases', () {
    Future<int> check(String kind, String json) async {
      http.Response res = await api.postRaw('/core/e32y/valid/$kind', json);
      return res.statusCode;
    }

    Future<int> dto(String json) async {
      http.Response res = await api.postRaw('/core/e32y/valid-dto', json);
      return res.statusCode;
    }

    test('v.num() rejects 1e999 (Infinity)', () async {
      expect(await check('num', '{"n":1e999}'), 422);
      expect(await check('num', '{"n":1.5}'), 200);
    });

    test('dates that do not exist give 422', () async {
      for (String bad in <String>[
        '2024-02-31',
        '2024-01-01T24:00:00Z',
        '2024-01-01T10:61:00Z',
      ]) {
        expect(await check('cdate', '{"n":"$bad"}'), 422, reason: bad);
        expect(await dto('{"at":"$bad"}'), 422, reason: bad);
      }
      for (String bad in <String>[
        '2024-01-01T24:00:00Z',
        '2024-01-01T10:61:00Z',
        '2024-02-31T10:00:00Z',
      ]) {
        expect(await check('datetime', '{"n":"$bad"}'), 422, reason: bad);
      }
      expect(await check('cdate', '{"n":"2024-02-29"}'), 200);
      expect(await dto('{"at":"2024-02-29"}'), 200);
      expect(await check('datetime', '{"n":"2024-02-29T10:00:00Z"}'), 200);
    });

    test('a DTO int rejects 1e30', () async {
      expect(await dto('{"count":1e30}'), 422);
      expect(await dto('{"count":7}'), 200);
    });

    test('coerce.int() rejects "0x1F"', () async {
      expect(await check('cint', '{"n":"0x1F"}'), 422);
      expect(await check('cint', '{"n":"31"}'), 200);
    });

    test('multipleOf: 0.3 of 0.1 passes, a near miss of 1 fails', () async {
      expect(await check('tenth', '{"n":0.3}'), 200);
      expect(await check('whole', '{"n":1000000.0000001}'), 422);
      expect(await check('whole', '{"n":1000000}'), 200);
    });

    test('coerce.date() with the smallest int gives 422, not 500', () async {
      expect(await check('cdate', '{"n":-9223372036854775808}'), 422);
    });
  });
}

void _mailTests() {
  group('3.2.y dox_mailer: non-ASCII headers', () {
    late ArrayTransport fake;

    setUp(() {
      fake = Mail.fake();
    });

    tearDown(Mail.restore);

    Message message({
      String to = 'ann@example.com',
      String name = 'Ann',
      String subject = 'Hi',
      List<Attachment> files = const <Attachment>[],
    }) {
      return Message(
        from: const Address('app@example.com', 'App'),
        to: <Address>[Address(to, name)],
        subject: subject,
        text: 'hello',
        attachments: files,
      );
    }

    test('a non-ASCII address throws a MailException', () async {
      await expectLater(
        Mail.send(message(to: 'añn@example.com')),
        throwsA(isA<MailException>()),
      );
      expect(fake.sent, isEmpty);
    });

    test('a non-ASCII cid or content type throws a MailException', () async {
      for (Attachment file in <Attachment>[
        Attachment(<int>[1], 'a.txt', contentType: 'text/plaïn'),
        Attachment(<int>[1], 'a.png', cid: 'logö'),
      ]) {
        await expectLater(
          Mail.send(message(files: <Attachment>[file])),
          throwsA(isA<MailException>()),
        );
      }
      expect(fake.sent, isEmpty);
    });

    test('a non-ASCII name, subject and file name are sent', () async {
      await Mail.send(
        message(
          name: 'Ánn Lée',
          subject: 'Grüße ✓',
          files: <Attachment>[
            Attachment(<int>[1, 2], 'résumé.txt'),
          ],
        ),
      );
      expect(fake.sent, hasLength(1));
      String mime = MimeBuilder().build(fake.sent.single.message).text;
      expect(mime.codeUnits.every((int c) => c < 128), true);
      expect(mime, isNot(contains('Grüße')));
    });
  });
}

void _socketTests(Api api) {
  group('3.2.y dox_socketio: bad packets', () {
    test('an event with no data closes only that client', () async {
      for (String frame in <String>['42', '420']) {
        RawSio raw = await RawSio.open(api);
        raw.ws.add('40');
        expect(await raw.next(), startsWith('40{"sid":'));
        raw.ws.add(frame);
        expect(await raw.closedWithin(), true, reason: frame);
      }
      SioClient ok = await SioClient.connect(api.sioUri, nsp: '/');
      expect(ok.sid, isNotNull);
      await ok.close();
      expect((await api.get('/ping')).body, 'pong');
    });

    test('40null is refused', () async {
      RawSio raw = await RawSio.open(api);
      raw.ws.add('40null');
      expect(await raw.connected(), false);
      await raw.ws.close();
    });

    test('auth 40 levels deep is refused, 20 deep connects', () async {
      String nested(int depth) => '{"a":${'[' * depth}1${']' * depth}}';
      RawSio deep = await RawSio.open(api);
      deep.ws.add('40${nested(40)}');
      expect(await deep.connected(), false);
      await deep.ws.close();

      RawSio ok = await RawSio.open(api);
      ok.ws.add('40${nested(20)}');
      expect(await ok.connected(), true);
      await ok.ws.close();
    });
  });

  group('3.2.y dox_socketio: Broadcast.socketId(req)', () {
    String email = 'e32y.sio@mail.com';
    int userId = 0;
    late SioClient first;
    late SioClient second;

    Future<SioClient> subscribed() async {
      SioClient client = await SioClient.connect(api.sioUri, nsp: '/');
      http.Response res = await api.post(
        '/broadcasting/auth',
        <String, dynamic>{
          'socket_id': client.sid,
          'channel_name': 'private-users.$userId',
        },
        token: 'e32y.sio',
      );
      Object? ack = await client.emitWithAck('subscribe', <String, dynamic>{
        'channel': 'private-users.$userId',
        'auth': api.json(res)['auth'],
      });
      expect(ack, <String, dynamic>{'ok': true});
      return client;
    }

    setUpAll(() async {
      await registerUser(api, 'E32y Sio', email);
      http.Response res = await api.post('/api/auth/login', <String, dynamic>{
        'email': email,
        'password': 'secret123',
      });
      api.tokens['e32y.sio'] = api.json(res)['token'];
      userId = api.json(await api.get('/api/auth/me', token: 'e32y.sio'))['id'];
      first = await subscribed();
      second = await subscribed();
    });

    tearDownAll(() async {
      await first.close();
      await second.close();
    });

    Future<http.Response> ping(String socketId) {
      return api.send(
        'POST',
        '/core/e32y/ping-others/$userId',
        headers: <String, String>{'X-Socket-ID': socketId},
      );
    }

    test('a room name in X-Socket-ID skips nobody', () async {
      http.Response res = await ping('broadcast:private-users.$userId');
      expect(res.statusCode, 200, reason: res.body);
      expect(api.json(res)['skip'], isNull);
      expect(await pinged(first), <String, dynamic>{'id': userId});
      expect(await pinged(second), <String, dynamic>{'id': userId});
    });

    test('a real socket id skips only that socket', () async {
      http.Response res = await ping(first.sid!);
      expect(api.json(res)['skip'], first.sid);
      expect(await pinged(second), <String, dynamic>{'id': userId});
      expect(await first.nothing('e32y.pinged'), true);
    });
  });
}

void _redisTests() {
  group('3.2.y ioredis: subscriber mode', () {
    List<Redis> clients = <Redis>[];
    int n = 0;

    Redis client({void Function(dynamic)? onError}) {
      Redis redis = Redis(
        RedisOptions(
          host: env.redisHost,
          port: env.redisPort,
          onError: onError,
        ),
      );
      clients.add(redis);
      return redis;
    }

    /// a channel name of its own for each check
    String channel() => 'e32y_${pid}_${n++}';

    tearDown(() async {
      for (Redis redis in clients) {
        await redis.disconnect();
      }
      clients.clear();
    });

    Future<void> settle() => Future<void>.delayed(Duration(milliseconds: 200));

    test('two psubscribe on one pattern: both get it, once', () async {
      String chan = channel();
      Redis sub = client();
      List<String> a = <String>[];
      List<String> b = <String>[];
      (await sub.psubscribe('$chan.*'))
          .onPatternMessage = (String p, String c, String? m) =>
          a.add(m!);
      (await sub.psubscribe('$chan.*'))
          .onPatternMessage = (String p, String c, String? m) =>
          b.add(m!);
      await client().publish('$chan.x', 'hi');
      await settle();
      expect(a, <String>['hi']);
      expect(b, <String>['hi']);
    });

    test('ping() and ping("hi") on a subscribed client', () async {
      Redis sub = client();
      await sub.subscribe(channel());
      expect(await sub.ping(), 'PONG');
      expect(await sub.ping('hi'), 'hi');
    });

    test(
      'unsubscribe not awaited, then subscribe: the new one gets it',
      () async {
        String chan = channel();
        Redis sub = client();
        await sub.subscribe(chan);
        Future<void> leaving = sub.unsubscribe(chan);
        List<String> got = <String>[];
        (await sub.subscribe(chan)).onMessage = (String c, String? m) {
          got.add(m!);
        };
        await leaving;
        await client().publish(chan, 'next');
        await settle();
        expect(got, <String>['next']);
      },
    );

    test('connect() not awaited, then disconnect(): later set works', () async {
      Redis redis = client();
      Future<void> connecting = redis.connect();
      await redis.disconnect();
      await connecting.catchError((Object _) {});
      expect(redis.connection.status, RedisConnectionStatus.disconnected);
      String key = 'e32y:$pid:after-disconnect';
      await redis.set(key, 'ok');
      expect(await redis.get(key), 'ok');
      await redis.delete(key);
    });

    test('the same const list subscribed twice: both get it', () async {
      String chan = channel();
      List<String> list = List<String>.unmodifiable(<String>[chan]);
      Redis sub = client();
      List<String> a = <String>[];
      List<String> b = <String>[];
      (await sub.subscribe(list)).onMessage = (String c, String? m) {
        a.add(m!);
      };
      (await sub.subscribe(list)).onMessage = (String c, String? m) {
        b.add(m!);
      };
      await client().publish(chan, 'both');
      await settle();
      expect(a, <String>['both']);
      expect(b, <String>['both']);
    });

    test('an async callback that throws goes to onError', () async {
      String chan = channel();
      Completer<Object> got = Completer<Object>();
      Redis sub = client(
        onError: (dynamic e) {
          if (!got.isCompleted && '$e'.contains('e32y boom')) {
            got.complete(e as Object);
          }
        },
      );
      (await sub.subscribe(chan)).onMessage = (String c, String? m) async {
        await Future<void>.delayed(Duration.zero);
        throw StateError('e32y boom');
      };
      await client().publish(chan, 'x');
      expect(await got.future.timeout(Duration(seconds: 3)), isNotNull);
      // the client still works
      expect(await sub.ping(), 'PONG');
    });
  });
}

void _authTests(Api api) {
  group('3.2.y dox_auth: login values and middleware', () {
    String email = 'e32y.auth@mail.com';

    setUpAll(() async {
      await registerUser(api, 'E32y Auth', email);
    });

    Future<http.Response> attempt(String json) {
      return api.postRaw('/core/e32y/attempt', json);
    }

    test('a number in the email field is a failed login', () async {
      http.Response res = await attempt('{"email":0,"password":"secret123"}');
      expect(res.statusCode, 401, reason: res.body);
      expect(res.body, isNot(contains('token')));
      http.Response login = await api.postRaw(
        '/api/auth/login',
        '{"email":0,"password":"secret123"}',
      );
      expect(<int>[401, 422], contains(login.statusCode), reason: login.body);
      expect(login.body, isNot(contains('"token"')));
    });

    test('a map in the email field fails', () async {
      http.Response res = await attempt(
        '{"email":{"op":"x"},"password":"secret123"}',
      );
      expect(<int>[401, 422], contains(res.statusCode), reason: res.body);
      expect(res.body, isNot(contains('"token"')));
    });

    test('text in a number column (id) is a failed login, no 500', () async {
      http.Response res = await attempt('{"id":"abc","password":"secret123"}');
      expect(res.statusCode, 401, reason: res.body);
      http.Response half = await attempt('{"id":1.5,"password":"secret123"}');
      expect(half.statusCode, 401, reason: half.body);
      // the real login still works after it
      http.Response ok = await attempt(
        '{"email":"$email","password":"secret123"}',
      );
      expect(ok.statusCode, 200, reason: ok.body);
    });

    test('AuthMiddleware().asOptional() keeps the guard', () async {
      AuthMiddleware copy = AuthMiddleware(guard: 'tokens').asOptional();
      expect(copy.guard, 'tokens');
      expect(copy.optional, true);

      http.Response login = await api.post('/api/auth/login', <String, dynamic>{
        'email': email,
        'password': 'secret123',
      });
      api.tokens['e32y.auth'] = api.json(login)['token'];
      http.Response guest = await api.get('/core/e32y/optional-api');
      expect(guest.statusCode, 200);
      expect(api.json(guest)['id'], isNull);
      http.Response user = await api.get(
        '/core/e32y/optional-api',
        token: 'e32y.auth',
      );
      expect(api.json(user)['name'], 'E32y Auth');
      // a JWT is no access token: the `tokens` guard does not take it
      http.Response tokens = await api.get(
        '/core/e32y/optional-tokens',
        token: 'e32y.auth',
      );
      expect(tokens.statusCode, 200, reason: tokens.body);
      expect(api.json(tokens)['id'], isNull);
    });

    test('Gate.hasAbility<M> reads the abilities of the policy', () {
      Gate.policy<E32yItem>(E32yItemPolicy());
      expect(Gate.hasAbility<E32yItem>('view'), true);
      expect(Gate.hasAbility<E32yItem>('delete'), false);
      expect(Gate.hasAbility<E32yStatus>('view'), false);
    });
  });
}

/// the policy of the Gate.hasAbility check: only `view`
class E32yItemPolicy extends Policy<User, E32yItem> {
  @override
  Map<String, Function> get abilities => <String, Function>{'view': view};

  bool view(User user, E32yItem item) => true;
}

/// the data of the next `e32y.pinged` event (args: channel, data)
Future<dynamic> pinged(SioClient client) async {
  return (await client.nextArgs('e32y.pinged')).last;
}

int one() => 1;
int five() => 5;

class Counter {
  int count = 0;

  int two() {
    count++;
    return 2;
  }
}

/// A Socket.IO client on a raw websocket that keeps every frame, for
/// packets the normal client does not send.
class RawSio {
  RawSio(this.ws) {
    ws.listen(_add, onDone: _done, onError: _error);
  }

  final WebSocket ws;
  final List<String> frames = <String>[];
  final Completer<void> closed = Completer<void>();
  int _read = 0;

  static Future<RawSio> open(Api api) async {
    RawSio raw = RawSio(await WebSocket.connect(api.sioUri.toString()));
    expect(await raw.next(), startsWith('0{')); // Engine.IO open
    return raw;
  }

  void _add(dynamic frame) => frames.add('$frame');

  void _done() {
    if (!closed.isCompleted) closed.complete();
  }

  void _error(Object e) => _done();

  /// the next frame that is not a ping, within 2 seconds. '' when closed.
  Future<String> next() async {
    for (int i = 0; i < 40; i++) {
      while (_read < frames.length) {
        String frame = frames[_read++];
        if (frame != '2') return frame;
      }
      if (closed.isCompleted) return '';
      await Future<void>.delayed(Duration(milliseconds: 50));
    }
    throw TimeoutException('no frame');
  }

  /// true when the server answered the CONNECT with a sid
  Future<bool> connected() async {
    String frame = await next();
    return frame.startsWith('40{"sid":');
  }

  /// true when the server closes the socket within 2 seconds
  Future<bool> closedWithin() async {
    try {
      await closed.future.timeout(Duration(seconds: 2));
      return true;
    } on TimeoutException {
      return false;
    }
  }
}
