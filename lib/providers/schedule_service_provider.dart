import 'package:dox_scheduler/dox_scheduler.dart';
import 'package:dox_test/config/schedule.dart';

/// Runs the schedule inside the server when
/// `ScheduleConfig(inProcess: true)`. Off here: bin/schedule.dart runs it.
class ScheduleService extends SchedulerService {
  ScheduleService() : super(schedule: schedule, config: scheduleConfig);
}
