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

/// Form data of POST /api/files/photo: the new file rules.
@Dto()
class UploadPhoto {
  /// The real bytes must be a png or a gif, whatever the client says.
  @MimeTypes(<String>['image/png', 'image/gif'])
  @MinSize('1KB')
  @MaxSize('64KB')
  @Dimensions(minWidth: 2, maxWidth: 100, ratio: 1)
  final RequestFile photo;

  const UploadPhoto({required this.photo});

  static const DtoSchema<UploadPhoto> schema = $UploadPhotoDto;
}

/// Body of POST /api/storage/{disk}/text/{key}.
@Dto()
class AddText {
  final String text;

  /// `true` puts the text at the start (prepend), else at the end (append).
  final bool atStart;

  const AddText({required this.text, this.atStart = false});

  static const DtoSchema<AddText> schema = $AddTextDto;
}
