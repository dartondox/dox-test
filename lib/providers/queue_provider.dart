import 'package:dox_queue_database/dox_queue_database.dart';
import 'package:dox_test/config/queue.dart';

/// Sets up the queue in every isolate, with the database driver, batches
/// and afterCommit. Dox finds every DoxProvider class, see
/// lib/container.g.dart.
class AppQueueProvider extends DatabaseQueueProvider {
  AppQueueProvider() : super(queueConfig);
}
