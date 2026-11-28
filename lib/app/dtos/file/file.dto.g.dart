// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file.dto.dart';

// **************************************************************************
// DoxDtoGenerator
// **************************************************************************

// ignore_for_file: type=lint

/// The checks, the converter and the JSON Schema of [UploadFile].
const DtoSchema<UploadFile> $UploadFileDto = _$UploadFileDto();

class _$UploadFileDto extends DtoSchema<UploadFile>
    implements JsonObjectWriter {
  const _$UploadFileDto();

  static const Map<String, String> _messages = <String, String>{};

  @override
  Type get type => UploadFile;

  @override
  String get name => 'UploadFile';

  @override
  bool get usesRequiredWhen => false;

  @override
  UploadFile? convert(Object? input, DtoState state, List<Object> path) {
    if (input is! Map) {
      state.notObject(input, path, _messages);
      return null;
    }
    int issuesBefore = state.issues.length;
    // file: RequestFile
    Object? file = state.file(
      state.read(input, 'file'),
      path,
      'file',
      _messages,
    );
    if (file == null || file is Undefined)
      state.required(path, 'file', _messages);
    // note: String
    Object? note = state.string(
      state.read(input, 'note'),
      path,
      'note',
      _messages,
      trim: true,
    );
    if (note == null || note is Undefined)
      state.required(path, 'note', _messages);
    if (state.issues.length != issuesBefore && !state.allErrors) return null;
    if (file is RequestFile) {
      if (!(file.length <= 1048576)) {
        state.fail(
          path,
          'file',
          IssueCodes.maxSize,
          DefaultMessages.maxSize,
          file,
          params: const <String, Object?>{'max': '1MB'},
          messages: _messages,
        );
      }
    }
    if (state.issues.length != issuesBefore) return null;
    return UploadFile(file: file as RequestFile, note: note as String);
  }

  @override
  UploadFile fromMap(Map<String, dynamic> map) {
    return UploadFile(
      file: map['file'] as RequestFile,
      note: map['note'] as String,
    );
  }

  @override
  Map<String, dynamic> toMap(UploadFile dto) {
    return <String, dynamic>{'file': dto.file, 'note': dto.note};
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as UploadFile));

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

class _$UploadAvatarDto extends DtoSchema<UploadAvatar>
    implements JsonObjectWriter {
  const _$UploadAvatarDto();

  static const Map<String, String> _messages = <String, String>{};

  @override
  Type get type => UploadAvatar;

  @override
  String get name => 'UploadAvatar';

  @override
  bool get usesRequiredWhen => false;

  @override
  UploadAvatar? convert(Object? input, DtoState state, List<Object> path) {
    if (input is! Map) {
      state.notObject(input, path, _messages);
      return null;
    }
    int issuesBefore = state.issues.length;
    // avatar: RequestFile
    Object? avatar = state.file(
      state.read(input, 'avatar'),
      path,
      'avatar',
      _messages,
    );
    if (avatar == null || avatar is Undefined)
      state.required(path, 'avatar', _messages);
    if (state.issues.length != issuesBefore && !state.allErrors) return null;
    if (avatar is RequestFile) {
      if (!(FileTypes.matches(avatar, SchemaConstants.imageExtensions))) {
        state.fail(
          path,
          'avatar',
          IssueCodes.image,
          DefaultMessages.image,
          avatar,
          messages: _messages,
        );
      } else if (!(avatar.length <= 65536)) {
        state.fail(
          path,
          'avatar',
          IssueCodes.maxSize,
          DefaultMessages.maxSize,
          avatar,
          params: const <String, Object?>{'max': '64KB'},
          messages: _messages,
        );
      }
    }
    if (state.issues.length != issuesBefore) return null;
    return UploadAvatar(avatar: avatar as RequestFile);
  }

  @override
  UploadAvatar fromMap(Map<String, dynamic> map) {
    return UploadAvatar(avatar: map['avatar'] as RequestFile);
  }

  @override
  Map<String, dynamic> toMap(UploadAvatar dto) {
    return <String, dynamic>{'avatar': dto.avatar};
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as UploadAvatar));

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

class _$StoreFileDto extends DtoSchema<StoreFile> implements JsonObjectWriter {
  const _$StoreFileDto();

  static const Map<String, String> _messages = <String, String>{};

  @override
  Type get type => StoreFile;

  @override
  String get name => 'StoreFile';

  @override
  bool get usesRequiredWhen => false;

  @override
  StoreFile? convert(Object? input, DtoState state, List<Object> path) {
    if (input is! Map) {
      state.notObject(input, path, _messages);
      return null;
    }
    int issuesBefore = state.issues.length;
    // file: RequestFile
    Object? file = state.file(
      state.read(input, 'file'),
      path,
      'file',
      _messages,
    );
    if (file == null || file is Undefined)
      state.required(path, 'file', _messages);
    if (state.issues.length != issuesBefore && !state.allErrors) return null;
    if (state.issues.length != issuesBefore) return null;
    return StoreFile(file: file as RequestFile);
  }

  @override
  StoreFile fromMap(Map<String, dynamic> map) {
    return StoreFile(file: map['file'] as RequestFile);
  }

  @override
  Map<String, dynamic> toMap(StoreFile dto) {
    return <String, dynamic>{'file': dto.file};
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as StoreFile));

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

/// The checks, the converter and the JSON Schema of [UploadPhoto].
const DtoSchema<UploadPhoto> $UploadPhotoDto = _$UploadPhotoDto();

