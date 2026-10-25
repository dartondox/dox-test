import 'dart:io';

import 'package:dox_queue/dox_queue.dart';
import 'package:dox_test/config/app.dart';

/// Run queued jobs: `dart run bin/queue.dart [work] [flags]`.
/// `dox queue:*` commands run this file.
Future<void> main(List<String> args) async {
  exitCode = await QueueWorker(app: appConfig).run(args);
}
