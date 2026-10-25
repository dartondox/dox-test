import 'package:dox_queue/dox_queue.dart';
import 'package:dox_test/config/queue.dart';

/// Sets up the queue in every isolate. Dox finds every DoxProvider class,
/// see lib/container.g.dart.
class AppQueueProvider extends QueueProvider {
  AppQueueProvider() : super(queueConfig);
}