class _$UploadPhotoDto extends DtoSchema<UploadPhoto>
    implements JsonObjectWriter {
  const _$UploadPhotoDto();

  static const Map<String, String> _messages = <String, String>{};

  @override
  Type get type => UploadPhoto;

  @override
  String get name => 'UploadPhoto';

  @override
  bool get usesRequiredWhen => false;

  @override
  UploadPhoto? convert(Object? input, DtoState state, List<Object> path) {
    if (input is! Map) {
      state.notObject(input, path, _messages);
      return null;
    }
    int issuesBefore = state.issues.length;
    // photo: RequestFile
    Object? photo = state.file(
      state.read(input, 'photo'),
      path,
      'photo',
      _messages,
    );
    if (photo == null || photo is Undefined)
      state.required(path, 'photo', _messages);
    if (state.issues.length != issuesBefore && !state.allErrors) return null;
    if (photo is RequestFile) {
      if (!(FileTypes.matchesMimeTypes(photo, const <String>[
        'image/png',
        'image/gif',
      ]))) {
        state.fail(
          path,
          'photo',
          IssueCodes.mimeTypes,
          DefaultMessages.mimes,
          photo,
          params: const <String, Object?>{'types': 'image/png, image/gif'},
          messages: _messages,
        );
      } else if (!(photo.length >= 1024)) {
        state.fail(
          path,
          'photo',
          IssueCodes.minSize,
          DefaultMessages.minSize,
          photo,
          params: const <String, Object?>{'min': '1KB'},
          messages: _messages,
        );
      } else if (!(photo.length <= 65536)) {
        state.fail(
          path,
          'photo',
          IssueCodes.maxSize,
          DefaultMessages.maxSize,
          photo,
          params: const <String, Object?>{'max': '64KB'},
          messages: _messages,
        );
      } else if (!(ImageSize.fits(
        photo,
        minWidth: 2,
        maxWidth: 100,
        ratio: 1.0,
      ))) {
        state.fail(
          path,
          'photo',
          IssueCodes.dimensions,
          DefaultMessages.dimensions,
          photo,
          messages: _messages,
        );
      }
    }
    if (state.issues.length != issuesBefore) return null;
    return UploadPhoto(photo: photo as RequestFile);
  }

  @override
  UploadPhoto fromMap(Map<String, dynamic> map) {
    return UploadPhoto(photo: map['photo'] as RequestFile);
  }

  @override
  Map<String, dynamic> toMap(UploadPhoto dto) {
    return <String, dynamic>{'photo': dto.photo};
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as UploadPhoto));

  @override
  Map<String, dynamic> toJsonSchema() {
    return <String, dynamic>{
      'type': 'object',
      'title': 'UploadPhoto',
      'properties': <String, dynamic>{
        'photo': <String, dynamic>{
          'type': 'string',
          'format': 'binary',
          'contentMediaType': 'image/*',
          'minLength': 1024,
          'maxLength': 65536,
          'description': 'The real bytes must be a png or a gif, whatever the client says.',
        },
      },
      'required': <dynamic>['photo'],
    };
  }
}

/// The checks, the converter and the JSON Schema of [AddText].
const DtoSchema<AddText> $AddTextDto = _$AddTextDto();

class _$AddTextDto extends DtoSchema<AddText> implements JsonObjectWriter {
  const _$AddTextDto();

  static const Map<String, String> _messages = <String, String>{};

  @override
  Type get type => AddText;

  @override
  String get name => 'AddText';

  @override
  bool get usesRequiredWhen => false;

  @override
  AddText? convert(Object? input, DtoState state, List<Object> path) {
    if (input is! Map) {
      state.notObject(input, path, _messages);
      return null;
    }
    int issuesBefore = state.issues.length;
    // text: String
    Object? text = state.string(
      state.read(input, 'text'),
      path,
      'text',
      _messages,
    );
    if (text == null || text is Undefined)
      state.required(path, 'text', _messages);
    // atStart: bool
    Object? atStart = state.boolean(
      state.read(input, 'at_start'),
      path,
      'at_start',
      _messages,
    );
    if (atStart == null) state.required(path, 'at_start', _messages);
    if (state.issues.length != issuesBefore && !state.allErrors) return null;
    if (state.issues.length != issuesBefore) return null;
    return AddText(
      text: text as String,
      atStart: atStart is Undefined ? false : atStart as bool,
    );
  }

  @override
  AddText fromMap(Map<String, dynamic> map) {
    return AddText(
      text: map['text'] as String,
      atStart: map.containsKey('at_start') ? map['at_start'] as bool : false,
    );
  }

  @override
  Map<String, dynamic> toMap(AddText dto) {
    return <String, dynamic>{'text': dto.text, 'at_start': dto.atStart};
  }

  @override
  void writeObject(Object object, JsonWriter writer) =>
      writer.value(toMap(object as AddText));

  @override
  Map<String, dynamic> toJsonSchema() {
    return <String, dynamic>{
      'type': 'object',
      'title': 'AddText',
      'properties': <String, dynamic>{
        'text': <String, dynamic>{'type': 'string'},
        'at_start': <String, dynamic>{
          'type': 'boolean',
          'description': '`true` puts the text at the start (prepend), else at the end (append).',
          'default': false,
        },
      },
      'required': <dynamic>['text'],
    };
  }
}
