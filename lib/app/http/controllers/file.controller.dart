import 'dart:io';

import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/dtos/file/file.dto.dart';
import 'package:dox_test/app/services/file.service.dart';

@Inject()
class FileController {
  final FileService service;

  FileController(this.service);

  /// Upload a file with a note (form data)
  Future<DoxResponse> upload(DoxRequest req, UploadFile body) async {
    Map<String, dynamic> saved = await service.store(body.file);
    saved['note'] = body.note;
    saved['is_form_data'] = req.isFormData();
    return response(saved).statusCode(201);
  }

  /// Upload an avatar image (form data, 64 KB at most)
  Future<DoxResponse> avatar(UploadAvatar body) async {
    return response(await service.store(body.avatar)).statusCode(201);
  }

  /// Download an upload (streamed)
  Future<StreamFile> download(String name) async {
    return await service.read(name);
  }

  /// An upload as a File (Range gives 206 Partial Content)
  File raw(String name) {
    return service.file(name);
  }
}
