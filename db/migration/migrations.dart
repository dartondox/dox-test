// Made by `dox make:migration` and the `dox migration:*` commands.
// Do not edit, it is made again from the files in this folder.
import 'package:dox_migration/dox_migration.dart';

import '2024_01_01_000001_create_users_table.dart' as m1;
import '2024_01_01_000002_create_profiles_table.dart' as m2;
import '2024_01_01_000003_create_posts_table.dart' as m3;
import '2024_01_01_000004_create_comments_table.dart' as m4;
import '2024_01_01_000005_create_tags_table.dart' as m5;
import '2024_01_01_000006_add_names_to_users_table.dart' as m6;
import '2024_01_01_000007_create_queue_tables.dart' as m7;
import '2024_01_01_000008_add_views_to_posts_table.dart' as m8;

/// all Dart migrations of db/migration, sorted by name
final List<MigrationEntry> migrations = <MigrationEntry>[
  MigrationEntry('2024_01_01_000001_create_users_table', m1.CreateUsersTable()),
  MigrationEntry(
    '2024_01_01_000002_create_profiles_table',
    m2.CreateProfilesTable(),
  ),
  MigrationEntry('2024_01_01_000003_create_posts_table', m3.CreatePostsTable()),
  MigrationEntry(
    '2024_01_01_000004_create_comments_table',
    m4.CreateCommentsTable(),
  ),
  MigrationEntry('2024_01_01_000005_create_tags_table', m5.CreateTagsTable()),
  MigrationEntry(
    '2024_01_01_000006_add_names_to_users_table',
    m6.AddNamesToUsersTable(),
  ),
  MigrationEntry(
    '2024_01_01_000007_create_queue_tables',
    m7.CreateQueueTables(),
  ),
  MigrationEntry(
    '2024_01_01_000008_add_views_to_posts_table',
    m8.AddViewsToPostsTable(),
  ),
];
