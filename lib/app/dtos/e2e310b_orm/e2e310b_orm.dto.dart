import 'package:dox_core/dox_core.dart';

part 'e2e310b_orm.dto.g.dart';

/// Test DTOs of test/e2e_310b_orm.dart. The route
/// POST /core/e310b/profile checks [E310bProfileForm].

/// The nested DTO. Its own message is only for `street`.
@Dto(messages: <String, String>{'street.required': 'Inner: the street'})
class E310bAddress {
  final String city;

  final String street;

  final String zip;

  const E310bAddress({
    required this.city,
    required this.street,
    required this.zip,
  });

  static const DtoSchema<E310bAddress> schema = $E310bAddressDto;
}

/// Messages with the full dotted path, like Laravel. `zip.required` is
/// a last key message of the outer DTO: it does not reach the nested one.
@Dto(
  messages: <String, String>{
    'address.city.required': 'Outer: the city',
    'tags.*.required': 'Outer: each tag',
    'zip.required': 'Outer: not used',
    'name.required': 'Outer: the name',
  },
)
class E310bProfileForm {
  final String name;

  final E310bAddress address;

  final List<String> tags;

  const E310bProfileForm({
    required this.name,
    required this.address,
    this.tags = const <String>[],
  });

  static const DtoSchema<E310bProfileForm> schema = $E310bProfileFormDto;
}
