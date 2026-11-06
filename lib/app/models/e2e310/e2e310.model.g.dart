// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'e2e310.model.dart';

// **************************************************************************
// Generator: DoxModelBuilder
// **************************************************************************

// ignore_for_file: always_specify_types

class Oauth2ClientGenerator extends Model<Oauth2Client> {
  @override
  String get primaryKey => 'id';

  @override
  Map<String, dynamic> get timestampsColumn => const <String, dynamic>{
    'created_at': 'created_at',
    'updated_at': 'updated_at',
  };

  int? get id => tempIdValue as int?;

  set id(int? val) => tempIdValue = val;

  Oauth2Client query() => Oauth2Client();

  @override
  bool get readsRowDates => true;

  @override
  List<String> get tableColumns => const <String>[
    'id',
    'name',
    'created_at',
    'updated_at',
  ];

  @override
  List<String> get preloadList => const <String>[];

  @override
  Map<String, Function> get relationsResultMatcher =>
      const <String, Function>{};

  @override
  Map<String, Function> get relationsQueryMatcher => const <String, Function>{};

  @override
  Oauth2Client fromMap(Map<String, dynamic> m) => Oauth2Client()
    ..id = m['id'] as int?
    ..name = m['name'] as String?
    ..createdAt = m['created_at'] is DateTime?
        ? m['created_at'] as DateTime?
        : DateTime.parse(m['created_at'] as String)
    ..updatedAt = m['updated_at'] is DateTime?
        ? m['updated_at'] as DateTime?
        : DateTime.parse(m['updated_at'] as String);
  @override
  Map<String, dynamic> columnsToMap() {
    Oauth2Client instance = this as Oauth2Client;
    Map<String, dynamic> map = <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

    return map;
  }

  @override
  Map<String, dynamic> convertToMap(dynamic i) {
    Oauth2Client instance = i as Oauth2Client;
    Map<String, dynamic> map = instance.columnsToMap();

    return map;
  }

  @override
  bool setColumnValue(String column, dynamic value) {
    Oauth2Client instance = this as Oauth2Client;
    switch (column) {
      case 'id':
        if (value is! int?) return false;
        instance.id = value;
        return true;
      case 'name':
        if (value is! String?) return false;
        instance.name = value;
        return true;
      case 'created_at':
        if (value is! DateTime?) return false;
        instance.createdAt = value;
        return true;
      case 'updated_at':
        if (value is! DateTime?) return false;
        instance.updatedAt = value;
        return true;
    }
    return false;
  }
}

// ignore_for_file: always_specify_types

class E2eMemberGenerator extends Model<E2eMember> {
  @override
  String get primaryKey => 'id';

  @override
  Map<String, dynamic> get timestampsColumn => const <String, dynamic>{
    'created_at': 'created_at',
    'updated_at': 'updated_at',
  };

  @override
  String get tableName => 'e2e_members';

  int? get id => tempIdValue as int?;

  set id(int? val) => tempIdValue = val;

  E2eMember query() => E2eMember();

  @override
  bool get readsRowDates => true;

  @override
  List<String> get tableColumns => const <String>[
    'id',
    'name',
    'is_admin',
    'created_at',
    'updated_at',
  ];

  @override
  List<String> get preloadList => const <String>[];

  @override
  Map<String, Function> get relationsResultMatcher =>
      const <String, Function>{};

  @override
  Map<String, Function> get relationsQueryMatcher => const <String, Function>{};

  static const _isAdminCast = BoolCast();

  @override
  E2eMember fromMap(Map<String, dynamic> m) => E2eMember()
    ..id = m['id'] as int?
    ..name = m['name'] as String?
    ..isAdmin = _isAdminCast.get(m['is_admin'])
    ..createdAt = m['created_at'] is DateTime?
        ? m['created_at'] as DateTime?
        : DateTime.parse(m['created_at'] as String)
    ..updatedAt = m['updated_at'] is DateTime?
        ? m['updated_at'] as DateTime?
        : DateTime.parse(m['updated_at'] as String);
  @override
  Map<String, dynamic> columnsToMap() {
    E2eMember instance = this as E2eMember;
    Map<String, dynamic> map = <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'is_admin': _isAdminCast.set(instance.isAdmin),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

    return map;
  }

  @override
  Map<String, dynamic> convertToMap(dynamic i) {
    E2eMember instance = i as E2eMember;
    Map<String, dynamic> map = instance.columnsToMap();

    return map;
  }

  @override
  bool setColumnValue(String column, dynamic value) {
    E2eMember instance = this as E2eMember;
    switch (column) {
      case 'id':
        if (value is! int?) return false;
        instance.id = value;
        return true;
      case 'name':
        if (value is! String?) return false;
        instance.name = value;
        return true;
      case 'is_admin':
        if (value is! bool?) return false;
        instance.isAdmin = value;
        return true;
      case 'created_at':
        if (value is! DateTime?) return false;
        instance.createdAt = value;
        return true;
      case 'updated_at':
        if (value is! DateTime?) return false;
        instance.updatedAt = value;
        return true;
    }
    return false;
  }
}

// ignore_for_file: always_specify_types

class E2eShelfGenerator extends Model<E2eShelf> {
  @override
  String get primaryKey => 'id';

  @override
  Map<String, dynamic> get timestampsColumn => const <String, dynamic>{
    'created_at': 'created_at',
    'updated_at': 'updated_at',
  };

  @override
  String get tableName => 'e2e_shelves';

  int? get id => tempIdValue as int?;

  set id(int? val) => tempIdValue = val;

  E2eShelf query() => E2eShelf();

