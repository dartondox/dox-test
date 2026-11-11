import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dox_mailer/dox_mailer.dart';
import 'package:dox_orm/dox_orm.dart' show QueryBuilder;
import 'package:dox_queue/dox_queue.dart';
import 'package:dox_scheduler/dox_scheduler.dart';
import 'package:dox_storage/dox_storage.dart';
import 'package:dox_test/config/mail.dart';
import 'package:dox_test/config/queue.dart';
import 'package:dox_test/constants/app_constants.dart';
import 'package:dox_test/routes/e310b_pkg.dart';
import 'package:dox_view/dox_view.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'e2e_310_packages.dart' show BrokenTransport, LinkMail;
import 'e2e_test.dart' show Api, Browser;
import 'jobs_e2e.dart' show JobsHelper, MailHog, MailHogMessage;

/// Round 3 of the 3.1.0 package checks: the features that merged last
/// in dox_queue, dox_cli, dox_mailer, dox_storage, dox_scheduler,
/// dox_inertia and dox_view. e2e_test.dart calls it, on the same server
/// and database. Every queue, folder and key here starts with
/// `e310b_pkg_`, so tests that run at the same time do not mix.
void packages310bTests(Api api) {
  JobsHelper jobs = JobsHelper(api);

  _queueTests();
  _cliTests();
  _mailerTests(jobs);
  _storageTests(api);
  _schedulerTests();
  _inertiaTests(api);
  _viewTests(api);
}

/// The queue of the jobs of this file.
const String _queue = 'e310b_pkg_jobs';

/// Run every job of [queue] that is due. Stop when the queue is empty.
Future<void> _work({String queue = _queue, WorkerOptions? options}) {
  return Worker(
    driver: Queue.driver,
    jobs: Queue.config.jobs,
    options:
        options ??
        WorkerOptions(
          queues: <String>[queue],
          stopWhenEmpty: true,
          sleep: Duration(milliseconds: 50),
        ),
  ).run();
}

/// The saved rows of the `jobs` table on [queue].
Future<List<Map<String, dynamic>>> _rows([String queue = _queue]) {
  return QueryBuilder.table('jobs').where('queue', queue).get();
}

/// The failed jobs of [queue].
Future<List<FailedJob>> _failed([String queue = _queue]) async {
  return <FailedJob>[
    for (FailedJob job in await Queue.driver.failed())
      if (job.queue == queue) job,
  ];
}

/// Use a queue with only [PlanJob], on the database driver.
void _configureQueue() {
  Queue.configure(
    QueueConfig(
      driver: 'database',
      jobs: JobRegistry(<JobCodec>[PlanJob.codec]),
    ),
  );
}

/// Remove the jobs and failed jobs of [queue], and use the app queue.
Future<void> _resetQueue([String queue = _queue]) async {
  PlanJob.release();
  // stop a fake first, so clear() runs on the real driver
  Queue.restore();
  await Queue.driver.clear(queue);
  for (FailedJob job in await _failed(queue)) {
    await Queue.driver.forget(job.id);
  }
  Queue.configure(queueConfig);
}

