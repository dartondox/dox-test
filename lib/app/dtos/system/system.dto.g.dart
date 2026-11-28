// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system.dto.dart';

// **************************************************************************
// DoxDtoGenerator
// **************************************************************************

// ignore_for_file: type=lint

/// The checks, the converter and the JSON Schema of [HashPassword].
const DtoSchema<HashPassword> $HashPasswordDto = _$HashPasswordDto();

class _$HashPasswordDto extends DtoSchema<HashPassword>
    implements JsonObjectWriter {
  const _$HashPasswordDto();

  static const Map<String, String> _messages = <String, String>{};

  @override
  Type get type => HashPassword;

  @override
  String get name => 'HashPassword';

  @override
  bool get usesRequiredWhen => false;

  @override
  HashPassword? convert(Object? input, DtoState state, List<Object> path) {
    if (input is! Map) {
      state.notObject(input, path, _messages);
      return null;
    }
    int issuesBefore = state.issues.length;
    // password: String
    Object? password = state.string(
      state.read(input, 'password'),
      path,
      'password',
      _messages,
    );
    if (password == null || password is Undefined)
      state.required(path, 'password', _messages);
    if (state.issues.length != issuesBefore && !state.allErrors) return null;
    if (state.issues.length != issuesBefore) return null;
    return HashPassword(password: password as String);
  }

  @override
  HashPassword fromMap(Map<String, dynamic> map) {
    return HashPassword(password: map['password'] as String);
  }

  @override
  Map<String, dynamic> toMap(HashPassword dto) {
    return <String, dynamic>{'password': dto.password};
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as HashPassword));

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

class _$AddressDto extends DtoSchema<Address> implements JsonObjectWriter {
  const _$AddressDto();

  static const Map<String, String> _messages = <String, String>{};

  static final RegExp _r0 = RegExp('^(?:\\d{5})\$');

  @override
  Type get type => Address;

  @override
  String get name => 'Address';

  @override
  bool get usesRequiredWhen => false;

  @override
  Address? convert(Object? input, DtoState state, List<Object> path) {
    if (input is! Map) {
      state.notObject(input, path, _messages);
      return null;
    }
    int issuesBefore = state.issues.length;
    // city: String
    Object? city = state.string(
      state.read(input, 'city'),
      path,
      'city',
      _messages,
      trim: true,
    );
    if (city == null || city is Undefined)
      state.required(path, 'city', _messages);
    // postCode: String
    Object? postCode = state.string(
      state.read(input, 'post_code'),
      path,
      'post_code',
      _messages,
    );
    if (postCode == null || postCode is Undefined)
      state.required(path, 'post_code', _messages);
    if (state.issues.length != issuesBefore && !state.allErrors) return null;
    if (postCode is String) {
      if (!(_r0.hasMatch(postCode))) {
        state.fail(
          path,
          'post_code',
          IssueCodes.regex,
          DefaultMessages.regex,
          postCode,
          messages: _messages,
        );
      }
    }
    if (state.issues.length != issuesBefore) return null;
    return Address(city: city as String, postCode: postCode as String);
  }

  @override
  Address fromMap(Map<String, dynamic> map) {
    return Address(
      city: map['city'] as String,
      postCode: map['post_code'] as String,
    );
  }

  @override
  Map<String, dynamic> toMap(Address dto) {
    return <String, dynamic>{'city': dto.city, 'post_code': dto.postCode};
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as Address));

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

class _$OrderItemDto extends DtoSchema<OrderItem> implements JsonObjectWriter {
  const _$OrderItemDto();

  static const Map<String, String> _messages = <String, String>{};

  @override
  Type get type => OrderItem;

  @override
  String get name => 'OrderItem';

  @override
  bool get usesRequiredWhen => false;

