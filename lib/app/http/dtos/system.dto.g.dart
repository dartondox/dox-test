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
