import 'package:dox_mailer/dox_mailer.dart';
import 'package:dox_test/config/env.dart';

/// The SMTP server of the app (MailHog in docker compose, no TLS).
SmtpTransport smtp = SmtpTransport(
  host: env.mailHost,
  port: env.mailPort,
  encryption: SmtpEncryption.none,
  timeout: Duration(seconds: 5),
);

MailConfig mailConfig = MailConfig(
  /// the mailer of Mail.send()
  defaultMailer: env.mailMailer,

  /// for messages with no from address
  from: Address(env.mailFrom, env.appName),

  mailers: <String, Transport>{
    'smtp': smtp,

    /// Tries a server that is down first, then the real one.
    /// Shows that one dead server does not stop the email.
    'failover': FailoverTransport(<Transport>[
      SmtpTransport(
        host: '127.0.0.1',
        port: 1,
        encryption: SmtpEncryption.none,
        timeout: Duration(seconds: 2),
      ),
      smtp,
    ]),

    /// prints emails, sends nothing
    'log': LogTransport(),
  },
);
