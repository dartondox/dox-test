import 'package:dox_core/dox_core.dart';

/// Custom rule: lower case words joined by `-`, like `dart-tips`.
class Slug extends Rule<String> {
  const Slug({super.message});

  static final RegExp _pattern = RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$');

  @override
  String get name {
    return 'slug';
  }

  @override
  String get defaultMessage {
    return 'The {field} must be a slug, like dart-tips';
  }

  @override
  bool check(String value, RuleContext context) {
    return _pattern.hasMatch(value);
  }

  @override
  Map<String, dynamic> toJsonSchema() {
    return <String, dynamic>{'pattern': _pattern.pattern};
  }
}
