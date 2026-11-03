import 'package:dox_core/dox_core.dart';

part 'core.dto.g.dart';

/// Body of POST /api/tokens. A new access token with some abilities.
@Dto()
class CreateToken {
  @Trim()
  @Length(min: 2, max: 100)
  final String name;

  @MinItems(1)
  final List<String> abilities;

  const CreateToken({required this.name, required this.abilities});

  static const DtoSchema<CreateToken> schema = $CreateTokenDto;
}

/// Body of POST /core/contacts.
/// A company needs a company name. A phone needs a country code.
@Dto()
class SaveContact {
  @In(<String>['person', 'company'])
  final String accountType;

  @RequiredIf('account_type', 'company')
  final String? companyName;

  final String? phone;

  @RequiredWith(<String>['phone'])
  final String? countryCode;

  const SaveContact({
    required this.accountType,
    this.companyName,
    this.phone,
    this.countryCode,
  });

  static const DtoSchema<SaveContact> schema = $SaveContactDto;
}

/// Form data of POST /core/banner. A PNG of at least 2x2 pixels and 100 bytes.
@Dto()
class UploadBanner {
  @MimeTypes(<String>['image/png'])
  @MinSize('100B')
  @Dimensions(minWidth: 2, minHeight: 2)
  final RequestFile banner;

  const UploadBanner({required this.banner});

  static const DtoSchema<UploadBanner> schema = $UploadBannerDto;
}
