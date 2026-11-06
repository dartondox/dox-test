// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'e2e310b_orm.dto.dart';

// **************************************************************************
// DoxDtoGenerator
// **************************************************************************

// ignore_for_file: type=lint

/// The checks, the converter and the JSON Schema of [E310bAddress].
const DtoSchema<E310bAddress> $E310bAddressDto = _$E310bAddressDto();

class _$E310bAddressDto extends DtoSchema<E310bAddress> {
  const _$E310bAddressDto();

  static const Map<String, String> _m = <String, String>{
    'street.required': 'Inner: the street',
  };

  @override
  Type get type => E310bAddress;

  @override
  String get name => 'E310bAddress';

  @override
  E310bAddress? convert(Object? input, DtoState s, List<Object> p) {
    if (input is! Map) {
      s.notObject(input, p, _m);
      return null;
    }
    int e = s.issues.length;
    // city: String
    Object? c0;
    c0 = s.string(s.read(input, 'city'), p, 'city', _m);
    if (c0 == null || c0 is Undefined) s.required(p, 'city', _m);
    // street: String
    Object? c1;
    c1 = s.string(s.read(input, 'street'), p, 'street', _m);
    if (c1 == null || c1 is Undefined) s.required(p, 'street', _m);
    // zip: String
    Object? c2;
    c2 = s.string(s.read(input, 'zip'), p, 'zip', _m);
    if (c2 == null || c2 is Undefined) s.required(p, 'zip', _m);
    if (s.issues.length != e) return null;
    return E310bAddress(
      city: c0 as String,
      street: c1 as String,
      zip: c2 as String,
    );
  }

  @override
  E310bAddress fromMap(Map<String, dynamic> m) {
    return E310bAddress(
      city: m['city'] as String,
      street: m['street'] as String,
      zip: m['zip'] as String,
    );
  }

  @override
  Map<String, dynamic> toMap(E310bAddress o) {
    String f0 = o.city;
    String f1 = o.street;
    String f2 = o.zip;
    return <String, dynamic>{'city': f0, 'street': f1, 'zip': f2};
  }

  @override
  Map<String, dynamic> toJsonSchema() {
    return <String, dynamic>{
      'type': 'object',
      'title': 'E310bAddress',
      'properties': <String, dynamic>{
        'city': <String, dynamic>{'type': 'string'},
        'street': <String, dynamic>{'type': 'string'},
        'zip': <String, dynamic>{'type': 'string'},
      },
      'required': <dynamic>['city', 'street', 'zip'],
    };
  }
}

/// The checks, the converter and the JSON Schema of [E310bProfileForm].
const DtoSchema<E310bProfileForm> $E310bProfileFormDto =
    _$E310bProfileFormDto();

class _$E310bProfileFormDto extends DtoSchema<E310bProfileForm> {
  const _$E310bProfileFormDto();

  static const Map<String, String> _m = <String, String>{
    'address.city.required': 'Outer: the city',
    'tags.*.required': 'Outer: each tag',
    'zip.required': 'Outer: not used',
    'name.required': 'Outer: the name',
  };

  @override
  Type get type => E310bProfileForm;

  @override
  String get name => 'E310bProfileForm';

  @override
  E310bProfileForm? convert(Object? input, DtoState s, List<Object> p) {
    if (input is! Map) {
      s.notObject(input, p, _m);
      return null;
    }
    int e = s.issues.length;
    // name: String
    Object? c0;
    c0 = s.string(s.read(input, 'name'), p, 'name', _m);
    if (c0 == null || c0 is Undefined) s.required(p, 'name', _m);
    // address: E310bAddress
    Object? c1;
    c1 = s.object(s.read(input, 'address'), p, 'address', _m);
    if (c1 is Map) {
      c1 =
          $E310bAddressDto.convert(c1, s, <Object>[...p, 'address']) ?? invalid;
    }
    if (c1 == null || c1 is Undefined) s.required(p, 'address', _m);
    // tags: List<String>
    Object? c2;
    c2 = s.list(s.read(input, 'tags'), p, 'tags', _m);
    if (c2 is List) {
      List<Object> q0 = <Object>[...p, 'tags'];
      List<String> o0 = <String>[];
      for (int i0 = 0; i0 < c2.length; i0++) {
        Object? x0;
        x0 = s.string(c2[i0], q0, i0, _m);
        if (x0 == null || x0 is Undefined) {
          s.required(q0, i0, _m);
        } else if (x0 is! Invalid) {
          o0.add(x0 as String);
        }
      }
      c2 = o0;
    }
    if (c2 == null) s.required(p, 'tags', _m);
    if (s.issues.length != e) return null;
    return E310bProfileForm(
      name: c0 as String,
      address: c1 as E310bAddress,
      tags: c2 is Undefined ? const <String>[] : c2 as List<String>,
    );
  }

  @override
  E310bProfileForm fromMap(Map<String, dynamic> m) {
    return E310bProfileForm(
      name: m['name'] as String,
      address: $E310bAddressDto.fromMap(m['address'] as Map<String, dynamic>),
      tags: m.containsKey('tags')
          ? <String>[
              for (Object? x0 in m['tags'] as List<dynamic>) x0 as String,
            ]
          : const <String>[],
    );
  }

  @override
  Map<String, dynamic> toMap(E310bProfileForm o) {
    String f0 = o.name;
    E310bAddress f1 = o.address;
    List<String> f2 = o.tags;
    return <String, dynamic>{
      'name': f0,
      'address': $E310bAddressDto.toMap(f1),
      'tags': f2,
    };
  }

  @override
  Map<String, dynamic> toJsonSchema() {
    return <String, dynamic>{
      'type': 'object',
      'title': 'E310bProfileForm',
      'properties': <String, dynamic>{
        'name': <String, dynamic>{'type': 'string'},
        'address': <String, dynamic>{'\$ref': '#/\$defs/E310bAddress'},
        'tags': <String, dynamic>{
          'type': 'array',
          'items': <String, dynamic>{'type': 'string'},
          'default': <dynamic>[],
        },
      },
      'required': <dynamic>['name', 'address'],
      '\$defs': <String, dynamic>{
        'E310bAddress': <String, dynamic>{
          'type': 'object',
          'title': 'E310bAddress',
          'properties': <String, dynamic>{
            'city': <String, dynamic>{'type': 'string'},
            'street': <String, dynamic>{'type': 'string'},
            'zip': <String, dynamic>{'type': 'string'},
          },
          'required': <dynamic>['city', 'street', 'zip'],
        },
      },
    };
  }
}
