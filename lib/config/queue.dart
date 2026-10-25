import 'package:dox_queue/dox_queue.dart';
import 'package:dox_test/jobs.g.dart';

/// Jobs are rows in the `jobs` table of the app database
/// (postgres, mysql or sqlite). Run them with `dart run bin/queue.dart`.
QueueConfig queueConfig = QueueConfig(
  /// sync, database or redis
  driver: 'database',

  /// every @Job class, from lib/jobs.g.dart
  jobs: jobRegistry,
);
