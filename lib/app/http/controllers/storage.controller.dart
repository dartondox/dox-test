import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/services/storage.service.dart';

/// /api/storage/{disk}/... where disk is local, memory or s3.
/// `{key*}` takes the rest of the path, slashes too.
@Tags(<String>['Storage'])
class StorageController {
  final StorageService service;

  StorageController(this.service);

  /// Upload a file (form-data field `file`)
  Future<DoxResponse> upload(DoxRequest req, String disk) async {
    req.validate(<String, String>{'file': 'required|file'});
    return response(await service.upload(disk, req.input('file')))
        .statusCode(201);
  }

  /// Show a file (streamed)
  Future<StreamFile> stream(DoxRequest req, String disk, String key) async {
    return await service.stream(disk, key);
  }

  /// Download a file (streamed, as an attachment)
  Future<DownloadableFile> download(
    DoxRequest req,
    String disk,
    String key,
  ) async {
    return await service.download(disk, key);
  }

  /// Make a signed URL that works for 10 minutes
  Future<Map<String, dynamic>> signed(
    DoxRequest req,
    String disk,
    String key,
  ) async {
    return await service.signedUrl(disk, key);
  }

  /// Delete a file
  Future<Map<String, dynamic>> delete(
    DoxRequest req,
    String disk,
    String key,
  ) async {
    return await service.delete(disk, key);
  }
}
