import 'package:dox_core/dox_core.dart';
import 'package:dox_orm/dox_orm.dart' hide Schema;
import 'package:dox_test/constants/app_constants.dart';

part 'user.dto.g.dart';

/// Query of GET /api/users. Query values are text; Dox converts them.
@Dto()
class ListUsers {
  @Min(1)
  final int page;

  @Min(1)
  @Max(100)
  final int perPage;

  /// Part of the name or the email.
  @Trim()
  final String? search;

  const ListUsers({
    this.page = 1,
    this.perPage = AppConstants.defaultPerPage,
    this.search,
  });

  static const DtoSchema<ListUsers> schema = $ListUsersDto;
}

/// Body of PUT /api/users/{id}.
@Dto()
class UpdateUser {
  @Trim()
  @Length(min: 2, max: 100)
  final String name;

  /// Must be free, but the user may keep its own email.
  @Trim()
  @Lowercase()
  @Email()
  @Unique('users', column: 'email', ignoreParam: 'id')
  final String email;

  const UpdateUser({required this.name, required this.email});

  static const DtoSchema<UpdateUser> schema = $UpdateUserDto;
}

/// Body of PUT /api/auth/me/profile. Every field is replaced.
@Dto()
class SaveProfile {
  @MaxLength(500)
  final String? bio;

  @Url()
  final String? website;

  const SaveProfile({this.bio, this.website});

  static const DtoSchema<SaveProfile> schema = $SaveProfileDto;
}

/// Body of PATCH /api/auth/me/profile.
/// A missing key keeps the old value. `null` clears it.
@Dto()
class PatchProfile {
  @MaxLength(500)
  final Maybe<String?> bio;

  @Url()
  final Maybe<String?> website;

  const PatchProfile({
    this.bio = const Maybe<String?>.missing(),
    this.website = const Maybe<String?>.missing(),
  });

  static const DtoSchema<PatchProfile> schema = $PatchProfileDto;
}
