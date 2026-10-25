import 'dart:io';

import 'package:dox_scheduler/dox_scheduler.dart';
import 'package:dox_test/config/app.dart';
import 'package:dox_test/config/schedule.dart';

/// Run the schedule of lib/config/schedule.dart:
/// `dart run bin/schedule.dart <work|run|list|test name>`.
Future<void> main(List<String> args) async {
  exitCode = await SchedulerRunner(
    schedule: schedule,
    app: appConfig,
    config: scheduleConfig,
  ).run(args);
}
