import 'package:dox_core/dox_core.dart';
import 'package:dox_orm/dox_orm.dart' hide Schema;

part 'auth.dto.g.dart';

/// Body of POST /api/auth/register.
@Dto(messages: <String, String>{'required': '{field} is missing'})
class RegisterUser {
  @Trim()
  @Length(min: 2, max: 100)
  final String name;

  @Trim()
  @Lowercase()
  @Email()
  @Unique('users', column: 'email')
  final String email;

  @MinLength(6)
  final String password;

  /// Must be the same as `password`.
  final String passwordConfirmation;

  @Trim()
  @MaxLength(100)
  final String? firstName;

  @Trim()
  @MaxLength(100)
  final String? lastName;

  const RegisterUser({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    this.firstName,
    this.lastName,
  });

  /// Check across fields. Runs after every field rule passed.
  void validate(DtoErrors errors) {
    if (password != passwordConfirmation) {
      errors.add('password_confirmation', 'The passwords do not match');
    }
  }

  static const DtoSchema<RegisterUser> schema = $RegisterUserDto;
}

/// Body of POST /api/auth/login.
@Dto()
class LoginUser {
  @Trim()
  @Lowercase()
  @Email()
  final String email;

  final String password;

  const LoginUser({required this.email, required this.password});

  static const DtoSchema<LoginUser> schema = $LoginUserDto;
}
