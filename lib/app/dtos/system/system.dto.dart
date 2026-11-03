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

/// Body of POST /api/system/rules: the Laravel-style rules of
/// dox_validation in one DTO.
@Dto()
class RuleCheck {
  /// `team` or `solo`.
  @In(<String>['team', 'solo'])
  final String kind;

  /// Needed only when `kind` is `team`.
  @RequiredIf('kind', 'team')
  final String? teamName;

  @Email()
  final String? email;

  /// Needed when `email` is there.
  @RequiredWith(<String>['email'])
  final String? phone;

  /// 4 to 6 digits.
  @DigitsBetween(4, 6)
  final String pin;

  @DateFormatted('Y-m-d')
  final String startsOn;

  /// 8 or more, letters in both cases and a number. Needs
  /// `password_confirmation` with the same text.
  @Password(letters: true, mixedCase: true, numbers: true)
  @Confirmed()
  final String password;

  final String? passwordConfirmation;

  final String code;

  @Same('code')
  final String codeAgain;

  @Ip()
  final String? ip;

  @Json()
  final String? data;

  @AlphaDash()
  final String? slug;

  const RuleCheck({
    required this.kind,
    this.teamName,
    this.email,
    this.phone,
    required this.pin,
    required this.startsOn,
    required this.password,
    this.passwordConfirmation,
    required this.code,
    required this.codeAgain,
    this.ip,
    this.data,
    this.slug,
  });

  static const DtoSchema<RuleCheck> schema = $RuleCheckDto;
}
