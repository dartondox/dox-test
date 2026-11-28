// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'e2e310.dto.dart';

// **************************************************************************
// DoxDtoGenerator
// **************************************************************************

// ignore_for_file: type=lint

/// The checks, the converter and the JSON Schema of [E2eTeamForm].
const DtoSchema<E2eTeamForm> $E2eTeamFormDto = _$E2eTeamFormDto();

class _$E2eTeamFormDto extends DtoSchema<E2eTeamForm>
    implements JsonObjectWriter {
  const _$E2eTeamFormDto();

  static const Map<String, String> _messages = <String, String>{};

  @override
  Type get type => E2eTeamForm;

  @override
  String get name => 'E2eTeamForm';

  @override
  E2eTeamForm? convert(Object? input, DtoState state, List<Object> path) {
    if (input is! Map) {
      state.notObject(input, path, _messages);
      return null;
    }
    int issuesBefore = state.issues.length;
    // kind: String
    Object? kind = state.string(
      state.read(input, 'kind'),
      path,
      'kind',
      _messages,
      trim: true,
      textCase: 1,
    );
    if (kind == null || kind is Undefined)
      state.required(path, 'kind', _messages);
    // teamName: String?
    Object? teamName = state.string(
      state.read(input, 'team_name'),
      path,
      'team_name',
      _messages,
    );
    // email: String?
    Object? email = state.string(
      state.read(input, 'email'),
      path,
      'email',
      _messages,
      trim: true,
    );
    // phone: String?
    Object? phone = state.string(
      state.read(input, 'phone'),
      path,
      'phone',
      _messages,
    );
    state.requiredWhen(
      const RequiredIf('kind', 'team'),
      teamName,
      input,
      path,
      'team_name',
      _messages,
    );
    state.requiredWhen(
      const RequiredWith(<String>['email']),
      phone,
      input,
      path,
      'phone',
      _messages,
    );
    if (state.issues.length != issuesBefore && !state.allErrors) return null;
    if (state.issues.length != issuesBefore) return null;
    return E2eTeamForm(
      kind: kind as String,
      teamName: teamName is Undefined ? null : teamName as String?,
      email: email is Undefined ? null : email as String?,
      phone: phone is Undefined ? null : phone as String?,
    );
  }

  @override
  E2eTeamForm fromMap(Map<String, dynamic> map) {
    return E2eTeamForm(
      kind: map['kind'] as String,
      teamName: map['team_name'] == null ? null : (map['team_name'] as String),
      email: map['email'] == null ? null : (map['email'] as String),
      phone: map['phone'] == null ? null : (map['phone'] as String),
    );
  }

  @override
  Map<String, dynamic> toMap(E2eTeamForm dto) {
    return <String, dynamic>{
      'kind': dto.kind,
      'team_name': dto.teamName,
      'email': dto.email,
      'phone': dto.phone,
    };
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as E2eTeamForm));

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
