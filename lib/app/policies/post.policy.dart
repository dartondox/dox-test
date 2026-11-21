import 'package:dox_auth/dox_auth.dart' show Ability, Policy;
import 'package:dox_test/app/models/post/post.model.dart';
import 'package:dox_test/app/models/user/user.model.dart';

/// The GraphQL rules of a post (test/e2e_33_graphql.dart). The user type
/// is nullable, so a guest can list and read posts.
class PostPolicy extends Policy<User?, Post> {
  /// the name of a user that may not list posts
  static const String blind = 'GQL Blind';

  /// the name of a user that may not create posts
  static const String noCreate = 'GQL NoCreate';

  /// a post with this status is seen only by its owner
  static const String secret = 'secret';

  bool viewAny(User? user) => user?.name != blind;

  /// A blank post (a missing id) is denied, so a missing id and a secret
  /// post of someone else give the same answer.
  bool view(User? user, Post post) =>
      post.id != null &&
      (post.status != secret || (user != null && post.userId == user.id));

  bool create(User? user) => user != null && user.name != noCreate;

  bool update(User? user, Post post) => user != null && post.userId == user.id;

  bool delete(User? user, Post post) => user != null && post.userId == user.id;

  @override
  Map<String, Function> get abilities => <String, Function>{
    Ability.viewAny: viewAny,
    Ability.view: view,
    Ability.create: create,
    Ability.update: update,
    Ability.delete: delete,
  };
}
