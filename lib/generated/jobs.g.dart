// GENERATED CODE - DO NOT MODIFY BY HAND
// Made by dox_builder. Run `dart run build_runner build`.
// ignore_for_file: type=lint

import 'package:dox_queue/dox_queue.dart';
import 'package:dox_test/app/jobs/record_step.job.dart' as i1;
import 'package:dox_test/app/jobs/welcome_user.job.dart' as i2;
import 'package:dox_mailer/dox_mailer.dart' as i3;

/// Every `@Job()` class of the app.
/// Use it in `QueueConfig(jobs: jobRegistry)`.
const JobRegistry jobRegistry = JobRegistry(<JobCodec>[
  JobCodec('RecordStep', i1.RecordStep, _encode0, _decode0),
  JobCodec('WelcomeUser', i2.WelcomeUser, _encode1, _decode1),
  i3.SendQueuedMail.codec,
  i3.SendEncryptedQueuedMail.codec,
]);

Map<String, Object?> _encode0(DoxJob job) {
  i1.RecordStep value = job as i1.RecordStep;
  return <String, Object?>{'step': value.step, 'fail': value.fail};
}

DoxJob _decode0(Map<String, Object?> data) {
  return i1.RecordStep(
    step: data['step'] as String,
    fail: data['fail'] as bool,
  );
}

Map<String, Object?> _encode1(DoxJob job) {
  i2.WelcomeUser value = job as i2.WelcomeUser;
  return <String, Object?>{'userId': value.userId};
}

DoxJob _decode1(Map<String, Object?> data) {
  return i2.WelcomeUser(userId: (data['userId'] as num).toInt());
}
