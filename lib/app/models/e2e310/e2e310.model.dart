import 'package:dox_orm/dox_orm.dart';

part 'e2e310.model.g.dart';

/// Test models of test/e2e_310_orm.dart. The test makes and drops their
/// tables, so no migration has them.

/// No `table:`, so the ORM picks the name. A digit stays with the word
/// before it: `oauth2_client`.
@DoxModel()
class Oauth2Client extends Oauth2ClientGenerator {
  @Column()
  String? name;
}

/// Only `guarded`, no `fillable`: every column but `is_admin` comes from
/// a map. A key that is not a column is dropped.
@DoxModel(table: 'e2e_members')
class E2eMember extends E2eMemberGenerator {
  @override
  List<String> get guarded => <String>['is_admin'];

  @Column()
  String? name;

  @Column()
  bool? isAdmin;
}

/// A shelf with books. The pivot keeps the book `sku`, a text key.
@DoxModel(table: 'e2e_shelves')
class E2eShelf extends E2eShelfGenerator {
  @override
  List<String> get fillable => <String>['name'];

  @Column()
  String? name;

  @ManyToMany(
    E2eBook,
    pivotTable: 'e2e_shelf_book',
    localKey: 'id',
    relatedKey: 'sku',
    pivotForeignKey: 'shelf_id',
    pivotRelatedForeignKey: 'book_sku',
  )
  List<E2eBook> books = <E2eBook>[];
}

/// A book, found by its `sku`.
@DoxModel(table: 'e2e_books')
class E2eBook extends E2eBookGenerator {
  @override
  List<String> get fillable => <String>['sku', 'title', 'meta'];

  @Column()
  String? sku;

  @Column()
  String? title;

  @Column()
  Map<String, dynamic>? meta;

  /// books whose sku starts with [prefix]
  @Scope()
  static QueryBuilder<E2eBook> skuStarts(
    QueryBuilder<E2eBook> q,
    String prefix,
  ) {
    return q.where('sku', 'like', '$prefix%');
  }
}
