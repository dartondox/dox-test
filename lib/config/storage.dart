import 'package:dox_core/dox_core.dart';

StorageConfig storage = StorageConfig(
  /// default storage disk
  defaultDisk: Env.get('STORAGE_DISK', 'local'),

  /// storage disks
  disks: <String, Map<String, dynamic>>{
    'local': <String, dynamic>{'driver': 'local', 'root': 'storage'},
  },
);
