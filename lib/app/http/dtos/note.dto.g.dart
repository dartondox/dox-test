// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dto.dart';

// **************************************************************************
// DoxDtoGenerator
// **************************************************************************

// ignore_for_file: type=lint

/// The checks, the converter and the JSON Schema of [CreateNote].
const DtoSchema<CreateNote> $CreateNoteDto = _$CreateNoteDto();

class _$CreateNoteDto extends DtoSchema<CreateNote> {
  const _$CreateNoteDto();

  static const Map<String, String> _m = <String, String>{};

  @override
  Type get type => CreateNote;

  @override
  String get name => 'CreateNote';

  @override
  CreateNote? convert(Object? input, DtoState s, List<Object> p) {
    if (input is! Map) {
      s.notObject(input, p, _m);
      return null;
    }
    int e = s.issues.length;
    // text: String
    Object? c0;
    c0 = s.string(s.read(input, 'text'), p, 'text', _m, trim: true);
    if (c0 == null || c0 is Undefined) s.required(p, 'text', _m);
    if (s.issues.length != e) return null;
    if (c0 is String) {
      if (!(c0.runes.length >= 2 && c0.runes.length <= 100)) {
        s.fail(
          p,
          'text',
          IssueCodes.lengthBetween,
          DefaultMessages.lengthBetween,
          c0,
          params: const <String, Object?>{'min': 2, 'max': 100},
          messages: _m,
        );
      }
    }
    if (s.issues.length != e) return null;
    return CreateNote(text: c0 as String);
  }

  @override
  CreateNote fromMap(Map<String, dynamic> m) {
    return CreateNote(text: m['text'] as String);
  }

  @override
  Map<String, dynamic> toMap(CreateNote o) {
    String f0 = o.text;
    return <String, dynamic>{'text': f0};
  }

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
