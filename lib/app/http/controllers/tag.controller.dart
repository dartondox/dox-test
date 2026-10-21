import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/http/schemas/tag.schemas.dart';
import 'package:dox_test/app/models/tag/tag.model.dart';
import 'package:dox_test/app/services/tag.service.dart';

class TagController {
  final TagService service;

  TagController(this.service);

  /// List tags
  ///
  /// `except=a,b` leaves those names out (whereNotIn).
  @summary('List tags (lower case annotation)')
  Future<List<Tag>> index(DoxRequest req) async {
    Map<String, dynamic> data = await req.validateSchema(TagSchemas.list);
    String except = data['except'] ?? '';
    return await service.list(
      data['limit'] as int,
      except.isEmpty ? <String>[] : except.split(','),
    );
  }

  /// Create tags in one transaction
  ///
  /// With `fail: true` the transaction rolls back and nothing is saved.
  @Summary('Create tags in a transaction')
  @Tags(<String>['Tag', 'ORM'])
  Future<Map<String, dynamic>> store(DoxRequest req) async {
    Map<String, dynamic> data = await req.validateSchema(TagSchemas.create);
    return await service.createMany(
      List<String>.from(data['names']),
      data['fail'] as bool,
    );
  }

  /// GET /api/tags/{name}/posts
  Future<Tag> posts(DoxRequest req, String name) async {
    return await service.withPosts(name);
  }
}
