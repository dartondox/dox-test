import 'dart:io';

import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/http/dtos/system.dto.dart';
import 'package:dox_test/app/services/system.service.dart';
import 'package:dox_test/constants/app_constants.dart';

/// Endpoints that check core features (request, response, env, hashing).
@Inject()
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
    return service.envInfo();
  }

  /// POST /api/system/hash
  Map<String, dynamic> hash(HashPassword body) {
    return service.hash(body.password);
  }

  /// POST /api/system/orders (nested DTO and a list of DTOs)
  Map<String, dynamic> order(CreateOrder body) {
    return service.order(body);
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

  /// GET /api/system/ip (X-Forwarded-* is read only from trusted proxies)
  Map<String, dynamic> ip(DoxRequest req) {
    return <String, dynamic>{
      'ip': req.ip(),
      'scheme': req.scheme(),
      'secure': req.isSecure(),
    };
  }

  /// GET /api/system/twice/{n} (`abc` is not an int, so 404)
  Map<String, int> twice(int n) {
    return <String, int>{'result': n * 2};
  }

  /// Browser page to try Socket.IO
  @ApiIgnore()
  File playground(DoxRequest req) {
    return File(AppConstants.playgroundFile);
  }

  /// GET /no-cors
  String noCors(DoxRequest req) {
    return 'no cors here';
  }
}
