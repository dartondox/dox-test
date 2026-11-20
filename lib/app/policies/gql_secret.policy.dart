import 'package:dox_auth/dox_auth.dart' show Policy;
import 'package:dox_test/app/models/gql_secret/gql_secret.model.dart';
import 'package:dox_test/app/models/user/user.model.dart';
import 'package:dox_test/app/policies/post.policy.dart';

/// `viewAny` and `view` under other method names: GraphQL reads the
/// abilities of Gate, not the method names.
class GqlSecretPolicy extends Policy<User, GqlSecret> {
  bool mayList(User user) => user.name != PostPolicy.blind;

  bool isOwner(User user, GqlSecret secret) => secret.userId == user.id;

  @override
  Map<String, Function> get abilities => <String, Function>{
    'viewAny': mayList,
    'view': isOwner,
  };
}
