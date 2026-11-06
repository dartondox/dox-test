import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dox_core/dox_core.dart';
import 'package:dox_mailer/dox_mailer.dart';
import 'package:dox_orm/dox_orm.dart' show QueryBuilder;
import 'package:dox_queue/dox_queue.dart';
import 'package:dox_scheduler/dox_scheduler.dart';
import 'package:dox_test/app/jobs/welcome_user.job.dart';
import 'package:dox_test/app/mail/welcome.mail.dart';
import 'package:dox_test/config/env.dart';
import 'package:dox_test/config/mail.dart';
import 'package:dox_test/config/queue.dart';
import 'package:dox_test/config/schedule.dart';
import 'package:http/http.dart' as http;
import 'package:ioredis/ioredis.dart';
import 'package:test/test.dart';

import 'e2e_test.dart';

/// End to end checks of the 3.1 work on dox_mailer, dox_queue,
/// dox_scheduler and ioredis. e2e_test.dart calls it, so it shares the
/// server and the database of that file.
///
/// The tests that send real email need MailHog (SMTP on MAIL_PORT, its
/// HTTP API on MAILHOG_API). They skip when MailHog is not there.
void jobsE2e(Api api) {
  MailHog mailhog = MailHog();
  JobsHelper jobs = JobsHelper(api);

  group('3.1: dox_mailer over SMTP (MailHog)', () {
    setUpAll(mailhog.check);

    test('a Markdown mailable with a file reaches the inbox', () async {
      if (mailhog.skip(markTestSkipped)) return;
      var (int id, String email) = await jobs.newUser('Ann');
      http.Response res = await api.post(
        '/api/mail/welcome/$id',
        <String, dynamic>{'mode': 'send'},
      );
      expect(res.statusCode, 200, reason: res.body);
      expect(api.json(res)['message_id'], isNotEmpty);

      MailHogMessage mail = await mailhog.waitFor(email);
      expect(mail.subject, 'Welcome to dox-test, Ann');
      expect(mail.to, contains(email));
      expect(mail.from, contains(env.mailFrom));
      // the Markdown is HTML in the layout, with the table
      expect(mail.html, contains('Hello Ann</h1>'));
      expect(mail.html, contains('<table>'));
      expect(mail.html, contains('href="${env.appUrl}"'));
      // the text body is the Markdown
      expect(mail.text, contains('# Hello Ann'));
      expect(mail.attachments.keys, contains('terms.txt'));
      expect(
        mail.attachments['terms.txt'],
        File(WelcomeMail.termsFile).readAsStringSync(),
      );
    });

    test(
      'failover: a dead first SMTP server does not stop the email',
      () async {
        if (mailhog.skip(markTestSkipped)) return;
        var (int id, String email) = await jobs.newUser('Fail Over');
        http.Response res = await api.post(
          '/api/mail/welcome/$id',
          <String, dynamic>{'mode': 'send', 'mailer': 'failover'},
        );
        expect(res.statusCode, 200, reason: res.body);
        MailHogMessage mail = await mailhog.waitFor(email);
        expect(mail.subject, 'Welcome to dox-test, Fail Over');
      },
    );

    test('Mail.queue: the queue worker sends the email', () async {
      if (mailhog.skip(markTestSkipped)) return;
      var (int id, String email) = await jobs.newUser('Queued');
      http.Response res = await api.post(
        '/api/mail/welcome/$id',
        <String, dynamic>{'mode': 'queue'},
      );
      expect(res.statusCode, 200, reason: res.body);
      String payload = await jobs.payloadOf(api.json(res)['job_id']);
      expect(payload, contains('dox_queue:SendQueuedMail'));
      // not sent yet: it waits for a worker
      expect(await mailhog.find(email), isEmpty);

      await jobs.work();

      MailHogMessage mail = await mailhog.waitFor(email);
      expect(mail.subject, 'Welcome to dox-test, Queued');
      expect(mail.attachments.keys, contains('terms.txt'));
      expect(await jobs.failedCount(), 0);
    });

    test('encrypt: true keeps the email out of the jobs table', () async {
      if (mailhog.skip(markTestSkipped)) return;
      var (int id, String email) = await jobs.newUser('Secret');
      http.Response res = await api.post(
        '/api/mail/welcome/$id',
        <String, dynamic>{'mode': 'queue', 'encrypt': true},
      );
      expect(res.statusCode, 200, reason: res.body);
      String payload = await jobs.payloadOf(api.json(res)['job_id']);
      expect(payload, contains('dox_queue:SendEncryptedQueuedMail'));
      expect(payload, isNot(contains(email)));
      expect(payload, isNot(contains('Welcome')));

      await jobs.work();

      MailHogMessage mail = await mailhog.waitFor(email);
      expect(mail.subject, 'Welcome to dox-test, Secret');
    });

    test('a queued notification reaches the user', () async {
      if (mailhog.skip(markTestSkipped)) return;
      var (int id, String email) = await jobs.newUser('Noti');
      http.Response res = await api.post(
        '/api/mail/account-ready/$id',
        <String, dynamic>{},
      );
      expect(res.statusCode, 200, reason: res.body);
      expect(await mailhog.find(email), isEmpty);

      await jobs.work();

      MailHogMessage mail = await mailhog.waitFor(email);
      expect(mail.subject, 'Your account is ready');
      expect(mail.to, contains('Noti'));
      expect(mail.html, contains('<strong>dox-test</strong>'));
      expect(mail.html, contains('href="${env.appUrl}"'));
      expect(mail.text, contains('Open the app: ${env.appUrl}'));
    });

    test('the daily-report task queues an email that a worker sends', () async {
      if (mailhog.skip(markTestSkipped)) return;
      // the task sends to MAIL_FROM: forget the old ones first
      Set<String> before = <String>{
        for (MailHogMessage m in await mailhog.find(env.mailFrom)) m.id,
      };
      Map<String, TaskOutcome> outcomes = await jobs.scheduler().runDue(
        tick: DateTime.utc(2026, 11, 3, 1), // 08:00 in Bangkok
      );
      expect(outcomes['daily-report'], TaskOutcome.ran);

      await jobs.work();

      MailHogMessage mail = await mailhog.waitFor(
        env.mailFrom,
        where: (MailHogMessage m) =>
            !before.contains(m.id) && m.subject == 'Daily report',
      );
      expect(mail.text, startsWith('Users: '));
    });
  });

  group('3.1: dox_mailer fakes and checks', () {
    tearDown(Mail.restore);

    test('Mail.fake() catches sent and queued mail from the app', () async {
      var (int id, String email) = await jobs.newUser('Fake');
      ArrayTransport mail = Mail.fake();

      await api.post('/api/mail/welcome/$id', <String, dynamic>{});
      mail.assertSentCount(1);
      mail.assertSent((Message m) => m.to.single.email == email);
      mail.assertNothingQueued();
      // Attachment.fromFile was read when the mail was sent
      Attachment file = mail.messages.single.attachments.single;
      expect(file.filename, 'terms.txt');
      expect(file.contentType, startsWith('text/plain'));
      expect(
        utf8.decode(file.bytes),
        File(WelcomeMail.termsFile).readAsStringSync(),
      );

      int jobsBefore = await jobs.jobCount();
      await api.post('/api/mail/welcome/$id', <String, dynamic>{
        'mode': 'later',
        'delay': 600,
        'encrypt': true,
      });
      await api.post('/api/mail/account-ready/$id', <String, dynamic>{});
      expect(mail.queued, hasLength(2));
      expect(mail.queued.first.delay, Duration(minutes: 10));
      expect(mail.queued.first.encrypt, true);
      mail.assertQueued((Message m) => m.subject == 'Your account is ready');
      mail.assertNotSent((Message m) => m.subject == 'Your account is ready');
      // no job was pushed
      expect(await jobs.jobCount(), jobsBefore);

      expect(
        () => mail.assertNothingSent(),
        throwsA(
          isA<StateError>().having(
            (StateError e) => e.message,
            'message',
            contains(email),
          ),
        ),
      );
    });

    test('a line break in the subject or an address is refused', () async {
      ArrayTransport mail = Mail.fake();
      Message bad = Message(
        to: <Address>[Address('ann@x.com')],
        subject: 'Hi\r\nBcc: evil@x.com',
        text: 'hi',
      );
      await expectLater(Mail.send(bad), throwsA(isA<MailException>()));
      await expectLater(Mail.queue(bad), throwsA(isA<MailException>()));
      Message badName = Message(
        to: <Address>[Address('ann@x.com', 'Ann\nBcc: evil@x.com')],
        subject: 'Hi',
        text: 'hi',
      );
      await expectLater(Mail.send(badName), throwsA(isA<MailException>()));
      mail.assertNothingSent();
      mail.assertNothingQueued();
    });

    test('a missing Attachment.fromFile file fails at send(), not before', () {
      Message message = Message(
        to: <Address>[Address('ann@x.com')],
        subject: 'File',
        text: 'see the file',
        attachments: <Attachment>[Attachment.fromFile('nope/missing.pdf')],
      );
      Mail.fake();
      expect(Mail.send(message), throwsA(isA<FileSystemException>()));
    });

    test('the from address of the config is added', () async {
      ArrayTransport mail = Mail.fake();
      await Mail.send(
        Message(
          to: <Address>[Address('ann@x.com')],
          subject: 'From',
          text: 'hi',
        ),
      );
      expect(mail.messages.single.from?.email, env.mailFrom);
      expect(mail.messages.single.from?.name, env.appName);
    });
  });

  group('3.1: dox_queue', () {
    tearDown(Queue.restore);

    test(
      'Queue.fake(): register pushes WelcomeUser, no job is saved',
      () async {
        int before = await jobs.jobCount();
        QueueFake queue = Queue.fake();
        var (int id, _) = await jobs.newUser('Pushed');
        queue.assertPushed<WelcomeUser>((WelcomeUser job) => job.userId == id);
        queue.assertPushedTimes<WelcomeUser>(1);
        expect(queue.pushed.single.queue, 'default');
        expect(await jobs.jobCount(), before);
      },
    );

    test(
      'Queue.fake() catches Mail.queue, restore() puts the queue back',
      () async {
        Mail.restore();
        var (int id, _) = await jobs.newUser('Mail Job');
        int before = await jobs.jobCount();

        QueueFake queue = Queue.fake();
        await api.post('/api/mail/welcome/$id', <String, dynamic>{
          'mode': 'queue',
        });
        // the mail job class is not exported, so check its name
        expect(queue.pushed, hasLength(1));
        expect('${queue.pushed.single.job.runtimeType}', 'SendQueuedMail');
        expect(await jobs.jobCount(), before);

        Queue.restore();
        http.Response res = await api.post(
          '/api/mail/welcome/$id',
          <String, dynamic>{'mode': 'queue'},
        );
        expect(await jobs.jobCount(), before + 1);
        await jobs.deleteJob(api.json(res)['job_id']);
      },
    );

    test('Mail.later: the worker does not send it before the delay', () async {
      var (int id, _) = await jobs.newUser('Later');
      http.Response res = await api.post(
        '/api/mail/welcome/$id',
        <String, dynamic>{'mode': 'later', 'delay': 600},
      );
      String jobId = api.json(res)['job_id'];
      await jobs.work();
      // still waiting, not taken and not failed
      expect(await jobs.payloadOf(jobId), contains('SendQueuedMail'));
      expect(await jobs.failedCount(), 0);
      await jobs.deleteJob(jobId);
    });

    test(
      'an encrypted mail job that fails hides the email in the error',
      () async {
        String email = 'hidden.${jobs.stamp()}@jobs.dox-test.dev';
        // an SMTP server that says no, and names the address
        RejectingSmtp server = await RejectingSmtp.start();
        Mail.configure(
          MailConfig(
            from: mailConfig.from,
            mailers: <String, Transport>{
              'down': SmtpTransport(
                host: '127.0.0.1',
                port: server.port,
                encryption: SmtpEncryption.none,
                timeout: Duration(seconds: 2),
              ),
            },
          ),
        );
        try {
          await Mail.mailer('down').queue(
            Message(
              to: <Address>[Address(email)],
              subject: 'Secret subject',
              text: 'secret body',
            ),
            encrypt: true,
          );
          await jobs.work();
        } finally {
          Mail.configure(mailConfig);
          await server.close();
        }
        List<FailedJob> failed = await Queue.driver.failed();
        expect(failed, hasLength(1));
        String error = failed.single.error;
        expect(
          error,
          startsWith('RedactedMailError: MailException (code 550)'),
        );
        expect(error, isNot(contains(email)));
        expect(error, isNot(contains('Secret subject')));
        expect(failed.single.payload, isNot(contains(email)));
        // the app key can read the full error
        expect(RedactedMailError.decrypt(error), contains(email));
        await Queue.driver.flush();
      },
    );

    test(
      'with timeoutGrace a timed-out job does not run twice at once',
      () async {
        SlowJob.reset();
        Queue.configure(
          QueueConfig(
            driver: 'database',
            jobs: JobRegistry(<JobCodec>[SlowJob.codec]),
          ),
        );
        try {
          await SlowJob().dispatch();
          await Worker(
            driver: Queue.driver,
            jobs: Queue.config.jobs,
            options: WorkerOptions(
              stopWhenEmpty: true,
              sleep: Duration(milliseconds: 100),
              timeoutGrace: Duration(seconds: 2),
            ),
          ).run();
        } finally {
          Queue.configure(queueConfig);
        }
        expect(SlowJob.runs, 2);
        expect(SlowJob.mostAtOnce, 1);
        List<FailedJob> failed = await Queue.driver.failed();
        expect(failed.single.job, SlowJob.name);
        await Queue.driver.flush();
      },
    );

    test(
      'redis driver: REDIS_URL with a db number, a worker runs the job',
      () async {
        String url = 'redis://127.0.0.1:${env.redisPort}/${JobsHelper.redisDb}';
        String prefix = 'dox_test_jobs_${jobs.stamp()}:';
        Redis redis = Redis(RedisOptions.fromUrl(url));
        Redis db0 = Redis(RedisOptions(port: env.redisPort));
        Queue.configure(
          QueueConfig(
            driver: 'redis',
            jobs: queueConfig.jobs,
            prefix: prefix,
            redis: QueueConfig.redisFromEnv(<String, String>{'REDIS_URL': url}),
          ),
        );
        try {
          // register dispatches WelcomeUser, now on redis
          int before = await jobs.jobCount();
          var (int id, _) = await jobs.newUser('Redis');
          expect(await jobs.jobCount(), before);
          expect(await redis.keys('$prefix*'), isNotEmpty);
          // SELECT ran before the first command: nothing in db 0
          expect(await db0.keys('$prefix*'), isEmpty);

          await Worker(
            driver: Queue.driver,
            jobs: Queue.config.jobs,
            options: WorkerOptions(stopWhenEmpty: true),
          ).run();
          expect((await profileOf(id))?.bio, WelcomeUser.bio);
        } finally {
          await Queue.close();
          Queue.configure(queueConfig);
          for (String key in await redis.keys('$prefix*')) {
            await redis.delete(key);
          }
          await redis.disconnect();
          await db0.disconnect();
        }
      },
    );

    test('QueueConfig.redisFromEnv() reads REDIS_PORT of .env', () {
      RedisOptions options = QueueConfig.redisFromEnv();
      expect(options.port, env.redisPort);
      expect(options.host, '127.0.0.1');
    });

    test(
      'ioredis: a wrong password fails at once and does not show it',
      () async {
        Redis redis = Redis(
          RedisOptions.fromUrl(
            'redis://:wrong-pass@127.0.0.1:${env.redisPort}/0',
            connectTimeout: Duration(seconds: 2),
          ),
        );
        Stopwatch watch = Stopwatch()..start();
        Object? error;
        try {
          await redis.get('x').timeout(Duration(seconds: 5));
        } catch (e) {
          error = e;
        }
        expect(error, isNotNull);
        expect(error, isNot(isA<TimeoutException>()));
        expect('$error', isNot(contains('wrong-pass')));
        expect(watch.elapsed, lessThan(Duration(seconds: 3)));
        await redis.disconnect();
      },
    );

    test('ioredis: fromUrl errors hide the password', () {
      expect(
        () => RedisOptions.fromUrl('http://me:top-secret@127.0.0.1:6379'),
        throwsA(
          isA<ArgumentError>().having(
            (ArgumentError e) => '$e',
            'text',
            isNot(contains('top-secret')),
          ),
        ),
      );
    });
  });

  group('3.1: dox_scheduler', () {
    Schedule appSchedule() {
      Schedule s = Schedule(timezone: scheduleConfig.timezone);
      schedule(s);
      return s;
    }

    test('ScheduleConfig timezone: dailyAt("8") is 08:00 in Bangkok', () {
      ScheduledTask task = appSchedule().find('daily-report')!;
      expect(task.isDue(DateTime.utc(2026, 11, 3, 1)), true); // 08:00 +07
      expect(task.isDue(DateTime.utc(2026, 11, 3, 8)), false);
      expect(
        task.nextRun(DateTime.utc(2026, 11, 3, 2)),
        DateTime.utc(2026, 11, 4, 1),
      );
    });

    test('a task timezone() still wins over the config', () {
      Schedule s = Schedule(timezone: scheduleConfig.timezone);
      ScheduledTask task = s.call('utc', () {}).dailyAt('8').timezone('UTC');
      expect(task.isDue(DateTime.utc(2026, 11, 3, 8)), true);
      expect(() => Schedule(timezone: 'Mars/Base'), throwsArgumentError);
    });

    test('between("9", "17") with hours alone', () {
      ScheduledTask task = appSchedule().find('queue-health')!;
      expect(task.isDue(DateTime.utc(2026, 11, 3, 3, 5)), true); // 10:05 +07
      expect(task.isDue(DateTime.utc(2026, 11, 3, 12, 5)), false); // 19:05 +07
    });

    test(
      'environments(["production"]) skips the task in development',
      () async {
        expect(env.appEnv, 'development');
        Map<String, TaskOutcome> outcomes = await jobs.scheduler().runDue(
          tick: DateTime.utc(2026, 11, 2, 17), // 00:00 in Bangkok
        );
        expect(outcomes['prune-failed-jobs'], TaskOutcome.skipped);
      },
    );

    /// Sets APP_ENV for one test. The scheduler reads it with Env.get.
    void appEnv(String value) {
      String? before = Env().env['APP_ENV'];
      Env().env['APP_ENV'] = value;
      addTearDown(() {
        if (before == null) {
          Env().env.remove('APP_ENV');
        } else {
          Env().env['APP_ENV'] = before;
        }
      });
    }

    String? realAppEnv = Platform.environment.containsKey('APP_ENV')
        ? 'APP_ENV is a real env variable, it wins over .env'
        : null;

    test(
      'onOneServer() on a memory lock store prints one warning in production',
      () async {
        appEnv('production');
        StringBuffer err = StringBuffer();
        Scheduler scheduler = jobs.scheduler(err: err);
        ArrayTransport mail = Mail.fake();
        try {
          await scheduler.runDue(tick: DateTime.utc(2026, 11, 5, 1));
          await scheduler.runDue(tick: DateTime.utc(2026, 11, 5, 2));
        } finally {
          Mail.restore();
        }
        expect(RegExp('onOneServer').allMatches(err.toString()), hasLength(1));
        expect(err.toString(), contains('the lock store is a memory store'));
        expect(err.toString(), contains("ScheduleConfig(store: 'redis')"));
        // the task queued its email (caught by the fake)
        mail.assertQueued((Message m) => m.subject == 'Daily report');
      },
      skip: realAppEnv,
    );

    test('no onOneServer() warning in development or local', () async {
      for (String name in <String>['development', ' Local ']) {
        appEnv(name);
        StringBuffer err = StringBuffer();
        // the daily-report email goes to the fake, not the queue
        Mail.fake();
        try {
          await jobs
              .scheduler(err: err)
              .runDue(tick: DateTime.utc(2026, 11, 6, 1));
        } finally {
          Mail.restore();
        }
        expect(err.toString(), isEmpty, reason: name);
      }
    }, skip: realAppEnv);

    test('new frequency helpers', () {
      Schedule s = Schedule();
      DateTime mon = DateTime.utc(2026, 11, 2); // a Monday
      expect(
        s
            .call('a', () {})
            .everyThreeMinutes()
            .isDue(mon.add(Duration(minutes: 3))),
        true,
      );
      expect(
        s
            .call('b', () {})
            .everyFourMinutes()
            .isDue(mon.add(Duration(minutes: 6))),
        false,
      );
      expect(
        s.call('c', () {}).everyTwoHours().isDue(mon.add(Duration(hours: 4))),
        true,
      );
      expect(
        s.call('d', () {}).everyOddHour().isDue(mon.add(Duration(hours: 3))),
        true,
      );
      expect(
        s.call('e', () {}).everyOddHour().isDue(mon.add(Duration(hours: 4))),
        false,
      );
      expect(
        s
            .call('f', () {})
            .twiceDailyAt(1, 13, 15)
            .isDue(DateTime.utc(2026, 11, 2, 13, 15)),
        true,
      );
      expect(s.call('g', () {}).daily().mondays().isDue(mon), true);
      expect(s.call('h', () {}).daily().sundays().isDue(mon), false);
      expect(
        s
            .call('i', () {})
            .lastDayOfMonth('23')
            .isDue(DateTime.utc(2026, 11, 30, 23)),
        true,
      );
      expect(
        s
            .call('j', () {})
            .lastDayOfMonth('23')
            .isDue(DateTime.utc(2026, 11, 29, 23)),
        false,
      );
      expect(
        s
            .call('k', () {})
            .quarterlyOn(2, '10:30')
            .isDue(DateTime.utc(2026, 10, 2, 10, 30)),
        true,
      );
      expect(
        s
            .call('l', () {})
            .quarterlyOn(2, '10:30')
            .isDue(DateTime.utc(2026, 11, 2, 10, 30)),
        false,
      );
      expect(
        s
            .call('m', () {})
            .yearlyOn(12, 25, '9')
            .isDue(DateTime.utc(2026, 12, 25, 9)),
        true,
      );
      expect(
        s
            .call('n', () {})
            .twiceMonthly(1, 16, '8')
            .isDue(DateTime.utc(2026, 11, 16, 8)),
        true,
      );
      expect(
        s.call('o', () {}).at('7').isDue(DateTime.utc(2026, 11, 2, 7)),
        true,
      );
      expect(
        s
            .call('p', () {})
            .hourly()
            .unlessBetween('1', '5')
            .isDue(DateTime.utc(2026, 11, 2, 3)),
        false,
      );
      expect(
        s
            .call('q', () {})
            .hourly()
            .unlessBetween('1', '5')
            .isDue(DateTime.utc(2026, 11, 2, 7)),
        true,
      );
    });

    test(
      'withoutOverlapping keeps the lock until a timed-out task ends',
      () async {
        Completer<void> release = Completer<void>();
        int started = 0;
        Schedule s = Schedule();
        s
            .call('jobs-e2e-slow-${jobs.stamp()}', () async {
              started++;
              await release.future;
            })
            .everyMinute()
            .withoutOverlapping()
            .timeout(Duration(milliseconds: 100));
        Scheduler scheduler = Scheduler(
          tasks: s.tasks,
          store: Scheduler.lockStore(Dox().cache, 'redis'),
        );
        String name = s.tasks.single.name;
        DateTime t = DateTime.utc(2026, 11, 3, 4);
        expect((await scheduler.runDue(tick: t))[name], TaskOutcome.failed);
        // the first run still works: the next minute is skipped
        expect(
          (await scheduler.runDue(tick: t.add(Duration(minutes: 1))))[name],
          TaskOutcome.skipped,
        );
        expect(started, 1);
        release.complete();
        await Future<void>.delayed(Duration(milliseconds: 200));
        Completer<void> again = release = Completer<void>()..complete();
        expect(again.isCompleted, true);
        expect(
          (await scheduler.runDue(tick: t.add(Duration(minutes: 2))))[name],
          TaskOutcome.ran,
        );
        expect(started, 2);
        await scheduler.close();
      },
    );
  });

  group('3.1: the real bin/schedule.dart', () {
    test(
      'Ctrl+C stops `schedule work` in a few seconds',
      () async {
        Process p = await Process.start('dart', <String>[
          'run',
          'bin/schedule.dart',
          'work',
        ]);
        StringBuffer out = StringBuffer();
        p.stdout.transform(utf8.decoder).listen(out.write);
        p.stderr.transform(utf8.decoder).listen(out.write);
        for (int i = 0; i < 600 && !out.toString().contains('working'); i++) {
          await Future<void>.delayed(Duration(milliseconds: 100));
        }
        p.kill(ProcessSignal.sigint);
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

/// A job that runs longer than its timeout. It counts its runs and how
/// many run at the same time.
class SlowJob extends DoxJob {
  static const String name = 'SlowJob';

  static int runs = 0;
  static int running = 0;
  static int mostAtOnce = 0;

  static void reset() {
    runs = 0;
    running = 0;
    mostAtOnce = 0;
  }

  static const JobCodec codec = JobCodec(name, SlowJob, _encode, _decode);

  static Map<String, Object?> _encode(DoxJob job) => <String, Object?>{};

  static DoxJob _decode(Map<String, Object?> data) => SlowJob();

  @override
  int? get tries => 2;

  @override
  Duration? get timeout => Duration(milliseconds: 200);

  @override
  Future<void> handle() async {
    runs++;
    running++;
    if (running > mostAtOnce) mostAtOnce = running;
    await Future<void>.delayed(Duration(milliseconds: 600));
    running--;
  }
}

/// A tiny SMTP server that refuses every recipient with
/// `550 <email>: mailbox unavailable`, like a real server can.
class RejectingSmtp {
  RejectingSmtp(this.socket);

  final ServerSocket socket;

  int get port => socket.port;

  static Future<RejectingSmtp> start() async {
    RejectingSmtp server = RejectingSmtp(
      await ServerSocket.bind(InternetAddress.loopbackIPv4, 0),
    );
    server.socket.listen(server.talk);
    return server;
  }

  void talk(Socket client) {
    client.write('220 reject.test ESMTP\r\n');
    client
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .listen((String line) => client.write(answer(line)));
  }

  String answer(String line) {
    String upper = line.toUpperCase();
    if (upper.startsWith('EHLO') || upper.startsWith('HELO')) {
      return '250 reject.test\r\n';
    }
    if (upper.startsWith('RCPT')) {
      String to = RegExp('<([^>]*)>').firstMatch(line)?.group(1) ?? '';
      return '550 <$to>: mailbox unavailable\r\n';
    }
    if (upper.startsWith('QUIT')) return '221 bye\r\n';
    return '250 ok\r\n';
  }

  Future<void> close() async {
    await socket.close();
  }
}

/// Users, jobs and a scheduler for the tests above.
class JobsHelper {
  JobsHelper(this.api);

  final Api api;

  /// the Redis db of the redis queue test, not the db of other apps
  static const int redisDb = 5;

  int _count = 0;

  /// a text that is new on every call
  String stamp() {
    _count++;
    return '${DateTime.now().microsecondsSinceEpoch}$_count';
  }

  /// Register a user over HTTP. Gives its id and a new email address.
  Future<(int, String)> newUser(String name) async {
    String email =
        '${name.toLowerCase().replaceAll(' ', '.')}.${stamp()}'
        '@jobs.dox-test.dev';
    http.Response res = await api.post('/api/auth/register', <String, dynamic>{
      'name': name,
      'email': email,
      'password': 'secret123',
      'password_confirmation': 'secret123',
    });
    expect(res.statusCode, 201, reason: res.body);
    return (api.json(res)['id'] as int, email);
  }

  /// Run every job that is due, then stop.
  Future<void> work() async {
    await Worker(
      driver: Queue.driver,
      jobs: queueConfig.jobs,
      options: WorkerOptions(stopWhenEmpty: true),
    ).run();
  }

  Future<int> jobCount() async {
    return await QueryBuilder.table('jobs').count();
  }

  Future<int> failedCount() async {
    return await QueryBuilder.table('failed_jobs').count();
  }

  /// the saved payload of the job [id] in the `jobs` table
  Future<String> payloadOf(String id) async {
    List<Map<String, dynamic>> rows = await QueryBuilder.table('jobs').get();
    for (Map<String, dynamic> row in rows) {
      String payload = row['payload'].toString();
      if (payload.contains(id)) return payload;
    }
    throw StateError('no job $id');
  }

  Future<void> deleteJob(String id) async {
    List<Map<String, dynamic>> rows = await QueryBuilder.table('jobs').get();
    for (Map<String, dynamic> row in rows) {
      if (row['payload'].toString().contains(id)) {
        await QueryBuilder.table('jobs').where('id', row['id']).delete();
      }
    }
  }

  /// The scheduler of the app config, like bin/schedule.dart makes it.
  Scheduler scheduler({StringSink? err}) {
    Schedule s = Schedule(timezone: scheduleConfig.timezone);
    schedule(s);
    return Scheduler(
      tasks: s.tasks,
      store: Scheduler.lockStore(Dox().cache, scheduleConfig.store),
      err: err ?? StringBuffer(),
    );
  }
}

/// One email in MailHog.
class MailHogMessage {
  MailHogMessage(this.raw);

  final Map<String, dynamic> raw;

  String get id => raw['ID'].toString();

  Map<String, dynamic> get headers => raw['Content']['Headers'];

  String header(String name) {
    List<dynamic>? values = headers[name];
    return values == null ? '' : values.join(', ');
  }

  String get subject => header('Subject');
  String get to => header('To');
  String get from => header('From');

  /// every leaf MIME part: its headers and its decoded body
  List<(Map<String, dynamic>, String)> get parts {
    List<(Map<String, dynamic>, String)> ret =
        <(Map<String, dynamic>, String)>[];
    _walk(raw['MIME'], raw['Content'], ret);
    return ret;
  }

  void _walk(
    Map<String, dynamic>? mime,
    Map<String, dynamic> content,
    List<(Map<String, dynamic>, String)> ret,
  ) {
    List<dynamic>? children = mime?['Parts'];
    if (children == null || children.isEmpty) {
      ret.add((content['Headers'], _decode(content)));
      return;
    }
    for (dynamic child in children) {
      _walk(child['MIME'], child, ret);
    }
  }

  static String _decode(Map<String, dynamic> part) {
    Map<String, dynamic> h = part['Headers'];
    String encoding = (h['Content-Transfer-Encoding'] ?? <dynamic>['']).first
        .toString()
        .toLowerCase();
    String body = part['Body'].toString();
    if (encoding == 'base64') {
      return utf8.decode(base64.decode(body.replaceAll(RegExp(r'\s'), '')));
    }
    if (encoding == 'quoted-printable') {
      String joined = body.replaceAll(RegExp(r'=\r?\n'), '');
      List<int> bytes = <int>[];
      for (int i = 0; i < joined.length; i++) {
        if (joined[i] == '=' && i + 2 < joined.length + 0) {
          bytes.add(int.parse(joined.substring(i + 1, i + 3), radix: 16));
          i += 2;
        } else {
          bytes.addAll(utf8.encode(joined[i]));
        }
      }
      return utf8.decode(bytes);
    }
    return body;
  }

  String _type(Map<String, dynamic> h) {
    return (h['Content-Type'] ?? <dynamic>['']).first.toString();
  }

  String _bodyOf(String type) {
    for ((Map<String, dynamic>, String) part in parts) {
      if (_type(part.$1).startsWith(type) &&
          !(part.$1['Content-Disposition'] ?? <dynamic>['']).first
              .toString()
              .startsWith('attachment')) {
        return part.$2;
      }
    }
    return '';
  }

  String get html => _bodyOf('text/html');
  String get text => _bodyOf('text/plain');

  /// file name -> content of each attached file
  Map<String, String> get attachments {
    Map<String, String> ret = <String, String>{};
    for ((Map<String, dynamic>, String) part in parts) {
      String disposition = (part.$1['Content-Disposition'] ?? <dynamic>[''])
          .first
          .toString();
      Match? name = RegExp(r'filename="?([^";]+)"?').firstMatch(disposition);
      if (disposition.startsWith('attachment') && name != null) {
        ret[name.group(1)!] = part.$2;
      }
    }
    return ret;
  }
}

/// Reads the emails that MailHog caught, with its HTTP API.
class MailHog {
  String get base =>
      Platform.environment['MAILHOG_API'] ?? 'http://127.0.0.1:8125';

  bool _up = false;

  /// Is MailHog there? Tests skip when it is not.
  Future<void> check() async {
    try {
      http.Response res = await http
          .get(Uri.parse('$base/api/v2/messages?limit=1'))
          .timeout(Duration(seconds: 2));
      _up = res.statusCode == 200;
    } catch (_) {
      _up = false;
    }
  }

  /// True (and the test is marked skipped) when MailHog is not there.
  bool skip(void Function(String) mark) {
    if (_up) return false;
    mark('MailHog is not running at $base (docker compose up mailhog)');
    return true;
  }

  /// the emails sent to [email], newest first
  Future<List<MailHogMessage>> find(String email) async {
    http.Response res = await http.get(
      Uri.parse(
        '$base/api/v2/search?kind=to&query=${Uri.encodeQueryComponent(email)}',
      ),
    );
    List<dynamic> items = jsonDecode(res.body)['items'];
    return <MailHogMessage>[for (dynamic item in items) MailHogMessage(item)];
  }

  /// Wait up to 5 seconds for an email to [email].
  Future<MailHogMessage> waitFor(
    String email, {
    bool Function(MailHogMessage)? where,
  }) async {
    for (int i = 0; i < 50; i++) {
      for (MailHogMessage m in await find(email)) {
        if (where == null || where(m)) return m;
      }
      await Future<void>.delayed(Duration(milliseconds: 100));
    }
    throw TimeoutException('no email to $email in MailHog');
  }
}
