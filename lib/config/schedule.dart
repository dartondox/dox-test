import 'package:dox_core/dox_core.dart';
import 'package:dox_mailer/dox_mailer.dart';
import 'package:dox_queue/dox_queue.dart';
import 'package:dox_scheduler/dox_scheduler.dart';
import 'package:dox_test/app/models/user/user.model.dart';
import 'package:dox_test/config/env.dart';

/// Run the tasks with `dart run bin/schedule.dart`.
/// The locks use the memory cache store (one scheduler process).
/// The times are Bangkok times (UTC+7), not UTC.
ScheduleConfig scheduleConfig = const ScheduleConfig(
  store: 'memory',
  timezone: 'Asia/Bangkok',
);

void schedule(Schedule s) {
  s.call('user-stats', saveUserCount).hourly();

  // '8' is 08:00 in Bangkok
  s.call('daily-report', queueDailyReport).dailyAt('8').onOneServer();

  // only in office hours: 09:00 to 17:00
  s
      .call('queue-health', saveFailedJobCount)
      .everyFiveMinutes()
      .between('9', '17');

  // never on a laptop: only when APP_ENV is production
  s.call('prune-failed-jobs', pruneFailedJobs).daily().environments(<String>[
    'production',
  ]);
}

/// Keeps the number of users in the cache.
Future<void> saveUserCount() async {
  await Cache().put('stats:user_count', await User().count());
}

/// Puts the daily report email on the queue. A queue worker sends it.
Future<void> queueDailyReport() async {
  await Mail.queue(
    Message(
      to: <Address>[Address(env.mailFrom)],
      subject: 'Daily report',
      text: 'Users: ${await User().count()}',
    ),
  );
}

/// Keeps the number of failed jobs in the cache.
Future<void> saveFailedJobCount() async {
  await Cache().put('stats:failed_jobs', (await Queue.driver.failed()).length);
}

/// Forgets every failed job.
Future<void> pruneFailedJobs() async {
  await Queue.driver.flush();
}