void _queueTests() {
  group('3.1 round 3: dox_queue job options', () {
    setUp(() {
      PlanJob.plans.clear();
      _configureQueue();
    });

    tearDown(_resetQueue);

    test('retryUntil: retries past tries until it works', () async {
      Plan plan = PlanJob.plan(
        'until',
        tries: 1,
        failTimes: 2,
        retryUntil: () => DateTime.now().add(Duration(minutes: 1)),
      );
      await PlanJob('until').dispatch();
      // retryUntil is read at dispatch and saved with the job
      String payload = '${(await _rows()).single['payload']}';
      expect(payload, contains('"retryUntil"'));
      await _work();
      expect(plan.runs, 3);
      expect(await _failed(), isEmpty);
      expect(await _rows(), isEmpty);
    });

    test('retryUntil in the past: fails after the first error', () async {
      Plan plan = PlanJob.plan(
        'past',
        tries: 5,
        failTimes: 99,
        retryUntil: () => DateTime.now().subtract(Duration(seconds: 1)),
      );
      await PlanJob('past').dispatch();
      await _work();
      expect(plan.runs, 1);
      expect(await _failed(), hasLength(1));
    });

    test('no retryUntil: the payload has no retryUntil key', () async {
      PlanJob.plan('plain');
      await PlanJob('plain').dispatch();
      String payload = '${(await _rows()).single['payload']}';
      expect(payload, isNot(contains('retryUntil')));
      expect(payload, isNot(contains('exceptions')));
    });

    test('maxExceptions: fails after 2 errors, tries allow 10', () async {
      Plan plan = PlanJob.plan(
        'max',
        tries: 10,
        failTimes: 99,
        maxExceptions: 2,
      );
      await PlanJob('max').dispatch();
      await _work();
      expect(plan.runs, 2);
      List<FailedJob> failed = await _failed();
      expect(failed, hasLength(1));
      expect(failed.single.error, contains('plan max try 2'));
    });

    test('maxExceptions: a timeout is not counted', () async {
      Plan plan = PlanJob.plan(
        'timeout-count',
        tries: 10,
        failTimes: 99,
        maxExceptions: 2,
        hangOnRun: 1,
        timeout: Duration(milliseconds: 100),
      );
      await PlanJob('timeout-count').dispatch();
      await _work();
      // run 1 times out (not counted), runs 2 and 3 throw
      expect(plan.runs, 3);
      expect(await _failed(), hasLength(1));
    });

    test('failOnTimeout: a timeout fails at once, no retry', () async {
      Plan plan = PlanJob.plan(
        'fail-on-timeout',
        tries: 3,
        hangOnRun: 1,
        timeout: Duration(milliseconds: 100),
        failOnTimeout: true,
      );
      await PlanJob('fail-on-timeout').dispatch();
      await _work();
      expect(plan.runs, 1);
      List<FailedJob> failed = await _failed();
      expect(failed, hasLength(1));
      expect(failed.single.error, contains('Timeout'));
    });

    test('without failOnTimeout a timed out job is tried again', () async {
      Plan plan = PlanJob.plan(
        'timeout-retry',
        tries: 3,
        hangOnRun: 1,
        timeout: Duration(milliseconds: 100),
      );
      await PlanJob('timeout-retry').dispatch();
      await _work();
      expect(plan.runs, 2);
      expect(await _failed(), isEmpty);
    });

    test('dispatch(delayUntil:) waits until that time', () async {
      PlanJob.plan('later');
      DateTime at = DateTime.now().add(Duration(minutes: 10));
      await PlanJob('later').dispatch(delayUntil: at);
      int available = int.parse('${(await _rows()).single['available_at']}');
      expect((available - at.millisecondsSinceEpoch).abs(), lessThan(5000));
      await _work();
      // not due yet
      expect(PlanJob.plans['later']!.runs, 0);
      expect(await _rows(), hasLength(1));
    });

    test('dispatch(delayUntil:) in the past runs at once', () async {
      Plan plan = PlanJob.plan('past-time');
      await PlanJob('past-time')
          .dispatch(delayUntil: DateTime.now().subtract(Duration(hours: 1)));
      await _work();
      expect(plan.runs, 1);
    });

    test('delay and delayUntil together throw an ArgumentError', () async {
      PlanJob.plan('both');
      await expectLater(
        PlanJob('both').dispatch(
          delay: Duration(minutes: 1),
          delayUntil: DateTime.now().add(Duration(minutes: 1)),
        ),
        throwsArgumentError,
      );
      expect(await _rows(), isEmpty);
      // the fake too
      QueueFake fake = Queue.fake();
      await expectLater(
        PlanJob('both')
            .dispatch(delay: Duration(minutes: 1), delayUntil: DateTime.now()),
        throwsArgumentError,
      );
      fake.assertNothingPushed();
    });

    test('dispatchIf and dispatchUnless give null when skipped', () async {
      PlanJob.plan('if');
      expect(await PlanJob('if').dispatchIf(false), isNull);
      expect(await PlanJob('if').dispatchUnless(true), isNull);
      expect(await _rows(), isEmpty);
      String? a = await PlanJob('if').dispatchIf(true);
      String? b = await PlanJob('if').dispatchUnless(false, queue: _queue);
      expect(a, isNotNull);
      expect(b, isNotNull);
      expect(a, isNot(b));
      expect(await _rows(), hasLength(2));
    });

    test('the fake keeps the delay of delayUntil', () async {
      QueueFake fake = Queue.fake();
      PlanJob.plan('fake');
      await PlanJob('fake')
          .dispatch(delayUntil: DateTime.now().add(Duration(minutes: 30)));
      Duration delay = fake.pushed.single.delay!;
      expect(delay, greaterThan(Duration(minutes: 29)));
      expect(delay, lessThanOrEqualTo(Duration(minutes: 30)));
      expect(await PlanJob('fake').dispatchIf(false), isNull);
      fake.assertPushedTimes<PlanJob>(1);
    });
  });

  group('3.1 round 3: dox_queue worker limits', () {
    setUp(() {
      PlanJob.plans.clear();
      _configureQueue();
    });

    tearDown(_resetQueue);

    test('maxJobs: stops after 2 jobs, the third waits', () async {
      Plan plan = PlanJob.plan('jobs');
      for (int i = 0; i < 3; i++) {
        await PlanJob('jobs').dispatch();
      }
      await _work(
        options: WorkerOptions(
          queues: <String>[_queue],
          maxJobs: 2,
          sleep: Duration(milliseconds: 50),
        ),
      ).timeout(Duration(seconds: 10));
      expect(plan.runs, 2);
      expect(await _rows(), hasLength(1));
    });

    test('memory: a low limit stops after the first job', () async {
      Plan plan = PlanJob.plan('memory');
      await PlanJob('memory').dispatch();
      await PlanJob('memory').dispatch();
      await _work(
        options: WorkerOptions(
          queues: <String>[_queue],
          memory: 1,
          sleep: Duration(milliseconds: 50),
        ),
      ).timeout(Duration(seconds: 10));
      expect(plan.runs, 1);
      expect(await _rows(), hasLength(1));
    });

    test('maxTime: an idle worker stops after the time', () async {
      Stopwatch watch = Stopwatch()..start();
      await _work(
        options: WorkerOptions(
          queues: <String>[_queue],
          maxTime: Duration(milliseconds: 300),
          sleep: Duration(seconds: 1),
        ),
      ).timeout(Duration(seconds: 10));
      expect(watch.elapsed, lessThan(Duration(seconds: 5)));
      expect(watch.elapsed, greaterThanOrEqualTo(Duration(milliseconds: 300)));
    });

    test('backoff: a job with no backoff waits the worker backoff', () async {
      Plan plan = PlanJob.plan('backoff', tries: 2, failTimes: 1);
      await PlanJob('backoff').dispatch();
      int before = DateTime.now().millisecondsSinceEpoch;
      await _work(
        options: WorkerOptions(
          queues: <String>[_queue],
          stopWhenEmpty: true,
          sleep: Duration(milliseconds: 50),
          backoff: <Duration>[Duration(seconds: 60)],
        ),
      );
      expect(plan.runs, 1);
      List<Map<String, dynamic>> rows = await _rows();
      expect(rows, hasLength(1));
      int available = int.parse('${rows.single['available_at']}');
      expect(available - before, greaterThan(55000));
      // the payload keeps the exception count
      expect('${rows.single['payload']}', contains('"exceptions":1'));
    });

    test('the job backoff wins over the worker backoff', () async {
      Plan plan = PlanJob.plan(
        'own-backoff',
        tries: 2,
        failTimes: 1,
        backoff: <Duration>[Duration.zero],
      );
      await PlanJob('own-backoff').dispatch();
      await _work(
        options: WorkerOptions(
          queues: <String>[_queue],
          stopWhenEmpty: true,
          sleep: Duration(milliseconds: 50),
          backoff: <Duration>[Duration(minutes: 5)],
        ),
      );
      expect(plan.runs, 2);
      expect(await _rows(), isEmpty);
    });

    test('bin/queue.dart flags: good and bad values', () {
      QueueCommand ok = QueueCommand.parse(<String>[
        'work',
        '--backoff=1, 5,10',
        '--max-jobs=1000',
        '--max-time=3600',
        '--memory=256',
      ]);
      expect(ok.options.backoff, <Duration>[
        Duration(seconds: 1),
        Duration(seconds: 5),
        Duration(seconds: 10),
      ]);
      expect(ok.options.maxJobs, 1000);
      expect(ok.options.maxTime, Duration(hours: 1));
      expect(ok.options.memory, 256);
      // all off by default
      QueueCommand plain = QueueCommand.parse(<String>['work']);
      expect(plain.options.backoff, isEmpty);
      expect(plain.options.maxJobs, isNull);
      expect(plain.options.maxTime, isNull);
      expect(plain.options.memory, isNull);
      expect(QueueCommand.parse(<String>['prune-failed']).hours, 24);
      expect(
        QueueCommand.parse(<String>['prune-failed', '--hours=0']).hours,
        0,
      );
      expect(QueueCommand.parse(<String>['clear', 'mail']).argument, 'mail');
      for (List<String> bad in <List<String>>[
        <String>['work', '--backoff=1,x'],
        <String>['work', '--backoff=-1'],
        <String>['work', '--backoff='],
        <String>['work', '--max-jobs=0'],
        <String>['work', '--max-time=0'],
        <String>['work', '--memory=0'],
        <String>['work', '--memory=lots'],
        <String>['prune-failed', '--hours=-1'],
      ]) {
        expect(
          () => QueueCommand.parse(bad),
          throwsFormatException,
          reason: bad.join(' '),
        );
      }
    });
  });

  group('3.1 round 3: dox_queue clear, prune and retry', () {
    setUp(() {
      PlanJob.plans.clear();
      _configureQueue();
    });

    tearDown(() async {
      await Queue.driver.clear('e310b_pkg_other');
      await _resetQueue();
    });

    test('clear(queue) deletes the jobs of one queue only', () async {
      PlanJob.plan('clear');
      await PlanJob('clear').dispatch();
      await PlanJob('clear').dispatch(delay: Duration(hours: 1));
      await PlanJob('clear').dispatch(queue: 'e310b_pkg_other');
      expect(await Queue.driver.clear(_queue), 2);
      expect(await _rows(), isEmpty);
      expect(await _rows('e310b_pkg_other'), hasLength(1));
      // nothing left: 0
      expect(await Queue.driver.clear(_queue), 0);
    });

    test('pruneFailed deletes only the old failed jobs', () async {
      PlanJob.plan('prune', tries: 1, failTimes: 99);
      String old = await PlanJob('prune').dispatch();
      String fresh = await PlanJob('prune').dispatch();
      await _work();
      expect(await _failed(), hasLength(2));
      await _ageFailed(old, Duration(hours: 5));
      int count = await Queue.driver.pruneFailed(
        DateTime.now().subtract(Duration(hours: 2)),
      );
      expect(count, greaterThanOrEqualTo(1));
      List<String> left = <String>[
        for (FailedJob job in await _failed()) job.id,
      ];
      expect(left, <String>[fresh]);
    });

    test('retry resets the exception count (#19)', () async {
      Plan plan = PlanJob.plan(
        'retry-count',
        tries: 10,
        failTimes: 99,
        maxExceptions: 2,
      );
      String id = await PlanJob('retry-count').dispatch();
      await _work();
      expect(plan.runs, 2);
      expect(await _failed(), hasLength(1));

      // the next try fails once more, then works
      plan.failTimes = plan.runs + 1;
      expect(await Queue.driver.retry(id), true);
      Map<String, dynamic> payload = jsonDecode(
        '${(await _rows()).single['payload']}',
      );
      expect(payload['attempts'], 0);
      expect(payload.containsKey('exceptions'), false);
      await _work();
      // with the old count (2) the first error would fail it again
      expect(plan.runs, 4);
      expect(await _failed(), isEmpty);
      expect(await _rows(), isEmpty);
    });

    test('retry gives a new retryUntil window (#19)', () async {
      Plan plan = PlanJob.plan(
        'retry-until',
        failTimes: 99,
        retryUntil: () => DateTime.now().subtract(Duration(seconds: 1)),
      );
      String id = await PlanJob('retry-until').dispatch();
      await _work();
      expect(plan.runs, 1);
      expect(await _failed(), hasLength(1));

      plan.retryUntil = () => DateTime.now().add(Duration(minutes: 1));
      plan.failTimes = plan.runs + 1;
      int now = DateTime.now().millisecondsSinceEpoch;
      expect(await Queue.driver.retry(id), true);
      Map<String, dynamic> payload = jsonDecode(
        '${(await _rows()).single['payload']}',
      );
      expect(payload['retryUntil'] as int, greaterThan(now + 50000));
      await _work();
      expect(plan.runs, 3);
      expect(await _failed(), isEmpty);
    });
  });

  group('3.1 round 3: Queue.fake and Mail.useQueue', () {
    MailQueue? before;

    setUp(() {
      try {
        before = Mail.mailQueue;
      } on StateError {
        before = null;
      }
    });

    tearDown(() {
      Queue.restore();
      Mail.restore();
      Mail.useQueue(before);
    });

    test('Mail.fake() first: Queue.restore keeps the useQueue queue', () {
      RecordQueue mine = RecordQueue();
      Mail.useQueue(mine);
      ArrayTransport mail = Mail.fake();
      Queue.fake();
      // while both are on, Mail.fake() catches queued mail
      expect(Mail.mailQueue, same(mail));
      Queue.restore();
      Mail.restore();
      expect(Mail.mailQueue, same(mine));
    });

    test('Queue.fake() alone: restore puts the old queue back', () async {
      RecordQueue mine = RecordQueue();
      Mail.useQueue(mine);
      QueueFake fake = Queue.fake();
      await Mail.queue(
        Message(
          to: <Address>[Address('ann@x.com')],
          subject: 'Faked',
          text: 'x',
        ),
      );
      expect(fake.pushed, hasLength(1));
      expect(mine.pushed, isEmpty);
      Queue.restore();
      expect(Mail.mailQueue, same(mine));
    });
  });
}

