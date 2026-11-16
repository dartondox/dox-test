import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dox_auth/dox_auth.dart';
// ignore: depend_on_referenced_packages
import 'package:dox_cache/dox_cache.dart'
    show CacheClock, FileDriver, MemoryDriver;
import 'package:dox_cache_database/dox_cache_database.dart';
import 'package:dox_core/dox_core.dart';
import 'package:dox_core/middleware/rate_limit_counter.dart';
import 'package:dox_core/utils/log_buffer.dart';
import 'package:dox_mailer/dox_mailer.dart';
import 'package:dox_orm/dox_orm.dart'
    show OrmStrict, QueryBuilder, SqlQueryBuilder;
import 'package:dox_queue/dox_queue.dart';
import 'package:dox_scheduler/dox_scheduler.dart';
import 'package:dox_socketio/dox_socketio.dart'
    show InMemoryAdapter, Namespace, SocketIoProvider, SocketIoServer;
import 'package:dox_storage/dox_storage.dart' hide MemoryDriver;
import 'package:dox_test/app/jobs/record_step.job.dart';
import 'package:dox_test/app/models/badge/badge.model.dart';
import 'package:dox_test/app/models/post/post.model.dart';
import 'package:dox_test/app/models/tag/tag.model.dart';
import 'package:dox_test/app/models/user/user.model.dart';
import 'package:dox_test/config/env.dart';
import 'package:dox_test/config/queue.dart';
import 'package:dox_test/routes/e32x.dart';
import 'package:http/http.dart' as http;
import 'package:ioredis/ioredis.dart';
import 'package:test/test.dart';

import 'e2e_310_core.dart' show PortApi, registerUser;
import 'e2e_test.dart' show Api, Browser, SioClient;
import 'jobs_e2e.dart' show JobsHelper;

