import 'package:dox_core/dox_core.dart';

part 'graphql.dto.g.dart';

/// The input of `createPost` and `updatePost` (GraphQL). No `userId`:
/// the owner is the logged-in user.
@Dto()
class GqlPostInput {
  @MinLength(3)
  final String title;

  final String body;

  final String status;

  const GqlPostInput({
    required this.title,
    this.body = '',
    this.status = 'draft',
  });

  static const DtoSchema<GqlPostInput> schema = $GqlPostInputDto;
}

/// The input of `createGqlSecret`. `policy:` needs a DTO.
@Dto()
class GqlSecretInput {
  final String body;

  final int postId;

  const GqlSecretInput({required this.body, required this.postId});

  static const DtoSchema<GqlSecretInput> schema = $GqlSecretInputDto;
}
