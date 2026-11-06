import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dox_auth/dox_auth.dart';
import 'package:dox_core/dox_core.dart' show Hash;
import 'package:dox_mailer/dox_mailer.dart';
import 'package:dox_openapi/dox_openapi.dart';
import 'package:dox_orm/dox_orm.dart';
import 'package:dox_queue/dox_queue.dart';
import 'package:dox_storage/dox_storage.dart';
import 'package:dox_test/app/jobs/welcome_user.job.dart';
import 'package:dox_test/app/models/badge/badge.model.dart';
import 'package:dox_test/app/models/user/user.model.dart';
import 'package:dox_test/config/env.dart';
import 'package:dox_test/constants/app_constants.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'e2e_test.dart' show Api;
import 'jobs_e2e.dart' show startScheduleWorker;

/// The second e2e round for 3.1.0: features with no check in the first
/// round. They run last, on the same server and database.
void round2Tests(Api api) {
  group('3.1 round 2: ORM fixes', () {
    List<String> names = <String>['R2 no code', 'R2 code', 'R2 gone'];
    Map<String, int> ids = <String, int>{};

    setUpAll(() async {
      await Badge().withTrash().whereIn('name', names).forceDelete();
      for (String name in names) {
        Badge badge = await Badge().create(<String, dynamic>{
          'name': name,
          'code': name == 'R2 code' ? 'R2' : null,
          'score': 1,
        });
        ids[name] = badge.id as int;
      }
    });

    tearDownAll(() async {
      await Badge().withTrash().whereIn('name', names).forceDelete();
    });

    test('find(column, null) finds the row where the column is null', () async {
      Badge? badge = await Badge()
          .where('name', 'R2 no code')
          .find('code', null);
      expect(badge?.name, 'R2 no code');
      expect(badge?.code, isNull);
      await expectLater(
        Future<dynamic>.sync(() => Badge().find(5, null)),
        throwsArgumentError,
      );
    });

    test('having with null gives IS NULL and IS NOT NULL', () async {
      List<Map<String, dynamic>> notNull = await QueryBuilder.table('badges')
          .select('code')
          .whereIn('name', names)
          .groupBy('code')
          .having('code', '!=', null)
          .get();
      expect(notNull.map((Map<String, dynamic> r) => r['code']), <String>[
        'R2',
      ]);

      List<Map<String, dynamic>> nullRows = await QueryBuilder.table('badges')
          .select('code')
          .whereIn('name', names)
          .groupBy('code')
          .having('code', '=', null)
          .get();
      expect(nullRows, hasLength(1));
      expect(nullRows.single['code'], isNull);
    });

    test('limit(-1) is ignored', () async {
      // SQLite reads LIMIT -1 as no limit, so a row count alone can not
      // tell. Check the SQL, and that an earlier limit is kept.
      expect(
        Badge().whereIn('name', names).limit(-1).toSql(),
        isNot(contains('LIMIT')),
      );
      List<Badge> all = await Badge().whereIn('name', names).limit(-1).get();
      expect(all, hasLength(3));
      List<Badge> two = await Badge()
          .whereIn('name', names)
          .limit(2)
          .limit(-1)
          .get();
      expect(two, hasLength(2));
    });

    test('a soft delete sets updated_at, the fields and the row', () async {
      DateTime old = DateTime.utc(2020);
      await QueryBuilder.table('badges')
          .where('id', ids['R2 gone'])
          .update(<String, dynamic>{'updated_at': old});
      Badge badge = (await Badge().find(ids['R2 gone']))!;
      await badge.delete();
      expect(badge.deletedAt, isNotNull);
      expect(badge.updatedAt!.isAfter(old), true);

      Map<String, dynamic> row = (await QueryBuilder.table(
        'badges',
      ).where('id', ids['R2 gone']).get()).single;
      expect(row['deleted_at'], isNotNull);
      expect(_time(row['updated_at']).isAfter(old), true);
    });

    test('restore() on a query changes only soft deleted rows', () async {
      // soft delete the row here, so this test does not need the one above
      await QueryBuilder.table('badges')
          .where('id', ids['R2 gone'])
          .update(<String, dynamic>{'deleted_at': DateTime.now().toUtc()});
      // a row that is not deleted: nothing to restore
      expect(
        await (Badge().where('id', ids['R2 code']) as Badge).restore(),
        false,
      );
      expect(
        await (Badge().withTrash().where('id', ids['R2 gone']) as Badge)
            .restore(),
        true,
      );
      Badge? back = await Badge().find(ids['R2 gone']);
      expect(back?.deletedAt, isNull);
      // no where(): it would restore every row, so it throws
      await expectLater(
        Future<dynamic>.sync(() => (Badge().withTrash() as Badge).restore()),
        throwsStateError,
      );
    });
  });

  group('3.1 round 2: dox_auth', () {
    int userId = 0;

    Future<String> login() async {
      http.Response res = await api.post('/api/auth/login', <String, dynamic>{
        'email': 'round2@mail.com',
        'password': 'secret123',
      });
      expect(res.statusCode, 200, reason: res.body);
      return api.json(res)['token'];
    }

    setUpAll(() async {
      http.Response res = await api.post(
        '/api/auth/register',
        <String, dynamic>{
          'name': 'Round Two',
          'email': 'round2@mail.com',
          'password': 'secret123',
          'password_confirmation': 'secret123',
        },
      );
      expect(res.statusCode, 201, reason: res.body);
      userId = api.json(res)['id'];
    });

    test('Auth.hashCost and needsRehash read the bcrypt cost', () async {
      User user = (await User().find(userId))!;
      String hash = user.password!;
      expect(Auth.hashCost(hash), Hash.rounds);
      expect(Auth.needsRehash(hash), false);
      expect(Auth.needsRehash(hash, rounds: Hash.rounds + 2), true);
      expect(Auth.hashCost('plain text'), isNull);
      expect(Auth.needsRehash('plain text'), true);
    });

    test(
      'JwtAuthDriver(minimalPayload: true): only the id is in the token',
      () async {
        JwtAuthDriver small = JwtAuthDriver(
          secret: SecretKey(env.appKey),
          minimalPayload: true,
        );
        User user = (await User().find(userId))!;
        String token = small.createToken(user.toJson(), 'api')!;
        Map<String, dynamic> payload = _jwtPayload(token);
        expect(payload['sub'], userId);
        expect(payload.keys, isNot(contains('email')));
        expect(payload.keys, isNot(contains('name')));
        expect(payload['jti'], isNotNull);

        // the app guard (no minimalPayload) still reads the id from `sub`
        http.Response me = await api.get(
          '/api/auth/me',
          headers: <String, String>{'Authorization': 'Bearer $token'},
        );
        expect(me.statusCode, 200, reason: me.body);
        expect(api.json(me)['email'], 'round2@mail.com');
        User? found = await small.userFromToken(token, 'api') as User?;
        expect(found?.id, userId);

        // the default token still holds the user fields
        String full = (await login());
        expect(_jwtPayload(full)['email'], 'round2@mail.com');
      },
    );

    test('revokeAllTokens: old tokens stop, new ones work', () async {
      String before = await login();
      http.Response ok = await api.get(
        '/api/auth/me',
        headers: <String, String>{'Authorization': 'Bearer $before'},
      );
      expect(ok.statusCode, 200);

      // `iat` counts whole seconds. A token made in the same second as
      // revokeAllTokens() still works (a known limit), so wait a second.
      await Future<void>.delayed(Duration(milliseconds: 1100));
      await Auth(guard: 'api').revokeAllTokens(userId);
      http.Response gone = await api.get(
        '/api/auth/me',
        headers: <String, String>{'Authorization': 'Bearer $before'},
      );
      expect(gone.statusCode, 401);

      await Future<void>.delayed(Duration(milliseconds: 1100));
      String after = await login();
      http.Response again = await api.get(
        '/api/auth/me',
        headers: <String, String>{'Authorization': 'Bearer $after'},
      );
      expect(again.statusCode, 200, reason: again.body);
    });
  });

  group('3.1 round 2: dox_storage atomic writes', () {
    // made in the tests: Dox is not set up while the groups are read
    Disk atomic() => Storage().use('atomic');
    String root = '${AppConstants.storageRoot}/atomic';

    // a left over file of an old run would break the checks below
    void clean() {
      Directory dir = Directory(root);
      if (dir.existsSync()) dir.deleteSync(recursive: true);
    }

    setUpAll(clean);
    tearDownAll(clean);

    test('put() replaces a file and leaves no temp file', () async {
      Disk disk = atomic();
      await disk.put('notes/a.txt', 'one');
      await disk.put('notes/a.txt', 'two');
      expect(await disk.getString('notes/a.txt'), 'two');
      await disk.putStream(
        'notes/b.txt',
        Stream<List<int>>.fromIterable(<List<int>>[
          utf8.encode('stream '),
          utf8.encode('body'),
        ]),
      );
      expect(await disk.getString('notes/b.txt'), 'stream body');
      List<String> files = Directory('$root/notes')
          .listSync()
          .map((FileSystemEntity e) => e.uri.pathSegments.last)
          .toList();
      expect(files, unorderedEquals(<String>['a.txt', 'b.txt']));
    });

    test('listAll() hides a left over .dox-upload.tmp file', () async {
      File('$root/notes/c.txt.x.dox-upload.tmp').writeAsStringSync('part');
      ListResult list = await atomic().listAll('notes');
      expect(
        list.objects.map((DriveEntry e) => e.name),
        unorderedEquals(<String>['a.txt', 'b.txt']),
      );
    });
  });

  group('3.1 round 2: dox_openapi on its own', () {
    test('an optional param {id?} gives two paths', () {
      ApiDoc docs = ApiDoc();
      docs.route('GET', '/blog/{id?}', summary: 'one or all');
      Map<String, dynamic> paths = _paths(docs);
      expect(paths.keys, containsAll(<String>['/blog', '/blog/{id}']));
      expect(jsonEncode(paths['/blog']), isNot(contains('"in":"path"')));
      expect(jsonEncode(paths['/blog/{id}']), contains('"in":"path"'));
    });

    test('a route on the short path itself wins', () {
      ApiDoc docs = ApiDoc();
      docs.route('GET', '/blog', summary: 'list');
      docs.route('GET', '/blog/{id?}', summary: 'one or all');
      Map<String, dynamic> paths = _paths(docs);
      expect(paths['/blog']['get']['summary'], 'list');
      expect(paths['/blog/{id}']['get']['summary'], 'one or all');
    });

    test('namedResponses: default and 2XX next to int codes', () {
      ApiDoc docs = ApiDoc();
      docs.route(
        'GET',
        '/ping',
        responses: <int, ResponseDoc>{200: ResponseDoc(description: 'ok')},
        namedResponses: <String, ResponseDoc>{
          'default': ResponseDoc(description: 'an error'),
          '2XX': ResponseDoc(description: 'any success'),
        },
      );
      Map<String, dynamic> responses = _paths(
        docs,
      )['/ping']['get']['responses'];
      expect(
        responses.keys,
        unorderedEquals(<String>['200', 'default', '2XX']),
      );
      expect(responses['default']['description'], 'an error');
    });
  });

  group('3.1 round 2: Queue.fake and Mail.fake checks', () {
    tearDown(() {
      Queue.restore();
      Mail.restore();
    });

    test(
      'assertNotPushed, assertNothingPushed, jobsOf and the messages',
      () async {
        QueueFake queue = Queue.fake();
        queue.assertNothingPushed();
        queue.assertNotPushed<WelcomeUser>();
        expect(
          () => queue.assertPushed<WelcomeUser>(),
          throwsA(_assertion('Expected a WelcomeUser job to be pushed')),
        );

        await WelcomeUser(userId: 1).dispatch();
        await WelcomeUser(userId: 2).dispatch();
        expect(
          queue.jobsOf<WelcomeUser>().map((WelcomeUser j) => j.userId),
          <int>[1, 2],
        );
        expect(
          () => queue.assertPushedTimes<WelcomeUser>(1),
          throwsA(_assertion('pushed 1 time, but it was pushed 2 times')),
        );
        expect(
          () => queue.assertNotPushed<WelcomeUser>(),
          throwsA(_assertion('it was pushed 2 times')),
        );
        expect(queue.assertNothingPushed, throwsA(isA<AssertionError>()));
      },
    );

    test('assertSentCount names "1 sent email", not "emails"', () async {
      ArrayTransport mail = Mail.fake();
      expect(
        () => mail.assertSentCount(1),
        throwsA(
          isA<StateError>().having(
            (StateError e) => e.message,
            'message',
            contains('Expected 1 sent email,'),
          ),
        ),
      );
    });
  });

  group('3.1 round 2: dox_core routes', () {
    test('Route.fallback in a group with {tenant} in the prefix', () async {
      http.Response home = await api.get('/core/t/acme/home');
      expect(api.json(home), <String, dynamic>{
        'tenant': 'acme',
        'path': '/core/t/acme/home',
      });

      http.Response other = await api.get('/core/t/acme/no/such/page');
      expect(other.statusCode, 200, reason: other.body);
      expect(api.json(other), <String, dynamic>{
        'tenant': 'acme',
        'path': '/core/t/acme/no/such/page',
      });
    });

    test('MethodOverride: the 405 names the new method', () async {
      http.Response res = await api.send(
        'POST',
        '/core/match',
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: '_method=PUT',
      );
      expect(res.statusCode, 405);
      expect(res.body, contains('PUT is not allowed'));
    });

    test('a bad % code in the path is not a 500', () async {
      // a raw request: the http package would send %zz as %25zz
      String body = '{}';
      Socket socket = await Socket.connect(
        '127.0.0.1',
        Uri.parse(api.base).port,
      );
      socket.write(
        'POST /core/request/%zz HTTP/1.1\r\n'
        'Host: 127.0.0.1\r\n'
        'Content-Type: application/json\r\n'
        'Content-Length: ${body.length}\r\n'
        'Connection: close\r\n\r\n'
        '$body',
      );
      String answer = await utf8.decoder.bind(socket).join();
      socket.destroy();
      String status = answer.split('\r\n').first;
      expect(status, contains('200'), reason: answer);
      // the server reads a bad `%zz` as the text `%zz` (sent as %25zz)
      expect(answer, contains('"path":"/core/request/%25zz"'));
    });
  });

  group('3.1 round 2: the real bin/schedule.dart', () {
    test(
      'SIGTERM (docker stop) stops `schedule work` in a few seconds',
      () async {
        var (Process p, StringBuffer out) = await startScheduleWorker();
        p.kill(); // SIGTERM
        int code = await p.exitCode.timeout(
          Duration(seconds: 5),
          onTimeout: () {
            p.kill(ProcessSignal.sigkill);
            return -1;
          },
        );
        expect(code, 0, reason: out.toString());
      },
      timeout: Timeout(Duration(minutes: 2)),
    );
  });
}

/// An AssertionError whose message has [text].
Matcher _assertion(String text) {
  return isA<AssertionError>().having(
    (AssertionError e) => '${e.message}',
    'message',
    contains(text),
  );
}

/// The `paths` of an OpenAPI document made from [docs].
Map<String, dynamic> _paths(ApiDoc docs) {
  OpenApi doc = OpenApi(
    info: const Info(title: 'round 2', version: '1.0.0'),
    docs: docs,
  );
  return jsonDecode(jsonEncode(doc.toJson()))['paths'];
}

/// The payload of a JWT, not checked.
Map<String, dynamic> _jwtPayload(String token) {
  String part = token.split('.')[1];
  return jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(part))));
}

/// A time column as a DateTime: drivers give a DateTime or a text.
DateTime _time(dynamic value) {
  return value is DateTime ? value : DateTime.parse('$value');
}
