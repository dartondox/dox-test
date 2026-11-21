import 'package:dox_auth/dox_auth.dart';
import 'package:dox_graphql/dox_graphql.dart';
import 'package:dox_test/generated/schema.g.dart';

/// GraphQL at /graphql. A field is public unless it has `guard: true`.
/// AuthMiddleware reads the user for `guard: true` and `can:`.
GraphQLConfig graphqlConfig = GraphQLConfig(
  schema: graphqlSchema,
  middleware: <Object>[AuthMiddleware()],
);

/// The same schema at /graphql-small, with a small relation cap, for the
/// limit checks of test/e2e_33_graphql.dart.
GraphQLConfig smallGraphqlConfig = GraphQLConfig(
  schema: graphqlSchema,
  path: '/graphql-small',
  middleware: <Object>[AuthMiddleware()],
  maxRelationRows: 5,
);