  @override
  OrderItem? convert(Object? input, DtoState state, List<Object> path) {
    if (input is! Map) {
      state.notObject(input, path, _messages);
      return null;
    }
    int issuesBefore = state.issues.length;
    // name: String
    Object? name = state.string(
      state.read(input, 'name'),
      path,
      'name',
      _messages,
      trim: true,
    );
    if (name == null || name is Undefined)
      state.required(path, 'name', _messages);
    // quantity: int
    Object? quantity = state.integer(
      state.read(input, 'quantity'),
      path,
      'quantity',
      _messages,
    );
    if (quantity == null || quantity is Undefined)
      state.required(path, 'quantity', _messages);
    if (state.issues.length != issuesBefore && !state.allErrors) return null;
    if (name is String) {
      if (!(name.runes.length >= 1 && name.runes.length <= 50)) {
        state.fail(
          path,
          'name',
          IssueCodes.lengthBetween,
          DefaultMessages.lengthBetween,
          name,
          params: const <String, Object?>{'min': 1, 'max': 50},
          messages: _messages,
        );
      }
    }
    if (quantity is int) {
      if (!(quantity >= 1)) {
        state.fail(
          path,
          'quantity',
          IssueCodes.min,
          DefaultMessages.min,
          quantity,
          params: const <String, Object?>{'min': 1},
          messages: _messages,
        );
      } else if (!(quantity <= 99)) {
        state.fail(
          path,
          'quantity',
          IssueCodes.max,
          DefaultMessages.max,
          quantity,
          params: const <String, Object?>{'max': 99},
          messages: _messages,
        );
      }
    }
    if (state.issues.length != issuesBefore) return null;
    return OrderItem(name: name as String, quantity: quantity as int);
  }

  @override
  OrderItem fromMap(Map<String, dynamic> map) {
    return OrderItem(
      name: map['name'] as String,
      quantity: (map['quantity'] as num).toInt(),
    );
  }

  @override
  Map<String, dynamic> toMap(OrderItem dto) {
    return <String, dynamic>{'name': dto.name, 'quantity': dto.quantity};
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as OrderItem));

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

class _$CreateOrderDto extends DtoSchema<CreateOrder>
    implements JsonObjectWriter {
  const _$CreateOrderDto();

  static const Map<String, String> _messages = <String, String>{};

  static const Set<String> _keys = <String>{'address', 'items'};

  @override
  Type get type => CreateOrder;

  @override
  String get name => 'CreateOrder';

  @override
  bool get usesRequiredWhen => false;

  @override
  CreateOrder? convert(Object? input, DtoState state, List<Object> path) {
    if (input is! Map) {
      state.notObject(input, path, _messages);
      return null;
    }
    int issuesBefore = state.issues.length;
    for (Object? k in input.keys) {
      if (!_keys.contains(k)) {
        state.fail(
          path,
          '$k',
          IssueCodes.unrecognizedKeys,
          DefaultMessages.notAllowed,
          input[k],
          messages: _messages,
        );
      }
    }
    // address: Address
    Object? address = state.object(
      state.read(input, 'address'),
      path,
      'address',
      _messages,
    );
    if (address is Map) {
      address =
          $AddressDto.convert(address, state, <Object>[...path, 'address']) ??
          invalid;
    }
    if (address == null || address is Undefined)
      state.required(path, 'address', _messages);
    // items: List<OrderItem>
    Object? items = state.list(
      state.read(input, 'items'),
      path,
      'items',
      _messages,
    );
    if (items is List) {
      int b0 = state.issues.length;
      List<Object> q0 = <Object>[...path, 'items'];
      List<OrderItem> o0 = <OrderItem>[];
      for (int i0 = 0; i0 < items.length; i0++) {
        Object? x0 = state.object(items[i0], q0, i0, _messages);
        if (x0 is Map) {
          x0 = $OrderItemDto.convert(x0, state, <Object>[...q0, i0]) ?? invalid;
        }
        if (x0 == null || x0 is Undefined) {
          state.required(q0, i0, _messages);
        } else if (x0 is! Invalid) {
          o0.add(x0 as OrderItem);
        }
      }
      items = state.issues.length != b0 ? invalid : o0;
    }
    if (items == null || items is Undefined || state.emptyList(items)) {
      state.required(path, 'items', _messages);
      items = invalid;
    }
    if (state.issues.length != issuesBefore && !state.allErrors) return null;
    if (items is List<OrderItem>) {
      if (!(items.length >= 1)) {
        state.fail(
          path,
          'items',
          IssueCodes.minItems,
          DefaultMessages.minItems,
          items,
          params: const <String, Object?>{'min': 1},
          messages: _messages,
        );
      } else if (!(items.length <= 10)) {
        state.fail(
          path,
          'items',
          IssueCodes.maxItems,
          DefaultMessages.maxItems,
          items,
          params: const <String, Object?>{'max': 10},
          messages: _messages,
        );
      }
    }
    if (state.issues.length != issuesBefore) return null;
    return CreateOrder(
      address: address as Address,
      items: items as List<OrderItem>,
    );
  }

  @override
  CreateOrder fromMap(Map<String, dynamic> map) {
    return CreateOrder(
      address: $AddressDto.fromMap(map['address'] as Map<String, dynamic>),
      items: <OrderItem>[
        for (Object? x0 in map['items'] as List<dynamic>)
          $OrderItemDto.fromMap(x0 as Map<String, dynamic>),
      ],
    );
  }

  @override
  Map<String, dynamic> toMap(CreateOrder dto) {
    return <String, dynamic>{
      'address': $AddressDto.toMap(dto.address),
      'items': <dynamic>[
        for (OrderItem x0 in dto.items) $OrderItemDto.toMap(x0),
      ],
    };
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as CreateOrder));

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

