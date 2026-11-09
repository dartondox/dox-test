import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/models/post/post.model.dart';
import 'package:dox_test/app/models/tag/tag.model.dart';

/// Public shape of a post, with tag names only.
class PostSerializer extends Serializer<Post> {
  PostSerializer(super.data);

  @override
  Map<String, dynamic> convert(Post m) {
    return <String, dynamic>{
      'id': m.id,
      'title': m.title,
      'status': m.status,
      'author': m.author?.name,
      'tags': m.tags.map(_tagName).toList(),
    };
  }

  String? _tagName(Tag tag) {
    return tag.name;
  }
}
