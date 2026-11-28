// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'e32y.model.dart';

// **************************************************************************
// Generator: DoxModelBuilder
// **************************************************************************

// ignore_for_file: always_specify_types

class E32yItemGenerator extends Model<E32yItem> implements JsonWritable {
  @override
  String get primaryKey => 'id';

  @override
  Map<String, dynamic> get timestampsColumn => const <String, dynamic>{
    'created_at': null,
    'updated_at': null,
  };

  @override
  String get tableName => 'e32y_items';

  int? get id => tempIdValue as int?;

  set id(int? val) => tempIdValue = val;

  E32yItem query() => E32yItem();

  @override
  bool get readsRowDates => true;

  @override
  List<String> get tableColumns => const <String>[
    'id',
    'title',
    'status',
    'fallback',
    'kind',
  ];

  @override
  List<String> get preloadList => const <String>[];

  @override
  Map<String, Function> get relationsResultMatcher =>
      const <String, Function>{};

  @override
  Map<String, Function> get relationsQueryMatcher => const <String, Function>{};

  static const _statusCast = EnumCast(E32yStatus.values);
  static const _fallbackCast = EnumCast<E32yStatus>(
    E32yStatus.values,
    unknown: E32yStatus.draft,
  );
  static const _kindCast = EnumCast(E32yStatus.values);

  @override
  E32yItem fromMap(Map<String, dynamic> m) => E32yItem()
    ..id = m['id'] as int?
    ..title = m['title'] as String?
    ..status = _statusCast.get(m['status'])
    ..fallback = _fallbackCast.get(m['fallback'])
    ..kind = _kindCast.get(m['kind']) as E32yStatus;
  @override
  Map<String, dynamic> columnsToMap() {
    E32yItem instance = this as E32yItem;
    Map<String, dynamic> map = <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'status': _statusCast.set(instance.status),
      'fallback': _fallbackCast.set(instance.fallback),
      'kind': _kindCast.set(instance.kind),
    };

    return map;
  }

  @override
  dynamic $columnValue(String column) {
    E32yItem instance = this as E32yItem;
    switch (column) {
      case 'id':
        return instance.id;
      case 'title':
        return instance.title;
      case 'status':
        return _statusCast.set(instance.status);
      case 'fallback':
        return _fallbackCast.set(instance.fallback);
      case 'kind':
        return _kindCast.set(instance.kind);
    }
    return super.$columnValue(column);
  }

  @override
  Map<String, dynamic> convertToMap(dynamic i) {
    E32yItem instance = i as E32yItem;
    Map<String, dynamic> map = instance.columnsToMap();

    return map;
  }

  @override
  bool setColumnValue(String column, dynamic value) {
    E32yItem instance = this as E32yItem;
    switch (column) {
      case 'id':
        if (value is! int?) return false;
        instance.id = value;
        return true;
      case 'title':
        if (value is! String?) return false;
        instance.title = value;
        return true;
      case 'status':
        if (value is! E32yStatus?) return false;
        instance.status = value;
        return true;
      case 'fallback':
        if (value is! E32yStatus?) return false;
        instance.fallback = value;
        return true;
      case 'kind':
        if (value is! E32yStatus) return false;
        instance.kind = value;
        return true;
    }
    return false;
  }

  @override
  bool $copyColumnsFrom(Model<E32yItem> other) {
    E32yItem o = other as E32yItem;
    (this as E32yItem)
      ..id = o.id
      ..title = o.title
      ..status = o.status
      ..fallback = o.fallback
      ..kind = o.kind;
    return true;
  }

  @override
  void writeJson(JsonWriter w) {
    List<String>? hide = $jsonHidden;
    // a class that extends the model can have its own toJson()
    if (hide == null || runtimeType != E32yItem) {
      w.value(toJson());
      return;
    }
    bool all = hide.isEmpty;
    E32yItem instance = this as E32yItem;
    w.startObject();
    if (all || !hide.contains('id')) {
      w.key('id');
      w.integer(instance.id);
    }
    if (all || !hide.contains('title')) {
      w.key('title');
      w.string(instance.title);
    }
    if (all || !hide.contains('status')) {
      w.key('status');
      w.value(_statusCast.set(instance.status));
    }
    if (all || !hide.contains('fallback')) {
      w.key('fallback');
      w.value(_fallbackCast.set(instance.fallback));
    }
    if (all || !hide.contains('kind')) {
      w.key('kind');
      w.value(_kindCast.set(instance.kind));
    }
    w.endObject();
  }
}
