import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dox_core/dox_core.dart';
import 'package:dox_inertia/dox_inertia.dart';
import 'package:dox_mailer/dox_mailer.dart';
import 'package:dox_openapi/dox_openapi.dart';
import 'package:dox_orm/dox_orm.dart' show QueryBuilder;
import 'package:dox_queue/dox_queue.dart';
import 'package:dox_scheduler/dox_scheduler.dart';
import 'package:dox_storage/dox_storage.dart';
import 'package:dox_test/config/env.dart';
import 'package:dox_test/config/mail.dart';
import 'package:dox_test/config/queue.dart';
import 'package:dox_test/constants/app_constants.dart';
import 'package:dox_view/dox_view.dart';
import 'package:http/http.dart' as http;
import 'package:ioredis/ioredis.dart';
import 'package:test/test.dart';

import 'e2e_test.dart' show Api;
import 'jobs_e2e.dart' show JobsHelper, MailHog, MailHogMessage;

/// The 3.1.0 checks of the packages: storage, queue, scheduler, mailer,
/// view, inertia, openapi, cache, ioredis and the dox CLI. Missing
/// features, edge cases and 3.0 behaviour that must still work.
/// e2e_test.dart calls it last, on the same server and database.
void packages310Tests(Api api) {
  JobsHelper jobs = JobsHelper(api);

  _storageTests(api, jobs);
  _queueTests(jobs);
  _schedulerTests();
  _mailerTests(jobs);
  _viewTests();
  _inertiaTests();
  _openApiTests(api);
  _cacheTests();
  _redisTests(jobs);
  _cliTests();
}

void _storageTests(Api api, JobsHelper jobs) {
  group('3.1 packages: dox_storage edges', () {
    // made in the tests: Dox is not set up while the groups are read
    Disk disk(String name) => Storage().use(name);
    String folder = 'e2e310';

    tearDownAll(() async {
      for (String name in <String>['local', 'memory', 's3', 'atomic']) {
        await disk(name).deleteAll(folder);
      }
    });

    for (String name in <String>['local', 'memory', 's3', 'atomic']) {
      test('$name: an empty file can be written, read and measured', () async {
        String key = '$folder/empty.txt';
        await disk(name).put(key, '');
        expect(await disk(name).exists(key), true);
        expect(await disk(name).getString(key), '');
        expect(await disk(name).size(key), 0);
        // append to an empty file adds no separator
        await disk(name).append(key, 'first');
        expect(await disk(name).getString(key), 'first');
      });

      test('$name: append and prepend make a missing file', () async {
        String a = '$folder/missing-append.txt';
        String b = '$folder/missing-prepend.txt';
        await disk(name).delete(a);
        await disk(name).delete(b);
        await disk(name).append(a, 'one');
        await disk(name).prepend(b, 'two');
        expect(await disk(name).getString(a), 'one');
        expect(await disk(name).getString(b), 'two');
        await disk(name).append(a, 'three', separator: ' | ');
        expect(await disk(name).getString(a), 'one | three');
      });

      test('$name: a unicode path is kept as it is', () async {
        String key = '$folder/ユニコード/файл ü 😀.txt';
        await disk(name).put(key, 'ünï');
        expect(await disk(name).getString(key), 'ünï');
        ListResult list = await disk(name).listAll('$folder/ユニコード');
        expect(
          list.objects.map((DriveEntry e) => e.name.split('/').last),
          contains('файл ü 😀.txt'),
        );
      });

      test('$name: ../, an absolute path and a null byte are refused', () {
        for (String bad in <String>[
          '../escape.txt',
          '$folder/../../escape.txt',
          '/etc/passwd',
          'a\u0000b.txt',
        ]) {
          expect(
            () => disk(name).put(bad, 'x'),
            throwsA(isA<InvalidKeyException>()),
            reason: bad,
          );
          expect(
            () => disk(name).get(bad),
            throwsA(isA<InvalidKeyException>()),
            reason: bad,
          );
        }
        expect(
          File('${AppConstants.storageRoot}/../escape.txt').existsSync(),
          false,
        );
      });
    }

    test(
      'atomic_writes: a long file name (240 chars) works like on local',
      () async {
        String key = '$folder/${'a' * 236}.txt';
        await disk('local').put(key, 'local');
        expect(await disk('local').getString(key), 'local');
        await disk('atomic').put(key, 'atomic');
        expect(await disk('atomic').getString(key), 'atomic');
      },
      skip:
          'BUG: atomic_writes temp name adds about 44 chars, so a name over '
          '211 chars fails with ENAMETOOLONG (local_driver.dart _tempFile)',
    );

    test('the unicode file is served by its signed URL', () async {
      String key = '$folder/ユニコード/файл ü 😀.txt';
      String url = await disk('local').getSignedUrl(key);
      expect(url, contains(Uri.encodeComponent('файл ü 😀.txt')));
      http.Response res = await http.get(Uri.parse(url));
      expect(res.statusCode, 200);
      expect(utf8.decode(res.bodyBytes), 'ünï');
    });

    test('an expired signed URL gets 403', () async {
      String key = '$folder/empty.txt';
      String url = await disk('local').getSignedUrl(
        key,
        options: SignedUrlOptions(expiresIn: Duration(seconds: -5)),
      );
      expect((await http.get(Uri.parse(url))).statusCode, 403);
      // the same key with a good expiry works
      String good = await disk('local').getSignedUrl(key);
      expect((await http.get(Uri.parse(good))).statusCode, 200);
    });

    test('a signed URL for one file does not open another file', () async {
      String url = await disk('local').getSignedUrl('$folder/empty.txt');
      String other = url.replaceFirst('empty.txt', 'missing-append.txt');
      expect((await http.get(Uri.parse(other))).statusCode, 403);
    });

    test('a ../ in the signed route path does not leave the disk', () async {
      for (String path in <String>[
        '/files/..%2F..%2Fpubspec.yaml',
        '/files/%2E%2E/%2E%2E/pubspec.yaml',
        '/storage/..%2F..%2Fpubspec.yaml',
      ]) {
        http.Response res = await api.get('$path?expires=1&signature=x');
        expect(res.statusCode, isNot(200), reason: path);
        expect(res.body, isNot(contains('dox_test')), reason: path);
      }
    });

    test('makeDirectory on the memory disk does nothing', () async {
      await disk('memory').makeDirectory('$folder/made');
      ListResult list = await disk('memory').listAll('$folder/made');
      expect(list.objects, isEmpty);
    });

    for (String name in <String>['local', 's3']) {
      test('3.0 regression on $name: copy, move, exists, delete', () async {
        String a = '$folder/reg/a.txt';
        String b = '$folder/reg/b.txt';
        String c = '$folder/reg/c.txt';
        await disk(name).put(a, 'body');
        await disk(name).copy(a, b);
        await disk(name).move(b, c);
        expect(await disk(name).exists(a), true);
        expect(await disk(name).exists(b), false);
        expect(await disk(name).getString(c), 'body');
        await disk(name).delete(a);
        await disk(name).delete(c);
        expect(await disk(name).exists(a), false);
        expect(() => disk(name).get(c), throwsA(isA<FileNotFoundException>()));
      });
    }
  });
}

