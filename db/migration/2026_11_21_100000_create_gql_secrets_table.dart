// ignore_for_file: file_names
import 'package:dox_migration/dox_migration.dart';

/// The `gql_secrets` table of test/e2e_33_graphql.dart: a private row,
/// seen only by its owner (see GqlSecretPolicy).
class CreateGqlSecretsTable extends Migration {
  @override
  Future<void> up(Schema schema) async {
    await schema.create('gql_secrets', (Table table) {
      table.id();
      table.foreignId('user_id').constrained('users');
      table.foreignId('post_id').constrained('posts');
      table.string('body');
      table.timestamps();
    });
  }

  @override
  Future<void> down(Schema schema) async {
    await schema.dropIfExists('gql_secrets');
  }
}
