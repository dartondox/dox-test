// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system.dto.dart';

// **************************************************************************
// DoxDtoGenerator
// **************************************************************************

// ignore_for_file: type=lint

/// The checks, the converter and the JSON Schema of [HashPassword].
const DtoSchema<HashPassword> $HashPasswordDto = _$HashPasswordDto();

class _$HashPasswordDto extends DtoSchema<HashPassword> {
  const _$HashPasswordDto();

  static const Map<String, String> _m = <String, String>{};

  @override
  Type get type => HashPassword;

  @override
  String get name => 'HashPassword';

  @override
  bool get usesRequiredWhen => false;

  @override
  HashPassword? convert(Object? input, DtoState s, List<Object> p) {
    if (input is! Map) {
      s.notObject(input, p, _m);
      return null;
    }
    int e = s.issues.length;
    // password: String
    Object? c0;
    c0 = s.string(s.read(input, 'password'), p, 'password', _m);
    if (c0 == null || c0 is Undefined) s.required(p, 'password', _m);
    if (s.issues.length != e) return null;
    return HashPassword(password: c0 as String);
  }

  @override
  HashPassword fromMap(Map<String, dynamic> m) {
    return HashPassword(password: m['password'] as String);
  }

  @override
  Map<String, dynamic> toMap(HashPassword o) {
    String f0 = o.password;
    return <String, dynamic>{'password': f0};
  }

  @override
  Map<String, dynamic> toJsonSchema() {
    return <String, dynamic>{
      'type': 'object',
      'title': 'HashPassword',
      'properties': <String, dynamic>{
        'password': <String, dynamic>{'type': 'string'},
      },
      'required': <dynamic>['password'],
    };
  }
}

/// The checks, the converter and the JSON Schema of [Address].
const DtoSchema<Address> $AddressDto = _$AddressDto();

class _$AddressDto extends DtoSchema<Address> {
  const _$AddressDto();

  static const Map<String, String> _m = <String, String>{};

  static final RegExp _r0 = RegExp('^(?:\\d{5})\$');

  @override
  Type get type => Address;

  @override
  String get name => 'Address';

  @override
  bool get usesRequiredWhen => false;

  @override
  Address? convert(Object? input, DtoState s, List<Object> p) {
    if (input is! Map) {
      s.notObject(input, p, _m);
      return null;
    }
    int e = s.issues.length;
    // city: String
    Object? c0;
    c0 = s.string(s.read(input, 'city'), p, 'city', _m, trim: true);
    if (c0 == null || c0 is Undefined) s.required(p, 'city', _m);
    // postCode: String
    Object? c1;
    c1 = s.string(s.read(input, 'post_code'), p, 'post_code', _m);
    if (c1 == null || c1 is Undefined) s.required(p, 'post_code', _m);
    if (s.issues.length != e) return null;
    if (c1 is String) {
      if (!(_r0.hasMatch(c1))) {
        s.fail(
          p,
          'post_code',
          IssueCodes.regex,
          DefaultMessages.regex,
          c1,
          messages: _m,
        );
      }
    }
    if (s.issues.length != e) return null;
    return Address(city: c0 as String, postCode: c1 as String);
  }

  @override
  Address fromMap(Map<String, dynamic> m) {
    return Address(
      city: m['city'] as String,
      postCode: m['post_code'] as String,
    );
  }

  @override
  Map<String, dynamic> toMap(Address o) {
    String f0 = o.city;
    String f1 = o.postCode;
    return <String, dynamic>{'city': f0, 'post_code': f1};
  }

  @override
  Map<String, dynamic> toJsonSchema() {
    return <String, dynamic>{
      'type': 'object',
      'title': 'Address',
      'properties': <String, dynamic>{
        'city': <String, dynamic>{'type': 'string'},
        'post_code': <String, dynamic>{
          'type': 'string',
          'pattern': '^(?:\\d{5})\$',
          'description': 'Five digits.',
        },
      },
      'required': <dynamic>['city', 'post_code'],
    };
  }
}

/// The checks, the converter and the JSON Schema of [OrderItem].
const DtoSchema<OrderItem> $OrderItemDto = _$OrderItemDto();

class _$OrderItemDto extends DtoSchema<OrderItem> {
  const _$OrderItemDto();

  static const Map<String, String> _m = <String, String>{};

  @override
  Type get type => OrderItem;

  @override
  String get name => 'OrderItem';

  @override
  bool get usesRequiredWhen => false;

