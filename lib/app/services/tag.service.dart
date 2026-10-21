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

  Future<List<Tag>> list(int limit, List<String> except) async {
    return await tags.list(limit, except);
  }

  /// Saves all names, or none when [fail] is true.
  Future<Map<String, dynamic>> createMany(List<String> names, bool fail) async {
    bool saved = true;
    try {
      await tags.createAll(names, failAtEnd: fail);
    } on TagRollbackException {
      saved = false;
    }
    return <String, dynamic>{'saved': saved, 'total': await tags.count()};
  }
}
