// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'e2e310b.dto.dart';

// **************************************************************************
// DoxDtoGenerator
// **************************************************************************

// ignore_for_file: type=lint

/// The checks, the converter and the JSON Schema of [E2ePlanForm].
const DtoSchema<E2ePlanForm> $E2ePlanFormDto = _$E2ePlanFormDto();

class _$E2ePlanFormDto extends DtoSchema<E2ePlanForm>
    implements JsonObjectWriter {
  const _$E2ePlanFormDto();

  static const Map<String, String> _messages = <String, String>{};

  @override
  Type get type => E2ePlanForm;

  @override
  String get name => 'E2ePlanForm';

  @override
  E2ePlanForm? convert(Object? input, DtoState state, List<Object> path) {
    if (input is! Map) {
      state.notObject(input, path, _messages);
      return null;
    }
    int issuesBefore = state.issues.length;
    // card: String?
    Object? card = state.string(
      state.read(input, 'card'),
      path,
      'card',
      _messages,
    );
    // plan: String
    Object? plan = state.string(
      state.read(input, 'plan'),
      path,
      'plan',
      _messages,
      trim: true,
      textCase: 1,
    );
    if (plan == null || plan is Undefined)
      state.required(path, 'plan', _messages);
    state.requiredWhen(
      const RequiredIf('plan', 'pro'),
      card,
      input,
      path,
      'card',
      _messages,
    );
    if (state.issues.length != issuesBefore && !state.allErrors) return null;
    if (state.issues.length != issuesBefore) return null;
    return E2ePlanForm(
      card: card is Undefined ? null : card as String?,
      plan: plan as String,
    );
  }

  @override
  E2ePlanForm fromMap(Map<String, dynamic> map) {
    return E2ePlanForm(
      card: map['card'] == null ? null : (map['card'] as String),
      plan: map['plan'] as String,
    );
  }

  @override
  Map<String, dynamic> toMap(E2ePlanForm dto) {
    return <String, dynamic>{'card': dto.card, 'plan': dto.plan};
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as E2ePlanForm));

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
