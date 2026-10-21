import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/http/requests/register.request.dart';
import 'package:dox_test/app/http/serializers/user.serializer.dart';
import 'package:dox_test/app/models/user/user.model.dart';
import 'package:dox_test/app/services/auth.service.dart';

class AuthController {
  final AuthService service;

  AuthController(this.service);

  /// Register a user
  ///
  /// The email is saved in lower case (UserObserver).
  @Tags(<String>['Auth'])
  Future<DoxResponse> register(RegisterRequest req) async {
    User user = await service.register(req);
    return response(UserSerializer(user)).statusCode(201);
  }

  /// POST /api/auth/login
  @Summary('Log in')
  @Description('Gives a JWT. Send it as `Authorization: Bearer <token>`.')
  @Tags(<String>['Auth'])
  @Response(200, Map<String, dynamic>, description: '{token, user}')
  @Response(401, null, description: 'Wrong email or password')
  Future<Map<String, dynamic>> login(DoxRequest req) async {
    return await service.login(
      req.input('email').toString(),
      req.input('password').toString(),
    );
  }

  /// The logged in user
  @Tags(<String>['Auth'])
  UserSerializer me(DoxRequest req) {
    return UserSerializer(req.auth?.user<User>());
  }
}