/// Set the `failed_at` of the failed job [id] to [age] ago.
Future<void> _ageFailed(String id, Duration age) async {
  await QueryBuilder.table('failed_jobs')
      .where('uuid', id)
      .update(<String, dynamic>{
        'failed_at': DateTime.now().subtract(age).millisecondsSinceEpoch,
      });
}

void _cliTests() {
  group('3.1 round 3: dox queue commands (dox-cli#14)', () {
    // CI clones dox-cli next to dox-test. DOX_CLI points to another one.
    String cli = Platform.environment['DOX_CLI'] ?? '../dox-cli/bin/dox.dart';
    String? skip = File(cli).existsSync() || Platform.environment['CI'] != null
        ? null
        : 'no dox CLI at $cli';
    Directory? temp;
    late String dill;

    setUpAll(() async {
      if (skip != null) return;
      temp = await Directory.systemTemp.createTemp('e310b_pkg_cli_');
      // compile once, so each command starts in a moment
      dill = '${temp!.path}/dox.dill';
      ProcessResult r = await Process.run('dart', <String>[
        'compile',
        'kernel',
        cli,
        '-o',
        dill,
      ]);
      if (r.exitCode != 0) fail('compile: ${r.stdout}${r.stderr}');
    });

    tearDownAll(() async {
      await temp?.delete(recursive: true);
      await _resetQueue('e310b_pkg_cli');
    });

    /// `dox <args>` in this app
    Future<ProcessResult> dox(List<String> args) {
      return Process.run('dart', <String>[
        dill,
        ...args,
      ]).timeout(Duration(minutes: 3));
    }

    Timeout long = Timeout(Duration(minutes: 4));

    test(
      'help queue:work lists the new flags and commands',
      () async {
        ProcessResult r = await dox(<String>['help', 'queue:work']);
        String out = '${r.stdout}${r.stderr}';
        expect(r.exitCode, 0, reason: out);
        for (String flag in <String>[
          '--backoff',
          '--max-jobs',
          '--max-time',
          '--memory',
        ]) {
          expect(out, contains(flag));
        }
        ProcessResult all = await dox(<String>['help']);
        for (String command in <String>[
          'queue:clear',
          'queue:restart',
          'queue:prune-failed',
        ]) {
          expect('${all.stdout}', contains(command));
        }
      },
      skip: skip,
      timeout: long,
    );

    test(
      'queue:clear deletes the jobs of one queue',
      () async {
        _configureQueue();
        try {
          PlanJob.plan('cli');
          await PlanJob('cli').dispatch(queue: 'e310b_pkg_cli');
          await PlanJob('cli').dispatch(queue: 'e310b_pkg_cli');
          await PlanJob('cli').dispatch(queue: 'e310b_pkg_cli_keep');
        } finally {
          Queue.configure(queueConfig);
        }
        addTearDown(() => Queue.driver.clear('e310b_pkg_cli_keep'));
        ProcessResult r = await dox(<String>['queue:clear', 'e310b_pkg_cli']);
        String out = '${r.stdout}${r.stderr}';
        expect(r.exitCode, 0, reason: out);
        expect(out, contains('Deleted 2 jobs of the e310b_pkg_cli queue'));
        expect(await _rows('e310b_pkg_cli'), isEmpty);
        expect(await _rows('e310b_pkg_cli_keep'), hasLength(1));
      },
      skip: skip,
      timeout: long,
    );

    test(
      'queue:prune-failed --hours=2 deletes the old failed job only',
      () async {
        _configureQueue();
        String old, fresh;
        try {
          PlanJob.plan('cli-prune', tries: 1, failTimes: 99);
          old = await PlanJob('cli-prune').dispatch(queue: 'e310b_pkg_cli');
          fresh = await PlanJob('cli-prune').dispatch(queue: 'e310b_pkg_cli');
          await _work(queue: 'e310b_pkg_cli');
        } finally {
          Queue.configure(queueConfig);
        }
        await _ageFailed(old, Duration(hours: 3));
        ProcessResult r = await dox(<String>[
          'queue:prune-failed',
          '--hours=2',
        ]);
        String out = '${r.stdout}${r.stderr}';
        expect(r.exitCode, 0, reason: out);
        expect(out, contains('failed jobs'));
        List<String> left = <String>[
          for (FailedJob job in await _failed('e310b_pkg_cli')) job.id,
        ];
        expect(left, <String>[fresh]);
      },
      skip: skip,
      timeout: long,
    );

    test(
      'queue:restart stops a running worker',
      () async {
        Process worker = await Process.start('dart', <String>[
          'run',
          'bin/queue.dart',
          'work',
          '--queue=e310b_pkg_restart',
          '--sleep=1',
        ]);
        StringBuffer out = StringBuffer();
        Completer<void> started = Completer<void>();
        void read(String text) {
          out.write(text);
          if (!started.isCompleted && '$out'.contains('worker started')) {
            started.complete();
          }
        }

        worker.stdout.transform(utf8.decoder).listen(read);
        worker.stderr.transform(utf8.decoder).listen(read);
        addTearDown(() => worker.kill(ProcessSignal.sigkill));
        await started.future.timeout(
          Duration(seconds: 90),
          onTimeout: () => fail('the worker did not start:\n$out'),
        );

        ProcessResult r = await dox(<String>['queue:restart']);
        expect(r.exitCode, 0, reason: '${r.stdout}${r.stderr}');
        expect('${r.stdout}', contains('stop after their current jobs'));

        // the worker reads the cache every 3 seconds
        int code = await worker.exitCode.timeout(
          Duration(seconds: 20),
          onTimeout: () => -1,
        );
        expect(code, 0, reason: '$out');
        expect('$out', contains('restart'));
      },
      skip: skip,
      timeout: long,
    );

    test(
      'a deleted .dart_tool/dox/commands.dart is written again',
      () async {
        File runner = File('.dart_tool/dox/commands.dart');
        File cache = File('.dart_tool/dox/commands.json');
        // a first run writes the cache and the runner
        ProcessResult first = await dox(<String>['queue:table']);
        expect(
          '${first.stdout}${first.stderr}',
          contains('create_queue_tables'),
        );
        expect(cache.existsSync(), true);
        expect(runner.existsSync(), true);

        runner.deleteSync();
        ProcessResult r = await dox(<String>['queue:table']);
        String out = '${r.stdout}${r.stderr}';
        // the same answer as before: the migration is there (exit 1)
        expect(r.exitCode, first.exitCode, reason: out);
        expect(out, contains('create_queue_tables'));
        expect(out, isNot(contains('FileSystemException')));
        expect(runner.existsSync(), true);
      },
      skip: skip,
      timeout: long,
    );
  });
}

