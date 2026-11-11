// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mail.dto.dart';

// **************************************************************************
// DoxDtoGenerator
// **************************************************************************

// ignore_for_file: type=lint

/// The checks, the converter and the JSON Schema of [SendWelcomeMail].
const DtoSchema<SendWelcomeMail> $SendWelcomeMailDto = _$SendWelcomeMailDto();

class _$SendWelcomeMailDto extends DtoSchema<SendWelcomeMail> {
  const _$SendWelcomeMailDto();

  static const Map<String, String> _m = <String, String>{};

  @override
  Type get type => SendWelcomeMail;

  @override
  String get name => 'SendWelcomeMail';

  @override
  bool get usesRequiredWhen => false;

  @override
  SendWelcomeMail? convert(Object? input, DtoState s, List<Object> p) {
    if (input is! Map) {
      s.notObject(input, p, _m);
      return null;
    }
    int e = s.issues.length;
    // mode: MailMode
    Object? c0;
    c0 = s.enumName(s.read(input, 'mode'), p, 'mode', _m, const <String>[
      'send',
      'queue',
      'later',
    ]);
    if (c0 is String) {
      c0 = switch (c0) {
        'send' => MailMode.send,
        'queue' => MailMode.queue,
        _ => MailMode.later,
      };
    }
    if (c0 == null) s.required(p, 'mode', _m);
    // delay: int
    Object? c1;
    c1 = s.integer(s.read(input, 'delay'), p, 'delay', _m);
    if (c1 == null) s.required(p, 'delay', _m);
    // encrypt: bool
    Object? c2;
    c2 = s.boolean(s.read(input, 'encrypt'), p, 'encrypt', _m);
    if (c2 == null) s.required(p, 'encrypt', _m);
    // mailer: String?
    Object? c3;
    c3 = s.string(s.read(input, 'mailer'), p, 'mailer', _m);
    if (s.issues.length != e) return null;
    if (c1 is int) {
      if (!(c1 >= 1)) {
        s.fail(
          p,
          'delay',
          IssueCodes.min,
          DefaultMessages.min,
          c1,
          params: const <String, Object?>{'min': 1},
          messages: _m,
        );
      }
    }
    if (s.issues.length != e) return null;
    return SendWelcomeMail(
      mode: c0 is Undefined ? MailMode.send : c0 as MailMode,
      delay: c1 is Undefined ? 60 : c1 as int,
      encrypt: c2 is Undefined ? false : c2 as bool,
      mailer: c3 is Undefined ? null : c3 as String?,
    );
  }

  @override
  SendWelcomeMail fromMap(Map<String, dynamic> m) {
    return SendWelcomeMail(
      mode: m.containsKey('mode')
          ? MailMode.values.byName(m['mode'] as String)
          : MailMode.send,
      delay: m.containsKey('delay') ? (m['delay'] as num).toInt() : 60,
      encrypt: m.containsKey('encrypt') ? m['encrypt'] as bool : false,
      mailer: m['mailer'] == null ? null : (m['mailer'] as String),
    );
  }

  @override
  Map<String, dynamic> toMap(SendWelcomeMail o) {
    MailMode f0 = o.mode;
    int f1 = o.delay;
    bool f2 = o.encrypt;
    String? f3 = o.mailer;
    return <String, dynamic>{
      'mode': f0.name,
      'delay': f1,
      'encrypt': f2,
      'mailer': f3,
    };
  }

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
