import 'package:dox_core/dox_core.dart';

/// Body of POST /api/auth/register. Dox checks the rules first.
class RegisterRequest extends FormRequest {
  String name = '';
  String email = '';
  String password = '';

  @override
  void setUp() {
    name = input('name').toString();
    email = input('email').toString();
    password = input('password').toString();
  }

  @override
  Map<String, String> rules() {
    return <String, String>{
      'name': 'required',
      'email': 'required|email',
      'password': 'required|min_length:6',
    };
  }

  @override
  Map<String, String> messages() {
    return <String, String>{'required': '{field} is missing'};
  }
}
