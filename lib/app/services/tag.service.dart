import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/models/tag/tag.model.dart';
import 'package:dox_test/app/repositories/tag.repository.dart';

/// Tag logic.
class TagService {
  final TagRepository tags;

  TagService(this.tags);

  Future<Tag> withPosts(String name) async {
    Tag? tag = await tags.findByNameWithPosts(name);
    if (tag == null) {
      throw NotFoundHttpException(message: 'tag not found');
    }
    return tag;
  }
}
