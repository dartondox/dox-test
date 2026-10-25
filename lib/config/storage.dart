import 'package:dox_storage/dox_storage.dart';
import 'package:dox_test/config/env.dart';
import 'package:dox_test/constants/app_constants.dart';

/// `local` and `memory` work with no setup. `s3` is MinIO from docker compose.
StorageConfig storageConfig = StorageConfig(
  /// default storage disk
  defaultDisk: env.storageDisk,

  /// storage disks
  disks: <String, Map<String, dynamic>>{
    'local': <String, dynamic>{
      'driver': 'local',
      'root': AppConstants.storageRoot,
      // Storage.route('files') serves signed URLs here
      'url': '${env.appUrl}/files',
    },
    'memory': <String, dynamic>{'driver': 'memory'},
    's3': <String, dynamic>{
      'driver': 's3',
      'bucket': env.awsBucket,
      'region': env.awsDefaultRegion,
      'key': env.awsAccessKeyId,
      'secret': env.awsSecretAccessKey,
      'endpoint': env.awsEndpoint,
      'path_style': true,
      'acl': false,
    },
  },
);
