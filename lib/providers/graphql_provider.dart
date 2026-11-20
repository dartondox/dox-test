import 'package:dox_auth/dox_auth.dart' show Gate;
import 'package:dox_graphql/dox_graphql.dart';
import 'package:dox_test/app/models/gql_secret/gql_secret.model.dart';
import 'package:dox_test/app/models/post/post.model.dart';
import 'package:dox_test/app/policies/gql_secret.policy.dart';
import 'package:dox_test/app/policies/post.policy.dart';
import 'package:dox_test/config/graphql.dart';

/// Serves GraphQL at /graphql, and registers the policies it uses.
class AppGraphQLProvider extends GraphQLProvider {
  AppGraphQLProvider() : super(graphqlConfig);

  @override
  void setup() {
    Gate.policy<Post>(PostPolicy());
    Gate.policy<GqlSecret>(GqlSecretPolicy());
    super.setup();
  }
}

/// /graphql-small: the same schema with `maxRelationRows: 5`.
class SmallGraphQLProvider extends GraphQLProvider {
  SmallGraphQLProvider() : super(smallGraphqlConfig);
}