/// 3.2.x patch checks: the changes merged after 3.2.0/3.2.1, seen from
/// the app. e2e_test.dart calls it, so it shares the server and the
/// database of that file.
void patch32xTests(Api api) {
  JobsHelper jobs = JobsHelper(api);

  group('3.2.x dox_core: log tags', () {
    test('a Logger line starts with its tag, [app] when none', () async {
      String log = await captureLog(() async {
        Logger.info('e32x tagged', null, 'billing');
        Logger.warn('e32x plain');
      });
      expect(hasTag(log, 'billing'), true, reason: log);
      expect(hasTag(log, 'app'), true, reason: log);
    });

    test('dox_auth prints its warning with [auth]', () async {
      String out = await capturePrint(() async {
        JwtAuthDriver(secret: SecretKey('short'));
      });
      expect(out, contains('[auth] warning:'));
    });

    test('dox_mailer logs a failed onSent hook with [mail]', () async {
      Mail.fake();
      Mail.onSent(throwOnSent);
      try {
        String err = await captureStderr(() async {
          await Mail.raw('e32x', to: 'ann@x.com');
        });
        expect(err, contains('[mail] an onSent hook threw'));
      } finally {
        Mail.clearHooks();
        Mail.restore();
      }
    });
  });

  group('3.2.x dox_core: Dox().compute and async hashing', () {
    test('compute gives the result of a worker isolate', () async {
      expect(await Dox().compute(fib25), 75025);
    });

    test('an error of the task comes back to the caller', () async {
      await expectLater(
        Dox().compute(failTask),
        throwsA(predicate((Object e) => '$e'.contains('e32x task failed'))),
      );
      // the pool still works after a failed task
      expect(await Dox().compute(fib25), 75025);
    });

    test('the server answers while a compute task runs', () async {
      Future<int> slow = Dox().compute(busy400);
      Stopwatch watch = Stopwatch()..start();
      http.Response ping = await api.get('/ping');
      expect(ping.body, 'pong');
      expect(watch.elapsedMilliseconds, lessThan(300));
      expect(await slow, greaterThanOrEqualTo(400));
    });

    test('Hash.makeAsync and Hash.verifyAsync run on the pool', () async {
      List<Future<String>> hashes = <Future<String>>[];
      for (int i = 0; i < 6; i++) {
        hashes.add(Hash.makeAsync('secret-$i', rounds: 4));
      }
      List<String> made = await Future.wait(hashes);
      for (int i = 0; i < 6; i++) {
        expect(await Hash.verifyAsync('secret-$i', made[i]), true);
        expect(await Hash.verifyAsync('wrong', made[i]), false);
      }
    });
  });

  group('3.2.x dox_core: requests', () {
    test('a GET has an empty body map, a write does not leak', () async {
      http.Response first = await api.get('/core/e32x/body?add=1');
      Map<String, dynamic> one = api.json(first);
      expect(one['before'], isEmpty);
      expect(one['all']['added'], 'yes');
      http.Response second = await api.get('/core/e32x/body');
      Map<String, dynamic> two = api.json(second);
      expect(two['before'], isEmpty);
      expect(two['all'], isNot(contains('added')));
    });

    test('a route with a dot in its prefix still matches', () async {
      http.Response ok = await api.get('/core/e32x/v1.0/7');
      expect(api.json(ok), <String, dynamic>{'id': '7'});
      http.Response other = await api.get('/core/e32x/v2.0/7');
      expect(other.statusCode, 404);
    });

    test('RequestId gives 32 hex chars, SecurityHeaders are sent', () async {
      http.Response res = await api.get('/core/e32x/headers');
      expect(res.headers['x-request-id'], matches(RegExp(r'^[0-9a-f]{32}$')));
      expect(res.headers['x-content-type-options'], 'nosniff');
      expect(res.headers['x-frame-options'], 'DENY');
      http.Response given = await api.get(
        '/core/e32x/headers',
        headers: <String, String>{'X-Request-Id': 'e32x-id-1'},
      );
      expect(given.headers['x-request-id'], 'e32x-id-1');
    });

    test('a big JSON body and a small one encode right', () async {
      http.Response small = await api.get('/core/e32x/v1.0/x');
      expect(small.body, '{"id":"x"}');
      String long = 'a' * 5000;
      http.Response big = await api.get('/core/e32x/v1.0/$long');
      expect(api.json(big)['id'], long);
    });
  });

  group('3.2.x dox_core: upload temp files', () {
    List<int> big = List<int>.filled(1024 * 1024 + 100, 66);

    test('a big upload is on disk in the handler, gone after', () async {
      http.Response res = await api.uploadBytes(
        '/core/e32x/upload-temp',
        'file',
        big,
        'big.bin',
      );
      expect(res.statusCode, 200, reason: res.body);
      Map<String, dynamic> body = api.json(res);
      expect(body['exists'], true);
      expect(body['bytes'], big.length);
      expect(await gone(body['path'] as String), true);
    });

    test('a small upload has no temp file', () async {
      http.Response res = await api.uploadBytes(
        '/core/e32x/upload-temp',
        'file',
        utf8.encode('small'),
        'small.txt',
      );
      expect(api.json(res)['path'], isNull);
    });

    test('the temp file is deleted when the handler fails too', () async {
      E32xRoutes.lastTempPath = null;
      http.Response res = await api.uploadBytes(
        '/core/e32x/upload-temp-fail',
        'file',
        big,
        'big.bin',
      );
      expect(res.statusCode, 500);
      String? path = E32xRoutes.lastTempPath;
      expect(path, isNotNull);
      expect(await gone(path!), true);
    });

    test('a multipart body with no closing boundary gives 400', () async {
      String body =
          '--e32x\r\n'
          'Content-Disposition: form-data; name="file"; filename="a.txt"\r\n'
          'Content-Type: text/plain\r\n\r\n'
          'cut here';
      String head = await rawAnswer(
        api,
        'POST /core/e32x/upload-temp HTTP/1.1\r\n'
        'Host: 127.0.0.1\r\n'
        'Content-Type: multipart/form-data; boundary=e32x\r\n'
        'Content-Length: ${utf8.encode(body).length}\r\n'
        'Connection: close\r\n\r\n'
        '$body',
      );
      expect(head, startsWith('HTTP/1.1 400'));
    });
  });

  group('3.2.x dox-http-native: streams and gone clients', () {
    test('flush sends the head and the first part at once', () async {
      Socket socket = await Socket.connect('127.0.0.1', port(api));
      StringBuffer got = StringBuffer();
      socket.listen((List<int> data) => got.write(utf8.decode(data)));
      socket.write('GET /e32x-sse HTTP/1.1\r\nHost: 127.0.0.1\r\n\r\n');
      expect(await waitFor(() => '$got'.contains('data: hello')), true);
      expect('$got', startsWith('HTTP/1.1 200'));
      expect(E32xRoutes.sseDone, false);
      // the client leaves: `done` of the open response completes
      socket.destroy();
      expect(await waitFor(() => E32xRoutes.sseDone), true);
    });

    test('an error after the head was sent only ends the stream', () async {
      String answer = await rawAnswer(
        api,
        'GET /core/e32x/flush-then-throw HTTP/1.1\r\n'
        'Host: 127.0.0.1\r\nConnection: close\r\n\r\n',
        whole: true,
      );
      expect(answer, startsWith('HTTP/1.1 200'));
      expect(answer, contains('data: one'));
      expect(answer, isNot(contains('Internal Server Error')));
    });

    test('WebSocket pingInterval pings, then closes a silent client', () async {
      Socket socket = await Socket.connect('127.0.0.1', port(api));
      SocketLog got = SocketLog(socket);
      socket.write(
        'GET /core/e32x/ws-ping HTTP/1.1\r\n'
        'Host: 127.0.0.1\r\n'
        'Upgrade: websocket\r\n'
        'Connection: Upgrade\r\n'
        'Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\n'
        'Sec-WebSocket-Version: 13\r\n\r\n',
      );
      // no pong: the server pings at 300 ms, closes at about 600 ms
      Stopwatch watch = Stopwatch()..start();
      bool closed = await got.closed(Duration(seconds: 3));
      int ms = watch.elapsedMilliseconds;
      socket.destroy();
      String text = latin1.decode(got.bytes);
      expect(text, startsWith('HTTP/1.1 101'));
      List<int> frames = got.bytes.sublist(text.indexOf('\r\n\r\n') + 4);
      // 0x89 is a ping frame
      expect(frames.first, 0x89, reason: '$frames');
      expect(closed, true, reason: 'open after $ms ms, frames $frames');
    });
  });

  group('3.2.x dox_core: rate limit', () {
    test('a Redis store counts in one round trip, 429 after max', () async {
      for (String path in <String>[
        '/core/e32x/limit',
        '/core/e32x/limit-sliding',
      ]) {
        String key = 'k${jobs.stamp()}';
        Map<String, String> h = <String, String>{'X-E32x-Key': key};
        http.Response a = await api.get(path, headers: h);
        http.Response b = await api.get(path, headers: h);
        http.Response c = await api.get(path, headers: h);
        expect(a.statusCode, 200, reason: path);
        expect(a.headers['x-ratelimit-remaining'], '1');
        expect(b.headers['x-ratelimit-remaining'], '0');
        expect(c.statusCode, 429, reason: path);
        expect(int.parse(c.headers['retry-after']!), greaterThan(0));
        // another client has its own count
        http.Response other = await api.get(
          path,
          headers: <String, String>{'X-E32x-Key': '$key-2'},
        );
        expect(other.statusCode, 200);
      }
    });

    test('the main isolate counter keeps at most maxKeys clients', () async {
      RateLimitCounter counter = RateLimitCounter.instance;
      expect(RateLimitCounter.defaultMaxKeys, 100000);
      expect(counter.maxKeys, 100000);
      String run = jobs.stamp();
      counter.maxKeys = counter.length + 3;
      try {
        for (int i = 0; i < 10; i++) {
          expect(
            await counter.increment('e32x:$run:$i', Duration(minutes: 1)),
            1,
          );
        }
        expect(counter.length, lessThanOrEqualTo(counter.maxKeys!));
        // the newest client still counts on
        expect(await counter.increment('e32x:$run:9', Duration(minutes: 1)), 2);
      } finally {
        counter.maxKeys = RateLimitCounter.defaultMaxKeys;
      }
    });

    test('RateLimit.ipBucket and the IPv6 /64 flag (off by default)', () {
      expect(Dox().flags.rateLimitIpv6Prefix, false);
      expect(RateLimit.ipBucket('2001:db8:1:2:aaaa::1'), '2001:db8:1:2::/64');
      expect(
        RateLimit.ipBucket('2001:db8:1:2:ffff:1:2:3'),
        RateLimit.ipBucket('2001:db8:1:2::9'),
      );
      expect(RateLimit.ipBucket('::ffff:1.2.3.4'), '1.2.3.4');
      expect(RateLimit.ipBucket('1.2.3.4'), '1.2.3.4');
      expect(RateLimit.ipBucket('not-an-ip'), 'not-an-ip');
    });
  });

  group('3.2.x dox_cache: memory and file stores', () {
    test('a full memory store drops the least recently used item', () async {
      MemoryDriver store = MemoryDriver(maxSize: 3);
      await store.put('a', 1, null);
      await store.put('b', 2, null);
      await store.put('c', 3, null);
      expect(await store.get('a'), 1);
      await store.put('d', 4, null);
      expect(await store.get('b'), isNull);
      expect(await store.get('a'), 1);
      expect(await store.get('d'), 4);
    });

    test('a broken value file reads as a miss', () async {
      Directory dir = await Directory.systemTemp.createTemp('e32x_cache');
      try {
        FileDriver store = FileDriver(directory: dir);
        await store.put('k', 'v', null);
        File file = store.fileFor('k');
        await file.writeAsString('[1, 2]');
        expect(await store.get('k'), isNull);
        await file.writeAsString('{"value": 1, "expires_at": "soon"}');
        expect(await store.get('k'), isNull);
      } finally {
        await dir.delete(recursive: true);
      }
    });

    test('prune deletes old temp files, keeps other files', () async {
      Directory dir = await Directory.systemTemp.createTemp('e32x_cache');
      try {
        FileDriver store = FileDriver(directory: dir);
        await store.put('k', 'v', null);
        String folder = store.storeDirectory.path;
        String hash = 'a' * 64;
        File temp = File('$folder/$hash.${'b' * 32}.tmp');
        await temp.writeAsString('left by a crash');
        await temp.setLastModified(DateTime.now().subtract(Duration(hours: 2)));
        File mine = File('$folder/notes.txt');
        await mine.writeAsString('not a cache file');
        await store.prune();
        expect(await temp.exists(), false);
        expect(await mine.exists(), true);
        expect(await store.get('k'), 'v');
      } finally {
        await dir.delete(recursive: true);
      }
    });

    test('a write starts the hourly prune by default', () async {
      Directory dir = await Directory.systemTemp.createTemp('e32x_cache');
      try {
        MovingCacheClock clock = MovingCacheClock(DateTime.now());
        FileDriver store = FileDriver(directory: dir, clock: clock);
        await store.put('old', 1, Duration(seconds: 1));
        File old = store.fileFor('old');
        expect(await old.exists(), true);
        clock.time = clock.time.add(Duration(minutes: 2));
        await store.put('new', 2, null);
        Future<int>? prune = store.backgroundPrune;
        expect(prune, isNotNull);
        await prune;
        expect(await old.exists(), false);
        expect(await store.get('new'), 2);
      } finally {
        await dir.delete(recursive: true);
      }
    });
  });

  group('3.2.x dox_cache_database: one statement per write', () {
    test('add, increment, pull and touch keep their results', () async {
      Cache db = Cache().store('database');
      String k = 'e32x-${jobs.stamp()}';
      expect(await db.add(k, 'one'), true);
      expect(await db.add(k, 'two'), false);
      expect(await db.get(k), 'one');
      expect(await db.increment('$k-n'), 1);
      expect(await db.increment('$k-n', 4), 5);
      expect(await db.decrement('$k-n', 2), 3);
      expect(await db.touch(k, duration: Duration(minutes: 5)), true);
      expect(await db.pull(k), 'one');
      expect(await db.get(k), isNull);
      // an expired row counts as missing for add
      await db.put('$k-x', 'gone', duration: Duration(milliseconds: 1));
      await Future<void>.delayed(Duration(milliseconds: 1100));
      expect(await db.add('$k-x', 'new'), true);
      expect(await db.get('$k-x'), 'new');
    });

    test('an increment past the 64-bit limit fails, value kept', () async {
      Cache db = Cache().store('database');
      String k = 'e32x-max-${jobs.stamp()}';
      await db.put(k, 9223372036854775807);
      await expectLater(db.increment(k), throwsA(anything));
      expect('${await db.get(k)}', '9223372036854775807');
    });

    test('prune_interval prunes on a write, not awaited', () async {
      DatabaseCacheDriver driver = DatabaseCacheDriver(
        prefix: 'e32x_prune',
        pruneInterval: Duration(milliseconds: 1),
      );
      await driver.put('old', 1, Duration(milliseconds: 1));
      await Future<void>.delayed(Duration(milliseconds: 1100));
      await driver.put('trigger', 2, null);
      bool pruned = await waitFor(() async {
        int n = await QueryBuilder.table('cache')
            .where('key', 'like', 'e32x_prune:old%')
            .count();
        return n == 0;
      });
      expect(pruned, true);
      await driver.flush();
    });
  });

  group('3.2.x dox_orm: rows, relations and caches', () {
    late User author;
    List<Post> made = <Post>[];

    setUpAll(() async {
      author = User();
      author.name = 'E32x';
      author.email = 'e32x.${jobs.stamp()}@x.com';
      author.password = 'not-a-real-hash';
      await author.save();
      for (int i = 0; i < 4; i++) {
        Post post = Post();
        post.userId = author.id;
        post.title = 'e32x post $i';
        post.body = 'body $i';
        post.status = 'draft';
        await post.save();
        made.add(post);
      }
    });

    Future<List<Post>> posts() {
      return Post().where('user_id', author.id).orderBy('id').get();
    }

    test('\$columnValue gives the same value as columnsToMap', () async {
      Post post = (await Post().find(made.first.id))!;
      Map<String, dynamic> map = post.columnsToMap();
      for (String column in <String>['id', 'user_id', 'title', 'created_at']) {
        expect(post.$columnValue(column), map[column], reason: column);
      }
      expect(post.createdAt, isA<DateTime>());
    });

    test('preload on many rows matches by key, toJson has it', () async {
      List<Post> rows = await Post()
          .preload('author')
          .where('user_id', author.id)
          .orderBy('id')
          .get();
      expect(rows.length, 4);
      for (Post row in rows) {
        expect(row.author?.id, author.id);
        expect(row.toJson()['author']['email'], author.email);
      }
    });

    test('a preload on one row does not change the other rows', () async {
      List<Post> rows = await Post()
          .preload('author')
          .where('user_id', author.id)
          .orderBy('id')
          .get();
      rows.first.preload('comments');
      expect(rows.first.getPreload(), contains('comments'));
      expect(rows[1].getPreload(), isNot(contains('comments')));
      expect(rows[1].toJson(), isNot(contains('comments')));
      expect(rows[1].toJson()['author']['id'], author.id);
    });

    test('a query from a row does not change the row or others', () async {
      List<Post> rows = await posts();
      Post first = rows.first;
      Post? second = await first.where('id', rows[1].id).getFirst();
      expect(second?.id, rows[1].id);
      expect(first.id, made.first.id);
      first.title = 'e32x changed';
      await first.save();
      expect((await Post().find(first.id))!.title, 'e32x changed');
      expect((await Post().find(rows[1].id))!.title, 'e32x post 1');
    });

    test('where(column, value).first() twice gives each row', () async {
      for (Post post in made.sublist(1)) {
        Post? got = await Post().where('id', post.id).first();
        expect(got?.title, post.title);
      }
    });

    // the bug was only on Postgres and MySQL
    test('find on a json path works twice', skip: sqliteSkip(), () async {
      String name = 'e32x-json-${jobs.stamp()}';
      await Badge().create(<String, dynamic>{
        'name': name,
        'meta': <String, dynamic>{'e32x': 7},
      });
      Badge? one = await Badge().find('meta->e32x', 7);
      Badge? two = await Badge().find('meta->e32x', 7);
      expect(one?.name, name);
      expect(two?.name, name);
    });

    test('save() with a copy of the same date sends no change', () async {
      Post post = (await Post().find(made[2].id))!;
      DateTime at = post.updatedAt!;
      post.updatedAt = DateTime.fromMicrosecondsSinceEpoch(
        at.microsecondsSinceEpoch,
        isUtc: at.isUtc,
      );
      expect(post.isClean('updated_at'), true, reason: '${post.getDirty()}');
      await post.save();
      expect(post.getChanges(), isEmpty);
      expect(post.updatedAt!.isAtSameMomentAs(at), true);
    });

    test('a typed \$getRelation loads the field and gives null', () async {
      Post post = (await Post().find(made.first.id))!;
      Object? got = await post.$getRelation<User>('author');
      expect(got, isNull);
      expect(post.author?.id, author.id);
    });

    test('relations load together inside a transaction', () async {
      List<Post> inside = <Post>[];
      await QueryBuilder.transaction(() async {
        inside = await Post()
            .preload('author')
            .preload('comments')
            .preload('tags')
            .where('user_id', author.id)
            .orderBy('id')
            .get();
      });
      expect(inside.length, 4);
      for (Post post in inside) {
        expect(post.author?.id, author.id);
        expect(post.comments, isEmpty);
        expect(post.tags, isEmpty);
      }
    });

    test('a query over 4 KB of SQL runs right many times', () async {
      List<int> ids = <int>[for (int i = 0; i < 1200; i++) 1000000 + i];
      // made.first got a new title above
      for (Post post in made.sublist(1)) {
        List<Post> rows = await Post().where('title', post.title).whereIn(
          'id',
          <int>[...ids, post.id!],
        ).get();
        expect(rows.map(titleOf), <String?>[post.title]);
      }
    });

    test('strict mode warns about N+1 and a big result', () async {
      SqlQueryBuilder sql = SqlQueryBuilder();
      OrmStrict old = sql.strict;
      sql.strict = OrmStrict(nPlusOneCount: 3, maxRows: 3);
      try {
        // dox_orm prints its lines, it does not use the dox_core Logger
        String log = await capturePrint(() async {
          for (Post post in await posts()) {
            await post.$getRelation('author');
          }
        });
        expect(log, contains('[db]'));
        expect(log, contains("preload('author')"));
        String paged = await capturePrint(() async {
          await Post()
              .where('user_id', author.id)
              .paginate(currentPage: 1, perPage: 10);
        });
        expect(paged, isNot(contains('paginate()')));
      } finally {
        sql.strict = old;
      }
    });
  });

  group('3.2.x dox-postgres-native: prepared statements', () {
    test(
      'failed queries do not grow pg_prepared_statements',
      skip: postgresSkip(),
      () async {
        await QueryBuilder.transaction(() async {
          // one transaction: every query below is on one connection
          await QueryBuilder.query(
            'CREATE TEMP TABLE e32x_u (id int PRIMARY KEY) ON COMMIT DROP',
          );
          await QueryBuilder.query('INSERT INTO e32x_u VALUES (1)');
          int before = await prepared();
          for (int i = 0; i < 20; i++) {
            await failInSavepoint('INSERT INTO e32x_u VALUES (1)');
            await failInSavepoint('SELECT * FROM e32x_missing_$i');
          }
          int after = await prepared();
          expect(
            after - before,
            lessThanOrEqualTo(3),
            reason: '$before $after',
          );
        });
      },
    );
  });

  group('3.2.x dox_queue: one poll for many queues, batch inserts', () {
    test('a worker with two queues takes the first queue first', () async {
      String run = 'e32xq${jobs.stamp()}';
      await RecordStep(step: '$run-low').dispatch(queue: 'e32x-low');
      await RecordStep(step: '$run-high').dispatch(queue: 'e32x-high');
      await Worker(
        driver: Queue.driver,
        jobs: queueConfig.jobs,
        options: WorkerOptions(
          queues: <String>['e32x-high', 'e32x-low'],
          stopWhenEmpty: true,
        ),
      ).run();
      expect(await stepsOf(run), <String>['$run-high', '$run-low']);
    });

    test('a batch of 450 jobs is pushed in multi-row inserts', () async {
      String run = 'e32xb${jobs.stamp()}';
      List<DoxJob> list = <DoxJob>[];
      for (int i = 0; i < 450; i++) {
        list.add(RecordStep(step: '$run-$i'));
      }
      int before = await jobs.jobCount();
      Batch batch = await Queue.batch(list).dispatch(queue: 'e32x-batch');
      expect(batch.totalJobs, 450);
      expect(await jobs.jobCount(), before + 450);
      await QueryBuilder.table('jobs').where('queue', 'e32x-batch').delete();
    });

    test('stop() wakes an idle worker at once', () async {
      Worker worker = Worker(
        driver: Queue.driver,
        jobs: queueConfig.jobs,
        options: WorkerOptions(
          queues: <String>['e32x-idle'],
          sleep: Duration(seconds: 3),
        ),
      );
      Future<void> loop = worker.run();
      await Future<void>.delayed(Duration(milliseconds: 300));
      Stopwatch watch = Stopwatch()..start();
      worker.stop();
      await loop.timeout(Duration(seconds: 2));
      expect(watch.elapsedMilliseconds, lessThan(1000));
    });
  });

  group('3.2.x dox_scheduler', () {
    DateTime tick = DateTime.utc(2026, 11, 16, 2);

    test('a tick that runs into the next minute runs that minute', () async {
      SleepClock clock = SleepClock(tick.subtract(Duration(seconds: 90)));
      List<DateTime> seen = <DateTime>[];
      List<DateTime> daily = <DateTime>[];
      late Scheduler scheduler;
      Schedule s = Schedule();
      s.call('slow', () {
        seen.add(clock.now());
        // the 01:59 run ends at 02:00:30
        if (seen.length == 1) {
          clock.time = clock.time.add(Duration(seconds: 90));
        }
        if (seen.length == 3) scheduler.stop();
      });
      s.call('daily', () => daily.add(clock.now())).dailyAt('02:00');
      scheduler = Scheduler(
        tasks: s.tasks,
        store: CacheStore(MemoryDriver()),
        clock: clock,
        err: StringBuffer(),
      );
      await scheduler.work().timeout(Duration(seconds: 5));
      expect(daily, <DateTime>[tick.add(Duration(seconds: 30))]);
      expect(seen.length, 3);
    });

    test('the default output keeps only the last 64 KB', () async {
      Schedule s = Schedule();
      s.call('e32x-noisy-task-with-a-long-name-${'x' * 60}', noop);
      Scheduler scheduler = Scheduler(
        tasks: s.tasks,
        store: CacheStore(MemoryDriver()),
        clock: SleepClock(tick),
        err: StringBuffer(),
      );
      for (int i = 0; i < 600; i++) {
        await scheduler.runTask(s.tasks.first, tick);
      }
      String out = scheduler.out.toString();
      expect(out.length, lessThanOrEqualTo(64 * 1024));
      expect(out, contains('e32x-noisy-task'));
    });

    test('loggerLines logs through the Logger with [scheduler]', () async {
      Schedule s = Schedule();
      s.call('e32x-logged', noop);
      Scheduler scheduler = Scheduler(
        tasks: s.tasks,
        store: CacheStore(MemoryDriver()),
        clock: SleepClock(tick),
        out: StringBuffer(),
        err: StringBuffer(),
        flags: SchedulerFlags(loggerLines: true),
      );
      String log = await captureLog(() async {
        await scheduler.runTask(s.tasks.first, tick);
      });
      expect(hasTag(log, 'scheduler'), true, reason: log);
      expect(log, contains('e32x-logged'));
    });
  });

  group('3.2.x dox_socketio: join after disconnect', () {
    test('a join after the client left keeps no room entry', () async {
      String room = 'e32x-room-${jobs.stamp()}';
      SioClient client = await SioClient.connect(api.sioUri);
      expect(await client.emitWithAck('late-join', room), 'ok');
      await client.close();
      await Future<void>.delayed(Duration(milliseconds: 600));
      SocketIoServer io = SocketIoProvider.server!;
      Namespace nsp = io.of('/chat');
      InMemoryAdapter adapter = nsp.adapter as InMemoryAdapter;
      expect(adapter.rooms(nsp), isNot(contains(room)));
    });
  });

  group('3.2.x dox_storage', () {
    Disk local() => Storage().use('local');
    Disk s3() => Storage().use('s3');
    String run = 'e32x${DateTime.now().microsecondsSinceEpoch}';

    test('local append and prepend', () async {
      String key = '$run/log.txt';
      await local().put(key, 'b');
      await local().append(key, 'c');
      await local().prepend(key, 'a');
      expect(await local().getString(key), 'a\nb\nc');
      await local().deleteDirectory(run);
    });

    test('local recursive listAll with a limit pages in order', () async {
      for (String name in <String>[
        'c.txt',
        'a.txt',
        'sub/b.txt',
        'sub/d.txt',
        'e.txt',
      ]) {
        await local().put('$run/list/$name', name);
      }
      List<String> keys = <String>[];
      String? token;
      do {
        ListResult page = await local().listAll(
          '$run/list',
          ListOptions(recursive: true, limit: 2, paginationToken: token),
        );
        expect(page.objects.length, lessThanOrEqualTo(2));
        for (DriveEntry e in page.objects) {
          if (e is DriveFile) keys.add(e.key);
        }
        token = page.paginationToken;
      } while (token != null);
      List<String> sorted = <String>[...keys]..sort();
      expect(keys, sorted);
      expect(keys.length, 5);
      await local().deleteDirectory(run);
    });

    test('S3: an empty folder marker exists, delete removes it', () async {
      Disk disk = s3();
      await disk.driver.put('$run/empty/', Uint8List(0), const WriteOptions());
      expect(await disk.directoryExists('$run/empty'), true);
      await disk.deleteDirectory('$run/empty');
      expect(await disk.directoryExists('$run/empty'), false);
    });

    test('S3: a marker before the files, listAll hides it', () async {
      Disk disk = s3();
      await disk.driver.put('$run/mf/', Uint8List(0), const WriteOptions());
      await disk.put('$run/mf/a.txt', 'a');
      expect(await disk.directoryExists('$run/mf'), true);
      ListResult list = await disk.listAll('$run/mf');
      expect(list.objects.map(keyOf), <String>['$run/mf/a.txt']);
      await disk.deleteDirectory('$run/mf');
      expect(await disk.directoryExists('$run/mf'), false);
    });

    test('S3: putStream of 6 MiB, stream with its meta data', () async {
      Disk disk = s3();
      int size = 6 * 1024 * 1024;
      await disk.putStream('$run/big.bin', chunks(size));
      ObjectStream got = await disk.getStreamWithMetaData('$run/big.bin');
      expect(got.metaData.size, size);
      expect(got.metaData.etag, isNotEmpty);
      int read = 0;
      await for (List<int> part in got.stream) {
        read += part.length;
      }
      expect(read, size);
      await expectLater(
        disk.getStreamWithMetaData('$run/missing.bin'),
        throwsA(anything),
      );
      await disk.deleteDirectory(run);
    });
  });

  group('3.2.x ioredis', () {
    test('commandTimeout is 10 s by default', () {
      expect(RedisOptions().commandTimeout, Duration(seconds: 10));
    });

    test('a server that never answers gives RedisTimeoutError', () async {
      ServerSocket silent = await ServerSocket.bind('127.0.0.1', 0);
      List<Socket> held = <Socket>[];
      silent.listen(held.add);
      Redis redis = Redis(
        RedisOptions(
          port: silent.port,
          commandTimeout: Duration(milliseconds: 300),
        ),
      );
      Stopwatch watch = Stopwatch()..start();
      try {
        await expectLater(redis.get('e32x'), throwsA(isA<RedisTimeoutError>()));
        expect(watch.elapsedMilliseconds, lessThan(3000));
      } finally {
        await redis.disconnect();
        for (Socket s in held) {
          s.destroy();
        }
        await silent.close();
      }
    });

    test('a bad reply byte fails the command, no crash', () async {
      ServerSocket bad = await ServerSocket.bind('127.0.0.1', 0);
      List<Socket> held = <Socket>[];
      bad.listen((Socket s) {
        held.add(s);
        s.listen((List<int> _) => s.add(utf8.encode('?what\r\n')));
      });
      Redis redis = Redis(
        RedisOptions(port: bad.port, commandTimeout: Duration(seconds: 2)),
      );
      try {
        await expectLater(redis.get('e32x'), throwsA(anything));
      } finally {
        await redis.disconnect();
        for (Socket s in held) {
          s.destroy();
        }
        await bad.close();
      }
    });

    test('Burmese and emoji text round trip', () async {
      String text = 'မင်္ဂလာပါ dox 🐶 ${'ဧ' * 300}';
      Cache cache = Cache().store('redis');
      String k = 'e32x-mm-${jobs.stamp()}';
      await cache.put(k, text);
      expect(await cache.get(k), text);
      await cache.forget(k);
      Redis redis = Redis(
        RedisOptions(port: env.redisPort, db: JobsHelper.redisDb),
      );
      try {
        await redis.set(k, text);
        expect(await redis.get(k), text);
        await redis.delete(k);
      } finally {
        await redis.disconnect();
      }
    });
  });

  group('3.2.x a server with 3 isolates, memory sessions, strict mode', () {
    Process? server;
    StringBuffer log = StringBuffer();
    late Api child;
    String email = 'e32x.iso@mail.com';

    setUpAll(() async {
      await registerUser(api, 'E32x Isolate', email);
      ServerSocket free = await ServerSocket.bind('127.0.0.1', 0);
      int p = free.port;
      await free.close();
      child = PortApi(p);
      Process proc = await Process.start(
        'dart',
        <String>['run', 'bin/e2e_isolates.dart'],
        environment: <String, String>{
          'APP_PORT': '$p',
          'APP_URL': 'http://127.0.0.1:$p',
          'APP_TOTAL_ISOLATE': '3',
          'SESSION_STORE': 'memory',
          'APP_STRICT': 'true',
        },
      );
      server = proc;
      proc.stdout.transform(utf8.decoder).listen(log.write);
      proc.stderr.transform(utf8.decoder).listen(log.write);
      bool up = false;
      for (int i = 0; i < 1500 && !up; i++) {
        try {
          up = (await child.get('/ping')).statusCode == 200;
        } on Exception {
          await Future<void>.delayed(Duration(milliseconds: 100));
        }
      }
      expect(up, true, reason: '$log');
    });

    tearDownAll(() async {
      Process? p = server;
      if (p == null) return;
      p.kill();
      await p.exitCode.timeout(
        Duration(seconds: 10),
        onTimeout: () {
          p.kill(ProcessSignal.sigkill);
          return -1;
        },
      );
    });

    test('server lines have the [server] tag', () {
      expect('$log', contains('[server]'));
      // the maxSessions warning of dox_socketio
      expect('$log', contains('[socketio]'));
      expect('$log', isNot(contains('dox: warning:')));
    });

    test('a memory store session is the same in every isolate', () async {
      Browser browser = Browser(child);
      Set<int> isolates = <int>{};
      for (int i = 1; i <= 12; i++) {
        http.Response res = await browser.send(
          'GET',
          '/core/e32x/session-count',
          <String, String>{},
        );
        Map<String, dynamic> body = api.json(res);
        expect(body['count'], i, reason: 'request $i, $isolates');
        isolates.add(body['isolate'] as int);
      }
      // ponytail: macOS gives all new connections to one isolate, Linux
      // (CI) spreads them. Only Linux can show the old bug.
      if (Platform.isLinux) {
        expect(isolates.length, greaterThan(1), reason: 'one isolate answered');
      }
    });

    test('a session login stays in every isolate', () async {
      Browser browser = Browser(child);
      await browser.send('GET', '/ping', <String, String>{});
      http.Response res = await browser.send(
        'POST',
        '/web-auth/login',
        <String, String>{'Content-Type': 'application/json'},
        jsonEncode(<String, String>{'email': email, 'password': 'secret123'}),
      );
      expect(res.statusCode, 200, reason: res.body);
      for (int i = 0; i < 12; i++) {
        http.Response me = await browser.send(
          'GET',
          '/web-auth/me',
          <String, String>{},
        );
        expect(me.statusCode, 200, reason: 'request $i');
      }
    });

    test('strict mode warns about a blocking route and Hash.make', () async {
      await child.get('/core/e32x/block');
      await child.get('/core/e32x/hash-sync');
      expect(
        await waitFor(() => '$log'.contains('Hash.makeAsync')),
        true,
        reason: '$log',
      );
      expect('$log', contains('[strict]'));
      expect('$log', contains('/core/e32x/block'));
    });
  });
}

