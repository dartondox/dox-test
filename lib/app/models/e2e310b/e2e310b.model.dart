import 'package:dox_orm/dox_orm.dart';

part 'e2e310b.model.g.dart';

/// Test models of test/e2e_310b_orm.dart. The test makes and drops their
/// tables, so no migration has them.

/// An item with `fillable`: `insertMany` and `insertGetId` drop `secret`.
@DoxModel(table: 'e310b_orm_items')
class E310bItem extends E310bItemGenerator {
  @override
  List<String> get fillable => <String>['name', 'qty'];

  @Column()
  String? name;

  @Column()
  int? qty;

  @Column()
  String? secret;

  @ManyToMany(
    E310bTag,
    pivotTable: 'e310b_orm_item_tag',
    pivotForeignKey: 'item_id',
    pivotRelatedForeignKey: 'tag_id',
  )
  List<E310bTag> tags = <E310bTag>[];
}

/// A tag with a plain int id, for the many to many checks.
@DoxModel(table: 'e310b_orm_tags', timestamps: false)
class E310bTag extends E310bTagGenerator {
  @Column()
  String? name;
}

/// A note with custom timestamp columns.
@DoxModel(
  table: 'e310b_orm_notes',
  createdAt: 'made_at',
  updatedAt: 'changed_at',
)
class E310bNote extends E310bNoteGenerator {
  @override
  List<String> get fillable => <String>['body', 'changed_at'];

  @Column()
  String? body;
}
