/// Global constants used across the app.
class AppConstants {
  /// Header added to every response by the global middleware.
  static const String appHeader = 'X-App-Name';

  /// Header the system routes need.
  static const String apiKeyHeader = 'X-Api-Key';

  /// Storage folder for uploaded files.
  static const String uploadFolder = 'uploads';

  /// Cookie name used by the cookie check.
  static const String themeCookie = 'theme';

  /// Cache key for post stats.
  static const String postStatsCacheKey = 'post_stats';

  /// Post status values.
  static const String statusDraft = 'draft';
  static const String statusPublished = 'published';

  /// Default page size for lists.
  static const int defaultPerPage = 10;
}