void _mailerTests(JobsHelper jobs) {
  MailHog mailhog = MailHog();

  Message message({String subject = 'Hi'}) {
    return Message(
      to: <Address>[Address('ann@x.com')],
      cc: <Address>[Address('cc@x.com')],
      bcc: <Address>[Address('bcc@x.com')],
      subject: subject,
      text: 'hi',
    );
  }

  void reset() {
    Mail.clearHooks();
    Mail.alwaysTo(null);
    Mail.restore();
    Mail.configure(mailConfig);
  }

  group('3.1 round 3: dox_mailer hooks, alwaysTo, Mail.to', () {
    tearDown(reset);

    test('onSending and onSent run, clearHooks removes them', () async {
      ArrayTransport mail = Mail.fake();
      List<String> sending = <String>[];
      List<String?> sent = <String?>[];
      Mail.onSending((Message m) => sending.add(m.subject));
      Mail.onSent((SentMessage s) async {
        await Future<void>.delayed(Duration(milliseconds: 1));
        sent.add(s.message.subject);
      });
      await Mail.send(message(subject: 'one'));
      expect(sending, <String>['one']);
      expect(sent, <String>['one']);
      // the hook sees the from of the config
      Mail.onSending((Message m) => sending.add('${m.from?.email}'));
      await Mail.send(message(subject: 'two'));
      expect(sending, <String>['one', 'two', mailConfig.from!.email]);

      Mail.clearHooks();
      await Mail.send(message(subject: 'three'));
      expect(sending, hasLength(3));
      expect(sent, <String>['one', 'two']);
      expect(mail.messages, hasLength(3));
    });

    test('a throwing onSending stops the email', () async {
      ArrayTransport mail = Mail.fake();
      Mail.onSending((Message m) => throw StateError('no email today'));
      await expectLater(Mail.send(message()), throwsA(isA<StateError>()));
      mail.assertNothingSent();
    });

    test('a throwing onSent: the error is logged, send still works', () async {
      ArrayTransport mail = Mail.fake();
      List<String?> sent = <String?>[];
      try {
        Mail.onSent((SentMessage s) async => throw StateError('log is down'));
        Mail.onSent((SentMessage s) async => sent.add(s.message.subject));
        await Mail.send(message(subject: 'already out'));
        expect(mail.messages.single.subject, 'already out');
        // the hook after the throwing one still runs
        expect(sent, <String>['already out']);
      } finally {
        Mail.clearHooks();
      }
    });

    test('alwaysTo: every email goes to one address, no cc or bcc', () async {
      ArrayTransport mail = Mail.fake();
      Mail.alwaysTo('QA <qa@e310b.test>');
      Message hookSaw = message();
      Mail.onSending((Message m) => hookSaw = m);
      await Mail.send(message(subject: 'staging'));
      Message got = mail.messages.single;
      expect(got.to.map((Address a) => a.email), <String>['qa@e310b.test']);
      expect(got.to.single.name, 'QA');
      expect(got.cc, isEmpty);
      expect(got.bcc, isEmpty);
      // the hook sees the new address
      expect(hookSaw.to.single.email, 'qa@e310b.test');

      // a list works, null turns it off
      Mail.alwaysTo(<Object>['a@e310b.test', Address('b@e310b.test')]);
      await Mail.raw('x', to: 'ann@x.com');
      expect(mail.messages.last.to.map((Address a) => a.email), <String>[
        'a@e310b.test',
        'b@e310b.test',
      ]);
      Mail.alwaysTo(null);
      await Mail.send(message(subject: 'off'));
      expect(mail.messages.last.to.single.email, 'ann@x.com');
      expect(mail.messages.last.cc.single.email, 'cc@x.com');
    });

    test('alwaysTo: a bad address throws at once', () {
      expect(
        () => Mail.alwaysTo('qa@e310b.test\r\nBcc: evil@x.com'),
        throwsA(isA<MailException>()),
      );
      expect(() => Mail.alwaysTo(42), throwsArgumentError);
    });

    test('Mail.raw: a plain text email, the address is parsed', () async {
      ArrayTransport mail = Mail.fake();
      await Mail.raw(
        'Your code is 1234',
        to: 'Ann Lee <ann@x.com>',
        subject: 'Your code',
      );
      Message m = mail.messages.single;
      expect(m.text, 'Your code is 1234');
      expect(m.html, isNull);
      expect(m.subject, 'Your code');
      expect(m.to.single.email, 'ann@x.com');
      expect(m.to.single.name, 'Ann Lee');
      // a bad address type
      expect(() => Mail.raw('x', to: 5), throwsArgumentError);
    });

    test('Mail.to().cc().bcc(): send, queue, later and raw', () async {
      ArrayTransport mail = Mail.fake();
      await Mail.to('Bob <bob@x.com>')
          .cc('cc@x.com')
          .bcc(<Object>['b1@x.com', Address('b2@x.com')])
          .send(E310bMail());
      Message sent = mail.messages.single;
      // the mailable's own `to` is kept, the builder adds more
      expect(sent.to.map((Address a) => a.email), <String>[
        'ann@x.com',
        'bob@x.com',
      ]);
      expect(sent.cc.single.email, 'cc@x.com');
      expect(sent.bcc.map((Address a) => a.email), <String>[
        'b1@x.com',
        'b2@x.com',
      ]);
      expect(sent.subject, 'E310b mail');

      await Mail.to('bob@x.com').cc('cc@x.com').queue(E310bMail());
      await Mail.to('bob@x.com')
          .later(Duration(minutes: 5), E310bMail(), queue: 'e310b_pkg_mail');
      expect(mail.queued, hasLength(2));
      expect(mail.queued.first.message.cc.single.email, 'cc@x.com');
      expect(mail.queued.last.delay, Duration(minutes: 5));
      expect(mail.queued.last.message.to.last.email, 'bob@x.com');

      await Mail.to(<String>['x@x.com', 'y@x.com']).raw('raw', subject: 'R');
      expect(mail.messages.last.text, 'raw');
      expect(mail.messages.last.to, hasLength(2));
    });

    test('Address.list: an Address, text, a list; else ArgumentError', () {
      expect(Address.list('ann@x.com').single.email, 'ann@x.com');
      List<Address> mixed = Address.list(<Object>[
        'Ann <ann@x.com>',
        Address('bob@x.com', 'Bob'),
      ]);
      expect(mixed.map((Address a) => a.name), <String?>['Ann', 'Bob']);
      expect(Address.list(<String>[]), isEmpty);
      expect(() => Address.list(42), throwsArgumentError);
      expect(
        () => Address.list(<Object?>['a@x.com', null]),
        throwsArgumentError,
      );
    });

    test('Markdown: a user value with a link or ** stays text', () {
      Message m = LinkMail(
        name: '[Verify](https://evil.test) **bold** `code` # x | y',
        url: 'https://ok.test',
      ).toMessage();
      String html = m.html!;
      expect(html, isNot(contains('href="https://evil.test"')));
      expect(html, isNot(contains('<strong>bold</strong>')));
      expect(html, contains('[Verify](https://evil.test)'));
      expect(html, contains('**bold**'));
      // the url of the template is still a link
      expect(html, contains('href="https://ok.test"'));
      // the text body shows the value as it is
      expect(m.text, contains('# Hello [Verify](https://evil.test) **bold**'));
      // no private-use mask characters leak out
      expect(html, isNot(contains(RegExp('[-]'))));
      expect(m.text, isNot(contains(RegExp('[-]'))));
    });

    test('Markdown: a SafeString value is still Markdown', () {
      Message m = LinkMail(name: '**x**', url: 'https://ok.test').toMessage();
      expect(m.html, isNot(contains('<strong>x</strong>')));
      Message safe = SafeMarkdownMail().toMessage();
      expect(safe.html, contains('<strong>x</strong>'));
    });

    test('failover: an async onError that throws is not uncaught', () async {
      ArrayTransport second = ArrayTransport();
      int calls = 0;
      List<Object> uncaught = <Object>[];
      await runZonedGuarded(
        () async {
          Mail.configure(
            MailConfig(
              from: mailConfig.from,
              defaultMailer: 'failover',
              mailers: <String, Transport>{
                'failover': FailoverTransport(
                  <Transport>[BrokenTransport(), second],
                  onError: (Transport t, Object e, StackTrace s) async {
                    calls++;
                    await Future<void>.delayed(Duration.zero);
                    throw StateError('async onError broke');
                  },
                ),
              },
            ),
          );
          await Mail.send(message(subject: 'async failover'));
          await Future<void>.delayed(Duration(milliseconds: 100));
        },
        (Object e, StackTrace s) {
          uncaught.add(e);
        },
      );
      expect(calls, 1);
      expect(second.messages.single.subject, 'async failover');
      expect(uncaught, isEmpty);
    });
  });

  group('3.1 round 3: dox_mailer over SMTP (MailHog)', () {
    setUpAll(mailhog.check);

    tearDown(() async {
      reset();
      await _resetQueue('e310b_pkg_mail');
    });

    test('Mail.to().cc().raw() reaches the inbox with the Cc', () async {
      if (mailhog.skip(markTestSkipped)) return;
      String to = 'e310b.to.${jobs.stamp()}@jobs.dox-test.dev';
      String cc = 'e310b.cc.${jobs.stamp()}@jobs.dox-test.dev';
      await Mail.to(to).cc(cc).raw('raw body', subject: 'E310b raw');
      MailHogMessage mail = await mailhog.waitFor(to);
      expect(mail.subject, 'E310b raw');
      expect(mail.text, contains('raw body'));
      expect(mail.header('Cc'), contains(cc));
    });

    test('alwaysTo counts for a queued email when the worker sends', () async {
      if (mailhog.skip(markTestSkipped)) return;
      String real = 'e310b.real.${jobs.stamp()}@jobs.dox-test.dev';
      String qa = 'e310b.qa.${jobs.stamp()}@jobs.dox-test.dev';
      String subject = 'E310b queued ${jobs.stamp()}';
      await Mail.queue(
        Message(
          to: <Address>[Address(real)],
          cc: <Address>[Address('cc.$real')],
          subject: subject,
          text: 'queued',
        ),
        queue: 'e310b_pkg_mail',
      );
      // set after the queue call: it counts at send time
      Mail.alwaysTo(qa);
      await _work(queue: 'e310b_pkg_mail');
      MailHogMessage mail = await mailhog.waitFor(qa);
      expect(mail.subject, subject);
      expect(mail.header('Cc'), isEmpty);
      expect(await mailhog.find(real), isEmpty);
      expect(await mailhog.find('cc.$real'), isEmpty);
    });
  });
}

