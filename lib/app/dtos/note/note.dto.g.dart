// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dto.dart';

// **************************************************************************
// DoxDtoGenerator
// **************************************************************************

// ignore_for_file: type=lint

/// The checks, the converter and the JSON Schema of [CreateNote].
const DtoSchema<CreateNote> $CreateNoteDto = _$CreateNoteDto();

class _$CreateNoteDto extends DtoSchema<CreateNote>
    implements JsonObjectWriter {
  const _$CreateNoteDto();

  static const Map<String, String> _messages = <String, String>{};

  @override
  Type get type => CreateNote;

  @override
  String get name => 'CreateNote';

  @override
  bool get usesRequiredWhen => false;

  @override
  CreateNote? convert(Object? input, DtoState state, List<Object> path) {
    if (input is! Map) {
      state.notObject(input, path, _messages);
      return null;
    }
    int issuesBefore = state.issues.length;
    // text: String
    Object? text = state.string(
      state.read(input, 'text'),
      path,
      'text',
      _messages,
      trim: true,
    );
    if (text == null || text is Undefined)
      state.required(path, 'text', _messages);
    if (state.issues.length != issuesBefore && !state.allErrors) return null;
    if (text is String) {
      if (!(text.runes.length >= 2 && text.runes.length <= 100)) {
        state.fail(
          path,
          'text',
          IssueCodes.lengthBetween,
          DefaultMessages.lengthBetween,
          text,
          params: const <String, Object?>{'min': 2, 'max': 100},
          messages: _messages,
        );
      }
    }
    if (state.issues.length != issuesBefore) return null;
    return CreateNote(text: text as String);
  }

  @override
  CreateNote fromMap(Map<String, dynamic> map) {
    return CreateNote(text: map['text'] as String);
  }

  @override
  Map<String, dynamic> toMap(CreateNote dto) {
    return <String, dynamic>{'text': dto.text};
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as CreateNote));

  @override
  Map<String, dynamic> toJsonSchema() {
    return <String, dynamic>{
      'type': 'object',
      'title': 'CreateNote',
      'properties': <String, dynamic>{
        'text': <String, dynamic>{
          'type': 'string',
          'minLength': 2,
          'maxLength': 100,
        },
      },
      'required': <dynamic>['text'],
    };
  }
}