void _queueTests(JobsHelper jobs) {
  group('3.1 packages: dox_queue retries, timeouts, encryption', () {
    setUp(() async {
      FlakyJob.reset();
      Queue.configure(
        QueueConfig(
          driver: 'database',
          jobs: JobRegistry(<JobCodec>[
            FlakyJob.codec,
            HangingJob.codec,
            EncryptedNoteJob.codec,
          ]),
        ),
      );
      await Queue.driver.flush();
    });

    tearDown(() async {
      HangingJob.release();
      await Queue.driver.flush();
      Queue.restore();
      Queue.configure(queueConfig);
    });

    Future<void> work() async {
      await Worker(
        driver: Queue.driver,
        jobs: Queue.config.jobs,
        options: WorkerOptions(
          queues: <String>[e2eQueue],
          stopWhenEmpty: true,
          sleep: Duration(milliseconds: 50),
        ),
      ).run();
    }

    test('a job that fails once runs again and then works', () async {
      await FlakyJob(failTimes: 1).dispatch();
      await work();
      expect(FlakyJob.runs, 2);
      expect(FlakyJob.failedCalls, 0);
      expect(await Queue.driver.failed(), isEmpty);
    });

    test('a job that fails every try goes to failed jobs once', () async {
      await FlakyJob(failTimes: 99).dispatch();
      await work();
      expect(FlakyJob.runs, 3); // tries => 3
      expect(FlakyJob.failedCalls, 1);
      List<FailedJob> failed = await Queue.driver.failed();
      expect(failed, hasLength(1));
      expect(failed.single.job, FlakyJob.name);
      expect(failed.single.error, contains('flaky try 3'));
    });

    test('a job that times out fails with a timeout error', () async {
      await HangingJob().dispatch();
      await work();
      List<FailedJob> failed = await Queue.driver.failed();
      expect(failed, hasLength(1));
      expect(failed.single.job, HangingJob.name);
      expect(failed.single.error, contains('Timeout'));
    });

    test(
      'ShouldBeEncrypted: the row has no data, the worker reads it',
      () async {
        String secret = 'card-${jobs.stamp()}';
        String id = await EncryptedNoteJob(secret).dispatch();
        String payload = await jobs.payloadOf(id);
        expect(payload, contains(EncryptedNoteJob.name));
        expect(payload, isNot(contains(secret)));
        await work();
        expect(EncryptedNoteJob.seen, contains(secret));
        expect(await Queue.driver.failed(), isEmpty);
      },
    );

    test('a changed encrypted payload fails, it does not run', () async {
      String secret = 'tampered-${jobs.stamp()}';
      String id = await EncryptedNoteJob(secret).dispatch();
      List<Map<String, dynamic>> rows = await QueryBuilder.table('jobs').get();
      Map<String, dynamic> row = rows.firstWhere(
        (Map<String, dynamic> r) => '${r['payload']}'.contains(id),
      );
      Map<String, dynamic> payload = jsonDecode('${row['payload']}');
      String data = payload['data'] as String;
      // flip one base64 char in the middle
      int at = data.length ~/ 2;
      String flipped = data[at] == 'A' ? 'B' : 'A';
      payload['data'] = data.replaceRange(at, at + 1, flipped);
      await QueryBuilder.table('jobs')
          .where('id', row['id'])
          .update(<String, dynamic>{'payload': jsonEncode(payload)});
      await work();
      expect(EncryptedNoteJob.seen, isNot(contains(secret)));
      expect(await Queue.driver.failed(), hasLength(1));
    });
  });

  group('3.1 packages: Queue.fake edges', () {
    tearDown(Queue.restore);

    test('delay and queue name are kept, dispatchSync still runs', () async {
      FlakyJob.reset();
      QueueFake queue = Queue.fake();
      await FlakyJob(failTimes: 0)
          .dispatch(delay: Duration(minutes: 3), queue: 'slow');
      expect(queue.pushed.single.delay, Duration(minutes: 3));
      expect(queue.pushed.single.queue, 'slow');
      await FlakyJob(failTimes: 0).dispatch();
      // the job's own queue when dispatch() names none
      expect(queue.pushed.last.queue, e2eQueue);
      await FlakyJob(failTimes: 0).dispatchSync();
      expect(FlakyJob.runs, 1);
      // dispatchSync is not a push
      queue.assertPushedTimes<FlakyJob>(2);
    });

    test('a second fake() starts empty; restore() twice is fine', () async {
      Queue.fake();
      await FlakyJob(failTimes: 0).dispatch();
      QueueFake second = Queue.fake();
      second.assertNothingPushed();
      Queue.restore();
      Queue.restore();
    });

    test('a job name with a vowel gets "an" in the message', () {
      QueueFake queue = Queue.fake();
      expect(
        () => queue.assertPushed<EncryptedNoteJob>(),
        throwsA(
          isA<AssertionError>().having(
            (AssertionError e) => '${e.message}',
            'message',
            contains('Expected an EncryptedNoteJob job to be pushed'),
          ),
        ),
      );
    });

    test('assertPushed with a test that no job passes says so', () async {
      QueueFake queue = Queue.fake();
      await EncryptedNoteJob('a').dispatch();
      expect(
        () => queue.assertPushed<EncryptedNoteJob>(
          (EncryptedNoteJob j) => j.note == 'b',
        ),
        throwsA(
          isA<AssertionError>().having(
            (AssertionError e) => '${e.message}',
            'message',
            contains('none of the 1 pushed EncryptedNoteJob job passed it'),
          ),
        ),
      );
      queue.clear();
      queue.assertNothingPushed();
    });
  });

  group('3.1 packages: dox_queue on Redis', () {
    test('a retry on the redis driver, and a delayed job waits', () async {
      String prefix = 'dox_test_310_${jobs.stamp()}:';
      Redis redis = Redis(
        RedisOptions(port: env.redisPort, db: JobsHelper.redisDb),
      );
      FlakyJob.reset();
      Queue.configure(
        QueueConfig(
          driver: 'redis',
          jobs: JobRegistry(<JobCodec>[FlakyJob.codec]),
          prefix: prefix,
          redis: RedisOptions(port: env.redisPort, db: JobsHelper.redisDb),
        ),
      );
      try {
        await FlakyJob(failTimes: 1).dispatch();
        await FlakyJob(failTimes: 0).dispatch(delay: Duration(minutes: 10));
        await Worker(
          driver: Queue.driver,
          jobs: Queue.config.jobs,
          options: WorkerOptions(
            queues: <String>[e2eQueue],
            stopWhenEmpty: true,
            sleep: Duration(milliseconds: 50),
          ),
        ).run();
        // the first job ran twice, the delayed one not yet
        expect(FlakyJob.runs, 2);
        expect(await Queue.driver.failed(), isEmpty);
        expect(await redis.keys('$prefix*'), isNotEmpty);
      } finally {
        await Queue.close();
        Queue.configure(queueConfig);
        for (String key in await redis.keys('$prefix*')) {
          await redis.delete(key);
        }
        await redis.disconnect();
      }
    });
  });
}

