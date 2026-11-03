import 'package:dox_queue/dox_queue.dart';
import 'package:dox_test/generated/jobs.g.dart';

/// Jobs are rows in the `jobs` table of the app database
/// (postgres, mysql or sqlite). Run them with `dart run bin/queue.dart`.
/// Queued emails (`Mail.queue()`) are jobs too.
QueueConfig queueConfig = QueueConfig(
  /// sync, database or redis
  driver: 'database',

  /// every @Job class, from lib/jobs.g.dart
  jobs: jobRegistry,

  /// For the redis driver: REDIS_URL, or REDIS_HOST and REDIS_PORT.
  redis: QueueConfig.redisFromEnv(),
  prefix: 'dox_test_queue:',
);
