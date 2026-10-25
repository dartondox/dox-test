import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/http/dtos/auth.dto.dart';
import 'package:dox_test/app/http/serializers/user.serializer.dart';
import 'package:dox_test/app/models/user/user.model.dart';
import 'package:dox_test/app/services/auth.service.dart';

@Inject()
class AuthController {
  final AuthService service;

  AuthController(this.service);

  /// Register a user
  ///
  /// The email is saved in lower case.
  @Tags(<String>['Auth'])
  Future<DoxResponse> register(RegisterUser body) async {
    User user = await service.register(body);
    return response(UserSerializer(user)).statusCode(201);
  }

  /// POST /api/auth/login
  @Summary('Log in')
  @Description('Gives a JWT. Send it as `Authorization: Bearer <token>`.')
  @Tags(<String>['Auth'])
  @Response(200, Map<String, dynamic>, description: '{token, user}')
  @Response(401, null, description: 'Wrong email or password')
  Future<Map<String, dynamic>> login(LoginUser body) async {
    return await service.login(body.email, body.password);
  }

  /// The logged in user
  @Tags(<String>['Auth'])
  UserSerializer me(DoxRequest req) {
    return UserSerializer(req.auth?.user<User>());
  }
}