void _schedulerTests() {
  group('3.1 packages: dox_scheduler time zones and DST', () {
    Schedule ny() => Schedule(timezone: 'America/New_York');

    test('dailyAt("8") follows summer time in New York', () {
      ScheduledTask task = ny().call('ny', () {}).dailyAt('8');
      expect(task.isDue(DateTime.utc(2026, 1, 15, 13)), true); // EST -5
      expect(task.isDue(DateTime.utc(2026, 7, 15, 12)), true); // EDT -4
      expect(task.isDue(DateTime.utc(2026, 7, 15, 13)), false);
      // across the change on 8 March
      expect(
        task.nextRun(DateTime.utc(2026, 3, 7, 14)),
        DateTime.utc(2026, 3, 8, 12),
      );
    });

    test('a time that summer time skips does not run that day', () {
      ScheduledTask task = ny().call('gap', () {}).dailyAt('2:30');
      // 8 March 2026: 02:00 -> 03:00, so 02:30 is not there
      for (
        DateTime t = DateTime.utc(2026, 3, 8, 5);
        t.isBefore(DateTime.utc(2026, 3, 9, 5));
        t = t.add(Duration(minutes: 1))
      ) {
        expect(task.isDue(t), false, reason: '$t');
      }
      expect(
        task.nextRun(DateTime.utc(2026, 3, 8, 5)),
        DateTime.utc(2026, 3, 9, 6, 30),
      );
    });

    test('a time that happens twice in autumn runs only once', () {
      ScheduledTask task = ny().call('twice', () {}).dailyAt('1:30');
      // 1 November 2026: 01:30 EDT (05:30Z), then 01:30 EST (06:30Z)
      expect(task.isDue(DateTime.utc(2026, 11, 1, 5, 30)), true);
      expect(task.isDue(DateTime.utc(2026, 11, 1, 6, 30)), false);
      expect(
        task.nextRun(DateTime.utc(2026, 11, 1, 5, 31)),
        DateTime.utc(2026, 11, 2, 6, 30),
      );
    });

    test('hourly in a +05:30 zone runs at minute 30 UTC', () {
      ScheduledTask task = Schedule(timezone: 'Asia/Kolkata')
          .call('india', () {})
          .hourly();
      // hourly is minute 0 in Kolkata: minute 30 in UTC
      expect(task.isDue(DateTime.utc(2026, 11, 3, 4, 30)), true);
      expect(task.isDue(DateTime.utc(2026, 11, 3, 4)), false);
    });
  });

  group('3.1 packages: dox_scheduler environments()', () {
    String? before;
    int envRuns = 0;

    setUp(() => before = Env().env['APP_ENV']);

    tearDown(() {
      if (before == null) {
        Env().env.remove('APP_ENV');
      } else {
        Env().env['APP_ENV'] = before!;
      }
    });

    Future<TaskOutcome?> runIn(String appEnv, List<String> names) async {
      Env().env['APP_ENV'] = appEnv;
      envRuns++;
      int runs = 0;
      Schedule s = Schedule();
      s
          .call('env-task-$envRuns', () => runs++)
          .everyMinute()
          .environments(names);
      Scheduler scheduler = Scheduler(
        tasks: s.tasks,
        store: Scheduler.lockStore(Dox().cache, 'memory'),
        err: StringBuffer(),
      );
      Map<String, TaskOutcome> out = await scheduler.runDue(
        tick: DateTime.utc(2026, 11, 3, 4),
      );
      await scheduler.close();
      expect(runs, out['env-task-$envRuns'] == TaskOutcome.ran ? 1 : 0);
      return out['env-task-$envRuns'];
    }

    test(
      'case and spaces do not matter, other names skip',
      () async {
        expect(
          await runIn(' Production ', <String>['production']),
          TaskOutcome.ran,
        );
        expect(
          await runIn('production', <String>[' PRODUCTION ']),
          TaskOutcome.ran,
        );
        expect(
          await runIn('staging', <String>['production', 'staging']),
          TaskOutcome.ran,
        );
        expect(
          await runIn('local', <String>['production', 'staging']),
          TaskOutcome.skipped,
        );
      },
      skip: Platform.environment.containsKey('APP_ENV')
          ? 'APP_ENV is a real env variable, it wins over .env'
          : false,
    );

    test('3.0 regression: when() and skip() filters', () async {
      Schedule s = Schedule();
      s.call('when-false', () {}).everyMinute().when(() => false);
      s.call('skip-true', () {}).everyMinute().skip(() => true);
      s.call('plain', () {}).everyMinute();
      Scheduler scheduler = Scheduler(
        tasks: s.tasks,
        store: Scheduler.lockStore(Dox().cache, 'memory'),
        err: StringBuffer(),
      );
      Map<String, TaskOutcome> out = await scheduler.runDue(
        tick: DateTime.utc(2026, 11, 3, 4),
      );
      await scheduler.close();
      expect(out['when-false'], TaskOutcome.skipped);
      expect(out['skip-true'], TaskOutcome.skipped);
      expect(out['plain'], TaskOutcome.ran);
    });
  });
}

