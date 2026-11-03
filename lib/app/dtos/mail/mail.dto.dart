import 'package:dox_core/dox_core.dart';
import 'package:dox_test/constants/mail_mode.dart';

part 'mail.dto.g.dart';

/// Body of POST /api/mail/welcome/{id}.
@Dto()
class SendWelcomeMail {
  /// send, queue or later
  final MailMode mode;

  /// For `later`: the wait in seconds.
  @Min(1)
  final int delay;

  /// For `queue` and `later`: save the job data encrypted.
  final bool encrypt;

  /// The mailer name of lib/config/mail.dart. Empty: the default.
  final String? mailer;

  const SendWelcomeMail({
    this.mode = MailMode.send,
    this.delay = 60,
    this.encrypt = false,
    this.mailer,
  });

  static const DtoSchema<SendWelcomeMail> schema = $SendWelcomeMailDto;
}
