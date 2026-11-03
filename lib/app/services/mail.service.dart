import 'package:dox_core/dox_core.dart';
import 'package:dox_mailer/dox_mailer.dart';
import 'package:dox_test/app/dtos/mail/mail.dto.dart';
import 'package:dox_test/app/mail/welcome.mail.dart';
import 'package:dox_test/app/models/user/user.model.dart';
import 'package:dox_test/app/notifications/account_ready.notification.dart';
import 'package:dox_test/app/repositories/user.repository.dart';
import 'package:dox_test/constants/mail_mode.dart';

/// Sends the emails of the app: now, on the queue, or later.
@Inject()
class MailService {
  final UserRepository users;

  MailService(this.users);

  /// The welcome email of user [id].
  /// `message_id` for a sent email, `job_id` for a queued one.
  Future<Map<String, dynamic>> welcome(int id, SendWelcomeMail body) async {
    WelcomeMail mail = WelcomeMail(await user(id), mailer: body.mailer);
    switch (body.mode) {
      case MailMode.send:
        SentMessage sent = await mail.send();
        return <String, dynamic>{'mode': 'send', 'message_id': sent.messageId};
      case MailMode.queue:
        String job = await mail.queue(encrypt: body.encrypt);
        return <String, dynamic>{'mode': 'queue', 'job_id': job};
      case MailMode.later:
        String job = await mail.later(
          Duration(seconds: body.delay),
          encrypt: body.encrypt,
        );
        return <String, dynamic>{'mode': 'later', 'job_id': job};
    }
  }

  /// The "account ready" notification of user [id]. It is queued.
  Future<Map<String, dynamic>> accountReady(int id) async {
    await (await user(id)).notify(const AccountReady());
    return <String, dynamic>{'notified': true};
  }

  Future<User> user(int id) async {
    User? user = await users.find(id);
    if (user == null) {
      throw NotFoundHttpException(message: 'no user $id');
    }
    return user;
  }
}
