import 'dart:io';

import 'package:dox_core/dox_core.dart';
import 'package:dox_test/constants/app_constants.dart';

/// Upload and read files with dox Storage.
@Inject()
class FileService {
  /// Saves the file and returns its name inside the upload folder.
  Future<Map<String, dynamic>> store(RequestFile file) async {
    String path = await file.store(AppConstants.uploadFolder);
    return <String, dynamic>{
      'name': path.split('/').last,
      'original_name': file.filename,
      'extension': file.extension,
      'bytes': (await file.bytes).length,
      'size_kb': await file.size,
    };
  }

  /// The upload as a File. Only a plain name, so no `..` tricks.
  File file(String name) {
    File found = File(
      '${AppConstants.storageRoot}/${AppConstants.uploadFolder}/$name',
    );
    if (name.contains('/') || name.contains('..') || !found.existsSync()) {
      throw NotFoundHttpException(message: 'file not found');
    }
    return found;
  }

  Future<StreamFile> read(String name) async {
    return await Storage().stream('${AppConstants.uploadFolder}/$name');
  }
}
