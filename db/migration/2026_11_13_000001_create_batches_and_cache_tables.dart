// ignore_for_file: file_names
import 'package:dox_cache_database/dox_cache_database.dart';
import 'package:dox_migration/dox_migration.dart';
import 'package:dox_queue_database/dox_queue_database.dart';

/// The `job_batches` table of `Queue.batch()` and the `cache` table of
/// the `database` cache store.
class CreateBatchesAndCacheTables extends Migration {
  @override
  Future<void> up(Schema schema) async {
    await QueueTables.upBatches(schema);
    await CacheTables.up(schema);
  }

  @override
  Future<void> down(Schema schema) async {
    await CacheTables.down(schema);
    await QueueTables.downBatches(schema);
  }
}
