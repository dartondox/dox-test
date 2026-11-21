// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'e32y.dto.dart';

// **************************************************************************
// DoxDtoGenerator
// **************************************************************************

// ignore_for_file: type=lint

/// The checks, the converter and the JSON Schema of [E32yForm].
const DtoSchema<E32yForm> $E32yFormDto = _$E32yFormDto();

class _$E32yFormDto extends DtoSchema<E32yForm> {
  const _$E32yFormDto();

  static const Map<String, String> _m = <String, String>{};

  @override
  Type get type => E32yForm;

  @override
  String get name => 'E32yForm';

  @override
  bool get usesRequiredWhen => false;

  @override
  E32yForm? convert(Object? input, DtoState s, List<Object> p) {
    if (input is! Map) {
      s.notObject(input, p, _m);
      return null;
    }
    int e = s.issues.length;
    // at: DateTime?
    Object? c0;
    c0 = s.date(s.read(input, 'at'), p, 'at', _m);
    // count: int?
    Object? c1;
    c1 = s.integer(s.read(input, 'count'), p, 'count', _m);
    if (s.issues.length != e && !s.allErrors) return null;
    if (s.issues.length != e) return null;
    return E32yForm(
      at: c0 is Undefined ? null : c0 as DateTime?,
      count: c1 is Undefined ? null : c1 as int?,
    );
  }

  @override
  E32yForm fromMap(Map<String, dynamic> m) {
    return E32yForm(
      at: m['at'] == null ? null : (DateTime.parse(m['at'] as String).toUtc()),
      count: m['count'] == null ? null : ((m['count'] as num).toInt()),
    );
  }

  @override
  Map<String, dynamic> toMap(E32yForm o) {
    DateTime? f0 = o.at;
    int? f1 = o.count;
    return <String, dynamic>{
      'at': f0 == null ? null : f0.toIso8601String(),
      'count': f1,
    };
  }

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
