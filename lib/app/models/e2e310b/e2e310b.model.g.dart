// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'e2e310b.model.dart';

// **************************************************************************
// Generator: DoxModelBuilder
// **************************************************************************

// ignore_for_file: always_specify_types

class E310bItemGenerator extends Model<E310bItem> {
  @override
  String get primaryKey => 'id';

  @override
  Map<String, dynamic> get timestampsColumn => const <String, dynamic>{
    'created_at': 'created_at',
    'updated_at': 'updated_at',
  };

  @override
  String get tableName => 'e310b_orm_items';

  int? get id => tempIdValue as int?;

  set id(int? val) => tempIdValue = val;

  E310bItem query() => E310bItem();

  @override
  bool get readsRowDates => true;

  @override
  List<String> get tableColumns => const <String>[
    'id',
    'name',
    'qty',
    'secret',
    'created_at',
    'updated_at',
  ];

  @override
  List<String> get preloadList => const <String>[];

  @override
  Map<String, Function> get relationsResultMatcher => const <String, Function>{
    'tags': getTags,
  };

  @override
  Map<String, Function> get relationsQueryMatcher => const <String, Function>{
    'tags': queryTags,
  };

  static Future<void> getTags(List<Model<E310bItem>> list) async {
    var result = await getManyToMany<E310bItem, E310bTag>(
      queryTags(list),
      list,
    );
    for (dynamic i in list) {
      i.tags = result[i.tempIdValue.toString()] ?? <E310bTag>[];
    }
  }

  static E310bTag? queryTags(List<Model<E310bItem>> list) {
    return manyToMany<E310bItem, E310bTag>(
      list,
      () => E310bTag(),
      pivotForeignKey: 'item_id',
      pivotRelatedForeignKey: 'tag_id',
      pivotTable: 'e310b_orm_item_tag',
    );
  }

  @override
  E310bItem fromMap(Map<String, dynamic> m) => E310bItem()
    ..id = m['id'] as int?
    ..name = m['name'] as String?
    ..qty = m['qty'] as int?
    ..secret = m['secret'] as String?
    ..createdAt = m['created_at'] is DateTime?
        ? m['created_at'] as DateTime?
        : DateTime.parse(m['created_at'] as String)
    ..updatedAt = m['updated_at'] is DateTime?
        ? m['updated_at'] as DateTime?
        : DateTime.parse(m['updated_at'] as String);
  @override
  Map<String, dynamic> columnsToMap() {
    E310bItem instance = this as E310bItem;
    Map<String, dynamic> map = <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'qty': instance.qty,
      'secret': instance.secret,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

    return map;
  }

  @override
  Map<String, dynamic> convertToMap(dynamic i) {
    E310bItem instance = i as E310bItem;
    Map<String, dynamic> map = instance.columnsToMap();

    List<String> preload = getPreload();
    if (preload.contains('tags')) {
      map['tags'] = toMap(instance.tags);
    }

    return map;
  }

  @override
  bool setColumnValue(String column, dynamic value) {
    E310bItem instance = this as E310bItem;
    switch (column) {
      case 'id':
        if (value is! int?) return false;
        instance.id = value;
        return true;
      case 'name':
        if (value is! String?) return false;
        instance.name = value;
        return true;
      case 'qty':
        if (value is! int?) return false;
        instance.qty = value;
        return true;
      case 'secret':
        if (value is! String?) return false;
        instance.secret = value;
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

class E310bTagGenerator extends Model<E310bTag> {
  @override
  String get primaryKey => 'id';

  @override
  Map<String, dynamic> get timestampsColumn => const <String, dynamic>{
    'created_at': null,
    'updated_at': null,
  };

  @override
  String get tableName => 'e310b_orm_tags';

  int? get id => tempIdValue as int?;

  set id(int? val) => tempIdValue = val;

  E310bTag query() => E310bTag();

  @override
  bool get readsRowDates => true;

  @override
  List<String> get tableColumns => const <String>['id', 'name'];

  @override
  List<String> get preloadList => const <String>[];

  @override
  Map<String, Function> get relationsResultMatcher =>
      const <String, Function>{};

  @override
  Map<String, Function> get relationsQueryMatcher => const <String, Function>{};

  @override
  E310bTag fromMap(Map<String, dynamic> m) => E310bTag()
    ..id = m['id'] as int?
    ..name = m['name'] as String?;
  @override
  Map<String, dynamic> columnsToMap() {
    E310bTag instance = this as E310bTag;
    Map<String, dynamic> map = <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

    return map;
  }

  @override
  Map<String, dynamic> convertToMap(dynamic i) {
    E310bTag instance = i as E310bTag;
    Map<String, dynamic> map = instance.columnsToMap();

    return map;
  }

  @override
  bool setColumnValue(String column, dynamic value) {
    E310bTag instance = this as E310bTag;
    switch (column) {
      case 'id':
        if (value is! int?) return false;
        instance.id = value;
        return true;
      case 'name':
        if (value is! String?) return false;
        instance.name = value;
        return true;
    }
    return false;
  }
}

// ignore_for_file: always_specify_types

class E310bNoteGenerator extends Model<E310bNote> {
  @override
  String get primaryKey => 'id';

  @override
  Map<String, dynamic> get timestampsColumn => const <String, dynamic>{
    'created_at': 'made_at',
    'updated_at': 'changed_at',
  };

  @override
  String get tableName => 'e310b_orm_notes';

  int? get id => tempIdValue as int?;

  set id(int? val) => tempIdValue = val;

  E310bNote query() => E310bNote();

  @override
  bool get readsRowDates => true;

  @override
  List<String> get tableColumns => const <String>[
    'id',
    'body',
    'made_at',
    'changed_at',
  ];

  @override
  List<String> get preloadList => const <String>[];

  @override
  Map<String, Function> get relationsResultMatcher =>
      const <String, Function>{};

  @override
  Map<String, Function> get relationsQueryMatcher => const <String, Function>{};

  @override
  E310bNote fromMap(Map<String, dynamic> m) => E310bNote()
    ..id = m['id'] as int?
    ..body = m['body'] as String?
    ..createdAt = m['made_at'] is DateTime?
        ? m['made_at'] as DateTime?
        : DateTime.parse(m['made_at'] as String)
    ..updatedAt = m['changed_at'] is DateTime?
        ? m['changed_at'] as DateTime?
        : DateTime.parse(m['changed_at'] as String);
  @override
  Map<String, dynamic> columnsToMap() {
    E310bNote instance = this as E310bNote;
    Map<String, dynamic> map = <String, dynamic>{
      'id': instance.id,
      'body': instance.body,
      'made_at': instance.createdAt?.toIso8601String(),
      'changed_at': instance.updatedAt?.toIso8601String(),
    };

    return map;
  }

  @override
  Map<String, dynamic> convertToMap(dynamic i) {
    E310bNote instance = i as E310bNote;
    Map<String, dynamic> map = instance.columnsToMap();

    return map;
  }

  @override
  bool setColumnValue(String column, dynamic value) {
    E310bNote instance = this as E310bNote;
    switch (column) {
      case 'id':
        if (value is! int?) return false;
        instance.id = value;
        return true;
      case 'body':
        if (value is! String?) return false;
        instance.body = value;
        return true;
      case 'made_at':
        if (value is! DateTime?) return false;
        instance.createdAt = value;
        return true;
      case 'changed_at':
        if (value is! DateTime?) return false;
        instance.updatedAt = value;
        return true;
    }
    return false;
  }
}