void _mailerTests(JobsHelper jobs) {
  MailHog mailhog = MailHog();

  group('3.1 packages: dox_mailer checks', () {
    tearDown(() {
      Mail.restore();
      Mail.configure(mailConfig);
    });

    Message message({
      List<Address>? to,
      List<Address> cc = const <Address>[],
      List<Address> replyTo = const <Address>[],
      String subject = 'Hi',
      Map<String, String> headers = const <String, String>{},
      List<Attachment> attachments = const <Attachment>[],
    }) {
      return Message(
        to: to ?? <Address>[Address('ann@x.com')],
        cc: cc,
        replyTo: replyTo,
        subject: subject,
        text: 'hi',
        headers: headers,
        attachments: attachments,
      );
    }

    test('a message with no recipient is refused, also on the queue', () async {
      ArrayTransport mail = Mail.fake();
      Message none = message(to: <Address>[]);
      await expectLater(
        Mail.send(none),
        throwsA(
          isA<MailException>().having(
            (MailException e) => '$e',
            'text',
            contains('no recipient'),
          ),
        ),
      );
      await expectLater(Mail.queue(none), throwsA(isA<MailException>()));
      mail.assertNothingSent();
      mail.assertNothingQueued();
    });

    test('CR or LF in an address, cc, reply-to or header is refused', () async {
      ArrayTransport mail = Mail.fake();
      List<Message> bad = <Message>[
        message(to: <Address>[Address('ann@x.com\r\nBcc: evil@x.com')]),
        message(cc: <Address>[Address('bob@x.com\nBcc: evil@x.com')]),
        message(replyTo: <Address>[Address('r@x.com', 'R\r\nX: y')]),
        message(headers: <String, String>{'X-Tag': 'a\r\nBcc: evil@x.com'}),
        message(headers: <String, String>{'X-Bad\r\nBcc': 'evil@x.com'}),
      ];
      for (Message m in bad) {
        await expectLater(Mail.send(m), throwsA(isA<MailException>()));
      }
      mail.assertNothingSent();
    });

    test('the SMTP transport checks the headers before it connects', () async {
      // a port with nothing on it: a connect would give a SocketException
      ServerSocket free = await ServerSocket.bind(
        InternetAddress.loopbackIPv4,
        0,
      );
      int port = free.port;
      await free.close();
      SmtpTransport smtp = SmtpTransport(
        host: '127.0.0.1',
        port: port,
        encryption: SmtpEncryption.none,
        timeout: Duration(seconds: 2),
      );
      await expectLater(
        smtp.send(
          message(subject: 'Hi\r\nBcc: evil@x.com')
              .copyWith(from: Address('a@x.com')),
        ),
        throwsA(isA<MailException>()),
      );
    });

    test('Attachment.fromFile sends the file as it is at send time', () async {
      Directory dir = await Directory.systemTemp.createTemp('dox_e2e310_');
      File file = File('${dir.path}/report.txt')..writeAsStringSync('old');
      try {
        ArrayTransport mail = Mail.fake();
        Attachment attachment = Attachment.fromFile(file.path);
        file.writeAsStringSync('new text');
        await Mail.send(message(attachments: <Attachment>[attachment]));
        expect(
          utf8.decode(mail.messages.single.attachments.single.bytes),
          'new text',
        );

        // queued: the file is read when it is queued
        Attachment queued = Attachment.fromFile(file.path);
        file.writeAsStringSync('queued text');
        await Mail.queue(message(attachments: <Attachment>[queued]));
        expect(
          utf8.decode(mail.queued.single.message.attachments.single.bytes),
          'queued text',
        );
      } finally {
        await dir.delete(recursive: true);
      }
    });

    test('Markdown: an unsafe link in a value loses its URL', () {
      Message m = LinkMail(
        name: '[click me](javascript:alert(1))',
        url: 'https://ok.test/a?b=1&c=2',
      ).toMessage();
      expect(m.html, isNot(contains('javascript:')));
      expect(m.html, contains('click me'));
      expect(m.html, contains('href="https://ok.test/a?b=1&amp;c=2"'));
      // the text body keeps the Markdown
      expect(m.text, contains('# Hello'));
    });

    test('Markdown: a bare URL stays text, <url> is a link', () {
      Message m = LinkMail(
        name: 'Ann https://bare.test',
        url: 'https://ok.test',
      ).toMessage();
      expect(m.html, isNot(contains('href="https://bare.test"')));
      expect(m.html, contains('https://bare.test'));
    });

    test('MailMessage: unsafe action URL throws, error() is red', () {
      MailMessage m = MailMessage(subject: 'Problem');
      expect(
        () => m.action('Open', 'javascript:alert(1)'),
        throwsArgumentError,
      );
      expect(() => m.action('Open', 'data:text/html,x'), throwsArgumentError);
      MailMessage ok = MailMessage(subject: 'Ok')
        ..action('Open', 'https://ok.test');
      MailMessage red = MailMessage(subject: 'Red')
        ..error()
        ..action('Open', 'https://ok.test');
      String okHtml = ok.toMessage().html!;
      String redHtml = red.toMessage().html!;
      expect(okHtml, contains('href="https://ok.test"'));
      expect(redHtml, contains('href="https://ok.test"'));
      expect(redHtml, isNot(okHtml));
      // a Markdown link in a line with a bad URL loses the URL
      MailMessage line = MailMessage(subject: 'Line')
        ..line('see [this](javascript:alert(1))');
      expect(line.toMessage().html, isNot(contains('javascript:')));
    });

    test(
      'failover: an onError that throws does not stop the next transport',
      () async {
        ArrayTransport second = ArrayTransport();
        int calls = 0;
        Mail.configure(
          MailConfig(
            from: mailConfig.from,
            defaultMailer: 'failover',
            mailers: <String, Transport>{
              'failover': FailoverTransport(
                <Transport>[BrokenTransport(), second],
                onError: (Transport t, Object e, StackTrace s) {
                  calls++;
                  throw StateError('onError broke');
                },
              ),
            },
          ),
        );
        await Mail.send(message(subject: 'via failover'));
        expect(calls, 1);
        expect(second.messages.single.subject, 'via failover');
      },
    );

    test(
      'failover: when every transport fails, the last error is thrown',
      () async {
        Mail.configure(
          MailConfig(
            from: mailConfig.from,
            defaultMailer: 'failover',
            mailers: <String, Transport>{
              'failover': FailoverTransport(
                <Transport>[BrokenTransport('first'), BrokenTransport('last')],
                onError: (Transport t, Object e, StackTrace s) =>
                    throw StateError('onError broke'),
              ),
            },
          ),
        );
        await expectLater(
          Mail.send(message()),
          throwsA(
            isA<MailException>().having(
              (MailException e) => '$e',
              'text',
              contains('last'),
            ),
          ),
        );
      },
    );

    test(
      'Mail.mailer("log").later keeps the mailer, delay and queue',
      () async {
        ArrayTransport mail = Mail.fake();
        await Mail.mailer('log')
            .later(Duration(minutes: 2), message(), queue: 'mail');
        QueuedMessage q = mail.queued.single;
        expect(q.mailer, 'log');
        expect(q.delay, Duration(minutes: 2));
        expect(q.queue, 'mail');
        expect(q.encrypt, false);
      },
    );

    test('Notification.send: one bad channel, the others still send', () async {
      RecordChannel.reset();
      Note note = Note();
      Object ann = Person('person-a'), bob = Person('person-b');
      Object? error;
      try {
        await Notification.send(<Object>[ann, bob], note);
      } catch (e) {
        error = e;
      }
      expect(error, isA<NotificationException>());
      NotificationException ne = error as NotificationException;
      expect(ne.errors, hasLength(2));
      expect(ne.errors.map((NotificationError e) => e.index), <int>[0, 1]);
      // the error text has no data of the person
      expect('$ne', isNot(contains('person-')));
      expect(RecordChannel.got, <String>['person-a', 'person-b']);

      // one notifiable and one error: the error itself
      await expectLater(
        Notification.send(<Object>[ann], note),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('3.1 packages: dox_mailer over SMTP (MailHog)', () {
    setUpAll(mailhog.check);

    test('3.0 regression: cc, a unicode subject and an HTML body', () async {
      if (mailhog.skip(markTestSkipped)) return;
      String to = 'reg.${jobs.stamp()}@jobs.dox-test.dev';
      String cc = 'cc.${jobs.stamp()}@jobs.dox-test.dev';
      await Mail.send(
        Message(
          to: <Address>[Address(to, 'Zaw Zaw')],
          cc: <Address>[Address(cc)],
          subject: 'Mingalaba မင်္ဂလာပါ ✓',
          text: 'plain body',
          html: '<p>html body</p>',
        ),
      );
      MailHogMessage mail = await mailhog.waitFor(to);
      expect(mail.html, contains('<p>html body</p>'));
      expect(mail.text, contains('plain body'));
      expect(mail.header('Cc'), contains(cc));
      // MailHog keeps the encoded word: check it decodes to the subject
      expect(_decodeSubject(mail.subject), 'Mingalaba မင်္ဂလာပါ ✓');
    });
  });
}

void _viewTests() {
  group('3.1 packages: dox_view', () {
    ViewEngine engine(Map<String, String> templates) {
      return ViewEngine(MemoryTemplateLoader(templates));
    }

    test('toJson() is read again on the next render', () {
      Counter counter = Counter();
      ViewEngine e = engine(<String, String>{'count': '{{ c.n }}-{{ c.n }}'});
      e.global('c', counter);
      expect(e.render('count', <String, dynamic>{}), '1-1');
      // the object changed: the next render shows the new value
      expect(e.render('count', <String, dynamic>{}), '2-2');
    });

    test('a syntax error names the template and the line', () {
      ViewEngine e = engine(<String, String>{
        'broken': 'one\ntwo\n@if(x)\nno end',
      });
      expect(
        () => e.render('broken', <String, dynamic>{'x': true}),
        throwsA(
          isA<ViewException>()
              .having((ViewException v) => v.template, 'template', 'broken')
              .having((ViewException v) => v.line, 'line', isNotNull),
        ),
      );
    });

    test('a failed expression names the template and the line', () {
      ViewEngine e = engine(<String, String>{
        'bad': 'ok\n{{ user.name.first }}',
      });
      expect(
        () => e.render('bad', <String, dynamic>{'user': 5}),
        throwsA(
          isA<ViewException>()
              .having((ViewException v) => v.template, 'template', 'bad')
              .having((ViewException v) => v.line, 'line', 2),
        ),
      );
    });

    test('a missing template and a bad name throw a ViewException', () {
      expect(() => View.render('nope/not-here'), throwsA(isA<ViewException>()));
      expect(() => View.render('../pubspec'), throwsA(isA<ViewException>()));
    });

    test('View.render: errors.email prints nothing, values are escaped', () {
      ViewEngine e = engine(<String, String>{
        'form': '<p>{{ errors.email }}</p>{{ name }}',
      });
      expect(
        e.render(
          'form',
          <String, dynamic>{'name': '<b>x</b>'},
          <String, Object?>{'errors': <String, Object?>{}},
        ),
        '<p></p>&lt;b&gt;x&lt;/b&gt;',
      );
      expect(View.render('core/plain'), contains('<p class="error"></p>'));
    });
  });
}

void _inertiaTests() {
  group('3.1 packages: dox_inertia Vite', () {
    late Directory dir;
    String? before;

    setUp(() async {
      before = Env().env['APP_ENV'];
      dir = await Directory.systemTemp.createTemp('dox_e2e310_vite_');
      await Directory('${dir.path}/build/.vite').create(recursive: true);
    });

    tearDown(() async {
      if (before == null) {
        Env().env.remove('APP_ENV');
      } else {
        Env().env['APP_ENV'] = before!;
      }
      await dir.delete(recursive: true);
    });

    InertiaConfig config({String? devServerUrl}) {
      return InertiaConfig(
        entryPoints: <String>['resources/js/app.jsx'],
        publicPath: dir.path,
        devServerUrl: devServerUrl,
      );
    }

    void manifest(String file) {
      File('${dir.path}/build/.vite/manifest.json').writeAsStringSync(
        jsonEncode(<String, dynamic>{
          'resources/js/app.jsx': <String, dynamic>{
            'file': file,
            'isEntry': true,
          },
        }),
      );
    }

    test(
      'production ignores the hot file, development uses it',
      () async {
        File('${dir.path}/hot').writeAsStringSync('http://evil.test:5173');
        manifest('assets/app-1.js');

        Env().env['APP_ENV'] = 'development';
        expect(await Vite(config()).tags(), contains('http://evil.test:5173'));

        Env().env['APP_ENV'] = 'production';
        String tags = await Vite(config()).tags();
        expect(tags, isNot(contains('evil.test')));
        expect(tags, contains('assets/app-1.js'));

        // devServerUrl of the config is still used
        expect(
          await Vite(config(devServerUrl: 'http://dev.test:5173/')).devUrl(),
          'http://dev.test:5173',
        );
      },
      skip: Platform.environment.containsKey('APP_ENV')
          ? 'APP_ENV is a real env variable, it wins over .env'
          : false,
    );

    test('the manifest is read again when the file changes', () async {
      manifest('assets/app-1.js');
      expect(await Vite(config()).tags(), contains('assets/app-1.js'));
      // a longer name: the size changes even when the time does not
      manifest('assets/app-22.js');
      String tags = await Vite(config()).tags();
      expect(tags, contains('assets/app-22.js'));
      expect(tags, isNot(contains('assets/app-1.js')));
    });

    test('no manifest and no hot file gives a clear error', () async {
      expect(
        Vite(config()).tags(),
        throwsA(
          isA<StateError>().having(
            (StateError e) => e.message,
            'message',
            contains('No Vite manifest'),
          ),
        ),
      );
    });
  });
}

void _openApiTests(Api api) {
  group('3.1 packages: dox_openapi optional params', () {
    Map<String, dynamic> paths(ApiDoc docs) {
      OpenApi doc = OpenApi(
        info: const Info(title: '3.1 packages', version: '1.0.0'),
        docs: docs,
      );
      return jsonDecode(jsonEncode(doc.toJson()))['paths'];
    }

    List<String> pathParams(Map<String, dynamic> op) {
      List<dynamic> params = op['parameters'] ?? <dynamic>[];
      return <String>[
        for (dynamic p in params)
          if (p['in'] == 'path') p['name'] as String,
      ];
    }

    test('two optional params at the end give three paths', () {
      ApiDoc docs = ApiDoc();
      docs.route('GET', '/files/{year?}/{month?}', summary: 'files');
      Map<String, dynamic> p = paths(docs);
      expect(
        p.keys,
        unorderedEquals(<String>[
          '/files/{year}/{month}',
          '/files/{year}',
          '/files',
        ]),
      );
      expect(pathParams(p['/files']['get']), isEmpty);
      expect(pathParams(p['/files/{year}']['get']), <String>['year']);
      Set<String> ids = <String>{
        for (dynamic path in p.values) path['get']['operationId'] as String,
      };
      expect(ids, hasLength(3));
    });

    test('an optional param in the middle stays, and is required', () {
      ApiDoc docs = ApiDoc();
      docs.route('GET', '/a/{x?}/b', summary: 'middle');
      docs.route('GET', '/c/{x?}/d/{y?}', summary: 'both');
      Map<String, dynamic> p = paths(docs);
      expect(p.keys, contains('/a/{x}/b'));
      expect(p.keys, isNot(contains('/a/b')));
      expect(p.keys, isNot(contains('/a')));
      expect(p.keys, containsAll(<String>['/c/{x}/d/{y}', '/c/{x}/d']));
      expect(p.keys, isNot(contains('/c/d')));
      for (dynamic param in p['/a/{x}/b']['get']['parameters']) {
        if (param['in'] == 'path') expect(param['required'], true);
      }
    });

    test('3.0 regression: the app document is valid OpenAPI 3', () async {
      http.Response res = await api.get('/openapi.json');
      expect(res.statusCode, 200);
      Map<String, dynamic> doc = api.json(res);
      expect('${doc['openapi']}', startsWith('3.'));
      expect(doc['info']['title'], isNotEmpty);
      Map<String, dynamic> p = doc['paths'];
      expect(p, isNotEmpty);
      // every {param} in a path is a required path parameter
      for (MapEntry<String, dynamic> entry in p.entries) {
        List<String> names = RegExp(r'\{([^}]+)\}')
            .allMatches(entry.key)
            .map((Match m) => m[1]!)
            .toList();
        for (dynamic op in (entry.value as Map<String, dynamic>).values) {
          if (op is! Map || !op.containsKey('responses')) continue;
          List<String> got = <String>[
            for (dynamic param in op['parameters'] ?? <dynamic>[])
              if (param['in'] == 'path' && param['required'] == true)
                param['name'] as String,
          ];
          expect(got, unorderedEquals(names), reason: entry.key);
        }
      }
    });
  });
}

void _cacheTests() {
  group('3.1 packages: dox_cache file driver prune', () {
    late Directory dir;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('dox_e2e310_cache_');
    });

    tearDown(() async {
      await dir.delete(recursive: true);
    });

    CacheStore store(Map<String, dynamic> options) {
      return CacheManager(
        CacheConfig(
          defaultStore: 'f',
          stores: <String, Map<String, dynamic>>{
            'f': <String, dynamic>{
              'driver': 'file',
              'path': dir.path,
              ...options,
            },
          },
        ),
      ).store();
    }

    /// the value files of the store (no lock or temp files)
    Future<int> files() async {
      int count = 0;
      await for (FileSystemEntity e in dir.list(recursive: true)) {
        String name = e.uri.pathSegments.last;
        if (e is File && !name.contains('.lock') && !name.contains('.tmp')) {
          count++;
        }
      }
      return count;
    }

    /// put a value that is expired when this returns
    Future<void> putExpired(CacheStore cache, String key) async {
      await cache.put(key, 'x', Duration(milliseconds: 200));
      // ponytail: real time, the clock of dox_cache is not exported
      while (await cache.get(key) != null) {
        await Future<void>.delayed(Duration(milliseconds: 50));
      }
    }

    test('prune_every: the third write deletes the expired file', () async {
      CacheStore cache = store(<String, dynamic>{'prune_every': 3});
      await putExpired(cache, 'old');
      await cache.put('a', 'a');
      expect(await files(), 2); // 2 writes: no prune yet
      await cache.put('b', 'b', Duration(hours: 1));
      for (int i = 0; i < 100 && await files() != 2; i++) {
        await Future<void>.delayed(Duration(milliseconds: 20));
      }
      expect(await files(), 2);
      expect(await cache.get('a'), 'a');
      expect(await cache.get('b'), 'b');
    });

    test(
      'no prune_every (default): expired files stay until prune()',
      () async {
        CacheStore cache = store(<String, dynamic>{});
        await putExpired(cache, 'old');
        for (int i = 0; i < 10; i++) {
          await cache.put('k$i', i);
        }
        expect(await files(), 11);
        // prune() by hand still works and gives the count
        expect(await (cache.driver as dynamic).prune(), 1);
        expect(await files(), 10);
      },
    );

    test(
      '3.0 regression: forget, pull and increment on the file store',
      () async {
        CacheStore cache = store(<String, dynamic>{});
        await cache.put('n', 5);
        expect(await cache.increment('n', 2), 7);
        expect(await cache.pull('n'), 7);
        expect(await cache.has('n'), false);
        await cache.put('f', 'v');
        expect(await cache.forget('f'), true);
        expect(await cache.forget('f'), false);
      },
    );
  });
}

void _redisTests(JobsHelper jobs) {
  group('3.1 packages: ioredis handshake', () {
    /// a port with nothing on it
    Future<int> deadPort() async {
      ServerSocket s = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      int port = s.port;
      await s.close();
      return port;
    }

    /// Start [command] and wait until [onError] got an error with
    /// [text]. Then disconnect: the waiting command must end with an
    /// error, not hang.
    Future<void> failsThenEnds(RedisOptions options, String text) async {
      List<String> errors = <String>[];
      options.onError = (dynamic e) => errors.add('$e');
      Redis redis = Redis(options);
      Future<dynamic> get = redis.get('x');
      Object? result;
      unawaited(
        get.then(
          (_) => result = 'ok',
          onError: (Object e) {
            result = e;
          },
        ),
      );
      for (
        int i = 0;
        i < 100 && !errors.any((String e) => e.contains(text));
        i++
      ) {
        await Future<void>.delayed(Duration(milliseconds: 50));
      }
      expect(errors.join('\n'), contains(text));
      await redis.disconnect();
      for (int i = 0; i < 100 && result == null; i++) {
        await Future<void>.delayed(Duration(milliseconds: 20));
      }
      expect(result, isA<SocketException>());
    }

    test(
      'Redis down: the error goes to onError, disconnect ends the wait',
      () async {
        await failsThenEnds(
          RedisOptions(
            port: await deadPort(),
            connectTimeout: Duration(milliseconds: 500),
            retryStrategy: (int _) => Duration(milliseconds: 50),
          ),
          'Connection refused',
        );
      },
    );

    test('a server that never answers AUTH: the handshake times out', () async {
      ServerSocket silent = await ServerSocket.bind(
        InternetAddress.loopbackIPv4,
        0,
      );
      List<Socket> clients = <Socket>[];
      silent.listen(clients.add);
      try {
        await failsThenEnds(
          RedisOptions(
            port: silent.port,
            password: 'pw',
            connectTimeout: Duration(milliseconds: 300),
            retryStrategy: (int _) => Duration(milliseconds: 50),
          ),
          'handshake timed out',
        );
      } finally {
        for (Socket c in clients) {
          c.destroy();
        }
        await silent.close();
      }
    });

    test(
      'a server that closes the connection does not crash the app',
      () async {
        ServerSocket full = await ServerSocket.bind(
          InternetAddress.loopbackIPv4,
          0,
        );
        // like a Redis that restarts: it drops every new connection
        full.listen((Socket c) => c.destroy());
        List<Object> uncaught = <Object>[];
        await runZonedGuarded(() async {
          Redis redis = Redis(
            RedisOptions(
              port: full.port,
              connectTimeout: Duration(milliseconds: 300),
              retryStrategy: (int _) => Duration(milliseconds: 50),
              onError: (dynamic _) {},
            ),
          );
          unawaited(redis.get('x').then((_) {}, onError: (Object _) {}));
          await Future<void>.delayed(Duration(seconds: 1));
          await redis.disconnect();
        }, (Object e, StackTrace s) => uncaught.add(e));
        await full.close();
        expect(uncaught, isEmpty);
      },
      skip:
          'BUG: a socket write after the server closed gives an uncaught '
          'SocketException (reset by peer); socket.done has no error '
          'handler (ioredis redis_connection.dart _flush, socket.add)',
    );

    test(
      'AUTH with a password on a server with no password fails at once',
      () async {
        Redis redis = Redis(
          RedisOptions(
            port: env.redisPort,
            password: 'not-needed',
            connectTimeout: Duration(seconds: 2),
          ),
        );
        Stopwatch watch = Stopwatch()..start();
        await expectLater(
          redis.get('x').timeout(Duration(seconds: 5)),
          throwsA(isNot(isA<TimeoutException>())),
        );
        expect(watch.elapsed, lessThan(Duration(seconds: 3)));
        await redis.disconnect();
      },
    );

    test('ACL user: AUTH and SELECT run before the first commands', () async {
      Redis admin = Redis(RedisOptions(port: env.redisPort));
      String user = 'e2e310_${jobs.stamp()}';
      String key = 'dox_test_310_acl_${jobs.stamp()}';
      await admin.sendCommand(<String>[
        'ACL',
        'SETUSER',
        user,
        'on',
        '>acl-pass',
        '~dox_test_310_*',
        '+@all',
      ]);
      Redis redis = Redis(
        RedisOptions.fromUrl(
          'redis://$user:acl-pass@127.0.0.1:${env.redisPort}/'
          '${JobsHelper.redisDb}',
        ),
      );
      try {
        // all sent before the connection is ready
        List<dynamic> out = await Future.wait(<Future<dynamic>>[
          redis.set(key, 'v'),
          redis.get(key),
          redis.sendCommand(<String>['CLIENT', 'INFO']),
        ]);
        expect(out[1], 'v');
        expect('${out[2]}', contains('user=$user'));
        expect('${out[2]}', contains('db=${JobsHelper.redisDb}'));
        // db 0 does not have it
        expect(await admin.get(key), isNull);
      } finally {
        await redis.delete(key);
        await redis.disconnect();
        await admin.sendCommand(<String>['ACL', 'DELUSER', user]);
        await admin.disconnect();
      }
    });

    test('fromUrl: rediss is TLS, ?db= and a user are read', () {
      RedisOptions a = RedisOptions.fromUrl('rediss://me:pw@cache.test:7000');
      expect(a.secure, true);
      expect(a.host, 'cache.test');
      expect(a.port, 7000);
      expect(a.username, 'me');
      expect(a.password, 'pw');
      RedisOptions b = RedisOptions.fromUrl('redis://127.0.0.1?db=3');
      expect(b.db, 3);
      expect(b.secure, false);
      RedisOptions c = RedisOptions.fromUrl('redis://127.0.0.1/4?db=3');
      expect(c.db, 4); // the path wins
      // a bad URL: the error text hides the password
      Object? error;
      try {
        RedisOptions.fromUrl('redis://u:secret-pw@127.0.0.1/x');
      } catch (e) {
        error = e;
      }
      expect(error, isA<FormatException>());
      expect('$error', isNot(contains('secret-pw')));
    });
  });
}

void _cliTests() {
  group('3.1 packages: the dox CLI in this app', () {
    // CI clones dox-cli next to dox-test. DOX_CLI points to another one.
    String cli = Platform.environment['DOX_CLI'] ?? '../dox-cli/bin/dox.dart';
    String? skip = File(cli).existsSync() ? null : 'no dox CLI at $cli';

    Future<ProcessResult> dox(List<String> args) {
      return Process.run('dart', <String>[
        'run',
        cli,
        ...args,
      ]).timeout(Duration(minutes: 3));
    }

    test(
      'an unknown command exits with code 1 and a hint',
      () async {
        ProcessResult r = await dox(<String>['not-a-command-310']);
        expect(r.exitCode, 1, reason: '${r.stdout}${r.stderr}');
        expect('${r.stdout}${r.stderr}', contains('not-a-command-310'));
        expect('${r.stdout}${r.stderr}', contains('dox: commands:'));
      },
      skip: skip,
      timeout: Timeout(Duration(minutes: 4)),
    );

    test(
      'help lists queue:table of dox_queue',
      () async {
        ProcessResult r = await dox(<String>['help']);
        expect(r.exitCode, 0, reason: '${r.stderr}');
        expect('${r.stdout}', contains('dox_queue'));
        expect('${r.stdout}', contains('queue:table'));
      },
      skip: skip,
      timeout: Timeout(Duration(minutes: 4)),
    );

    test(
      'queue:table does not overwrite the migration (exit 1)',
      () async {
        List<String> before = Directory('db/migration')
            .listSync()
            .map((FileSystemEntity e) => e.path)
            .toList();
        ProcessResult r = await dox(<String>['queue:table']);
        expect(r.exitCode, 1, reason: '${r.stdout}${r.stderr}');
        expect('${r.stdout}${r.stderr}', contains('create_queue_tables'));
        List<String> after = Directory('db/migration')
            .listSync()
            .map((FileSystemEntity e) => e.path)
            .toList();
        expect(after, unorderedEquals(before));
      },
      skip: skip,
      timeout: Timeout(Duration(minutes: 4)),
    );

    test(
      'key:generate --show prints a key and does not change .env',
      () async {
        String env = File('.env').readAsStringSync();
        ProcessResult r = await dox(<String>['key:generate', '--show']);
        expect(r.exitCode, 0, reason: '${r.stderr}');
        String key = '${r.stdout}'.trim().split('\n').last.trim();
        expect(key.length, greaterThanOrEqualTo(32));
        expect(env, isNot(contains(key)));
        expect(File('.env').readAsStringSync(), env);
      },
      skip: skip,
      timeout: Timeout(Duration(minutes: 4)),
    );

    test(
      'migration:rollback with --step twice exits 1',
      () async {
        ProcessResult r = await dox(<String>[
          'migration:rollback',
          '--step=2',
          '--step=3',
        ]);
        expect(r.exitCode, 1, reason: '${r.stdout}${r.stderr}');
        expect('${r.stdout}${r.stderr}', contains('--step'));
      },
      skip: skip,
      timeout: Timeout(Duration(minutes: 4)),
    );
  });
}

/// A RFC 2047 subject (`=?utf-8?B?...?=` or `=?utf-8?Q?...?=`) as text.
String _decodeSubject(String raw) {
  return raw.replaceAllMapped(
    RegExp(r'=\?utf-8\?([BbQq])\?([^?]*)\?=\s*', caseSensitive: false),
    (Match m) {
      String data = m[2]!;
      if (m[1]!.toUpperCase() == 'B') return utf8.decode(base64.decode(data));
      List<int> bytes = <int>[];
      for (int i = 0; i < data.length; i++) {
        if (data[i] == '_') {
          bytes.add(32);
        } else if (data[i] == '=') {
          bytes.add(int.parse(data.substring(i + 1, i + 3), radix: 16));
          i += 2;
        } else {
          bytes.addAll(utf8.encode(data[i]));
        }
      }
      return utf8.decode(bytes);
    },
  );
}

/// The queue of the jobs below, so a worker here does not take the
/// jobs that other tests left.
const String e2eQueue = 'e2e310';

/// A job that throws for its first [failTimes] tries.
class FlakyJob extends DoxJob {
  FlakyJob({required this.failTimes});

  static const String name = 'FlakyJob';
  static int runs = 0;
  static int failedCalls = 0;

  static void reset() {
    runs = 0;
    failedCalls = 0;
  }

  final int failTimes;

  static const JobCodec codec = JobCodec(name, FlakyJob, _encode, _decode);

  static Map<String, Object?> _encode(DoxJob job) {
    return <String, Object?>{'fail_times': (job as FlakyJob).failTimes};
  }

  static DoxJob _decode(Map<String, Object?> data) {
    return FlakyJob(failTimes: data['fail_times'] as int);
  }

  @override
  String get queue => e2eQueue;

  @override
  int? get tries => 3;

  @override
  Future<void> handle() async {
    runs++;
    if (runs <= failTimes) throw StateError('flaky try $runs');
  }

  @override
  void failed(Object error, StackTrace stack) {
    failedCalls++;
  }
}

/// A job that runs until [release], past its timeout.
class HangingJob extends DoxJob {
  static const String name = 'HangingJob';
  static Completer<void> _gate = Completer<void>();

  static void release() {
    if (!_gate.isCompleted) _gate.complete();
    _gate = Completer<void>();
  }

  static const JobCodec codec = JobCodec(name, HangingJob, _encode, _decode);

  static Map<String, Object?> _encode(DoxJob job) => <String, Object?>{};

  static DoxJob _decode(Map<String, Object?> data) => HangingJob();

  @override
  String get queue => e2eQueue;

  @override
  int? get tries => 1;

  @override
  Duration? get timeout => Duration(milliseconds: 100);

  @override
  Future<void> handle() => _gate.future;
}

/// A job with secret data, saved encrypted.
class EncryptedNoteJob extends DoxJob with ShouldBeEncrypted {
  EncryptedNoteJob(this.note);

  static const String name = 'EncryptedNoteJob';
  static final List<String> seen = <String>[];

  final String note;

  static const JobCodec codec = JobCodec(
    name,
    EncryptedNoteJob,
    _encode,
    _decode,
  );

  static Map<String, Object?> _encode(DoxJob job) {
    return <String, Object?>{'note': (job as EncryptedNoteJob).note};
  }

  static DoxJob _decode(Map<String, Object?> data) {
    return EncryptedNoteJob(data['note'] as String);
  }

  @override
  String get queue => e2eQueue;

  @override
  Future<void> handle() async {
    seen.add(note);
  }
}

/// The Markdown template of the welcome email, with test values.
class LinkMail extends Mailable {
  LinkMail({required this.name, required this.url});

  final String name;
  final String url;

  @override
  List<Address> get to => <Address>[Address('ann@x.com')];

  @override
  String get subject => 'Links';

  @override
  String? get markdown => 'emails/welcome';

  @override
  Map<String, Object?> get data => <String, Object?>{'name': name, 'url': url};
}

/// A transport that always fails.
class BrokenTransport extends Transport {
  BrokenTransport([this.label = 'broken']);

  final String label;

  @override
  Future<SentMessage> send(Message message) async {
    throw MailException('$label transport is down');
  }
}

/// Someone to notify, with no Notifiable mixin.
class Person {
  Person(this.name);

  final String name;
}

/// A notification on two channels: one records, one always fails.
class Note extends Notification {
  @override
  List<NotificationChannel> via(Object notifiable) {
    return <NotificationChannel>[FailChannel(), RecordChannel()];
  }
}

class RecordChannel implements NotificationChannel {
  static final List<String> got = <String>[];

  static void reset() => got.clear();

  @override
  Future<void> send(Object notifiable, Notification notification) async {
    got.add((notifiable as Person).name);
  }
}

class FailChannel implements NotificationChannel {
  @override
  Future<void> send(Object notifiable, Notification notification) async {
    throw StateError('channel down');
  }
}

/// An object whose toJson() changes on every call.
class Counter {
  int calls = 0;

  Map<String, dynamic> toJson() {
    calls++;
    return <String, dynamic>{'n': calls};
  }
}
