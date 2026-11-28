// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mail.dto.dart';

// **************************************************************************
// DoxDtoGenerator
// **************************************************************************

// ignore_for_file: type=lint

/// The checks, the converter and the JSON Schema of [SendWelcomeMail].
const DtoSchema<SendWelcomeMail> $SendWelcomeMailDto = _$SendWelcomeMailDto();

class _$SendWelcomeMailDto extends DtoSchema<SendWelcomeMail>
    implements JsonObjectWriter {
  const _$SendWelcomeMailDto();

  static const Map<String, String> _messages = <String, String>{};

  @override
  Type get type => SendWelcomeMail;

  @override
  String get name => 'SendWelcomeMail';

  @override
  bool get usesRequiredWhen => false;

  @override
  SendWelcomeMail? convert(Object? input, DtoState state, List<Object> path) {
    if (input is! Map) {
      state.notObject(input, path, _messages);
      return null;
    }
    int issuesBefore = state.issues.length;
    // mode: MailMode
    Object? mode = state.enumName(
      state.read(input, 'mode'),
      path,
      'mode',
      _messages,
      const <String>['send', 'queue', 'later'],
    );
    if (mode is String) {
      mode = switch (mode) {
        'send' => MailMode.send,
        'queue' => MailMode.queue,
        _ => MailMode.later,
      };
    }
    if (mode == null) state.required(path, 'mode', _messages);
    // delay: int
    Object? delay = state.integer(
      state.read(input, 'delay'),
      path,
      'delay',
      _messages,
    );
    if (delay == null) state.required(path, 'delay', _messages);
    // encrypt: bool
    Object? encrypt = state.boolean(
      state.read(input, 'encrypt'),
      path,
      'encrypt',
      _messages,
    );
    if (encrypt == null) state.required(path, 'encrypt', _messages);
    // mailer: String?
    Object? mailer = state.string(
      state.read(input, 'mailer'),
      path,
      'mailer',
      _messages,
    );
    if (state.issues.length != issuesBefore && !state.allErrors) return null;
    if (delay is int) {
      if (!(delay >= 1)) {
        state.fail(
          path,
          'delay',
          IssueCodes.min,
          DefaultMessages.min,
          delay,
          params: const <String, Object?>{'min': 1},
          messages: _messages,
        );
      }
    }
    if (state.issues.length != issuesBefore) return null;
    return SendWelcomeMail(
      mode: mode is Undefined ? MailMode.send : mode as MailMode,
      delay: delay is Undefined ? 60 : delay as int,
      encrypt: encrypt is Undefined ? false : encrypt as bool,
      mailer: mailer is Undefined ? null : mailer as String?,
    );
  }

  @override
  SendWelcomeMail fromMap(Map<String, dynamic> map) {
    return SendWelcomeMail(
      mode: map.containsKey('mode')
          ? MailMode.values.byName(map['mode'] as String)
          : MailMode.send,
      delay: map.containsKey('delay') ? (map['delay'] as num).toInt() : 60,
      encrypt: map.containsKey('encrypt') ? map['encrypt'] as bool : false,
      mailer: map['mailer'] == null ? null : (map['mailer'] as String),
    );
  }

  @override
  Map<String, dynamic> toMap(SendWelcomeMail dto) {
    return <String, dynamic>{
      'mode': dto.mode.name,
      'delay': dto.delay,
      'encrypt': dto.encrypt,
      'mailer': dto.mailer,
    };
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as SendWelcomeMail));

  @override
  Map<String, dynamic> toJsonSchema() {
    return <String, dynamic>{
      'type': 'object',
      'title': 'SendWelcomeMail',
      'properties': <String, dynamic>{
        'mode': <String, dynamic>{
          'type': 'string',
          'enum': <dynamic>['send', 'queue', 'later'],
          'description': 'send, queue or later',
          'default': 'send',
        },
        'delay': <String, dynamic>{
          'type': 'integer',
          'minimum': 1,
          'description': 'For `later`: the wait in seconds.',
          'default': 60,
        },
        'encrypt': <String, dynamic>{
          'type': 'boolean',
          'description':
              'For `queue` and `later`: save the job data encrypted.',
          'default': false,
        },
        'mailer': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
          'description':
              'The mailer name of lib/config/mail.dart. Empty: the default.',
        },
      },
    };
  }
}
