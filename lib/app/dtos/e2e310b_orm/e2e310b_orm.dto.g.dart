// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'e2e310b_orm.dto.dart';

// **************************************************************************
// DoxDtoGenerator
// **************************************************************************

// ignore_for_file: type=lint

/// The checks, the converter and the JSON Schema of [E310bAddress].
const DtoSchema<E310bAddress> $E310bAddressDto = _$E310bAddressDto();

class _$E310bAddressDto extends DtoSchema<E310bAddress>
    implements JsonObjectWriter {
  const _$E310bAddressDto();

  static const Map<String, String> _messages = <String, String>{
    'street.required': 'Inner: the street',
  };

  @override
  Type get type => E310bAddress;

  @override
  String get name => 'E310bAddress';

  @override
  bool get usesRequiredWhen => false;

  @override
  E310bAddress? convert(Object? input, DtoState state, List<Object> path) {
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
    );
    if (city == null || city is Undefined)
      state.required(path, 'city', _messages);
    // street: String
    Object? street = state.string(
      state.read(input, 'street'),
      path,
      'street',
      _messages,
    );
    if (street == null || street is Undefined)
      state.required(path, 'street', _messages);
    // zip: String
    Object? zip = state.string(
      state.read(input, 'zip'),
      path,
      'zip',
      _messages,
    );
    if (zip == null || zip is Undefined) state.required(path, 'zip', _messages);
    if (state.issues.length != issuesBefore && !state.allErrors) return null;
    if (state.issues.length != issuesBefore) return null;
    return E310bAddress(
      city: city as String,
      street: street as String,
      zip: zip as String,
    );
  }

  @override
  E310bAddress fromMap(Map<String, dynamic> map) {
    return E310bAddress(
      city: map['city'] as String,
      street: map['street'] as String,
      zip: map['zip'] as String,
    );
  }

  @override
  Map<String, dynamic> toMap(E310bAddress dto) {
    return <String, dynamic>{
      'city': dto.city,
      'street': dto.street,
      'zip': dto.zip,
    };
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as E310bAddress));

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

class _$E310bProfileFormDto extends DtoSchema<E310bProfileForm>
    implements JsonObjectWriter {
  const _$E310bProfileFormDto();

  static const Map<String, String> _messages = <String, String>{
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
  bool get usesRequiredWhen => false;

  @override
  E310bProfileForm? convert(Object? input, DtoState state, List<Object> path) {
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
    );
    if (name == null || name is Undefined)
      state.required(path, 'name', _messages);
    // address: E310bAddress
    Object? address = state.object(
      state.read(input, 'address'),
      path,
      'address',
      _messages,
    );
    if (address is Map) {
      address =
          $E310bAddressDto.convert(address, state, <Object>[
            ...path,
            'address',
          ]) ??
          invalid;
    }
    if (address == null || address is Undefined)
      state.required(path, 'address', _messages);
    // tags: List<String>
    Object? tags = state.list(
      state.read(input, 'tags'),
      path,
      'tags',
      _messages,
    );
    if (tags is List) {
      int b0 = state.issues.length;
      List<Object> q0 = <Object>[...path, 'tags'];
      List<String> o0 = <String>[];
      for (int i0 = 0; i0 < tags.length; i0++) {
        Object? x0 = state.string(tags[i0], q0, i0, _messages);
        if (x0 == null || x0 is Undefined) {
          state.required(q0, i0, _messages);
        } else if (x0 is! Invalid) {
          o0.add(x0 as String);
        }
      }
      tags = state.issues.length != b0 ? invalid : o0;
    }
    if (tags == null) state.required(path, 'tags', _messages);
    if (state.issues.length != issuesBefore && !state.allErrors) return null;
    if (state.issues.length != issuesBefore) return null;
    return E310bProfileForm(
      name: name as String,
      address: address as E310bAddress,
      tags: tags is Undefined ? const <String>[] : tags as List<String>,
    );
  }

  @override
  E310bProfileForm fromMap(Map<String, dynamic> map) {
    return E310bProfileForm(
      name: map['name'] as String,
      address: $E310bAddressDto.fromMap(map['address'] as Map<String, dynamic>),
      tags: map.containsKey('tags')
          ? <String>[
              for (Object? x0 in map['tags'] as List<dynamic>) x0 as String,
            ]
          : const <String>[],
    );
  }

  @override
  Map<String, dynamic> toMap(E310bProfileForm dto) {
    return <String, dynamic>{
      'name': dto.name,
      'address': $E310bAddressDto.toMap(dto.address),
      'tags': dto.tags,
    };
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as E310bProfileForm));

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
