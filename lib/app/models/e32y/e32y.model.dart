import 'package:dox_orm/dox_orm.dart';

part 'e32y.model.g.dart';

/// the values of the enum columns of [E32yItem]
enum E32yStatus { draft, live }

/// Test model of test/e2e_32y_patch.dart: enum columns, for stored
/// values the enum does not have.
@DoxModel(table: 'e32y_items', timestamps: false)
class E32yItem extends E32yItemGenerator {
  /// test model: takes every key of a map
  @override
  List<String> get guarded => const <String>[];

  @Column()
  String? title;

  /// nullable: an unknown value reads as null
  @Column()
  E32yStatus? status;

  /// an unknown value reads as `draft`
  @Column(
    cast: EnumCast<E32yStatus>(E32yStatus.values, unknown: E32yStatus.draft),
  )
  E32yStatus? fallback;

  /// not nullable, no fallback: an unknown value throws a StateError
  @Column()
  E32yStatus kind = E32yStatus.draft;
}
