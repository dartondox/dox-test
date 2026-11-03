import 'package:dox_mailer/dox_mailer.dart';
import 'package:dox_test/app/models/user/user.model.dart';
import 'package:dox_test/config/env.dart';

/// The welcome email of a new user. The body is the Markdown template
/// resources/views/emails/welcome.dox.html. The terms file goes with it.
class WelcomeMail extends Mailable {
  WelcomeMail(this.user, {this.mailer});

  final User user;

  /// the path of the attached file
  static const String termsFile = 'resources/mail/terms.txt';

  @override
  final String? mailer;

  @override
  List<Address> get to => <Address>[Address(user.email!, user.name)];

  @override
  String get subject => 'Welcome to ${env.appName}, ${user.name}';

  @override
  String? get markdown => 'emails/welcome';

  @override
  Map<String, Object?> get data => <String, Object?>{
    'name': user.name,
    'url': env.appUrl,
  };

  @override
  List<Attachment> get attachments => <Attachment>[
    Attachment.fromFile(termsFile),
  ];
}
