import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/dtos/mail/mail.dto.dart';
import 'package:dox_test/app/services/mail.service.dart';

/// /api/mail/...: send the emails of the app (needs the api key).
@Tags(<String>['Mail'])
@Inject()
class MailController {
  final MailService service;

  MailController(this.service);

  /// Send the welcome email
  ///
  /// Now, on the queue, or later. See `mode`.
  Future<Map<String, dynamic>> welcome(int id, SendWelcomeMail body) async {
    return await service.welcome(id, body);
  }

  /// Notify that the account is ready (queued email)
  Future<Map<String, dynamic>> accountReady(int id) async {
    return await service.accountReady(id);
  }
}