  @override
  bool get readsRowDates => true;

  @override
  List<String> get tableColumns => const <String>[
    'id',
    'name',
    'created_at',
    'updated_at',
  ];

  @override
  List<String> get preloadList => const <String>[];

  @override
  Map<String, Function> get relationsResultMatcher => const <String, Function>{
    'books': getBooks,
  };

  @override
  Map<String, Function> get relationsQueryMatcher => const <String, Function>{
    'books': queryBooks,
  };

  static Future<void> getBooks(List<Model<E2eShelf>> list) async {
    var result = await getManyToMany<E2eShelf, E2eBook>(queryBooks(list), list);
    for (dynamic i in list) {
      i.books = result[i.tempIdValue.toString()] ?? <E2eBook>[];
    }
  }

  static E2eBook? queryBooks(List<Model<E2eShelf>> list) {
    return manyToMany<E2eShelf, E2eBook>(
      list,
      () => E2eBook(),
      localKey: 'id',
      relatedKey: 'sku',
      pivotForeignKey: 'shelf_id',
      pivotRelatedForeignKey: 'book_sku',
      pivotTable: 'e2e_shelf_book',
    );
  }

  @override
  E2eShelf fromMap(Map<String, dynamic> m) => E2eShelf()
    ..id = m['id'] as int?
    ..name = m['name'] as String?
    ..createdAt = m['created_at'] is DateTime?
        ? m['created_at'] as DateTime?
        : DateTime.parse(m['created_at'] as String)
    ..updatedAt = m['updated_at'] is DateTime?
        ? m['updated_at'] as DateTime?
        : DateTime.parse(m['updated_at'] as String);
  @override
  Map<String, dynamic> columnsToMap() {
    E2eShelf instance = this as E2eShelf;
    Map<String, dynamic> map = <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

    return map;
  }

  @override
  Map<String, dynamic> convertToMap(dynamic i) {
    E2eShelf instance = i as E2eShelf;
    Map<String, dynamic> map = instance.columnsToMap();

    List<String> preload = getPreload();
    if (preload.contains('books')) {
      map['books'] = toMap(instance.books);
    }

    return map;
  }

  @override
  bool setColumnValue(String column, dynamic value) {
    E2eShelf instance = this as E2eShelf;
    switch (column) {
      case 'id':
        if (value is! int?) return false;
        instance.id = value;
        return true;
      case 'name':
        if (value is! String?) return false;
        instance.name = value;
        return true;
      case 'created_at':
        if (value is! DateTime?) return false;
        instance.createdAt = value;
        return true;
      case 'updated_at':
        if (value is! DateTime?) return false;
        instance.updatedAt = value;
        return true;
    }
    return false;
  }
}

// ignore_for_file: always_specify_types

class E2eBookGenerator extends Model<E2eBook> {
  @override
  String get primaryKey => 'id';

  @override
  Map<String, dynamic> get timestampsColumn => const <String, dynamic>{
    'created_at': 'created_at',
    'updated_at': 'updated_at',
  };

  @override
  String get tableName => 'e2e_books';

  int? get id => tempIdValue as int?;

  set id(int? val) => tempIdValue = val;

  E2eBook query() => E2eBook();

  @override
  bool get readsRowDates => true;

  @override
  List<String> get tableColumns => const <String>[
    'id',
    'sku',
    'title',
    'meta',
    'created_at',
    'updated_at',
  ];

  @override
  List<String> get preloadList => const <String>[];

  @override
  Map<String, Function> get relationsResultMatcher =>
      const <String, Function>{};

  @override
  Map<String, Function> get relationsQueryMatcher => const <String, Function>{};

  @override
  E2eBook fromMap(Map<String, dynamic> m) => E2eBook()
    ..id = m['id'] as int?
    ..sku = m['sku'] as String?
    ..title = m['title'] as String?
    ..meta = m['meta'] as Map<String, dynamic>?
    ..createdAt = m['created_at'] is DateTime?
        ? m['created_at'] as DateTime?
        : DateTime.parse(m['created_at'] as String)
    ..updatedAt = m['updated_at'] is DateTime?
        ? m['updated_at'] as DateTime?
        : DateTime.parse(m['updated_at'] as String);
  @override
  Map<String, dynamic> columnsToMap() {
    E2eBook instance = this as E2eBook;
    Map<String, dynamic> map = <String, dynamic>{
      'id': instance.id,
      'sku': instance.sku,
      'title': instance.title,
      'meta': instance.meta,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

    return map;
  }

  @override
  Map<String, dynamic> convertToMap(dynamic i) {
    E2eBook instance = i as E2eBook;
    Map<String, dynamic> map = instance.columnsToMap();

    return map;
  }

  @override
  bool setColumnValue(String column, dynamic value) {
    E2eBook instance = this as E2eBook;
    switch (column) {
      case 'id':
        if (value is! int?) return false;
        instance.id = value;
        return true;
      case 'sku':
        if (value is! String?) return false;
        instance.sku = value;
        return true;
      case 'title':
        if (value is! String?) return false;
        instance.title = value;
        return true;
      case 'meta':
        if (value is! Map<String, dynamic>?) return false;
        instance.meta = value;
        return true;
      case 'created_at':
        if (value is! DateTime?) return false;
        instance.createdAt = value;
        return true;
      case 'updated_at':
        if (value is! DateTime?) return false;
        instance.updatedAt = value;
        return true;
    }
    return false;
  }
}

extension E2eBookScopes on QueryBuilder<E2eBook> {
  QueryBuilder<E2eBook> skuStarts(String prefix) =>
      E2eBook.skuStarts(this, prefix);
}