/// a skip reason on SQLite
String? sqliteSkip() {
  return env.dbConnection == DbConnection.sqlite ? 'not on SQLite' : null;
}

/// a skip reason when the database is not Postgres
String? postgresSkip() {
  return env.dbConnection == DbConnection.postgres ? null : 'Postgres only';
}

int fib(int n) => n < 2 ? n : fib(n - 1) + fib(n - 2);

int fib25() => fib(25);

int failTask() => throw StateError('e32x task failed');

/// blocks its isolate for 400 ms, gives the time it took
int busy400() {
  Stopwatch watch = Stopwatch()..start();
  while (watch.elapsedMilliseconds < 400) {}
  return watch.elapsedMilliseconds;
}

void throwOnSent(SentMessage sent) {
  throw StateError('e32x hook');
}

void noop() {}

String? titleOf(Post post) => post.title;

String keyOf(DriveEntry entry) => entry.key;

int port(Api api) => Uri.parse(api.base).port;

/// a stream of [size] bytes in 64 KB parts
Stream<List<int>> chunks(int size) async* {
  int left = size;
  while (left > 0) {
    int n = left < 65536 ? left : 65536;
    yield Uint8List(n);
    left -= n;
  }
}

/// the tag names of the RecordStep jobs of [run], in save order
Future<List<String>> stepsOf(String run) async {
  List<Tag> tags = await Tag()
      .where('name', 'like', '$run-%')
      .orderBy('id')
      .get();
  return <String>[for (Tag tag in tags) tag.name!];
}

