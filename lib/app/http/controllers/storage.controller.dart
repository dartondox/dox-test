import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/http/dtos/file/file.dto.dart';
import 'package:dox_test/app/services/storage.service.dart';

/// /api/storage/{disk}/... where disk is local, memory or s3.
/// `{key*}` takes the rest of the path, slashes too.
@Tags(<String>['Storage'])
@Inject()
class StorageController {
  final FileStorageService service;

  StorageController(this.service);

  /// Upload a file (form-data field `file`)
  Future<DoxResponse> upload(String disk, StoreFile body) async {
    return response(await service.upload(disk, body.file)).statusCode(201);
  }

  /// Show a file (streamed)
  Future<StreamFile> stream(String disk, String key) async {
    return await service.stream(disk, key);
  }

  /// Download a file (streamed, as an attachment)
  Future<DownloadableFile> download(String disk, String key) async {
    return await service.download(disk, key);
  }

  /// Make a signed URL that works for 10 minutes
  Future<Map<String, dynamic>> signed(String disk, String key) async {
    return await service.signedUrl(disk, key);
  }

  /// Delete a file
  Future<Map<String, dynamic>> delete(String disk, String key) async {
    return await service.delete(disk, key);
  }
}
