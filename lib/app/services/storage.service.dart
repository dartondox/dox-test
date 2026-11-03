import 'dart:convert';

import 'package:dox_core/dox_core.dart';
import 'package:dox_storage/dox_storage.dart';
import 'package:dox_test/constants/app_constants.dart';

/// Upload, read and sign files on one disk: local, memory or s3.
@Inject()
class FileStorageService {
  Storage disk(String name) {
    if (!AppConstants.storageDisks.contains(name) &&
        name != AppConstants.publicDisk) {
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

  /// local: a /files/... link checked by Storage.route. s3: a SigV4 link.
  Future<Map<String, dynamic>> signedUrl(String name, String key) async {
    String url = await disk(name)
        .signedUrl(key, expiresIn: Duration(minutes: 10));
    return <String, dynamic>{'url': url};
  }

  /// append() or prepend(). Returns the new text of the file.
  Future<Map<String, dynamic>> addText(
    String name,
    String key,
    String text, {
    required bool atStart,
  }) async {
    Storage target = disk(name);
    if (atStart) {
      await target.prepend(key, text);
    } else {
      await target.append(key, text);
    }
    return <String, dynamic>{
      'text': utf8.decode(await target.get(key) ?? <int>[]),
    };
  }

  /// size(), lastModified() and url() of one file.
  /// A missing file throws [FileNotFoundException]: it is a 404 here.
  Future<Map<String, dynamic>> info(String name, String key) async {
    Storage target = disk(name);
    try {
      return <String, dynamic>{
        'size': await target.size(key),
        'last_modified': (await target.lastModified(key)).toIso8601String(),
        'url': await target.url(key),
      };
    } on FileNotFoundException {
      throw NotFoundHttpException(message: 'file not found');
    }
  }

  Future<void> makeDirectory(String name, String key) async {
    await disk(name).makeDirectory(key);
  }

  Future<Map<String, dynamic>> delete(String name, String key) async {
    Storage target = disk(name);
    bool existed = await target.exists(key);
    await target.delete(key);
    return <String, dynamic>{'deleted': existed};
  }
}