/// the prepared statements of this connection
Future<int> prepared() async {
  List<Map<String, dynamic>> rows = await QueryBuilder.query(
    'SELECT count(*)::int AS n FROM pg_prepared_statements',
  );
  return rows.first['n'] as int;
}

/// run [sql] in a savepoint that fails, so the outer transaction goes on
Future<void> failInSavepoint(String sql) async {
  try {
    await QueryBuilder.transaction(() async {
      await QueryBuilder.query(sql);
    });
  } catch (_) {
    // the error is the point
  }
}

/// true when [check] is true within 3 seconds
Future<bool> waitFor(FutureOr<bool> Function() check) async {
  for (int i = 0; i < 60; i++) {
    if (await check()) return true;
    await Future<void>.delayed(Duration(milliseconds: 50));
  }
  return false;
}

/// true when the file at [path] is gone within 3 seconds
Future<bool> gone(String path) {
  return waitFor(() async => !await File(path).exists());
}

/// Send [request] on a new socket. Gives the head, or all of the answer
/// with [whole].
Future<String> rawAnswer(Api api, String request, {bool whole = false}) async {
  Socket socket = await Socket.connect('127.0.0.1', port(api));
  socket.write(request);
  String answer = await utf8.decoder
      .bind(socket)
      .join()
      .timeout(Duration(seconds: 5));
  socket.destroy();
  return whole ? answer : answer.split('\r\n\r\n').first;
}

