import 'package:dox_core/dox_core.dart';
import 'package:dox_test/constants/app_constants.dart';

/// Body of POST and PUT /api/posts.
class PostRequest extends FormRequest {
  String title = '';
  String content = '';
  String status = AppConstants.statusDraft;
  List<String> tags = <String>[];

  @override
  void setUp() {
    title = input('title').toString();
    content = input('body').toString();
    status = input('status')?.toString() ?? AppConstants.statusDraft;
    List<dynamic> rawTags = input('tags') ?? <dynamic>[];
    tags = rawTags.map(_tagToString).toList();
  }

  String _tagToString(dynamic tag) {
    return tag.toString();
  }

  @override
  Map<String, String> rules() {
    return <String, String>{
      'title': 'required|max_length:255',
      'body': 'required',
      'status':
          'in:${AppConstants.statusDraft},${AppConstants.statusPublished}',
    };
  }
}
