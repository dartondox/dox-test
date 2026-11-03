import 'package:dox_auth/dox_auth.dart';
import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/dtos/auth/auth.dto.dart';
import 'package:dox_test/app/dtos/core/core.dto.dart';
import 'package:dox_test/app/models/user/user.model.dart';
import 'package:dox_test/app/services/token.service.dart';

/// /api/tokens: log in with an access token, make more, list, revoke.
@Inject()
@Tags(<String>['Tokens'])
class TokenController {
  final TokenService service;

  TokenController(this.service);

  /// POST /api/tokens/login
  Future<Map<String, dynamic>> tokenLogin(DoxRequest req, LoginUser body) {
    return service.login(body, req.ip());
  }

  /// POST /api/tokens
  Future<DoxResponse> store(DoxRequest req, CreateToken body) async {
    Map<String, dynamic> token = await service.create(_user(req), body);
    return response(token).statusCode(201);
  }

  /// GET /api/tokens
  Future<List<Map<String, dynamic>>> index(DoxRequest req) {
    return service.all(_user(req));
  }

  /// GET /api/tokens/can/{ability}: does this token have the ability?
  Map<String, dynamic> can(DoxRequest req, String ability) {
    Auth auth = req.auth as Auth;
    return <String, dynamic>{
      'can': auth.tokenCan(ability),
      'token_id': auth.currentAccessToken?.id,
    };
  }

  /// DELETE /api/tokens/current: log out this token.
  Future<Map<String, bool>> destroyCurrent(DoxRequest req) async {
    await service.revokeCurrent(req);
    return <String, bool>{'revoked': true};
  }

  /// DELETE /api/tokens/{id}
  Future<Map<String, bool>> destroy(DoxRequest req, int id) async {
    return <String, bool>{'revoked': await service.revoke(_user(req), id)};
  }

  User _user(DoxRequest req) {
    return req.auth!.user<User>()!;
  }
}
