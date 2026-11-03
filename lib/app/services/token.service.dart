import 'package:dox_auth/dox_auth.dart';
import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/dtos/auth/auth.dto.dart';
import 'package:dox_test/app/dtos/core/core.dto.dart';
import 'package:dox_test/app/models/user/user.model.dart';

/// Access tokens of the `tokens` guard (dox_auth AccessTokenAuthDriver).
/// The database only keeps a hash. The plain token is shown once.
@Inject()
class TokenService {
  static const String guard = 'tokens';

  /// A token with all abilities. Wrong password gives 401.
  Future<Map<String, dynamic>> login(LoginUser body, String? ip) async {
    String? token = await Auth(guard: guard, ip: ip).attempt(<String, dynamic>{
      'email': body.email,
      'password': body.password,
    });
    if (token == null) {
      throw UnAuthorizedException(message: 'wrong email or password');
    }
    return <String, dynamic>{'token': token};
  }

  /// A new named token with only [CreateToken.abilities].
  Future<Map<String, dynamic>> create(User user, CreateToken body) async {
    AccessToken token = await Auth(guard: guard)
        .createAccessToken(user, name: body.name, abilities: body.abilities);
    return <String, dynamic>{'id': token.id, 'token': token.value};
  }

  /// All tokens of [user], with no hash and no plain value.
  Future<List<Map<String, dynamic>>> all(User user) async {
    List<Map<String, dynamic>> ret = <Map<String, dynamic>>[];
    for (AccessToken token in await Auth(guard: guard).accessTokens(user)) {
      ret.add(<String, dynamic>{
        'id': token.id,
        'name': token.name,
        'abilities': token.abilities,
      });
    }
    return ret;
  }

  /// Delete the token [id] of [user]. false when it is not theirs.
  Future<bool> revoke(User user, int id) {
    return Auth(guard: guard).revokeAccessToken(user, id);
  }

  /// Delete the token the request came with.
  Future<void> revokeCurrent(DoxRequest req) async {
    await (req.auth as Auth).revokeToken(req);
  }
}
