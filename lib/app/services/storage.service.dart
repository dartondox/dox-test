import 'package:dox_core/dox_core.dart';
import 'package:dox_test/constants/app_constants.dart';

/// Upload, read and sign files on one disk: local, memory or s3.
@Inject()
class StorageService {
  Storage disk(String name) {
    if (!AppConstants.storageDisks.contains(name)) {
      throw NotFoundHttpException(message: 'unknown storage disk "$name"');
    }
    return Storage().disk(name);
  }

  /// Saves with a new uuid name. Returns the key, like `uploads/<uuid>.txt`.
  Future<Map<String, dynamic>> upload(String name, RequestFile file) async {
    String path = await disk(name)
        .putRequestFile(AppConstants.uploadFolder, file);
    String key = path.startsWith('/') ? path.substring(1) : path;
    return <String, dynamic>{
      'disk': name,
      'key': key,
      'original_name': file.filename,
      'bytes': file.length,
    };
  }

  /// Streamed, with Content-Length. The browser shows it.
  Future<StreamFile> stream(String name, String key) async {
    return await disk(name).stream(key);
  }

  /// Streamed, saved as a file by the browser.
  Future<DownloadableFile> download(String name, String key) async {
    return await disk(name).download(key);
  }

  /// local: a /files/... link checked by Route.files. s3: a SigV4 link.
  Future<Map<String, dynamic>> signedUrl(String name, String key) async {
    String url = await disk(name)
        .signedUrl(key, expiresIn: Duration(minutes: 10));
    return <String, dynamic>{'url': url};
  }

  Future<Map<String, dynamic>> delete(String name, String key) async {
    Storage target = disk(name);
    bool existed = await target.exists(key);
    await target.delete(key);
    return <String, dynamic>{'deleted': existed};
  }
}
