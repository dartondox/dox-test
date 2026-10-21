import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/http/requests/register.request.dart';
import 'package:dox_test/app/http/serializers/user.serializer.dart';
import 'package:dox_test/app/models/user/user.model.dart';
import 'package:dox_test/app/services/auth.service.dart';

class AuthController {
  final AuthService service;

  AuthController(this.service);

  /// POST /api/auth/register
  Future<DoxResponse> register(RegisterRequest req) async {
    User user = await service.register(req);
    return response(UserSerializer(user)).statusCode(201);
  }

  /// POST /api/auth/login
  Future<Map<String, dynamic>> login(DoxRequest req) async {
    return await service.login(
      req.input('email').toString(),
      req.input('password').toString(),
    );
  }

  /// GET /api/auth/me (needs token)
  UserSerializer me(DoxRequest req) {
    return UserSerializer(req.auth?.user<User>());
  }
}
