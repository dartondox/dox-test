import 'package:dox_core/dox_core.dart';
import 'package:dox_inertia/dox_inertia.dart';
import 'package:dox_storage/dox_storage.dart';

/// Routes for test/e2e_310b_packages.dart. CoreRouter adds them in the
/// group `/e310b-pkg`, so they start with /core/e310b-pkg. Plain methods,
/// so they need no container entry (no build_runner run).
class E310bPkgRoutes {
  /// the folder of the uploads below
  static const String folder = 'e310b_pkg_up';

  void register() {
    Route.post('/store', store);
    Route.post('/store-as', storeAs);
    Route.post('/put-as', putAs);
  }

  /// POST /core/e310b-pkg/store?disk=memory: `file.store(folder, disk:)`
  Future<Map<String, dynamic>> store(DoxRequest req) async {
    RequestFile file = req.file('file')!;
    String? disk = req.input('disk');
    return _saved(disk, await file.store(folder, disk: disk));
  }

  /// POST /core/e310b-pkg/store-as?disk=s3&name=a.txt: `file.storeAs`
  Future<Map<String, dynamic>> storeAs(DoxRequest req) async {
    RequestFile file = req.file('file')!;
    String? disk = req.input('disk');
    String name = '${req.input('name')}';
    return _saved(disk, await file.storeAs(folder, name, disk: disk));
  }

  /// POST /core/e310b-pkg/put-as?name=a.txt: `putRequestFileAs` on the
  /// default disk
  Future<Map<String, dynamic>> putAs(DoxRequest req) async {
    RequestFile file = req.file('file')!;
    String name = '${req.input('name')}';
    return _saved(null, await Storage().putRequestFileAs(folder, name, file));
  }

  /// the saved path and the text of the file on that disk
  Future<Map<String, dynamic>> _saved(String? disk, String path) async {
    String key = path.startsWith('/') ? path.substring(1) : path;
    Disk target = Storage().use(disk);
    return <String, dynamic>{'path': key, 'text': await target.getString(key)};
  }
}

/// Inertia routes for test/e2e_310b_packages.dart. InertiaRouter adds
/// them in the group `/e310b-pkg`, so they start with /inertia/e310b-pkg
/// and have the session, CSRF and Inertia middleware.
class E310bPkgInertiaRoutes {
  void register() {
    Route.get('/render', render);
    Route.get('/request-share', requestShare);
    Route.any('/empty', empty);
  }

  /// GET: `Inertia.render` with lazy, deferred and merged props
  Future<DoxResponse> render(DoxRequest req) {
    return Inertia.render(req, 'Home', <String, dynamic>{
      'e310b_pkg_page': 'page',
      'e310b_pkg_who': 'page prop',
      'e310b_pkg_lazy': Inertia.lazy(lazyValue),
      'e310b_pkg_feed': Inertia.defer(feed).merge(),
      'e310b_pkg_feed2': Inertia.defer(feed, merge: true),
      'e310b_pkg_plain': Inertia.defer(feed),
    });
  }

  /// GET: a prop shared for the request has the name of a global one
  Future<DoxResponse> requestShare(DoxRequest req) {
    Inertia.share(req, <String, dynamic>{'e310b_pkg_who': 'request'});
    return Inertia.render(req, 'Home');
  }

  /// any method: an empty 200 answer
  String empty(DoxRequest req) {
    return '';
  }

  String lazyValue() {
    return 'lazy value';
  }

  List<int> feed() {
    return <int>[1, 2];
  }
}
