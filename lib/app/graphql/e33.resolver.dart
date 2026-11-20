import 'package:dox_graphql/dox_graphql.dart';

/// Resolvers for test/e2e_33_graphql.dart.
class E33Resolver {
  /// how many times [gqlHits] ran
  static int hits = 0;

  /// Counts its runs, so a test can see that a rejected query ran none.
  @GraphQLQuery(auth: false)
  int gqlHits() {
    hits++;
    return hits;
  }

  /// Throws an error with a secret text: production must hide it.
  @GraphQLQuery(auth: false)
  String gqlBoom() {
    throw StateError('e33 secret detail');
  }
}