  @override
  OrderItem? convert(Object? input, DtoState s, List<Object> p) {
    if (input is! Map) {
      s.notObject(input, p, _m);
      return null;
    }
    int e = s.issues.length;
    // name: String
    Object? c0;
    c0 = s.string(s.read(input, 'name'), p, 'name', _m, trim: true);
    if (c0 == null || c0 is Undefined) s.required(p, 'name', _m);
    // quantity: int
    Object? c1;
    c1 = s.integer(s.read(input, 'quantity'), p, 'quantity', _m);
    if (c1 == null || c1 is Undefined) s.required(p, 'quantity', _m);
    if (s.issues.length != e) return null;
    if (c0 is String) {
      if (!(c0.runes.length >= 1 && c0.runes.length <= 50)) {
        s.fail(
          p,
          'name',
          IssueCodes.lengthBetween,
          DefaultMessages.lengthBetween,
          c0,
          params: const <String, Object?>{'min': 1, 'max': 50},
          messages: _m,
        );
      }
    }
    if (c1 is int) {
      if (!(c1 >= 1)) {
        s.fail(
          p,
          'quantity',
          IssueCodes.min,
          DefaultMessages.min,
          c1,
          params: const <String, Object?>{'min': 1},
          messages: _m,
        );
      } else if (!(c1 <= 99)) {
        s.fail(
          p,
          'quantity',
          IssueCodes.max,
          DefaultMessages.max,
          c1,
          params: const <String, Object?>{'max': 99},
          messages: _m,
        );
      }
    }
    if (s.issues.length != e) return null;
    return OrderItem(name: c0 as String, quantity: c1 as int);
  }

  @override
  OrderItem fromMap(Map<String, dynamic> m) {
    return OrderItem(
      name: m['name'] as String,
      quantity: (m['quantity'] as num).toInt(),
    );
  }

  @override
  Map<String, dynamic> toMap(OrderItem o) {
    String f0 = o.name;
    int f1 = o.quantity;
    return <String, dynamic>{'name': f0, 'quantity': f1};
  }

  @override
  Map<String, dynamic> toJsonSchema() {
    return <String, dynamic>{
      'type': 'object',
      'title': 'OrderItem',
      'properties': <String, dynamic>{
        'name': <String, dynamic>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 50,
        },
        'quantity': <String, dynamic>{
          'type': 'integer',
          'minimum': 1,
          'maximum': 99,
        },
      },
      'required': <dynamic>['name', 'quantity'],
    };
  }
}

/// The checks, the converter and the JSON Schema of [CreateOrder].
const DtoSchema<CreateOrder> $CreateOrderDto = _$CreateOrderDto();

class _$CreateOrderDto extends DtoSchema<CreateOrder> {
  const _$CreateOrderDto();

  static const Map<String, String> _m = <String, String>{};

  static const Set<String> _keys = <String>{'address', 'items'};

  @override
  Type get type => CreateOrder;

  @override
  String get name => 'CreateOrder';

  @override
  bool get usesRequiredWhen => false;

  @override
  CreateOrder? convert(Object? input, DtoState s, List<Object> p) {
    if (input is! Map) {
      s.notObject(input, p, _m);
      return null;
    }
    int e = s.issues.length;
    for (Object? k in input.keys) {
      if (!_keys.contains(k)) {
        s.fail(
          p,
          '$k',
          IssueCodes.unrecognizedKeys,
          DefaultMessages.notAllowed,
          input[k],
          messages: _m,
        );
      }
    }
    // address: Address
    Object? c0;
    c0 = s.object(s.read(input, 'address'), p, 'address', _m);
    if (c0 is Map) {
      c0 = $AddressDto.convert(c0, s, <Object>[...p, 'address']) ?? invalid;
    }
    if (c0 == null || c0 is Undefined) s.required(p, 'address', _m);
    // items: List<OrderItem>
    Object? c1;
    c1 = s.list(s.read(input, 'items'), p, 'items', _m);
    if (c1 is List) {
      List<Object> q0 = <Object>[...p, 'items'];
      List<OrderItem> o0 = <OrderItem>[];
      for (int i0 = 0; i0 < c1.length; i0++) {
        Object? x0;
        x0 = s.object(c1[i0], q0, i0, _m);
        if (x0 is Map) {
          x0 = $OrderItemDto.convert(x0, s, <Object>[...q0, i0]) ?? invalid;
        }
        if (x0 == null || x0 is Undefined) {
          s.required(q0, i0, _m);
        } else if (x0 is! Invalid) {
          o0.add(x0 as OrderItem);
        }
      }
      c1 = o0;
    }
    if (c1 == null || c1 is Undefined) s.required(p, 'items', _m);
    if (s.issues.length != e) return null;
    if (c1 is List<OrderItem>) {
      if (!(c1.length >= 1)) {
        s.fail(
          p,
          'items',
          IssueCodes.minItems,
          DefaultMessages.minItems,
          c1,
          params: const <String, Object?>{'min': 1},
          messages: _m,
        );
      } else if (!(c1.length <= 10)) {
        s.fail(
          p,
          'items',
          IssueCodes.maxItems,
          DefaultMessages.maxItems,
          c1,
          params: const <String, Object?>{'max': 10},
          messages: _m,
        );
      }
    }
    if (s.issues.length != e) return null;
    return CreateOrder(address: c0 as Address, items: c1 as List<OrderItem>);
  }

