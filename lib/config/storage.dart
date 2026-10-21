import 'package:dox_core/dox_core.dart';
import 'package:dox_test/config/env.dart';
import 'package:dox_test/constants/app_constants.dart';

/// `local` and `memory` work with no setup. `s3` is MinIO from docker compose.
StorageConfig storage = StorageConfig(
  /// default storage disk
  defaultDisk: AppEnv.get('STORAGE_DISK', 'local'),

  /// storage disks
  disks: <String, Map<String, dynamic>>{
    'local': <String, dynamic>{
      'driver': 'local',
      'root': AppConstants.storageRoot,
      // Route.files('files') serves signed URLs here
      'url': '${AppEnv.get('APP_URL', 'http://127.0.0.1:3100')}/files',
    },
    'memory': <String, dynamic>{'driver': 'memory'},
    's3': <String, dynamic>{
      'driver': 's3',
      'bucket': AppEnv.get('AWS_BUCKET', 'dox-test'),
      'region': AppEnv.get('AWS_DEFAULT_REGION', 'us-east-1'),
      'key': AppEnv.get('AWS_ACCESS_KEY_ID', 'minioadmin'),
      'secret': AppEnv.get('AWS_SECRET_ACCESS_KEY', 'minioadmin'),
      'endpoint': AppEnv.get('AWS_ENDPOINT', 'http://127.0.0.1:9110'),
      'path_style': true,
      'acl': false,
    },
  },
);
