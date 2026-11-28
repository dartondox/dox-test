// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.serializer.dart';

// **************************************************************************
// DoxSerializeGenerator
// **************************************************************************

// ignore_for_file: type=lint, unnecessary_null_comparison

/// The JSON writer of [UserSerializer]. Dox gets it from
/// `lib/generated/container.g.dart`.
const SerializeWriter $UserSerializerWriter = _$UserSerializerWriter();

class _$UserSerializerWriter implements SerializeWriter {
  const _$UserSerializerWriter();

  static final JsonRun _idKey = JsonRun('{"id":');
  static final JsonRun _nameKey = JsonRun(',"name":');
  static final JsonRun _emailKey = JsonRun(',"email":');
  static final JsonRun _fullNameKey = JsonRun(',"full_name":');
  static final JsonRun _end = JsonRun('}');
  static final JsonRun _listStart = JsonRun('[');
  static final JsonRun _listEnd = JsonRun(']');

  @override
  Type get type => UserSerializer;

  @override
  void writeObject(Object object, JsonWriter writer) =>
      $writeUserSerializer(object as UserSerializer, writer);

  @override
  Object? toJsonValue(Object object) => (object as UserSerializer).toJson();
}

/// Writes the JSON of [UserSerializer], as `toJson()` gives it.
void $writeUserSerializer(UserSerializer serializer, JsonWriter writer) {
  List<User>? items = Serializer.listOf(serializer);
  if (items == null) {
    if (Serializer.hasItem(serializer)) {
      $writeUserSerializer$item(Serializer.itemOf(serializer), writer);
    } else {
      writer.value(null);
    }
    return;
  }
  writer.run(_$UserSerializerWriter._listStart);
  for (int i = 0; i < items.length; i++) {
    if (i > 0) writer.run(JsonRun.comma);
    $writeUserSerializer$item(items[i], writer);
  }
  writer.run(_$UserSerializerWriter._listEnd);
}

/// Writes the map of `convert()` of [UserSerializer].
void $writeUserSerializer$item(User m, JsonWriter writer) {
  writer.run(_$UserSerializerWriter._idKey);
  writer.value(m.id);
  writer.run(_$UserSerializerWriter._nameKey);
  writer.string(m.name);
  writer.run(_$UserSerializerWriter._emailKey);
  writer.string(m.email);
  writer.run(_$UserSerializerWriter._fullNameKey);
  writer.string(m.fullName);
  writer.run(_$UserSerializerWriter._end);
}
