import 'package:dox_core/dox_core.dart';

part 'system.dto.g.dart';

/// Body of POST /api/system/hash.
@Dto()
class HashPassword {
  final String password;

  const HashPassword({required this.password});

  static const DtoSchema<HashPassword> schema = $HashPasswordDto;
}

/// Nested DTO inside [CreateOrder].
@Dto()
class Address {
  @Trim()
  final String city;

  /// Five digits.
  @Regex(r'\d{5}')
  final String postCode;

  const Address({required this.city, required this.postCode});

  static const DtoSchema<Address> schema = $AddressDto;
}

/// One item of [CreateOrder].
@Dto()
class OrderItem {
  @Trim()
  @Length(min: 1, max: 50)
  final String name;

  @Min(1)
  @Max(99)
  final int quantity;

  const OrderItem({required this.name, required this.quantity});

  static const DtoSchema<OrderItem> schema = $OrderItemDto;
}

/// Body of POST /api/system/orders: a nested DTO and a list of DTOs.
@Dto(strict: true)
class CreateOrder {
  final Address address;

  @MinItems(1)
  @MaxItems(10)
  final List<OrderItem> items;

  const CreateOrder({required this.address, required this.items});

  static const DtoSchema<CreateOrder> schema = $CreateOrderDto;
}
