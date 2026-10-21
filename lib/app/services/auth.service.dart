import 'package:dox_auth/dox_auth.dart';
import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/http/requests/register.request.dart';
import 'package:dox_test/app/models/user/user.model.dart';
import 'package:dox_test/app/repositories/user.repository.dart';

/// Register and login logic.
class AuthService {
  final UserRepository users;

  AuthService(this.users);

  Future<User> register(RegisterRequest req) async {
    // UserObserver saves the email in lower case, so look it up that way.
    User? existing = await users.findByEmail(req.email.toLowerCase());
    if (existing != null) {
      throw ValidationException(
        message: <String, String>{'email': 'email is already taken'},
      );
    }
    return await users.create(
      req.name,
      req.email,
      Hash.make(req.password),
      firstName: req.firstName,
      lastName: req.lastName,
    );
  }

  /// Returns the JWT token and the user. Wrong password gives 401.
  Future<Map<String, dynamic>> login(String email, String password) async {
    Auth auth = Auth();
    String? token = await auth.attempt(<String, dynamic>{
      'email': email,
      'password': password,
    });
    if (token == null) {
      throw UnAuthorizedException(message: 'wrong email or password');
    }
    return <String, dynamic>{'token': token, 'user': auth.user<User>()};
  }
}