  @override
  CreateOrder fromMap(Map<String, dynamic> m) {
    return CreateOrder(
      address: $AddressDto.fromMap(m['address'] as Map<String, dynamic>),
      items: <OrderItem>[
        for (Object? x0 in m['items'] as List<dynamic>)
          $OrderItemDto.fromMap(x0 as Map<String, dynamic>),
      ],
    );
  }

  @override
  Map<String, dynamic> toMap(CreateOrder o) {
    Address f0 = o.address;
    List<OrderItem> f1 = o.items;
    return <String, dynamic>{
      'address': $AddressDto.toMap(f0),
      'items': <dynamic>[for (OrderItem x0 in f1) $OrderItemDto.toMap(x0)],
    };
  }

  @override
  Map<String, dynamic> toJsonSchema() {
    return <String, dynamic>{
      'type': 'object',
      'title': 'CreateOrder',
      'properties': <String, dynamic>{
        'address': <String, dynamic>{'\$ref': '#/\$defs/Address'},
        'items': <String, dynamic>{
          'type': 'array',
          'items': <String, dynamic>{'\$ref': '#/\$defs/OrderItem'},
          'minItems': 1,
          'maxItems': 10,
        },
      },
      'required': <dynamic>['address', 'items'],
      'additionalProperties': false,
      '\$defs': <String, dynamic>{
        'Address': <String, dynamic>{
          'type': 'object',
          'title': 'Address',
          'properties': <String, dynamic>{
            'city': <String, dynamic>{'type': 'string'},
            'post_code': <String, dynamic>{
              'type': 'string',
              'pattern': '^(?:\\d{5})\$',
              'description': 'Five digits.',
            },
          },
          'required': <dynamic>['city', 'post_code'],
        },
        'OrderItem': <String, dynamic>{
          'type': 'object',
          'title': 'OrderItem',
          'properties': <String, dynamic>{
            'name': <String, dynamic>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 50,
            },
            'quantity': <String, dynamic>{
              'type': 'integer',
              'minimum': 1,
              'maximum': 99,
            },
          },
          'required': <dynamic>['name', 'quantity'],
        },
      },
    };
  }
}

/// The checks, the converter and the JSON Schema of [RuleCheck].
const DtoSchema<RuleCheck> $RuleCheckDto = _$RuleCheckDto();

class _$RuleCheckDto extends DtoSchema<RuleCheck> {
  const _$RuleCheckDto();

  static const Map<String, String> _m = <String, String>{};

  @override
  Type get type => RuleCheck;

  @override
  String get name => 'RuleCheck';

