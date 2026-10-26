import 'package:dox_storage/dox_storage.dart';
import 'package:dox_test/config/storage.dart';

/// Sets up the storage disks in every isolate. Dox finds every DoxProvider
/// class, see lib/container.g.dart.
class AppStorageProvider extends StorageProvider {
  AppStorageProvider() : super(storageConfig);
}
