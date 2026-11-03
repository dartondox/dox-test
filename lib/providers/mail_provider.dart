import 'package:dox_mailer/dox_mailer.dart';
import 'package:dox_test/config/mail.dart';

/// Sets up the mailers in every isolate, also in the queue worker.
/// Dox finds every DoxProvider class, see lib/generated/container.g.dart.
class AppMailProvider extends MailProvider {
  AppMailProvider() : super(mailConfig);
}