  @override
  RuleCheck? convert(Object? input, DtoState s, List<Object> p) {
    if (input is! Map) {
      s.notObject(input, p, _m);
      return null;
    }
    int e = s.issues.length;
    // kind: String
    Object? c0;
    c0 = s.string(s.read(input, 'kind'), p, 'kind', _m);
    if (c0 == null || c0 is Undefined) s.required(p, 'kind', _m);
    // teamName: String?
    Object? c1;
    c1 = s.string(s.read(input, 'team_name'), p, 'team_name', _m);
    // email: String?
    Object? c2;
    c2 = s.string(s.read(input, 'email'), p, 'email', _m);
    // phone: String?
    Object? c3;
    c3 = s.string(s.read(input, 'phone'), p, 'phone', _m);
    // pin: String
    Object? c4;
    c4 = s.string(s.read(input, 'pin'), p, 'pin', _m);
    if (c4 == null || c4 is Undefined) s.required(p, 'pin', _m);
    // startsOn: String
    Object? c5;
    c5 = s.string(s.read(input, 'starts_on'), p, 'starts_on', _m);
    if (c5 == null || c5 is Undefined) s.required(p, 'starts_on', _m);
    // password: String
    Object? c6;
    c6 = s.string(s.read(input, 'password'), p, 'password', _m);
    if (c6 == null || c6 is Undefined) s.required(p, 'password', _m);
    // passwordConfirmation: String?
    Object? c7;
    c7 = s.string(
      s.read(input, 'password_confirmation'),
      p,
      'password_confirmation',
      _m,
    );
    // code: String
    Object? c8;
    c8 = s.string(s.read(input, 'code'), p, 'code', _m);
    if (c8 == null || c8 is Undefined) s.required(p, 'code', _m);
    // codeAgain: String
    Object? c9;
    c9 = s.string(s.read(input, 'code_again'), p, 'code_again', _m);
    if (c9 == null || c9 is Undefined) s.required(p, 'code_again', _m);
    // ip: String?
    Object? c10;
    c10 = s.string(s.read(input, 'ip'), p, 'ip', _m);
    // data: String?
    Object? c11;
    c11 = s.string(s.read(input, 'data'), p, 'data', _m);
    // slug: String?
    Object? c12;
    c12 = s.string(s.read(input, 'slug'), p, 'slug', _m);
    s.requiredWhen(
      const RequiredIf('kind', 'team'),
      c1,
      input,
      p,
      'team_name',
      _m,
    );
    s.requiredWhen(
      const RequiredWith(<String>['email']),
      c3,
      input,
      p,
      'phone',
      _m,
    );
    if (s.issues.length != e) return null;
    if (c0 is String) {
      if (!(const <String>{'team', 'solo'}.contains(c0))) {
        s.fail(
          p,
          'kind',
          IssueCodes.inList,
          DefaultMessages.inList,
          c0,
          params: const <String, Object?>{'values': 'team, and solo'},
          messages: _m,
        );
      }
    }
    if (c2 is String) {
      if (!(Patterns.email.hasMatch(c2))) {
        s.fail(
          p,
          'email',
          IssueCodes.email,
          DefaultMessages.email,
          c2,
          messages: _m,
        );
      }
    }
    if (c4 is String) {
      if (!(const DigitsBetween(4, 6).check(c4, s.context(p, 'pin', c4)))) {
        s.failRule(const DigitsBetween(4, 6), p, 'pin', c4, _m);
      }
    }
    if (c5 is String) {
      if (!(const DateFormatted('Y-m-d')
          .check(c5, s.context(p, 'starts_on', c5)))) {
        s.failRule(const DateFormatted('Y-m-d'), p, 'starts_on', c5, _m);
      }
    }
    if (c6 is String) {
      if (!(const Password(
        letters: true,
        mixedCase: true,
        numbers: true,
      ).check(c6, s.context(p, 'password', c6)))) {
        s.failRule(
          const Password(letters: true, mixedCase: true, numbers: true),
          p,
          'password',
          c6,
          _m,
        );
      } else if (!(const Confirmed().check(c6, s.context(p, 'password', c6)))) {
        s.failRule(const Confirmed(), p, 'password', c6, _m);
      }
    }
    if (c9 is String) {
      if (!(const Same('code').check(c9, s.context(p, 'code_again', c9)))) {
        s.failRule(const Same('code'), p, 'code_again', c9, _m);
      }
    }
    if (c10 is String) {
      if (!(DtoChecks.ip(c10))) {
        s.fail(p, 'ip', IssueCodes.ip, DefaultMessages.ip, c10, messages: _m);
      }
    }
    if (c11 is String) {
      if (!(const Json().check(c11, s.context(p, 'data', c11)))) {
        s.failRule(const Json(), p, 'data', c11, _m);
      }
    }
    if (c12 is String) {
      if (!(Patterns.alphaDash.hasMatch(c12))) {
        s.fail(
          p,
          'slug',
          IssueCodes.alphaDash,
          DefaultMessages.alphaDash,
          c12,
          messages: _m,
        );
      }
    }
    if (s.issues.length != e) return null;
    return RuleCheck(
      kind: c0 as String,
      teamName: c1 is Undefined ? null : c1 as String?,
      email: c2 is Undefined ? null : c2 as String?,
      phone: c3 is Undefined ? null : c3 as String?,
      pin: c4 as String,
      startsOn: c5 as String,
      password: c6 as String,
      passwordConfirmation: c7 is Undefined ? null : c7 as String?,
      code: c8 as String,
      codeAgain: c9 as String,
      ip: c10 is Undefined ? null : c10 as String?,
      data: c11 is Undefined ? null : c11 as String?,
      slug: c12 is Undefined ? null : c12 as String?,
    );
  }

