/// Global constants used across the app.
class AppConstants {
  /// Header added to every response by the global middleware.
  static const String appHeader = 'X-App-Name';

  /// Header the system routes need.
  static const String apiKeyHeader = 'X-Api-Key';

  /// Root folder of the local storage disk.
  static const String storageRoot = 'storage';

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

  /// Cache stores that the /api/cache routes may use.
  static const List<String> cacheStores = <String>['memory', 'file', 'redis'];

  /// Storage disks that the /api/storage routes may use.
  static const List<String> storageDisks = <String>['local', 'memory', 's3'];

  /// Browser page to try websocket and Socket.IO.
  static const String playgroundFile = 'public/playground.html';

  /// Socket.IO namespace and the room used by the playground.
  static const String chatNamespace = '/chat';
}
