import 'package:dox_mailer/dox_mailer.dart';
import 'package:dox_test/config/env.dart';

/// Tells a user that the account is ready. It goes out by email, on the
/// queue, so the request does not wait for the SMTP server.
class AccountReady extends Notification {
  const AccountReady();

  @override
  List<NotificationChannel> via(Object notifiable) {
    return const <NotificationChannel>[MailChannel()];
  }

  /// No `to`: the mail goes to `routeNotificationFor('mail')` of the user.
  @override
  Mailable toMail(Object notifiable) {
    return MailMessage(subject: 'Your account is ready')
      ..line('Your **${env.appName}** account is ready.')
      ..action('Open the app', env.appUrl)
      ..line('Thank you!');
  }

  @override
  bool get shouldQueue => true;
}