void _storageTests(Api api) {
  group('3.1 round 3: dox_storage', () {
    String folder = 'e310b_pkg_storage';
    Disk disk(String name) => Storage().use(name);
    List<String> disks = <String>['local', 'memory', 's3'];

    tearDownAll(() async {
      for (String name in <String>[...disks, 'atomic']) {
        await disk(name).deleteAll(folder);
        await disk(name).deleteAll(E310bPkgRoutes.folder);
      }
    });

    for (String name in disks) {
      test('$name: directoryExists is true for a folder only', () async {
        await disk(name).put('$folder/dir/sub/a.txt', 'a');
        expect(await disk(name).directoryExists('$folder/dir/sub'), true);
        expect(await disk(name).directoryExists('$folder/dir'), true);
        expect(await disk(name).directoryExists('$folder/dir/'), true);
        expect(
          await disk(name).directoryExists('$folder/dir/sub/a.txt'),
          false,
        );
        expect(await disk(name).directoryExists('$folder/missing'), false);
        // a name that only starts like the folder is not it
        expect(await disk(name).directoryExists('$folder/di'), false);
        // exists() is still for files only
        expect(await disk(name).exists('$folder/dir/sub'), false);
        expect(
          () => disk(name).directoryExists('../$folder'),
          throwsA(isA<InvalidKeyException>()),
        );
      });

      test('$name: assertExists and assertMissing', () async {
        String key = '$folder/assert.txt';
        await disk(name).put(key, 'x');
        await disk(name).assertExists(key);
        await expectLater(
          disk(name).assertMissing(key),
          throwsA(
            isA<StateError>().having(
              (StateError e) => e.message,
              'message',
              contains(key),
            ),
          ),
        );
        await disk(name).delete(key);
        await disk(name).assertMissing(key);
        await expectLater(
          disk(name).assertExists(key),
          throwsA(isA<StateError>()),
        );
      });
    }

    test('local: an empty folder exists, Storage().directoryExists', () async {
      await disk('local').makeDirectory('$folder/empty');
      expect(await disk('local').directoryExists('$folder/empty'), true);
      expect(await Storage().disk('local').directoryExists(folder), true);
      // memory has no real folders: an empty one is not there
      await disk('memory').makeDirectory('$folder/empty');
      expect(await disk('memory').directoryExists('$folder/empty'), false);
    });

    test('temporaryUrl works like signedUrl', () async {
      String key = '$folder/temp-url.txt';
      Storage local = Storage().disk('local');
      await disk('local').put(key, 'temporary');
      String temporary = await local.temporaryUrl(key);
      String signed = await local.signedUrl(key);
      expect(Uri.parse(temporary).path, Uri.parse(signed).path);
      http.Response res = await http.get(Uri.parse(temporary));
      expect(res.statusCode, 200);
      expect(res.body, 'temporary');
      // an expired one is refused
      String expired = await local.temporaryUrl(
        key,
        expiresIn: Duration(seconds: -5),
      );
      expect((await http.get(Uri.parse(expired))).statusCode, 403);
    });

    test('append after the file was deleted makes it again', () async {
      Disk vanishing = Disk(VanishingDriver());
      await vanishing.put('$folder/a.txt', 'one');
      (vanishing.driver as VanishingDriver).vanish = true;
      await vanishing.append('$folder/a.txt', 'two');
      expect(await vanishing.getString('$folder/a.txt'), 'one\ntwo');
      // prepend too
      await vanishing.prepend('$folder/a.txt', 'zero');
      expect(await vanishing.getString('$folder/a.txt'), 'zero\none\ntwo');
    });

    test('append calls getMetaData of a LocalDriver subclass', () async {
      Directory dir = await Directory.systemTemp.createTemp('e310b_pkg_');
      addTearDown(() => dir.delete(recursive: true));
      CountingLocalDriver driver = CountingLocalDriver(dir.path);
      Disk local = Disk(driver);
      await local.put('$folder/count.txt', 'a');
      await local.append('$folder/count.txt', 'b');
      expect(driver.metaReads, greaterThanOrEqualTo(1));
      expect(await local.getString('$folder/count.txt'), 'a\nb');
    });

    test('atomic_writes: a 251 byte file name works', () async {
      String name = '${'b' * 247}.txt';
      expect(utf8.encode(name).length, 251);
      String key = '$folder/$name';
      await disk('atomic').put(key, 'one');
      await disk('atomic').put(key, 'two');
      expect(await disk('atomic').getString(key), 'two');
      // 250 bytes of a 2 byte letter, also fine
      String wide = '${'ü' * 123}.txt';
      expect(utf8.encode(wide).length, 250);
      await disk('atomic').put('$folder/$wide', 'wide');
      expect(await disk('atomic').getString('$folder/$wide'), 'wide');
      List<String> left =
          Directory('${AppConstants.storageRoot}/atomic/$folder')
              .listSync()
              .map((FileSystemEntity e) => e.uri.pathSegments.last)
              .where((String n) => n.endsWith(StorageConstants.localTempSuffix))
              .toList();
      expect(left, isEmpty);
      // a name over the limit still fails with a storage error
      await expectLater(
        disk('atomic').put('$folder/${'c' * 300}.txt', 'x'),
        throwsA(isA<StorageException>()),
      );
    });

    /// multipart upload of [text] as `file` to [path]
    Future<http.Response> upload(String path, String text, String filename) {
      return api.uploadBytes(path, 'file', utf8.encode(text), filename);
    }

    for (String name in disks) {
      test('$name: file.store(folder, disk:) over HTTP', () async {
        http.Response res = await upload(
          '/core/e310b-pkg/store?disk=$name',
          'stored on $name',
          'up.txt',
        );
        expect(res.statusCode, 200, reason: res.body);
        Map<String, dynamic> body = api.json(res);
        String path = body['path'];
        expect(path, startsWith('${E310bPkgRoutes.folder}/'));
        expect(path, endsWith('.txt'));
        expect(path, isNot(contains('up.txt')));
        expect(body['text'], 'stored on $name');
        expect(await disk(name).getString(path), 'stored on $name');
        // not on the default disk (local), unless it is that one
        if (name != 'local') {
          expect(await disk('local').exists(path), false);
        }
      });

      test('$name: file.storeAs(folder, name, disk:) over HTTP', () async {
        String file = 'named-$name.txt';
        http.Response res = await upload(
          '/core/e310b-pkg/store-as?disk=$name&name=$file',
          'first',
          'whatever.bin',
        );
        expect(res.statusCode, 200, reason: res.body);
        expect(api.json(res)['path'], '${E310bPkgRoutes.folder}/$file');
        // the same name again replaces the file
        res = await upload(
          '/core/e310b-pkg/store-as?disk=$name&name=$file',
          'second',
          'whatever.bin',
        );
        expect(res.statusCode, 200, reason: res.body);
        expect(
          await disk(name).getString('${E310bPkgRoutes.folder}/$file'),
          'second',
        );
      });
    }

    test('putRequestFileAs on the default disk over HTTP', () async {
      http.Response res = await upload(
        '/core/e310b-pkg/put-as?name=put-as.txt',
        'put as',
        'x.txt',
      );
      expect(res.statusCode, 200, reason: res.body);
      expect(api.json(res)['path'], '${E310bPkgRoutes.folder}/put-as.txt');
      expect(
        await Storage().use().getString('${E310bPkgRoutes.folder}/put-as.txt'),
        'put as',
      );
    });

    test('storeAs with ../ in the name is refused', () async {
      http.Response res = await upload(
        '/core/e310b-pkg/store-as?disk=local&name=../../e310b_pkg_escape.txt',
        'escape',
        'x.txt',
      );
      expect(res.statusCode, isNot(200), reason: res.body);
      expect(File('storage/e310b_pkg_escape.txt').existsSync(), false);
      expect(
        File('${AppConstants.storageRoot}/e310b_pkg_escape.txt').existsSync(),
        false,
      );
      expect(File('e310b_pkg_escape.txt').existsSync(), false);
    });
  });
}

