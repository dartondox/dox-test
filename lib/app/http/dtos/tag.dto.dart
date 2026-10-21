import 'package:dox_core/dox_core.dart';

part 'tag.dto.g.dart';

/// Query of GET /api/tags.
@Dto()
class ListTags {
  @Range(1, 100)
  final int limit;

  /// `alpha,beta` leaves those names out.
  final String? except;

  const ListTags({this.limit = 10, this.except});

  static const DtoSchema<ListTags> schema = $ListTagsDto;
}

/// Body of POST /api/tags.
@Dto()
class CreateTags {
  @MinItems(1)
  @MaxItems(10)
  @Trim()
  @Lowercase()
  @Length(min: 2, max: 100)
  final List<String> names;

  /// `true` throws inside the transaction, so nothing is saved.
  final bool fail;

  const CreateTags({required this.names, this.fail = false});

  static const DtoSchema<CreateTags> schema = $CreateTagsDto;
}
