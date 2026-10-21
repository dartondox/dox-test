import 'package:dox_auth/dox_auth.dart';
import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/http/dtos/auth.dto.dart';
import 'package:dox_test/app/models/user/user.model.dart';
import 'package:dox_test/app/repositories/user.repository.dart';

/// Register and login logic.
class AuthService {
  final UserRepository users;

  AuthService(this.users);

  /// The DTO already checked that the email is free (@Unique).
  Future<User> register(RegisterUser input) async {
    return await users.create(
      input.name,
      input.email,
      Hash.make(input.password),
      firstName: input.firstName,
      lastName: input.lastName,
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
