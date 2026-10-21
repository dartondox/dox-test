import 'dart:io';

import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/services/file.service.dart';

class FileController {
  final FileService service;

  FileController(this.service);

  /// POST /api/files (multipart form-data: file + note)
  Future<DoxResponse> upload(DoxRequest req) async {
    req.validate(<String, String>{'file': 'required', 'note': 'required'});
    Map<String, dynamic> saved = await service.store(req.input('file'));
    saved['note'] = req.input('note');
    saved['is_form_data'] = req.isFormData();
    return response(saved).statusCode(201);
  }

  /// GET /api/files/{name}
  Future<StreamFile> download(DoxRequest req, String name) async {
    return await service.read(name);
  }

  /// GET /api/files/{name}/raw (a File: Range gives 206 Partial Content)
  File raw(DoxRequest req, String name) {
    return service.file(name);
  }
}
