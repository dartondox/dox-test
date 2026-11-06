import 'package:dox_core/dox_core.dart';

part 'e2e310.dto.g.dart';

/// Test DTO of test/e2e_310_orm.dart. `@RequiredIf` and `@RequiredWith`
/// read `kind` and `email` after `@Trim` and `@Lowercase`.
@Dto()
class E2eTeamForm {
  @Trim()
  @Lowercase()
  final String kind;

  @RequiredIf('kind', 'team')
  final String? teamName;

  @Trim()
  final String? email;

  @RequiredWith(<String>['email'])
  final String? phone;

  const E2eTeamForm({
    required this.kind,
    this.teamName,
    this.email,
    this.phone,
  });

  static const DtoSchema<E2eTeamForm> schema = $E2eTeamFormDto;
}
