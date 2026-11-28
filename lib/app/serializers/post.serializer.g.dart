// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.serializer.dart';

// **************************************************************************
// DoxSerializeGenerator
// **************************************************************************

// ignore_for_file: type=lint, unnecessary_null_comparison

/// The JSON writer of [PostSerializer]. Dox gets it from
/// `lib/generated/container.g.dart`.
const SerializeWriter $PostSerializerWriter = _$PostSerializerWriter();

class _$PostSerializerWriter implements SerializeWriter {
  const _$PostSerializerWriter();

  static final JsonRun _idKey = JsonRun('{"id":');
  static final JsonRun _titleKey = JsonRun(',"title":');
  static final JsonRun _statusKey = JsonRun(',"status":');
  static final JsonRun _authorKey = JsonRun(',"author":');
  static final JsonRun _tagsKey = JsonRun(',"tags":[');
  static final JsonRun _end = JsonRun(']}');
  static final JsonRun _listStart = JsonRun('[');
  static final JsonRun _listEnd = JsonRun(']');

  @override
  Type get type => PostSerializer;

  @override
  void writeObject(Object object, JsonWriter writer) =>
      $writePostSerializer(object as PostSerializer, writer);

  @override
  Object? toJsonValue(Object object) => (object as PostSerializer).toJson();
}

/// Writes the JSON of [PostSerializer], as `toJson()` gives it.
void $writePostSerializer(PostSerializer serializer, JsonWriter writer) {
  List<Post>? items = Serializer.listOf(serializer);
  if (items == null) {
    if (Serializer.hasItem(serializer)) {
      _$writePostSerializer$item(
        serializer,
        Serializer.itemOf(serializer),
        writer,
      );
    } else {
      writer.value(null);
    }
    return;
  }
  writer.run(_$PostSerializerWriter._listStart);
  for (int i = 0; i < items.length; i++) {
    if (i > 0) writer.run(JsonRun.comma);
    _$writePostSerializer$item(serializer, items[i], writer);
  }
  writer.run(_$PostSerializerWriter._listEnd);
}

/// Writes the map of `convert()` of [PostSerializer].
void _$writePostSerializer$item(
  PostSerializer serializer,
  Post m,
  JsonWriter writer,
) {
  writer.run(_$PostSerializerWriter._idKey);
  writer.value(m.id);
  writer.run(_$PostSerializerWriter._titleKey);
  writer.string(m.title);
  writer.run(_$PostSerializerWriter._statusKey);
  writer.string(m.status);
  writer.run(_$PostSerializerWriter._authorKey);
  writer.string(m.author?.name);
  writer.run(_$PostSerializerWriter._tagsKey);
  {
    List<String?> tagsValue = m.tags.map(serializer._tagName).toList();
    for (int i = 0; i < tagsValue.length; i++) {
      if (i > 0) writer.run(JsonRun.comma);
      writer.string(tagsValue[i]);
    }
  }
  writer.run(_$PostSerializerWriter._end);
}