void _schedulerTests() {
  group('3.1 round 3: dox_scheduler checks', () {
    Schedule s() => Schedule();

    test('yearlyOn(2, 30) throws a RangeError, (2, 29) is fine', () {
      expect(() => s().call('a', () {}).yearlyOn(2, 30), throwsRangeError);
      expect(() => s().call('b', () {}).yearlyOn(4, 31), throwsRangeError);
      expect(() => s().call('c', () {}).yearlyOn(2, 0), throwsRangeError);
      expect(() => s().call('d', () {}).yearlyOn(13), throwsRangeError);
      ScheduledTask leap = s().call('leap', () {}).yearlyOn(2, 29);
      expect(leap.isDue(DateTime.utc(2028, 2, 29)), true);
      expect(leap.isDue(DateTime.utc(2028, 3)), false);
      // 2027 has no 29 February: the next run is in 2028
      expect(leap.nextRun(DateTime.utc(2027)), DateTime.utc(2028, 2, 29));
      ScheduledTask dec = s().call('dec', () {}).yearlyOn(12, 31, '23:59');
      expect(dec.isDue(DateTime.utc(2026, 12, 31, 23, 59)), true);
    });

    test('a bad yearlyOn or quarterlyOn leaves the task as it was', () {
      ScheduledTask task = s().call('kept', () {}).dailyAt('10:00');
      expect(() => task.quarterlyOn(32), throwsRangeError);
      expect(() => task.quarterlyOn(0), throwsRangeError);
      expect(() => task.quarterlyOn(1, '25:00'), throwsA(anything));
      expect(() => task.yearlyOn(2, 30), throwsRangeError);
      expect(() => task.yearlyOn(6, 1, 'noon'), throwsA(anything));
      // still daily at 10:00, also in a month that is not a quarter
      expect(task.isDue(DateTime.utc(2026, 11, 5, 10)), true);
      expect(task.isDue(DateTime.utc(2026, 2, 17, 10)), true);
      expect(task.isDue(DateTime.utc(2026, 11, 5)), false);
      // a good quarterlyOn after the bad ones works
      task.quarterlyOn(4, '14:00');
      expect(task.isDue(DateTime.utc(2026, 4, 4, 14)), true);
      expect(task.isDue(DateTime.utc(2026, 5, 4, 14)), false);
    });

    test('environments() with a blank name throws an ArgumentError', () {
      for (List<String> names in <List<String>>[
        <String>[''],
        <String>['   '],
        <String>['production', ''],
        <String>[],
      ]) {
        expect(
          () => s().call('env', () {}).environments(names),
          throwsArgumentError,
          reason: '$names',
        );
      }
      // a good list still works
      s().call('ok', () {}).environments(<String>[' Production ']);
    });

    String? realAppEnv = Platform.environment.containsKey('APP_ENV')
        ? 'APP_ENV is a real env variable'
        : null;

    for (String name in <String>['development', 'local']) {
      test(
        'schedule work with APP_ENV=$name prints no lock warning',
        () async {
          String out = await _scheduleWorkOutput(name);
          expect(out, contains('working'));
          expect(out, isNot(contains('onOneServer')));
        },
        skip: realAppEnv,
        timeout: Timeout(Duration(minutes: 3)),
      );
    }

    test(
      'schedule work with APP_ENV=production prints the warning once',
      () async {
        String out = await _scheduleWorkOutput('production');
        expect(out, contains('working'));
        expect(RegExp('onOneServer').allMatches(out), hasLength(1));
        expect(out, contains('the lock store is a memory store'));
      },
      skip: realAppEnv,
      // it may wait up to 3 minutes near 17:00 or 01:00 UTC, see _scheduleWorkOutput
      timeout: Timeout(Duration(minutes: 6)),
    );
  });
}

/// Waits while now is close to a tick at one of [hoursUtc] (UTC hours).
Future<void> _waitOutsideTicks(List<int> hoursUtc) async {
  for (int hour in hoursUtc) {
    DateTime now = DateTime.now().toUtc();
    DateTime tick = DateTime.utc(now.year, now.month, now.day, hour);
    if (!now.isBefore(tick.subtract(Duration(minutes: 2))) &&
        now.isBefore(tick.add(Duration(minutes: 1)))) {
      await Future<void>.delayed(
        tick.add(Duration(minutes: 1)).difference(now),
      );
    }
  }
}

/// Starts `dart run bin/schedule.dart work` with [appEnv], waits until it
/// prints `working`, gives it a moment for the warning, then stops it
/// with Ctrl+C. Gives all it printed. It starts in the first seconds of
/// a minute, so it stops before the first tick runs a task.
///
/// In production two tasks can run in the first minute of 17:00 UTC and
/// 01:00 UTC: `prune-failed-jobs` (00:00 Bangkok) and `daily-report`
/// (08:00 Bangkok, it puts a job in the shared queue). The process can
/// live for about 70 seconds. So a production run does not start from
/// 2 minutes before to 1 minute after these times: it waits until after.
Future<String> _scheduleWorkOutput(String appEnv) async {
  int second = DateTime.now().second;
  if (second > 30) {
    await Future<void>.delayed(Duration(seconds: 61 - second));
  }
  if (appEnv == 'production') await _waitOutsideTicks(<int>[17, 1]);
  Process p = await Process.start(
    'dart',
    <String>['run', 'bin/schedule.dart', 'work'],
    environment: <String, String>{'APP_ENV': appEnv},
  );
  StringBuffer out = StringBuffer();
  Completer<void> ready = Completer<void>();
  void read(String text) {
    out.write(text);
    if (!ready.isCompleted && '$out'.contains('working')) ready.complete();
  }

  p.stdout.transform(utf8.decoder).listen(read);
  p.stderr.transform(utf8.decoder).listen(read);
  unawaited(
    p.exitCode.then((int _) {
      if (!ready.isCompleted) ready.complete();
    }),
  );
  await ready.future.timeout(Duration(seconds: 60), onTimeout: () {});
  await Future<void>.delayed(Duration(milliseconds: 500));
  p.kill(ProcessSignal.sigint);
  await p.exitCode.timeout(
    Duration(seconds: 10),
    onTimeout: () {
      p.kill(ProcessSignal.sigkill);
      return -1;
    },
  );
  return '$out';
}

