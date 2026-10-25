import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/http/dtos/tag/tag.dto.dart';
import 'package:dox_test/app/models/tag/tag.model.dart';
import 'package:dox_test/app/services/tag.service.dart';

@Inject()
class TagController {
  final TagService service;

  TagController(this.service);

  /// List tags
  ///
  /// `except=a,b` leaves those names out (whereNotIn).
  @summary('List tags (lower case annotation)')
  Future<List<Tag>> index(ListTags query) async {
    String except = query.except ?? '';
    return await service.list(
      query.limit,
      except.isEmpty ? <String>[] : except.split(','),
    );
  }

  /// Create tags in one transaction
  ///
  /// With `fail: true` the transaction rolls back and nothing is saved.
  @Summary('Create tags in a transaction')
  @Tags(<String>['Tag', 'ORM'])
  Future<Map<String, dynamic>> store(CreateTags body) async {
    return await service.createMany(body.names, body.fail);
  }

  /// Get a tag with its posts
  Future<Tag> posts(String name) async {
    return await service.withPosts(name);
  }
}
