import 'package:dox_core/dox_core.dart';

part 'e2e310b.dto.g.dart';

/// Test DTO of test/e2e_310b_core.dart. `@RequiredIf` on `card` reads
/// `plan`, a field after it, after `@Trim` and `@Lowercase`.
@Dto()
class E2ePlanForm {
  @RequiredIf('plan', 'pro')
  final String? card;

  @Trim()
  @Lowercase()
  final String plan;

  const E2ePlanForm({this.card, required this.plan});

  static const DtoSchema<E2ePlanForm> schema = $E2ePlanFormDto;
}