void _inertiaTests(Api api) {
  group('3.1 round 3: dox_inertia (dox-inertia#7)', () {
    // like e2e_test.dart: a hot file gives the dev server tags, so no
    // `npm run build` is needed
    File hot = File('public/hot');
    bool madeHot = false;
    String version = '';
    Browser browser = Browser(api);
    String base = '/inertia/e310b-pkg';

    setUpAll(() async {
      if (!await hot.exists()) {
        await hot.writeAsString('http://localhost:5173');
        madeHot = true;
      }
      // the global props are set at boot by AppInertiaProvider
      http.Response html = await browser.send(
        'GET',
        '$base/render',
        <String, String>{},
      );
      expect(html.statusCode, 200, reason: html.body);
      Map<String, dynamic> page = jsonDecode(
        RegExp(r'data-page="app" type="application/json">(.*?)</script>')
            .firstMatch(html.body)![1]!,
      );
      version = page['version'] ?? '';
    });

    tearDownAll(() async {
      if (madeHot) await hot.delete();
    });

    Map<String, String> headers([Map<String, String>? extra]) {
      return <String, String>{
        'X-Inertia': 'true',
        'X-Inertia-Version': version,
        'Content-Type': 'application/json',
        ...?extra,
      };
    }

    test('Inertia.render: props, globals, lazy and deferred', () async {
      http.Response res = await browser.send('GET', '$base/render', headers());
      expect(res.statusCode, 200, reason: res.body);
      Map<String, dynamic> page = api.json(res);
      expect(page['component'], 'Home');
      Map<String, dynamic> props = page['props'];
      expect(props['e310b_pkg_page'], 'page');
      expect(props['e310b_pkg_global'], 'global value');
      // the page prop wins over the global one
      expect(props['e310b_pkg_who'], 'page prop');
      // the middleware share is still there
      expect(props['appName'], isNotEmpty);
      // lazy and deferred props are not sent on a full visit
      expect(props.containsKey('e310b_pkg_lazy'), false);
      expect(props.containsKey('e310b_pkg_feed'), false);
      expect(
        (page['deferredProps']['default'] as List<dynamic>).toSet(),
        <String>{'e310b_pkg_feed', 'e310b_pkg_feed2', 'e310b_pkg_plain'},
      );
      // a deferred prop that is not sent is not in mergeProps
      expect(page['mergeProps'] ?? <dynamic>[], isEmpty);
      expect(page['sharedProps'], contains('e310b_pkg_global'));
    });

    test('a request share wins over a global one', () async {
      http.Response res = await browser.send(
        'GET',
        '$base/request-share',
        headers(),
      );
      expect(res.statusCode, 200, reason: res.body);
      Map<String, dynamic> props = api.json(res)['props'];
      expect(props['e310b_pkg_who'], 'request');
      expect(props['e310b_pkg_global'], 'global value');
    });

    test(
      'partial reload: lazy is sent, merged defer is in mergeProps',
      () async {
        http.Response res = await browser.send(
          'GET',
          '$base/render',
          headers(<String, String>{
            'X-Inertia-Partial-Component': 'Home',
            'X-Inertia-Partial-Data':
                'e310b_pkg_lazy,e310b_pkg_feed,e310b_pkg_feed2,e310b_pkg_plain',
          }),
        );
        expect(res.statusCode, 200, reason: res.body);
        Map<String, dynamic> page = api.json(res);
        Map<String, dynamic> props = page['props'];
        expect(props['e310b_pkg_lazy'], 'lazy value');
        expect(props['e310b_pkg_feed'], <int>[1, 2]);
        expect(props['e310b_pkg_feed2'], <int>[1, 2]);
        expect(props['e310b_pkg_plain'], <int>[1, 2]);
        expect((page['mergeProps'] as List<dynamic>).toSet(), <String>{
          'e310b_pkg_feed',
          'e310b_pkg_feed2',
        });
        // a global prop is not sent when not asked
        expect(props.containsKey('e310b_pkg_global'), false);
      },
    );

    test('partial reload with a reset: the prop is not merged', () async {
      http.Response res = await browser.send(
        'GET',
        '$base/render',
        headers(<String, String>{
          'X-Inertia-Partial-Component': 'Home',
          'X-Inertia-Partial-Data': 'e310b_pkg_feed,e310b_pkg_feed2',
          'X-Inertia-Reset': 'e310b_pkg_feed',
        }),
      );
      expect(res.statusCode, 200, reason: res.body);
      expect(api.json(res)['mergeProps'], <String>['e310b_pkg_feed2']);
    });

    test('empty 200 to an Inertia GET goes back to the Referer', () async {
      String from = api.uri('/inertia/notes').toString();
      http.Response res = await browser.send(
        'GET',
        '$base/empty',
        headers(<String, String>{'Referer': from}),
      );
      expect(res.statusCode, 302, reason: res.body);
      expect(res.headers['location'], endsWith('/inertia/notes'));
      expect(res.headers['location'], isNot(contains('e310b-pkg')));
    });

    test('empty 200: a foreign Referer is never used, it goes to /', () async {
      for (String referer in <String>[
        'https://evil.test/inertia/notes',
        '//evil.test/x',
        'javascript:alert(1)',
        'not a url',
      ]) {
        http.Response res = await browser.send(
          'GET',
          '$base/empty',
          headers(<String, String>{'Referer': referer}),
        );
        expect(res.statusCode, 302, reason: referer);
        String location = res.headers['location']!;
        expect(location, isNot(contains('evil')), reason: referer);
        expect(location, isNot(contains('javascript')), reason: referer);
        expect(Uri.parse(location).path, '/', reason: referer);
      }
      // no Referer at all
      http.Response none = await browser.send('GET', '$base/empty', headers());
      expect(none.statusCode, 302);
      expect(Uri.parse(none.headers['location']!).path, '/');
    });

    test('empty 200 after PUT, PATCH and DELETE gives 303', () async {
      String from = api.uri('/inertia/notes').toString();
      for (String method in <String>['PUT', 'PATCH', 'DELETE']) {
        http.Response res = await browser.send(
          method,
          '$base/empty',
          headers(<String, String>{'Referer': from}),
          '{}',
        );
        expect(res.statusCode, 303, reason: '$method ${res.body}');
        expect(res.headers['location'], endsWith('/inertia/notes'));
      }
      // POST keeps 302
      http.Response post = await browser.send(
        'POST',
        '$base/empty',
        headers(<String, String>{'Referer': from}),
        '{}',
      );
      expect(post.statusCode, 302, reason: post.body);
    });

    test('no X-Inertia: the empty 200 is sent as it is', () async {
      http.Response res = await browser.send(
        'GET',
        '$base/empty',
        <String, String>{'Referer': api.uri('/inertia/notes').toString()},
      );
      expect(res.statusCode, 200);
      expect(res.body, isEmpty);
      expect(res.headers['location'], isNull);
    });
  });
}

void _viewTests(Api api) {
  group('3.1 round 3: dox_view tags (dox-view#8)', () {
    ViewEngine engine(Map<String, String> templates, {String env = 'local'}) {
      return ViewEngine(MemoryTemplateLoader(templates), environment: env);
    }

    String render(
      String source, {
      Map<String, Object?> data = const <String, Object?>{},
      Map<String, Object?> shared = const <String, Object?>{},
      Map<String, String> more = const <String, String>{},
      String env = 'local',
    }) {
      return engine(<String, String>{
        'page': source,
        ...more,
      }, env: env).render('page', data, shared).trim();
    }

    test('@isset: null and a field of null are false, 0 is true', () {
      String t = '@isset(user.phone)yes @else no @end';
      expect(render(t, data: <String, Object?>{'user': null}), 'no');
      expect(
        render(
          t,
          data: <String, Object?>{
            'user': <String, Object?>{'phone': null},
          },
        ),
        'no',
      );
      expect(
        render(
          t,
          data: <String, Object?>{
            'user': <String, Object?>{'phone': 0},
          },
        ),
        'yes',
      );
      expect(render('@isset(nothing.here.at.all)yes @else no @end'), 'no');
      expect(
        render('@isset(x) yes @end', data: <String, Object?>{'x': ''}),
        'yes',
      );
    });

    test('@empty: null, false, 0, empty text, list and map are empty', () {
      String t = '@empty(v)empty @else full @end';
      for (Object? v in <Object?>[
        null,
        false,
        0,
        '',
        <int>[],
        <String, int>{},
      ]) {
        expect(
          render(t, data: <String, Object?>{'v': v}),
          'empty',
          reason: '$v',
        );
      }
      for (Object? v in <Object?>[
        true,
        1,
        'a',
        <int>[1],
      ]) {
        expect(
          render(t, data: <String, Object?>{'v': v}),
          'full',
          reason: '$v',
        );
      }
      expect(render('@empty(a.b) empty @end'), 'empty');
    });

    test('@auth and @guest read \$auth, the data can not hide it', () {
      String t = '@auth\nin\n@else\nout\n@end';
      expect(render(t, shared: <String, Object?>{r'$auth': true}), 'in');
      expect(render(t, shared: <String, Object?>{r'$auth': false}), 'out');
      // no request (View.render): a guest
      expect(render(t), 'out');
      expect(render('@guest\nguest\n@end'), 'guest');
      // view data with $auth does not log anyone in
      expect(
        render(
          t,
          data: <String, Object?>{r'$auth': true},
          shared: <String, Object?>{r'$auth': false},
        ),
        'out',
      );
    });

    test("@auth('guard') and @guest('x') throw a ViewException", () {
      expect(
        () => render("@auth('web')\nin\n@end"),
        throwsA(isA<ViewException>()),
      );
      expect(
        () => render("@guest('web')\nout\n@end"),
        throwsA(isA<ViewException>()),
      );
    });

    test('@env and @production ignore case, @env takes a list', () {
      expect(render("@env('LOCAL')yes @else no @end", env: 'Local'), 'yes');
      expect(render("@env('staging')yes @else no @end"), 'no');
      expect(render("@env(['staging', 'local']) yes @end"), 'yes');
      expect(
        render('@production\nprod\n@else\ndev\n@end', env: 'PRODUCTION'),
        'prod',
      );
      expect(render('@production\nprod\n@else\ndev\n@end'), 'dev');
      // @env('') matches an empty environment
      expect(render("@env('')yes @else no @end", env: ''), 'yes');
    });

    test('@once shows once per render, also inside a component', () {
      Map<String, String> more = <String, String>{
        'components/widget': '@once\n<script>w</script>\n@end\n<i>w</i>',
      };
      String html = render('@!widget()\n@!widget()\n@!widget()', more: more);
      expect(RegExp('<script>w</script>').allMatches(html), hasLength(1));
      expect(RegExp('<i>w</i>').allMatches(html), hasLength(3));
      // a new render shows it again
      ViewEngine e = engine(<String, String>{'page': '@!widget()', ...more});
      expect(e.render('page'), contains('<script>w</script>'));
      expect(e.render('page'), contains('<script>w</script>'));
    });

    test('@verbatim keeps {{ }} and tags as text', () {
      String html = render(
        '@verbatim\n<div>{{ message }} @if(x) @end_x</div>\n@end\n{{ n }}',
        data: <String, Object?>{'n': 5},
      );
      expect(html, contains('<div>{{ message }} @if(x) @end_x</div>'));
      expect(html, endsWith('5'));
      expect(() => render('@verbatim\nno end'), throwsA(isA<ViewException>()));
    });

    test('@class: true names only, the names are escaped', () {
      expect(
        render(
          "<a @class(['link', { active: on, muted: !on }])>",
          data: <String, Object?>{'on': true},
        ),
        '<a class="link active">',
      );
      expect(
        render(
          '<a @class(names)>',
          data: <String, Object?>{
            'names': <String, Object?>{'"><script>x</script>': true},
          },
        ),
        '<a class="&quot;&gt;&lt;script&gt;x&lt;/script&gt;">',
      );
      expect(render("<a @class('')>"), '<a class="">');
    });

    test('@checked, @selected and @disabled', () {
      Map<String, Object?> data = <String, Object?>{
        'news': true,
        'lang': 'en',
        'saving': 0,
      };
      expect(render('<input @checked(news)>', data: data), '<input checked>');
      expect(
        render("<option @selected(lang == 'en')>", data: data),
        '<option selected>',
      );
      expect(
        render("<option @selected(lang == 'fr')>", data: data),
        '<option >',
      );
      expect(render('<button @disabled(saving)>', data: data), '<button >');
    });

    test('without ( ) the new tags stay plain text', () {
      for (String text in <String>[
        'mail me @isset today',
        'an @empty box',
        'the @env var',
        'a @class act',
        '@checked and @selected and @disabled',
        'we met @once upon a time',
        'login @auth now',
        'tell @guest hi',
        'code: @verbatim here',
        'built for @production use',
      ]) {
        expect(render(text), text, reason: text);
      }
      // an email address is not a tag
      expect(render('ann@isset(x).com'), 'ann@isset(x).com');
    });

    test('a component with the same name as a tag wins', () {
      Map<String, String> more = <String, String>{
        'components/class': '<b>component {{ \$props.n }}</b>',
        'components/once': '<u>once component</u>',
      };
      expect(render('@!class({ n: 1 })', more: more), '<b>component 1</b>');
      expect(render('@!once()', more: more), '<u>once component</u>');
    });

    test('components: \$attributes, merge() and \$slot', () {
      Map<String, String> more = <String, String>{
        'components/button': '<button {{ \$attributes.merge({ class: \'btn\', type: \'button\' }) }}>{{ \$slot }}</button>',
        'components/attrs':
            '<p {{ \$attributes }}>{{ \$attributes.title }}</p>',
        'components/slotty': '[{{ \$slot }}][{{ \$slots.main }}]',
      };
      expect(
        render(
          "@button({ class: 'btn-big', type: 'submit' })\nSave\n@end",
          more: more,
        ),
        contains('<button class="btn btn-big" type="submit">'),
      );
      expect(
        render('@!button()', more: more),
        '<button class="btn" type="button"></button>',
      );
      expect(
        render(
          "@!attrs({ id: 'a', title: 'x\"><b>', hidden: true, off: false, n: 2, list: [1] })",
          more: more,
        ),
        '<p id="a" title="x&quot;&gt;&lt;b&gt;" hidden n="2">'
        'x&quot;&gt;&lt;b&gt;</p>',
      );
      // no body: $slot and $slots.main are empty text
      expect(render('@!slotty()', more: more), '[][]');
      expect(
        render('@slotty()\n<b>x</b>\n@end', more: more),
        contains('[<b>x</b>\n]'),
      );
      // an empty slot is false in @if
      expect(
        render(
          '@!check()',
          more: <String, String>{
            'components/check': "@if(\$slot)has @else none @end",
          },
        ),
        'none',
      );
    });

    test('a component does not see the page variables', () {
      expect(
        render(
          '@!peek()',
          data: <String, Object?>{'secret': 's3'},
          more: <String, String>{'components/peek': '[{{ secret }}]'},
        ),
        '[]',
      );
    });
  });

  group('3.1 round 3: dox_view app global errors', () {
    Browser browser = Browser(api);

    tearDown(() {
      View.engine.globals.vars.remove('errors');
    });

    test('a global errors shows with no validation errors', () async {
      View.engine.global('errors', <String, Object?>{
        'text': 'e310b_pkg global error',
        'email': 'e310b_pkg global email',
      });
      expect(
        View.render('core/plain'),
        contains('<p class="error">e310b_pkg global email</p>'),
      );
      http.Response res = await browser.send(
        'GET',
        '/views',
        <String, String>{},
      );
      expect(res.statusCode, 200);
      expect(res.body, contains('e310b_pkg global error'));
    });

    test('session validation errors win over the global', () async {
      View.engine.global('errors', <String, Object?>{
        'text': 'e310b_pkg global error',
      });
      await browser.send('GET', '/views', <String, String>{});
      http.Response post = await browser.send(
        'POST',
        '/views/notes',
        <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
          'Referer': api.uri('/views').toString(),
        },
        'text=x',
      );
      expect(post.statusCode, 302, reason: post.body);
      http.Response res = await browser.send(
        'GET',
        '/views',
        <String, String>{},
      );
      expect(res.body, contains('between 2 and 100'));
      expect(res.body, isNot(contains('e310b_pkg global error')));
      // the page after: no errors, the global shows again
      res = await browser.send('GET', '/views', <String, String>{});
      expect(res.body, contains('e310b_pkg global error'));
    });
  });
}

