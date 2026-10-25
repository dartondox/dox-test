import 'package:dox_core/dox_core.dart';
import 'package:dox_scheduler/dox_scheduler.dart';
import 'package:dox_test/app/models/user/user.model.dart';

/// Run the tasks with `dart run bin/schedule.dart`.
/// The locks use the memory cache store (one scheduler process).
ScheduleConfig scheduleConfig = const ScheduleConfig(store: 'memory');

void schedule(Schedule s) {
  s.call('user-stats', saveUserCount).hourly();
}

/// Keeps the number of users in the cache.
Future<void> saveUserCount() async {
  await Cache().put('stats:user_count', await User().count());
}
