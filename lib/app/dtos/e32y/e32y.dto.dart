import 'package:dox_core/dox_core.dart';

part 'e32y.dto.g.dart';

/// Test DTO of test/e2e_32y_patch.dart: a date and an int field.
@Dto()
class E32yForm {
  final DateTime? at;
  final int? count;

  const E32yForm({this.at, this.count});

  static const DtoSchema<E32yForm> schema = $E32yFormDto;
}
