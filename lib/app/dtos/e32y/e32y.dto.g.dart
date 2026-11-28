// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'e32y.dto.dart';

// **************************************************************************
// DoxDtoGenerator
// **************************************************************************

// ignore_for_file: type=lint

/// The checks, the converter and the JSON Schema of [E32yForm].
const DtoSchema<E32yForm> $E32yFormDto = _$E32yFormDto();

class _$E32yFormDto extends DtoSchema<E32yForm> implements JsonObjectWriter {
  const _$E32yFormDto();

  static const Map<String, String> _messages = <String, String>{};

  @override
  Type get type => E32yForm;

  @override
  String get name => 'E32yForm';

  @override
  bool get usesRequiredWhen => false;

  @override
  E32yForm? convert(Object? input, DtoState state, List<Object> path) {
    if (input is! Map) {
      state.notObject(input, path, _messages);
      return null;
    }
    int issuesBefore = state.issues.length;
    // at: DateTime?
    Object? at = state.date(state.read(input, 'at'), path, 'at', _messages);
    // count: int?
    Object? count = state.integer(
      state.read(input, 'count'),
      path,
      'count',
      _messages,
    );
    if (state.issues.length != issuesBefore && !state.allErrors) return null;
    if (state.issues.length != issuesBefore) return null;
    return E32yForm(
      at: at is Undefined ? null : at as DateTime?,
      count: count is Undefined ? null : count as int?,
    );
  }

  @override
  E32yForm fromMap(Map<String, dynamic> map) {
    return E32yForm(
      at: map['at'] == null
          ? null
          : (DateTime.parse(map['at'] as String).toUtc()),
      count: map['count'] == null ? null : ((map['count'] as num).toInt()),
    );
  }

  @override
  Map<String, dynamic> toMap(E32yForm dto) {
    DateTime? at = dto.at;
    return <String, dynamic>{
      'at': at == null ? null : at.toIso8601String(),
      'count': dto.count,
    };
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as E32yForm));

  @override
  Map<String, dynamic> toJsonSchema() {
    return <String, dynamic>{
      'type': 'object',
      'title': 'E32yForm',
      'properties': <String, dynamic>{
        'at': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
          'format': 'date-time',
        },
        'count': <String, dynamic>{
          'type': <dynamic>['integer', 'null'],
        },
      },
    };
  }
}
