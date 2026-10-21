import 'package:dox_core/dox_core.dart';

part 'file.dto.g.dart';

/// Form data of POST /api/files.
@Dto()
class UploadFile {
  @MaxSize('1MB')
  final RequestFile file;

  @Trim()
  final String note;

  const UploadFile({required this.file, required this.note});

  static const DtoSchema<UploadFile> schema = $UploadFileDto;
}

/// Form data of POST /api/files/avatar. Only a small image.
@Dto()
class UploadAvatar {
  @Image()
  @MaxSize('64KB')
  final RequestFile avatar;

  const UploadAvatar({required this.avatar});

  static const DtoSchema<UploadAvatar> schema = $UploadAvatarDto;
}

/// Form data of POST /api/storage/{disk}.
@Dto()
class StoreFile {
  final RequestFile file;

  const StoreFile({required this.file});

  static const DtoSchema<StoreFile> schema = $StoreFileDto;
}