  @override
  RuleCheck fromMap(Map<String, dynamic> m) {
    return RuleCheck(
      kind: m['kind'] as String,
      teamName: m['team_name'] == null ? null : (m['team_name'] as String),
      email: m['email'] == null ? null : (m['email'] as String),
      phone: m['phone'] == null ? null : (m['phone'] as String),
      pin: m['pin'] as String,
      startsOn: m['starts_on'] as String,
      password: m['password'] as String,
      passwordConfirmation: m['password_confirmation'] == null
          ? null
          : (m['password_confirmation'] as String),
      code: m['code'] as String,
      codeAgain: m['code_again'] as String,
      ip: m['ip'] == null ? null : (m['ip'] as String),
      data: m['data'] == null ? null : (m['data'] as String),
      slug: m['slug'] == null ? null : (m['slug'] as String),
    );
  }

  @override
  Map<String, dynamic> toMap(RuleCheck o) {
    String f0 = o.kind;
    String? f1 = o.teamName;
    String? f2 = o.email;
    String? f3 = o.phone;
    String f4 = o.pin;
    String f5 = o.startsOn;
    String f6 = o.password;
    String? f7 = o.passwordConfirmation;
    String f8 = o.code;
    String f9 = o.codeAgain;
    String? f10 = o.ip;
    String? f11 = o.data;
    String? f12 = o.slug;
    return <String, dynamic>{
      'kind': f0,
      'team_name': f1,
      'email': f2,
      'phone': f3,
      'pin': f4,
      'starts_on': f5,
      'password': f6,
      'password_confirmation': f7,
      'code': f8,
      'code_again': f9,
      'ip': f10,
      'data': f11,
      'slug': f12,
    };
  }

  @override
  Map<String, dynamic> toJsonSchema() {
    Map<String, dynamic> j = <String, dynamic>{
      'type': 'object',
      'title': 'RuleCheck',
      'properties': <String, dynamic>{
        'kind': <String, dynamic>{
          'type': 'string',
          'enum': <dynamic>['team', 'solo'],
          'description': '`team` or `solo`.',
        },
        'team_name': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
          'description': 'Needed only when `kind` is `team`.',
        },
        'email': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
          'format': 'email',
        },
        'phone': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
          'description': 'Needed when `email` is there.',
        },
        'pin': <String, dynamic>{
          'type': 'string',
          'description': '4 to 6 digits.',
        },
        'starts_on': <String, dynamic>{'type': 'string'},
        'password': <String, dynamic>{
          'type': 'string',
          'description': '8 or more, letters in both cases and a number. Needs\n`password_confirmation` with the same text.',
        },
        'password_confirmation': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
        },
        'code': <String, dynamic>{'type': 'string'},
        'code_again': <String, dynamic>{'type': 'string'},
        'ip': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
          'anyOf': <dynamic>[
            <String, dynamic>{'format': 'ipv4'},
            <String, dynamic>{'format': 'ipv6'},
          ],
        },
        'data': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
        },
        'slug': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
          'pattern': '^[a-zA-Z0-9_-]+\$',
        },
      },
      'required': <dynamic>[
        'kind',
        'pin',
        'starts_on',
        'password',
        'code',
        'code_again',
      ],
    };
    JsonSchemaTools.merge(j, <String>[
      'properties',
      'pin',
    ], const DigitsBetween(4, 6).toJsonSchema());
    JsonSchemaTools.merge(j, <String>[
      'properties',
      'starts_on',
    ], const DateFormatted('Y-m-d').toJsonSchema());
    JsonSchemaTools.merge(
      j,
      <String>['properties', 'password'],
      const Password(
        letters: true,
        mixedCase: true,
        numbers: true,
      ).toJsonSchema(),
    );
    JsonSchemaTools.merge(j, <String>[
      'properties',
      'password',
    ], const Confirmed().toJsonSchema());
    JsonSchemaTools.merge(j, <String>[
      'properties',
      'code_again',
    ], const Same('code').toJsonSchema());
    JsonSchemaTools.merge(j, <String>[
      'properties',
      'data',
    ], const Json().toJsonSchema());
    return j;
  }
}
