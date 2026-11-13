import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dox_cache_database/dox_cache_database.dart';
import 'package:dox_core/dox_core.dart';
import 'package:dox_orm/dox_orm.dart' show QueryBuilder;
import 'package:dox_queue/dox_queue.dart';
import 'package:dox_socketio/dox_socketio.dart';
import 'package:dox_test/app/jobs/record_step.job.dart';
import 'package:dox_test/app/models/tag/tag.model.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'e2e_310_core.dart' show PortApi, registerUser;
import 'e2e_test.dart' show Api, SioClient;
import 'jobs_e2e.dart' show JobsHelper;

/// 3.2 checks of the packages: queue batches and chains (dox_queue,
/// dox_queue_database), the database cache store (dox_cache_database),
/// Socket.IO broadcasting (dox_socketio) and `Dox().isWebServer`
/// (dox_core). e2e_test.dart calls it, so it shares the server and the
/// database of that file.
void packages32Tests(Api api) {
  JobsHelper jobs = JobsHelper(api);

  /// the RecordStep tags of [run], in the order they were saved
  Future<List<String>> steps(String run) async {
    List<Tag> tags = await Tag()
        .where('name', 'like', '$run-%')
        .orderBy('id')
        .get();
    return <String>[for (Tag tag in tags) tag.name!];
  }

  group('3.2 dox_queue: chains', () {
    test('a chain runs its jobs one after the other', () async {
      String run = 'chain${jobs.stamp()}';
      await Queue.chain(<DoxJob>[
        RecordStep(step: '$run-1'),
        RecordStep(step: '$run-2'),
        RecordStep(step: '$run-3'),
      ]).dispatch();
      // only the first job is on the queue, the rest is in its payload
      expect(await steps(run), isEmpty);

      await jobs.work();

      expect(await steps(run), <String>['$run-1', '$run-2', '$run-3']);
    });

    test('a failed job drops the rest and runs the catch job', () async {
      String run = 'chainfail${jobs.stamp()}';
      await Queue.chain(<DoxJob>[
        RecordStep(step: '$run-1'),
        RecordStep(step: '$run-2', fail: true),
        RecordStep(step: '$run-3'),
      ]).catchError(RecordStep(step: '$run-catch')).dispatch();

      await jobs.work();

      expect(await steps(run), <String>['$run-1', '$run-catch:caught']);
      await _forgetFailed(run);
    });
  });

  group('3.2 dox_queue: batches', () {
    test('a batch counts its jobs and runs then + whenComplete', () async {
      String run = 'batch${jobs.stamp()}';
      Batch batch =
          await Queue.batch(<DoxJob>[
                RecordStep(step: '$run-a'),
                RecordStep(step: '$run-b'),
              ])
              .chain(<DoxJob>[
                RecordStep(step: '$run-c1'),
                RecordStep(step: '$run-c2'),
              ])
              .name('e2e32')
              .then(RecordStep(step: '$run-then'))
              .whenComplete(RecordStep(step: '$run-finally'))
              .dispatch();
      // the chain counts as one job
      expect(batch.name, 'e2e32');
      expect(batch.totalJobs, 3);
      expect(batch.pendingJobs, 3);
      expect(batch.finished, false);

      await jobs.work();

      Batch done = (await Queue.findBatch(batch.id))!;
      expect(done.finished, true);
      expect(done.pendingJobs, 0);
      expect(done.failedJobs, 0);
      expect(done.progress, 100);
      expect(done.cancelled, false);
      List<String> ran = await steps(run);
      expect(
        ran,
        containsAll(<String>[
          '$run-a',
          '$run-b',
          '$run-c1',
          '$run-c2',
          '$run-then',
          '$run-finally',
        ]),
      );
      expect(ran.indexOf('$run-c1'), lessThan(ran.indexOf('$run-c2')));
      expect(ran.length, 6);
    });

    test('a failed job cancels the batch and runs the catch job', () async {
      String run = 'batchfail${jobs.stamp()}';
      Batch batch =
          await Queue.batch(<DoxJob>[
                RecordStep(step: '$run-ok'),
                RecordStep(step: '$run-bad', fail: true),
              ])
              .then(RecordStep(step: '$run-then'))
              .catchError(RecordStep(step: '$run-catch'))
              .dispatch();

      await jobs.work();

      Batch done = (await Queue.findBatch(batch.id))!;
      expect(done.failedJobs, 1);
      expect(done.cancelled, true);
      List<String> ran = await steps(run);
      expect(ran, contains('$run-catch:caught'));
      expect(ran, isNot(contains('$run-then')));
      await _forgetFailed(run);
    });
  });

  group('3.2 dox_cache_database: the database store', () {
    // put, get, remember, increment, tags and locks run on this store
    // too: it is in AppConstants.cacheStores.
    CacheStore store() => Dox().cache.store('database');

    test('a value is a row of the cache table', () async {
      String key = 'e2e32:${jobs.stamp()}';
      await store().put(key, <String, dynamic>{'a': 1});
      List<Map<String, dynamic>> rows = await QueryBuilder.table('cache')
          .where('key', 'like', '%$key')
          .get();
      expect(rows, hasLength(1));
      expect(rows.first['expires_at'], isNull);
      expect(await store().get(key), <String, dynamic>{'a': 1});
      await store().forget(key);
      expect(
        await QueryBuilder.table('cache').where('key', 'like', '%$key').count(),
        0,
      );
    });

    test('an expired row reads as a miss, prune() deletes it', () async {
      String key = 'e2e32:old:${jobs.stamp()}';
      await store().put(key, 'x', Duration(milliseconds: 30));
      await Future<void>.delayed(Duration(milliseconds: 100));
      expect(await store().get(key), isNull);
      expect(
        await QueryBuilder.table('cache').where('key', 'like', '%$key').count(),
        1,
      );
      DatabaseCacheDriver driver = store().driver as DatabaseCacheDriver;
      expect(await driver.prune(), greaterThanOrEqualTo(1));
      expect(
        await QueryBuilder.table('cache').where('key', 'like', '%$key').count(),
        0,
      );
    });
  });

  group('3.2 dox_socketio: broadcasting', () {
    String email = 'e2e32broadcast@mail.com';
    int userId = 0;
    late SioClient client;

    setUpAll(() async {
      await registerUser(api, 'Broadcast', email);
      http.Response res = await api.post('/api/auth/login', <String, dynamic>{
        'email': email,
        'password': 'secret123',
      });
      expect(res.statusCode, 200, reason: res.body);
      api.tokens['e2e32'] = api.json(res)['token'];
      userId = api.json(await api.get('/api/auth/me', token: 'e2e32'))['id'];
      // broadcasting listens on the `/` namespace
      client = await SioClient.connect(api.sioUri, nsp: '/');
    });

    tearDownAll(() async {
      await client.close();
    });

    Future<http.Response> auth(String channel, {String? token}) {
      return api.post('/broadcasting/auth', <String, dynamic>{
        'socket_id': client.sid,
        'channel_name': channel,
      }, token: token);
    }

    test('POST /broadcasting/auth allows the own private channel', () async {
      http.Response res = await auth('private-users.$userId', token: 'e2e32');
      expect(res.statusCode, 200, reason: res.body);
      expect(api.json(res)['auth'], isA<String>());
    });

    test('POST /broadcasting/auth refuses another user or a guest', () async {
      http.Response other = await auth(
        'private-users.${userId + 1000}',
        token: 'e2e32',
      );
      expect(other.statusCode, 403, reason: other.body);
      http.Response guest = await auth('private-users.$userId');
      expect(guest.statusCode, 401, reason: guest.body);
    });

    test('a subscribed client gets a broadcast event', () async {
      String channel = 'private-users.$userId';
      http.Response res = await auth(channel, token: 'e2e32');
      Object? ack = await client.emitWithAck('subscribe', <String, dynamic>{
        'channel': channel,
        'auth': api.json(res)['auth'],
      });
      expect(ack, <String, dynamic>{'ok': true});

      // with no token, a private channel is refused
      SioClient outsider = await SioClient.connect(api.sioUri, nsp: '/');
      Object? refused = await outsider.emitWithAck(
        'subscribe',
        <String, dynamic>{'channel': channel},
      );
      expect((refused as Map<String, dynamic>)['ok'], false);

      await broadcast(UserPinged(userId));

      List<dynamic> args = await client.nextArgs('user.pinged');
      expect(args, <dynamic>[
        channel,
        <String, dynamic>{'id': userId, 'text': 'hi'},
      ]);
      expect(await outsider.nothing('user.pinged'), true);
      await outsider.close();
    });
  });

  group('3.2 dox_core: Dox().isWebServer', () {
    const String warning = 'Socket.IO does not check the Origin header';

    test('it is true in the web server', () {
      expect(Dox().isWebServer, true);
    });

    test('bin/queue.dart does not print the open origin warning', () async {
      ProcessResult r = await Process.run(
        'dart',
        <String>['run', 'bin/queue.dart', 'failed'],
        environment: <String, String>{'SOCKETIO_OPEN_ORIGIN': 'true'},
      ).timeout(Duration(minutes: 3));
      String out = '${r.stdout}${r.stderr}';
      expect(r.exitCode, 0, reason: out);
      expect(out, isNot(contains(warning)));
    });

    // the check above means something only when the server prints it
    test('the web server prints it', () async {
      ServerSocket free = await ServerSocket.bind('127.0.0.1', 0);
      int port = free.port;
      await free.close();
      Process p = await Process.start(
        'dart',
        // e2e_isolates.dart is the server of bin/server.dart. An earlier
        // check runs it, so `dart run` does not compile it again.
        <String>['run', 'bin/e2e_isolates.dart'],
        environment: <String, String>{
          'APP_PORT': '$port',
          'APP_URL': 'http://127.0.0.1:$port',
          'APP_TOTAL_ISOLATE': '1',
          'SOCKETIO_OPEN_ORIGIN': 'true',
        },
      );
      StringBuffer log = StringBuffer();
      p.stdout.transform(utf8.decoder).listen(log.write);
      p.stderr.transform(utf8.decoder).listen(log.write);
      try {
        Api child = PortApi(port);
        bool up = false;
        for (int i = 0; i < 1500 && !up; i++) {
          try {
            up = (await child.get('/ping')).statusCode == 200;
          } on Exception {
            await Future<void>.delayed(Duration(milliseconds: 100));
          }
        }
        expect(up, true, reason: '$log');
        expect('$log', contains(warning));
      } finally {
        p.kill();
        await p.exitCode.timeout(
          Duration(seconds: 10),
          onTimeout: () {
            p.kill(ProcessSignal.sigkill);
            return -1;
          },
        );
      }
    }, timeout: Timeout(Duration(minutes: 4)));
  });
}

/// Remove the failed_jobs rows of [run], so later checks start clean.
Future<void> _forgetFailed(String run) async {
  await QueryBuilder.table('failed_jobs')
      .where('payload', 'like', '%$run%')
      .delete();
}

/// A broadcast event to the private channel of one user.
class UserPinged with ShouldBroadcast {
  UserPinged(this.userId);

  final int userId;

  @override
  List<Channel> broadcastOn() {
    return <Channel>[PrivateChannel('users.$userId')];
  }

  @override
  String broadcastAs() => 'user.pinged';

  @override
  Map<String, Object?> broadcastWith() {
    return <String, Object?>{'id': userId, 'text': 'hi'};
  }
}
