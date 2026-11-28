// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reaction.model.dart';

// **************************************************************************
// Generator: DoxModelBuilder
// **************************************************************************

// ignore_for_file: always_specify_types

class ReactionGenerator extends Model<Reaction> implements JsonWritable {
  @override
  String get primaryKey => 'id';

  @override
  Map<String, dynamic> get timestampsColumn => const <String, dynamic>{
    'created_at': 'created_at',
    'updated_at': 'updated_at',
  };

  @override
  String get tableName => 'reactions';

  int? get id => tempIdValue as int?;

  set id(int? val) => tempIdValue = val;

  Reaction query() => Reaction();

  @override
  bool get readsRowDates => true;

  @override
  List<String> get tableColumns => const <String>[
    'id',
    'emoji',
    'reactable_id',
    'reactable_type',
    'created_at',
    'updated_at',
  ];

  @override
  List<String> get preloadList => const <String>[];

  @override
  Map<String, Function> get relationsResultMatcher => const <String, Function>{
    'reactable': getReactable,
  };

  @override
  Map<String, Function> get relationsQueryMatcher => const <String, Function>{
    'reactable': queryReactable,
  };

  static Future<void> getReactable(List<Model<Reaction>> list) async {
    var result = await getMorphTo<Reaction, Model<dynamic>>(
      queryReactable(list),
      list,
    );
    for (dynamic i in list) {
      i.reactable = result[i.tempIdValue.toString()];
    }
  }

  static Model<dynamic>? queryReactable(List<Model<Reaction>> list) {
    return morphTo<Reaction, Model<dynamic>>(list, name: 'reactable');
  }

  @override
  Reaction fromMap(Map<String, dynamic> m) => Reaction()
    ..id = m['id'] as int?
    ..emoji = m['emoji'] as String?
    ..reactableId = m['reactable_id'] as int?
    ..reactableType = m['reactable_type'] as String?
    ..createdAt = switch (m['created_at']) {
      DateTime? v => v,
      Object? v => DateTime.parse(v as String),
    }
    ..updatedAt = switch (m['updated_at']) {
      DateTime? v => v,
      Object? v => DateTime.parse(v as String),
    };
  @override
  Map<String, dynamic> columnsToMap() {
    Reaction instance = this as Reaction;
    Map<String, dynamic> map = <String, dynamic>{
      'id': instance.id,
      'emoji': instance.emoji,
      'reactable_id': instance.reactableId,
      'reactable_type': instance.reactableType,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

    return map;
  }

  @override
  dynamic $columnValue(String column) {
    Reaction instance = this as Reaction;
    switch (column) {
      case 'id':
        return instance.id;
      case 'emoji':
        return instance.emoji;
      case 'reactable_id':
        return instance.reactableId;
      case 'reactable_type':
        return instance.reactableType;
      case 'created_at':
        return instance.createdAt?.toIso8601String();
      case 'updated_at':
        return instance.updatedAt?.toIso8601String();
    }
    return super.$columnValue(column);
  }

  @override
  Map<String, dynamic> convertToMap(dynamic i) {
    Reaction instance = i as Reaction;
    Map<String, dynamic> map = instance.columnsToMap();

    List<String> preload = getPreload();
    if (preload.contains('reactable')) {
      map['reactable'] = toMap(instance.reactable);
    }

    return map;
  }

  @override
  bool setColumnValue(String column, dynamic value) {
    Reaction instance = this as Reaction;
    switch (column) {
      case 'id':
        if (value is! int?) return false;
        instance.id = value;
        return true;
      case 'emoji':
        if (value is! String?) return false;
        instance.emoji = value;
        return true;
      case 'reactable_id':
        if (value is! int?) return false;
        instance.reactableId = value;
        return true;
      case 'reactable_type':
        if (value is! String?) return false;
        instance.reactableType = value;
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

  @override
  bool $copyColumnsFrom(Model<Reaction> other) {
    Reaction o = other as Reaction;
    (this as Reaction)
      ..id = o.id
      ..emoji = o.emoji
      ..reactableId = o.reactableId
      ..reactableType = o.reactableType
      ..createdAt = o.createdAt
      ..updatedAt = o.updatedAt;
    return true;
  }

  @override
  void writeJson(JsonWriter w) {
    List<String>? hide = $jsonHidden;
    // a class that extends the model can have its own toJson()
    if (hide == null || runtimeType != Reaction) {
      w.value(toJson());
      return;
    }
    bool all = hide.isEmpty;
    Reaction instance = this as Reaction;
    w.startObject();
    if (all || !hide.contains('id')) {
      w.key('id');
      w.integer(instance.id);
    }
    if (all || !hide.contains('emoji')) {
      w.key('emoji');
      w.string(instance.emoji);
    }
    if (all || !hide.contains('reactable_id')) {
      w.key('reactable_id');
      w.integer(instance.reactableId);
    }
    if (all || !hide.contains('reactable_type')) {
      w.key('reactable_type');
      w.string(instance.reactableType);
    }
    if (all || !hide.contains('created_at')) {
      w.key('created_at');
      w.dateTime(instance.createdAt);
    }
    if (all || !hide.contains('updated_at')) {
      w.key('updated_at');
      w.dateTime(instance.updatedAt);
    }
    List<String> preload = getPreload();
    if (preload.contains('reactable') && (all || !hide.contains('reactable'))) {
      w.key('reactable');
      w.value(instance.reactable);
    }
    w.endObject();
  }
}
