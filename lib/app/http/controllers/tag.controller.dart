import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/models/tag/tag.model.dart';
import 'package:dox_test/app/services/tag.service.dart';

class TagController {
  final TagService service;

  TagController(this.service);

  /// GET /api/tags/{name}/posts
  Future<Tag> posts(DoxRequest req, String name) async {
    return await service.withPosts(name);
  }
}