class _$RuleCheckDto extends DtoSchema<RuleCheck> implements JsonObjectWriter {
  const _$RuleCheckDto();

  static const Map<String, String> _messages = <String, String>{};

  @override
  Type get type => RuleCheck;

  @override
  String get name => 'RuleCheck';

  @override
  RuleCheck? convert(Object? input, DtoState state, List<Object> path) {
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
    );
    // phone: String?
    Object? phone = state.string(
      state.read(input, 'phone'),
      path,
      'phone',
      _messages,
    );
    // pin: String
    Object? pin = state.string(
      state.read(input, 'pin'),
      path,
      'pin',
      _messages,
    );
    if (pin == null || pin is Undefined) state.required(path, 'pin', _messages);
    // startsOn: String
    Object? startsOn = state.string(
      state.read(input, 'starts_on'),
      path,
      'starts_on',
      _messages,
    );
    if (startsOn == null || startsOn is Undefined)
      state.required(path, 'starts_on', _messages);
    // password: String
    Object? password = state.string(
      state.read(input, 'password'),
      path,
      'password',
      _messages,
    );
    if (password == null || password is Undefined)
      state.required(path, 'password', _messages);
    // passwordConfirmation: String?
    Object? passwordConfirmation = state.string(
      state.read(input, 'password_confirmation'),
      path,
      'password_confirmation',
      _messages,
    );
    // code: String
    Object? code = state.string(
      state.read(input, 'code'),
      path,
      'code',
      _messages,
    );
    if (code == null || code is Undefined)
      state.required(path, 'code', _messages);
    // codeAgain: String
    Object? codeAgain = state.string(
      state.read(input, 'code_again'),
      path,
      'code_again',
      _messages,
    );
    if (codeAgain == null || codeAgain is Undefined)
      state.required(path, 'code_again', _messages);
    // ip: String?
    Object? ip = state.string(state.read(input, 'ip'), path, 'ip', _messages);
    // data: String?
    Object? data = state.string(
      state.read(input, 'data'),
      path,
      'data',
      _messages,
    );
    // slug: String?
    Object? slug = state.string(
      state.read(input, 'slug'),
      path,
      'slug',
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
    if (kind is String) {
      if (!(const <String>{'team', 'solo'}.contains(kind))) {
        state.fail(
          path,
          'kind',
          IssueCodes.inList,
          DefaultMessages.inList,
          kind,
          params: const <String, Object?>{'values': 'team, and solo'},
          messages: _messages,
        );
      }
    }
    if (email is String) {
      if (!(Patterns.email.hasMatch(email))) {
        state.fail(
          path,
          'email',
          IssueCodes.email,
          DefaultMessages.email,
          email,
          messages: _messages,
        );
      }
    }
    if (pin is String) {
      if (!(const DigitsBetween(
        4,
        6,
      ).check(pin, state.context(path, 'pin', pin)))) {
        state.failRule(const DigitsBetween(4, 6), path, 'pin', pin, _messages);
      }
    }
    if (startsOn is String) {
      if (!(const DateFormatted('Y-m-d')
          .check(startsOn, state.context(path, 'starts_on', startsOn)))) {
        state.failRule(
          const DateFormatted('Y-m-d'),
          path,
          'starts_on',
          startsOn,
          _messages,
        );
      }
    }
    if (password is String) {
      if (!(const Password(
        letters: true,
        mixedCase: true,
        numbers: true,
      ).check(password, state.context(path, 'password', password)))) {
        state.failRule(
          const Password(letters: true, mixedCase: true, numbers: true),
          path,
          'password',
          password,
          _messages,
        );
      } else if (!(const Confirmed().check(
        password,
        state.context(path, 'password', password),
      ))) {
        state.failRule(
          const Confirmed(),
          path,
          'password',
          password,
          _messages,
        );
      }
    }
    if (codeAgain is String) {
      if (!(const Same('code')
          .check(codeAgain, state.context(path, 'code_again', codeAgain)))) {
        state.failRule(
          const Same('code'),
          path,
          'code_again',
          codeAgain,
          _messages,
        );
      }
    }
    if (ip is String) {
      if (!(DtoChecks.ip(ip))) {
        state.fail(
          path,
          'ip',
          IssueCodes.ip,
          DefaultMessages.ip,
          ip,
          messages: _messages,
        );
      }
    }
    if (data is String) {
      if (!(const Json().check(data, state.context(path, 'data', data)))) {
        state.failRule(const Json(), path, 'data', data, _messages);
      }
    }
    if (slug is String) {
      if (!(Patterns.alphaDash.hasMatch(slug))) {
        state.fail(
          path,
          'slug',
          IssueCodes.alphaDash,
          DefaultMessages.alphaDash,
          slug,
          messages: _messages,
        );
      }
    }
    if (state.issues.length != issuesBefore) return null;
    return RuleCheck(
      kind: kind as String,
      teamName: teamName is Undefined ? null : teamName as String?,
      email: email is Undefined ? null : email as String?,
      phone: phone is Undefined ? null : phone as String?,
      pin: pin as String,
      startsOn: startsOn as String,
      password: password as String,
      passwordConfirmation: passwordConfirmation is Undefined
          ? null
          : passwordConfirmation as String?,
      code: code as String,
      codeAgain: codeAgain as String,
      ip: ip is Undefined ? null : ip as String?,
      data: data is Undefined ? null : data as String?,
      slug: slug is Undefined ? null : slug as String?,
    );
  }

