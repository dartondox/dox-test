import 'dart:convert';
import 'dart:io';

import 'package:dox_auth/dox_auth.dart';
import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/dtos/core/core.dto.dart';
import 'package:dox_test/app/models/user/user.model.dart';
import 'package:dox_view/dox_view.dart';

/// Endpoints for the dox_core features of 3.1.0: new routes, request
/// helpers, headers, flash, `req.auth?.id()` and new DTO rules.
/// Only /api/greet is in the API docs (OpenApiConfig.include is /api/*).
@Inject()
class CoreController {
  /// The method the route got, for Route.match, Route.any and MethodOverride.
  Map<String, String> method(DoxRequest req) {
    return <String, String>{'method': req.method};
  }

  /// GET /core/new, the target of Route.redirect.
  String newPage(DoxRequest req) {
    return 'new page';
  }

  /// GET /core/items/{id}: only digits, see `.where`.
  Map<String, dynamic> itemById(DoxRequest req, int id) {
    return <String, dynamic>{'by': 'id', 'id': id};
  }

  /// GET /core/items/{slug}: anything else.
  Map<String, dynamic> itemBySlug(DoxRequest req, String slug) {
    return <String, dynamic>{'by': 'slug', 'slug': slug};
  }

  /// Say hello
  ///
  /// GET /api/greet/{name?}. With no name, it greets a guest.
  @Tags(<String>['Core'])
  Map<String, String> greet(DoxRequest req, String? name) {
    return <String, String>{'hello': name ?? 'guest'};
  }

  /// POST /core/request/{id}: the new request helpers.
  Map<String, dynamic> inspect(DoxRequest req) {
    return <String, dynamic>{
      'user_name': req.input('user.name'),
      'first_item': req.input('items.0.id'),
      'city': req.input('user.city', 'none'),
      'filled_name': req.filled('name'),
      'filled_blank': req.filled('blank'),
      'exists_blank': req.exists('blank'),
      'missing_other': req.missing('other'),
      'except': req.except(<String>['user', 'items', 'secret']).keys.toList(),
      'remember': req.boolean('remember'),
      'page': req.integer('page', 1),
      'per_page': req.integer('per_page', 20),
      'bearer': req.bearerToken(),
      'path': req.path(),
      'full_url': req.fullUrl(),
      'path_is': req.pathIs('core/request/*'),
      'path_is_other': req.pathIs('admin/*'),
      'route_is': req.routeIs('core.*'),
    };
  }

  /// GET /core/headers: `header()` replaces a header of any case.
  DoxResponse headers(DoxRequest req) {
    return response('ok')
        .cache(Duration(minutes: 5))
        .header('cache-control', 'no-store')
        .header('X-One', '1')
        .withHeaders(<String, dynamic>{'x-one': 'one', 'X-Two': '2'});
  }

  /// GET /core/download: `withHeaders` keeps the Content-Disposition.
  DoxResponse download(DoxRequest req) {
    List<int> bytes = utf8.encode('file body');
    DownloadableFile file = DownloadableFile(
      ContentType.text,
      Stream<List<int>>.value(bytes),
      'report.txt',
      length: bytes.length,
    );
    return response(file).withHeaders(<String, dynamic>{'X-Report': 'yes'});
  }

  /// GET /core/flash/set
  Map<String, bool> flashSet(DoxRequest req) {
    req.session.flash('note', 'kept');
    return <String, bool>{'ok': true};
  }

  /// GET /core/flash/keep: `reflash()` is the first use of the session.
  Map<String, bool> flashKeep(DoxRequest req) {
    req.session.reflash();
    return <String, bool>{'ok': true};
  }

  /// GET /core/flash/read
  Map<String, dynamic> flashRead(DoxRequest req) {
    return <String, dynamic>{'note': req.session.get('note')};
  }

  /// GET /core/whoami: a guest gets through `AuthMiddleware(optional: true)`.
  Map<String, dynamic> whoami(DoxRequest req) {
    Auth? auth = req.auth as Auth?;
    return <String, dynamic>{
      'auth_set': auth != null,
      'id': req.auth?.id(),
      'guest': auth?.guest(),
      'name': auth?.user<User>()?.name,
    };
  }

  /// GET /core/guest-only, behind `GuestMiddleware`.
  Map<String, String> guestOnly(DoxRequest req) {
    return <String, String>{'page': 'login'};
  }

  /// POST /core/contacts: `@RequiredIf` and `@RequiredWith`.
  Map<String, dynamic> saveContact(SaveContact body) {
    return <String, dynamic>{
      'account_type': body.accountType,
      'company_name': body.companyName,
      'country_code': body.countryCode,
    };
  }

  /// POST /core/banner: `@MimeTypes`, `@MinSize` and `@Dimensions`.
  Map<String, dynamic> banner(UploadBanner body) {
    return <String, dynamic>{'bytes': body.banner.length};
  }

  /// GET /core/plain-view: a view with no session. `errors` is still there.
  DoxResponse plainView(DoxRequest req) {
    return response(View.render('core/plain', <String, dynamic>{'who': 'Dox'}))
        .contentType(ContentType.html);
  }

  /// Route.fallback: a GET to /core/... with no route
  DoxResponse notFound(DoxRequest req) {
    return response(<String, String>{'message': 'no page at ${req.path()}'})
        .statusCode(404);
  }
}