/// What one [PlanJob] does. The test sets it, the job reads it by tag.
class Plan {
  Plan({
    this.tries,
    this.failTimes = 0,
    this.retryUntil,
    this.maxExceptions,
    this.failOnTimeout = false,
    this.timeout,
    this.hangOnRun,
    this.backoff = const <Duration>[],
  });

  int? tries;
  int failTimes;
  DateTime Function()? retryUntil;
  int? maxExceptions;
  bool failOnTimeout;
  Duration? timeout;

  /// this run waits until [PlanJob.release]
  int? hangOnRun;
  List<Duration> backoff;
  int runs = 0;
}

/// A job that does what its [Plan] says.
class PlanJob extends DoxJob {
  PlanJob(this.tag);

  final String tag;

  static const String name = 'E310bPlanJob';
  static final Map<String, Plan> plans = <String, Plan>{};
  static Completer<void> _gate = Completer<void>();

  static Plan plan(
    String tag, {
    int? tries,
    int failTimes = 0,
    DateTime Function()? retryUntil,
    int? maxExceptions,
    bool failOnTimeout = false,
    Duration? timeout,
    int? hangOnRun,
    List<Duration> backoff = const <Duration>[],
  }) {
    return plans[tag] = Plan(
      tries: tries,
      failTimes: failTimes,
      retryUntil: retryUntil,
      maxExceptions: maxExceptions,
      failOnTimeout: failOnTimeout,
      timeout: timeout,
      hangOnRun: hangOnRun,
      backoff: backoff,
    );
  }

  /// end the runs that hang
  static void release() {
    if (!_gate.isCompleted) _gate.complete();
    _gate = Completer<void>();
  }

  static const JobCodec codec = JobCodec(name, PlanJob, _encode, _decode);

  static Map<String, Object?> _encode(DoxJob job) {
    return <String, Object?>{'tag': (job as PlanJob).tag};
  }

  static DoxJob _decode(Map<String, Object?> data) {
    return PlanJob(data['tag'] as String);
  }

  Plan get _plan => plans[tag]!;

  @override
  String get queue => _queue;

  @override
  int? get tries => _plan.tries;

  @override
  DateTime? get retryUntil => _plan.retryUntil?.call();

  @override
  int? get maxExceptions => _plan.maxExceptions;

  @override
  bool get failOnTimeout => _plan.failOnTimeout;

  @override
  Duration? get timeout => _plan.timeout;

  @override
  List<Duration> get backoff => _plan.backoff;

  @override
  Future<void> handle() async {
    Plan plan = _plan;
    plan.runs++;
    if (plan.runs == plan.hangOnRun) await _gate.future;
    if (plan.runs <= plan.failTimes) {
      throw StateError('plan $tag try ${plan.runs}');
    }
  }
}

/// A mail queue that keeps what it got.
class RecordQueue implements MailQueue {
  final List<Message> pushed = <Message>[];

  @override
  Future<String> push(
    String mailer,
    Message message, {
    Duration? delay,
    String? queue,
    bool encrypt = false,
  }) async {
    pushed.add(message);
    return 'record-${pushed.length}';
  }
}

/// A mailable with its own `to`, for `Mail.to()`.
class E310bMail extends Mailable {
  @override
  List<Address> get to => <Address>[Address('ann@x.com')];

  @override
  String get subject => 'E310b mail';

  @override
  String? get text => 'hello';
}

/// The welcome Markdown with a SafeString name: it stays Markdown.
class SafeMarkdownMail extends Mailable {
  @override
  List<Address> get to => <Address>[Address('ann@x.com')];

  @override
  String get subject => 'Safe';

  @override
  String? get markdown => 'emails/welcome';

  @override
  Map<String, Object?> get data => <String, Object?>{
    'name': SafeString('**x**'),
    'url': 'https://ok.test',
  };
}

/// A memory driver where the file is gone right after `append` read
/// it, like another writer deleted it.
class VanishingDriver extends MemoryDriver {
  bool vanish = false;

  @override
  Future<Visibility> getVisibility(String key) async {
    if (vanish) await delete(key);
    return super.getVisibility(key);
  }
}

/// A LocalDriver subclass that counts its `getMetaData` calls.
class CountingLocalDriver extends LocalDriver {
  CountingLocalDriver(String root) : super(LocalDriverConfig(root: root));

  int metaReads = 0;

  @override
  Future<ObjectMetaData> getMetaData(String key) {
    metaReads++;
    return super.getMetaData(key);
  }
}