/// true when a Logger line has [tag]: `[tag]` (pretty) or the JSON
/// `source` field
bool hasTag(String log, String tag) {
  return log.contains('[$tag]') || log.contains('"source":"$tag"');
}

/// the Logger lines written while [body] runs
Future<String> captureLog(Future<void> Function() body) async {
  StringBuffer out = StringBuffer();
  void Function(String) old = LogBuffer.writer;
  LogBuffer.writer = out.write;
  try {
    await body();
    LogBuffer.flush();
  } finally {
    LogBuffer.writer = old;
  }
  return '$out';
}

/// the `print` lines of [body]
Future<String> capturePrint(Future<void> Function() body) async {
  StringBuffer out = StringBuffer();
  await runZoned(
    body,
    zoneSpecification: ZoneSpecification(
      print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
        out.writeln(line);
      },
    ),
  );
  return '$out';
}

/// the stderr text of [body]
Future<String> captureStderr(Future<void> Function() body) async {
  StderrCapture err = StderrCapture();
  await IOOverrides.runZoned(body, stderr: () => err);
  return '${err.text}';
}

/// a fake stderr that keeps the text
class StderrCapture implements Stdout {
  final StringBuffer text = StringBuffer();

  @override
  void write(Object? object) => text.write(object);

  @override
  void writeln([Object? object = '']) => text.writeln(object);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// keeps the bytes of a socket and sees when it ends (a close or an error)
class SocketLog {
  SocketLog(Socket socket) {
    socket.listen(bytes.addAll, onError: _end, onDone: _end);
  }

  final List<int> bytes = <int>[];
  final Completer<void> _ended = Completer<void>();

  void _end([Object? error]) {
    if (!_ended.isCompleted) _ended.complete();
  }

  /// true when the socket ended within [limit]
  Future<bool> closed(Duration limit) async {
    try {
      await _ended.future.timeout(limit);
      return true;
    } on TimeoutException {
      return false;
    }
  }
}

/// a cache clock the test moves by hand
class MovingCacheClock extends CacheClock {
  MovingCacheClock(this.time);

  DateTime time;

  @override
  DateTime now() => time;

  @override
  int nowMs() => time.millisecondsSinceEpoch;
}

/// a schedule clock that only moves when the scheduler sleeps
class SleepClock extends ScheduleClock {
  SleepClock(this.time);

  DateTime time;

  @override
  DateTime now() => time;

  @override
  Future<void> sleep(Duration duration) async {
    time = time.add(duration);
    await Future<void>.delayed(Duration.zero);
  }
}
