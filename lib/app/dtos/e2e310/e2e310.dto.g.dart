// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'e2e310.dto.dart';

// **************************************************************************
// DoxDtoGenerator
// **************************************************************************

// ignore_for_file: type=lint

/// The checks, the converter and the JSON Schema of [E2eTeamForm].
const DtoSchema<E2eTeamForm> $E2eTeamFormDto = _$E2eTeamFormDto();

class _$E2eTeamFormDto extends DtoSchema<E2eTeamForm> {
  const _$E2eTeamFormDto();

  static const Map<String, String> _m = <String, String>{};

  @override
  Type get type => E2eTeamForm;

  @override
  String get name => 'E2eTeamForm';

  @override
  E2eTeamForm? convert(Object? input, DtoState s, List<Object> p) {
    if (input is! Map) {
      s.notObject(input, p, _m);
      return null;
    }
    int e = s.issues.length;
    // kind: String
    Object? c0;
    c0 = s.string(
      s.read(input, 'kind'),
      p,
      'kind',
      _m,
      trim: true,
      textCase: 1,
    );
    if (c0 == null || c0 is Undefined) s.required(p, 'kind', _m);
    // teamName: String?
    Object? c1;
    c1 = s.string(s.read(input, 'team_name'), p, 'team_name', _m);
    s.requiredWhen(
      const RequiredIf('kind', 'team'),
      c1,
      input,
      p,
      'team_name',
      _m,
    );
    // email: String?
    Object? c2;
    c2 = s.string(s.read(input, 'email'), p, 'email', _m, trim: true);
    // phone: String?
    Object? c3;
    c3 = s.string(s.read(input, 'phone'), p, 'phone', _m);
    s.requiredWhen(
      const RequiredWith(<String>['email']),
      c3,
      input,
      p,
      'phone',
      _m,
    );
    if (s.issues.length != e) return null;
    return E2eTeamForm(
      kind: c0 as String,
      teamName: c1 is Undefined ? null : c1 as String?,
      email: c2 is Undefined ? null : c2 as String?,
      phone: c3 is Undefined ? null : c3 as String?,
    );
  }

  @override
  E2eTeamForm fromMap(Map<String, dynamic> m) {
    return E2eTeamForm(
      kind: m['kind'] as String,
      teamName: m['team_name'] == null ? null : (m['team_name'] as String),
      email: m['email'] == null ? null : (m['email'] as String),
      phone: m['phone'] == null ? null : (m['phone'] as String),
    );
  }

  @override
  Map<String, dynamic> toMap(E2eTeamForm o) {
    String f0 = o.kind;
    String? f1 = o.teamName;
    String? f2 = o.email;
    String? f3 = o.phone;
    return <String, dynamic>{
      'kind': f0,
      'team_name': f1,
      'email': f2,
      'phone': f3,
    };
  }

  @override
  Map<String, dynamic> toJsonSchema() {
    return <String, dynamic>{
      'type': 'object',
      'title': 'E2eTeamForm',
      'properties': <String, dynamic>{
        'kind': <String, dynamic>{'type': 'string'},
        'team_name': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
        },
        'email': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
        },
        'phone': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
        },
      },
      'required': <dynamic>['kind'],
    };
  }
}
