// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'e2e310b.dto.dart';

// **************************************************************************
// DoxDtoGenerator
// **************************************************************************

// ignore_for_file: type=lint

/// The checks, the converter and the JSON Schema of [E2ePlanForm].
const DtoSchema<E2ePlanForm> $E2ePlanFormDto = _$E2ePlanFormDto();

class _$E2ePlanFormDto extends DtoSchema<E2ePlanForm> {
  const _$E2ePlanFormDto();

  static const Map<String, String> _m = <String, String>{};

  @override
  Type get type => E2ePlanForm;

  @override
  String get name => 'E2ePlanForm';

  @override
  E2ePlanForm? convert(Object? input, DtoState s, List<Object> p) {
    if (input is! Map) {
      s.notObject(input, p, _m);
      return null;
    }
    int e = s.issues.length;
    // card: String?
    Object? c0;
    c0 = s.string(s.read(input, 'card'), p, 'card', _m);
    // plan: String
    Object? c1;
    c1 = s.string(
      s.read(input, 'plan'),
      p,
      'plan',
      _m,
      trim: true,
      textCase: 1,
    );
    if (c1 == null || c1 is Undefined) s.required(p, 'plan', _m);
    s.requiredWhen(const RequiredIf('plan', 'pro'), c0, input, p, 'card', _m);
    if (s.issues.length != e) return null;
    return E2ePlanForm(
      card: c0 is Undefined ? null : c0 as String?,
      plan: c1 as String,
    );
  }

  @override
  E2ePlanForm fromMap(Map<String, dynamic> m) {
    return E2ePlanForm(
      card: m['card'] == null ? null : (m['card'] as String),
      plan: m['plan'] as String,
    );
  }

  @override
  Map<String, dynamic> toMap(E2ePlanForm o) {
    String? f0 = o.card;
    String f1 = o.plan;
    return <String, dynamic>{'card': f0, 'plan': f1};
  }

  @override
  Map<String, dynamic> toJsonSchema() {
    return <String, dynamic>{
      'type': 'object',
      'title': 'E2ePlanForm',
      'properties': <String, dynamic>{
        'card': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
        },
        'plan': <String, dynamic>{'type': 'string'},
      },
      'required': <dynamic>['plan'],
    };
  }
}