  @override
  RuleCheck fromMap(Map<String, dynamic> map) {
    return RuleCheck(
      kind: map['kind'] as String,
      teamName: map['team_name'] == null ? null : (map['team_name'] as String),
      email: map['email'] == null ? null : (map['email'] as String),
      phone: map['phone'] == null ? null : (map['phone'] as String),
      pin: map['pin'] as String,
      startsOn: map['starts_on'] as String,
      password: map['password'] as String,
      passwordConfirmation: map['password_confirmation'] == null
          ? null
          : (map['password_confirmation'] as String),
      code: map['code'] as String,
      codeAgain: map['code_again'] as String,
      ip: map['ip'] == null ? null : (map['ip'] as String),
      data: map['data'] == null ? null : (map['data'] as String),
      slug: map['slug'] == null ? null : (map['slug'] as String),
    );
  }

  @override
  Map<String, dynamic> toMap(RuleCheck dto) {
    return <String, dynamic>{
      'kind': dto.kind,
      'team_name': dto.teamName,
      'email': dto.email,
      'phone': dto.phone,
      'pin': dto.pin,
      'starts_on': dto.startsOn,
      'password': dto.password,
      'password_confirmation': dto.passwordConfirmation,
      'code': dto.code,
      'code_again': dto.codeAgain,
      'ip': dto.ip,
      'data': dto.data,
      'slug': dto.slug,
    };
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as RuleCheck));

  @override
  Map<String, dynamic> toJsonSchema() {
    Map<String, dynamic> schema = <String, dynamic>{
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
    JsonSchemaTools.merge(schema, <String>[
      'properties',
      'pin',
    ], const DigitsBetween(4, 6).toJsonSchema());
    JsonSchemaTools.merge(schema, <String>[
      'properties',
      'starts_on',
    ], const DateFormatted('Y-m-d').toJsonSchema());
    JsonSchemaTools.merge(
      schema,
      <String>['properties', 'password'],
      const Password(
        letters: true,
        mixedCase: true,
        numbers: true,
      ).toJsonSchema(),
    );
    JsonSchemaTools.merge(schema, <String>[
      'properties',
      'password',
    ], const Confirmed().toJsonSchema());
    JsonSchemaTools.merge(schema, <String>[
      'properties',
      'code_again',
    ], const Same('code').toJsonSchema());
    JsonSchemaTools.merge(schema, <String>[
      'properties',
      'data',
    ], const Json().toJsonSchema());
    return schema;
  }
}
