import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/services/system.service.dart';
import 'package:dox_test/constants/app_constants.dart';

/// Endpoints that check core features (request, response, env, hashing).
class SystemController {
  final SystemService service;

  SystemController(this.service);

  /// GET /ping
  String ping(DoxRequest req) {
    return 'pong';
  }

  /// GET /api/system/query?a=1
  Map<String, dynamic> query(DoxRequest req) {
    return <String, dynamic>{
      'query': req.query,
      'only': req.only(<String>['a']),
      'has_a': req.has('a'),
      'method': req.method,
    };
  }

  /// POST /api/system/echo (JSON body)
  Map<String, dynamic> echo(DoxRequest req) {
    return <String, dynamic>{
      'body': req.body,
      'is_json': req.isJson(),
      'user_agent': req.userAgent(),
    };
  }

  /// GET /api/system/env
  Map<String, dynamic> env(DoxRequest req) {
    return service.env();
  }

  /// POST /api/system/hash
  Map<String, dynamic> hash(DoxRequest req) {
    return service.hash(req.input('password').toString());
  }

  /// GET /api/system/cookie (sets an encrypted cookie)
  DoxResponse setCookie(DoxRequest req) {
    DoxCookie cookie = DoxCookie(AppConstants.themeCookie, 'dark');
    return response(<String, bool>{'ok': true}).cookie(cookie);
  }

  /// GET /api/system/cookie/read (reads it back)
  Map<String, dynamic> readCookie(DoxRequest req) {
    return <String, dynamic>{'theme': req.cookie(AppConstants.themeCookie)};
  }

  /// GET /api/system/teapot (custom status and header)
  DoxResponse teapot(DoxRequest req) {
    return response(<String, String>{'message': 'I am a teapot'})
        .statusCode(418)
        .header('X-Custom', 'yes');
  }

  /// GET /api/system/crash (unhandled error, so 500)
  String crash(DoxRequest req) {
    throw Exception('boom');
  }

  /// GET /api/system/container
  Map<String, int> container(DoxRequest req) {
    return <String, int>{'calls': service.nextCall()};
  }

  /// GET /no-cors
  String noCors(DoxRequest req) {
    return 'no cors here';
  }
}
