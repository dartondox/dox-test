// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file.dto.dart';

// **************************************************************************
// DoxDtoGenerator
// **************************************************************************

// ignore_for_file: type=lint

/// The checks, the converter and the JSON Schema of [UploadFile].
const DtoSchema<UploadFile> $UploadFileDto = _$UploadFileDto();

class _$UploadFileDto extends DtoSchema<UploadFile> {
  const _$UploadFileDto();

  static const Map<String, String> _m = <String, String>{};

  @override
  Type get type => UploadFile;

  @override
  String get name => 'UploadFile';

  @override
  UploadFile? convert(Object? input, DtoState s, List<Object> p) {
    if (input is! Map) {
      s.notObject(input, p, _m);
      return null;
    }
    int e = s.issues.length;
    // file: RequestFile
    Object? c0;
    c0 = s.file(s.read(input, 'file'), p, 'file', _m);
    if (c0 == null || c0 is Undefined) s.required(p, 'file', _m);
    // note: String
    Object? c1;
    c1 = s.string(s.read(input, 'note'), p, 'note', _m, trim: true);
    if (c1 == null || c1 is Undefined) s.required(p, 'note', _m);
    if (s.issues.length != e) return null;
    if (c0 is RequestFile) {
      if (!(c0.length <= 1048576)) {
        s.fail(
          p,
          'file',
          IssueCodes.maxSize,
          DefaultMessages.maxSize,
          c0,
          params: const <String, Object?>{'max': '1MB'},
          messages: _m,
        );
      }
    }
    if (s.issues.length != e) return null;
    return UploadFile(file: c0 as RequestFile, note: c1 as String);
  }

  @override
  UploadFile fromMap(Map<String, dynamic> m) {
    return UploadFile(
      file: m['file'] as RequestFile,
      note: m['note'] as String,
    );
  }

  @override
  Map<String, dynamic> toMap(UploadFile o) {
    RequestFile f0 = o.file;
    String f1 = o.note;
    return <String, dynamic>{'file': f0, 'note': f1};
  }

  @override
  Map<String, dynamic> toJsonSchema() {
    return <String, dynamic>{
      'type': 'object',
      'title': 'UploadFile',
      'properties': <String, dynamic>{
        'file': <String, dynamic>{
          'type': 'string',
          'format': 'binary',
          'maxLength': 1048576,
        },
        'note': <String, dynamic>{'type': 'string'},
      },
      'required': <dynamic>['file', 'note'],
    };
  }
}

/// The checks, the converter and the JSON Schema of [UploadAvatar].
const DtoSchema<UploadAvatar> $UploadAvatarDto = _$UploadAvatarDto();

class _$UploadAvatarDto extends DtoSchema<UploadAvatar> {
  const _$UploadAvatarDto();

  static const Map<String, String> _m = <String, String>{};

  @override
  Type get type => UploadAvatar;

  @override
  String get name => 'UploadAvatar';

  @override
  UploadAvatar? convert(Object? input, DtoState s, List<Object> p) {
    if (input is! Map) {
      s.notObject(input, p, _m);
      return null;
    }
    int e = s.issues.length;
    // avatar: RequestFile
    Object? c0;
    c0 = s.file(s.read(input, 'avatar'), p, 'avatar', _m);
    if (c0 == null || c0 is Undefined) s.required(p, 'avatar', _m);
    if (s.issues.length != e) return null;
    if (c0 is RequestFile) {
      if (!(FileTypes.matches(c0, SchemaConstants.imageExtensions))) {
        s.fail(
          p,
          'avatar',
          IssueCodes.image,
          DefaultMessages.image,
          c0,
          messages: _m,
        );
      } else if (!(c0.length <= 65536)) {
        s.fail(
          p,
          'avatar',
          IssueCodes.maxSize,
          DefaultMessages.maxSize,
          c0,
          params: const <String, Object?>{'max': '64KB'},
          messages: _m,
        );
      }
    }
    if (s.issues.length != e) return null;
    return UploadAvatar(avatar: c0 as RequestFile);
  }

  @override
  UploadAvatar fromMap(Map<String, dynamic> m) {
    return UploadAvatar(avatar: m['avatar'] as RequestFile);
  }

  @override
  Map<String, dynamic> toMap(UploadAvatar o) {
    RequestFile f0 = o.avatar;
    return <String, dynamic>{'avatar': f0};
  }

  @override
  Map<String, dynamic> toJsonSchema() {
    return <String, dynamic>{
      'type': 'object',
      'title': 'UploadAvatar',
      'properties': <String, dynamic>{
        'avatar': <String, dynamic>{
          'type': 'string',
          'format': 'binary',
          'contentMediaType': 'image/*',
          'maxLength': 65536,
        },
      },
      'required': <dynamic>['avatar'],
    };
  }
}

/// The checks, the converter and the JSON Schema of [StoreFile].
const DtoSchema<StoreFile> $StoreFileDto = _$StoreFileDto();

class _$StoreFileDto extends DtoSchema<StoreFile> {
  const _$StoreFileDto();

  static const Map<String, String> _m = <String, String>{};

  @override
  Type get type => StoreFile;

  @override
  String get name => 'StoreFile';

  @override
  StoreFile? convert(Object? input, DtoState s, List<Object> p) {
    if (input is! Map) {
      s.notObject(input, p, _m);
      return null;
    }
    int e = s.issues.length;
    // file: RequestFile
    Object? c0;
    c0 = s.file(s.read(input, 'file'), p, 'file', _m);
    if (c0 == null || c0 is Undefined) s.required(p, 'file', _m);
    if (s.issues.length != e) return null;
    return StoreFile(file: c0 as RequestFile);
  }

  @override
  StoreFile fromMap(Map<String, dynamic> m) {
    return StoreFile(file: m['file'] as RequestFile);
  }

  @override
  Map<String, dynamic> toMap(StoreFile o) {
    RequestFile f0 = o.file;
    return <String, dynamic>{'file': f0};
  }

  @override
  Map<String, dynamic> toJsonSchema() {
    return <String, dynamic>{
      'type': 'object',
      'title': 'StoreFile',
      'properties': <String, dynamic>{
        'file': <String, dynamic>{'type': 'string', 'format': 'binary'},
      },
      'required': <dynamic>['file'],
    };
  }
}
