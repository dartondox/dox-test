import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dox_auth/commands.dart';
import 'package:dox_auth/dox_auth.dart';
import 'package:dox_core/command.dart';
import 'package:dox_core/dox_core.dart';
import 'package:dox_orm/dox_orm.dart' show QueryBuilder;
import 'package:dox_test/app/models/user/user.model.dart';
import 'package:dox_test/config/env.dart';
import 'package:dox_test/constants/app_constants.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'e2e_core.dart' show cookieHeader;
import 'e2e_test.dart' show Api, Browser, SioClient;

/// More e2e checks for 3.1.0: dox_core, dox_auth and dox_socketio.
/// New features with no check yet, edge inputs, and 3.0.2 behavior that
/// must not change. The routes are in lib/routes/e2e_core.dart
/// (/core/e2e/...). `main()` of e2e_test.dart calls this.
void core310Tests(Api api) {
  group('3.1.0 core e2e: routes and paths', () {
    test('.where checks the decoded param: %2F can not add a /', () async {
      http.Response ok = await api.get('/core/e2e/files/report.txt');
      expect(api.json(ok), <String, dynamic>{'name': 'report.txt'});

      for (String path in <String>[
        '/core/e2e/files/..%2F..%2Fetc%2Fpasswd',
        '/core/e2e/files/a%2Fb',
        '/core/e2e/files/%2F',
      ]) {
        http.Response res = await api.get(path);
        expect(res.statusCode, 404, reason: path);
        expect(res.body, isNot(contains('"name"')), reason: path);
      }
    });

    test('.where: a decoded space or unicode text still matches', () async {
      http.Response space = await api.get('/core/e2e/files/a%20b');
      expect(api.json(space), <String, dynamic>{'name': 'a b'});
      http.Response unicode = await api.get('/core/e2e/files/caf%C3%A9');
      expect(api.json(unicode), <String, dynamic>{'name': 'café'});

      // [a-z]+ : the decoded é is not a-z, so no match
      expect(
        api.json(await api.get('/core/e2e/letters/abc')),
        <String, dynamic>{'word': 'abc'},
      );
      http.Response accent = await api.get('/core/e2e/letters/caf%C3%A9');
      expect(accent.statusCode, 404);
    });

    test('req.pathIs: a / at the end or // does not skip a guard', () async {
      for (String path in <String>[
        '/core/e2e/admin',
        '/core/e2e/admin/',
        '/core/e2e/admin//',
        '/core//e2e/admin',
      ]) {
        http.Response res = await api.get(path);
        expect(res.statusCode, 403, reason: path);
        expect(api.json(res), <String, dynamic>{
          'code': 'forbidden',
          'message': 'admin only',
        }, reason: path);
      }
      http.Response open = await api.get('/core/e2e/open');
      expect(open.statusCode, 200);
    });

    test('middleware order: group, then the route list, in order', () async {
      http.Response res = await api.get('/core/e2e/order');
      expect(res.statusCode, 200);
      expect(res.body, 'ok');
      // package:http joins the same header with ", "
      List<String> order = res.headers['x-order']!.split(',');
      expect(order.map((String s) => s.trim()), <String>[
        'group',
        'first',
        'second',
      ]);
      // the global middleware ran too
      expect(res.headers['x-app-name'], 'dox-test');
    });

    test('Route.resource: seven actions, PATCH is update too', () async {
      Map<String, List<String>> cases = <String, List<String>>{
        'GET /core/e2e/notes': <String>['index', 'GET'],
        'GET /core/e2e/notes/create': <String>['create', 'GET'],
        'POST /core/e2e/notes': <String>['store', 'POST'],
        'GET /core/e2e/notes/5': <String>['show', 'GET'],
        'GET /core/e2e/notes/5/edit': <String>['edit', 'GET'],
        'PUT /core/e2e/notes/5': <String>['update', 'PUT'],
        'PATCH /core/e2e/notes/5': <String>['update', 'PATCH'],
        'DELETE /core/e2e/notes/5': <String>['destroy', 'DELETE'],
      };
      for (MapEntry<String, List<String>> c in cases.entries) {
        List<String> parts = c.key.split(' ');
        http.Response res = await api.send(parts[0], parts[1]);
        expect(res.statusCode, 200, reason: c.key);
        Map<String, dynamic> body = api.json(res);
        expect(body['action'], c.value[0], reason: c.key);
        expect(body['method'], c.value[1], reason: c.key);
      }
      // MethodOverride reaches the resource routes from a form
      http.Response form = await api.send(
        'POST',
        '/core/e2e/notes/5',
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: '_method=DELETE',
      );
      expect(api.json(form)['action'], 'destroy');
    });

    test('Route.url of a named resource route', () async {
      http.Response res = await api.get('/core/e2e/note-url/7');
      expect(api.json(res), <String, dynamic>{
        'show': '/core/e2e/notes/7',
        'index': '/core/e2e/notes',
      });
    });

    test('wrong method: 405 with an Allow header, JSON body', () async {
      for (String method in <String>['DELETE', 'PUT', 'FOO']) {
        http.Response res = await api.send(method, '/ping');
        expect(res.statusCode, 405, reason: method);
        expect(res.headers['allow'], 'GET, HEAD', reason: method);
        expect(api.json(res), <String, dynamic>{
          'code': 'method_not_allowed',
          'message': '$method is not allowed for /ping',
        });
      }
    });

    test('a very long path is a 404, not a 500', () async {
      http.Response res = await api.get('/api/${'a' * 6000}');
      expect(res.statusCode, 404);
      expect(api.json(res)['code'], 'not_found');
    });
  });

  group('3.1.0 core e2e: request helpers with edge input', () {
    Future<Map<String, dynamic>> input(String body, [String query = '']) async {
      http.Response res = await api.send(
        'POST',
        '/core/e2e/input$query',
        headers: <String, String>{'Content-Type': 'application/json'},
        body: body,
      );
      expect(res.statusCode, 200, reason: res.body);
      return api.json(res);
    }

    test('an empty body: defaults everywhere', () async {
      for (String body in <String>['{}', '', '[]']) {
        Map<String, dynamic> r = await input(body);
        expect(r['name'], 'default', reason: body);
        expect(r['filled_name'], false);
        expect(r['exists_name'], false);
        expect(r['missing_name'], true);
        expect(r['flag'], false);
        expect(r['flag_or_true'], true);
        expect(r['n'], -1);
        expect(r['item'], 'none');
        expect(r['has_file'], false);
        expect(r['except'], isEmpty);
      }
    });

    test('null: exists, but not filled, and input gives the default', () async {
      Map<String, dynamic> r = await input('{"name": null}');
      expect(r['name'], 'default');
      expect(r['exists_name'], true);
      expect(r['missing_name'], false);
      expect(r['filled_name'], false);
    });

    test('unicode and a very long text come back the same', () async {
      String long = 'ü🙂' * 20000;
      Map<String, dynamic> r = await input(
        jsonEncode(<String, String>{'name': long}),
      );
      expect(r['name'], long);
      expect(r['filled_name'], true);
      expect(r['has_name'], true);

      r = await input(jsonEncode(<String, String>{'name': ' \t '}));
      expect(r['filled_name'], false);
      expect(r['exists_name'], true);
    });

    test('boolean(): true words in any case, other text is false', () async {
      Map<String, bool> cases = <String, bool>{
        '"YES"': true,
        '"On"': true,
        '"1"': true,
        '1': true,
        'true': true,
        '" true "': true,
        '"0"': false,
        '"no"': false,
        '"maybe"': false,
        'false': false,
        '""': false,
      };
      for (MapEntry<String, bool> c in cases.entries) {
        Map<String, dynamic> r = await input('{"flag": ${c.key}}');
        expect(r['flag'], c.value, reason: c.key);
        expect(r['flag_or_true'], c.value, reason: c.key);
      }
    });

    test('integer(): wrong types and huge numbers give the default', () async {
      Map<String, int> cases = <String, int>{
        '" 42 "': 42,
        '3.9': 3,
        '-5': -5,
        '0': 0,
        '9223372036854775807': 9223372036854775807,
        '"12abc"': -1,
        '"abc"': -1,
        'true': -1,
        '[1]': -1,
        '{"a": 1}': -1,
        '1e400': -1,
        '""': -1,
      };
      for (MapEntry<String, int> c in cases.entries) {
        Map<String, dynamic> r = await input('{"n": ${c.key}}');
        expect(r['n'], c.value, reason: c.key);
      }
    });

    test('dot keys: deep values, a literal "x.y" key wins', () async {
      Map<String, dynamic> r = await input(
        jsonEncode(<String, dynamic>{
          'a': <String, dynamic>{
            'b': <String, dynamic>{
              'c': <int>[1, 2],
            },
          },
          'x.y': 'literal',
          'x': <String, String>{'y': 'deep'},
          'items': <dynamic>[
            <String, int>{'id': 1},
          ],
        }),
      );
      expect(r['deep'], <int>[1, 2]);
      expect(r['dotted'], 'literal');
      // items.5 is past the end of the list
      expect(r['item'], 'none');
    });

    test('the query string is input too', () async {
      Map<String, dynamic> r = await input('{}', '?name=fromquery&n=7');
      expect(r['name'], 'fromquery');
      expect(r['n'], 7);
      expect(r['except'], <String>['n']);
    });

    test('file() and hasFile(): a file, a list of files, text', () async {
      http.MultipartRequest req = http.MultipartRequest(
        'POST',
        api.uri('/core/e2e/input'),
      );
      req.fields['name'] = 'x';
      req.files.add(
        http.MultipartFile.fromString('file', 'one', filename: 'ü 1.txt'),
      );
      req.files.add(http.MultipartFile.fromString('files', 'a', filename: 'a'));
      req.files.add(http.MultipartFile.fromString('files', 'b', filename: 'b'));
      http.Response res = await http.Response.fromStream(await req.send());
      Map<String, dynamic> r = api.json(res);
      expect(r['has_file'], true);
      expect(r['file_name'], 'ü 1.txt');
      expect(r['has_files'], true);

      // a text field with the same name is not a file
      http.MultipartRequest text = http.MultipartRequest(
        'POST',
        api.uri('/core/e2e/input'),
      );
      text.fields['file'] = 'just text';
      text.fields['files'] = 'more text';
      r = api.json(await http.Response.fromStream(await text.send()));
      expect(r['has_file'], false);
      expect(r['file_name'], isNull);
      expect(r['has_files'], false);
    });

    test('bearerToken(): any case, spaces, and bad headers', () async {
      Map<String, String?> cases = <String, String?>{
        'Bearer abc': 'abc',
        'bearer   tok  ': 'tok',
        'BEARER x.y.z': 'x.y.z',
        'Bearer ': null,
        'Bearer': null,
        'Basic abc': null,
        'Bearertok': null,
        '': null,
      };
      for (MapEntry<String, String?> c in cases.entries) {
        http.Response res = await api.get(
          '/core/e2e/bearer',
          headers: <String, String>{'Authorization': c.key},
        );
        expect(api.json(res)['token'], c.value, reason: '"${c.key}"');
      }
      http.Response none = await api.get('/core/e2e/bearer');
      expect(api.json(none)['token'], isNull);
    });
  });

  group('3.1.0 core e2e: static files', () {
    String lastModified = '';
    String etag = '';

    setUpAll(() async {
      http.Response res = await api.get('/core/assets/hello.txt');
      lastModified = res.headers['last-modified']!;
      etag = res.headers['etag']!;
    });

    test('If-Modified-Since with the same date gets 304', () async {
      http.Response res = await api.get(
        '/core/assets/hello.txt',
        headers: <String, String>{'If-Modified-Since': lastModified},
      );
      expect(res.statusCode, 304);
      expect(res.body, isEmpty);

      http.Response old = await api.get(
        '/core/assets/hello.txt',
        headers: <String, String>{
          'If-Modified-Since': 'Wed, 01 Jan 2020 00:00:00 GMT',
        },
      );
      expect(old.statusCode, 200);
      expect(old.body, 'hello static\n');
    });

    test('If-None-Match wins over If-Modified-Since', () async {
      http.Response res = await api.get(
        '/core/assets/hello.txt',
        headers: <String, String>{
          'If-None-Match': 'W/"other"',
          'If-Modified-Since': lastModified,
        },
      );
      expect(res.statusCode, 200);
      expect(res.body, 'hello static\n');
    });

    test('If-Range: the Last-Modified date gives 206, else 200', () async {
      http.Response same = await api.get(
        '/core/assets/hello.txt',
        headers: <String, String>{
          'Range': 'bytes=0-4',
          'If-Range': lastModified,
        },
      );
      expect(same.statusCode, 206);
      expect(same.body, 'hello');
      expect(same.headers['content-range'], 'bytes 0-4/13');

      // a weak ETag and an old date may not use the range
      for (String ifRange in <String>[etag, 'Wed, 01 Jan 2020 00:00:00 GMT']) {
        http.Response res = await api.get(
          '/core/assets/hello.txt',
          headers: <String, String>{'Range': 'bytes=0-4', 'If-Range': ifRange},
        );
        expect(res.statusCode, 200, reason: ifRange);
        expect(res.body, 'hello static\n', reason: ifRange);
      }
    });

    test('a Range outside the file gets 416', () async {
      for (String range in <String>['bytes=50-10', 'bytes=1000-']) {
        http.Response res = await api.get(
          '/core/assets/hello.txt',
          headers: <String, String>{'Range': range},
        );
        expect(res.statusCode, 416, reason: range);
        expect(res.headers['content-range'], 'bytes */13', reason: range);
      }
    });

    test('a Range or If-None-Match header on two lines is not a 500', () async {
      for (String header in <String>['Range', 'If-None-Match', 'If-Range']) {
        String head = await rawRequest(
          api,
          'GET /core/assets/hello.txt HTTP/1.1\r\n'
          'Host: 127.0.0.1\r\n'
          '$header: bytes=0-1\r\n'
          '$header: bytes=2-3\r\n'
          'Connection: close\r\n\r\n',
        );
        expect(head, isNot(contains(' 500 ')), reason: header);
        expect(head, startsWith('HTTP/1.1 2'), reason: header);
      }
    });

    test('maxAge sends Cache-Control', () async {
      http.Response res = await api.get('/core/e2e/cached/hello.txt');
      expect(res.statusCode, 200);
      expect(res.body, 'hello static\n');
      expect(res.headers['cache-control'], 'public, max-age=3600');
      // no maxAge: no Cache-Control
      http.Response plain = await api.get('/core/assets/hello.txt');
      expect(plain.headers['cache-control'], isNull);
    });

    test('the global CORS headers are on a static file', () async {
      http.Response res = await api.get(
        '/core/assets/hello.txt',
        headers: <String, String>{'Origin': 'https://x.example'},
      );
      expect(res.headers['access-control-allow-origin'], '*');
    });

    test('POST, PUT and DELETE do not get the file', () async {
      for (String method in <String>['POST', 'PUT', 'DELETE']) {
        http.Response res = await api.send(method, '/core/assets/hello.txt');
        expect(res.statusCode, 404, reason: method);
        expect(res.body, isNot(contains('hello static')), reason: method);
      }
    });

    test('odd names are 404: a null byte, unicode, a long name', () async {
      for (String path in <String>[
        '/core/assets/hello.txt%00.png',
        '/core/assets/%C3%A9.txt',
        '/core/assets/${'a' * 5000}',
        '/core/assets/hello.txt/',
        '/core/assets/..%5Cpubspec.yaml',
      ]) {
        http.Response res = await api.get(path);
        expect(res.statusCode, 404, reason: path);
        expect(res.body, isNot(contains('hello static')), reason: path);
      }
    });

    test('30 requests at once all get the file', () async {
      List<Future<http.Response>> calls = <Future<http.Response>>[];
      for (int i = 0; i < 30; i++) {
        calls.add(api.get('/core/assets/hello.txt'));
      }
      for (http.Response res in await Future.wait(calls)) {
        expect(res.statusCode, 200);
        expect(res.body, 'hello static\n');
      }
    });
  });

  group('3.1.0 core e2e: errors (same as 3.0.2)', () {
    test('a 404 is JSON with code and message', () async {
      http.Response res = await api.get('/api/nothing-at-all');
      expect(res.statusCode, 404);
      expect(res.headers['content-type'], startsWith('application/json'));
      expect(api.json(res), <String, dynamic>{
        'code': 'not_found',
        'message': 'GET /api/nothing-at-all not found',
      });
    });

    test('abort(409, message) and HttpStatusException headers', () async {
      http.Response conflict = await api.get('/core/e2e/conflict');
      expect(conflict.statusCode, 409);
      expect(api.json(conflict), <String, dynamic>{
        'code': 'conflict',
        'message': 'The name is taken',
      });

      http.Response retry = await api.get('/core/e2e/retry');
      expect(retry.statusCode, 503);
      expect(retry.headers['retry-after'], '60');
      expect(api.json(retry), <String, dynamic>{
        'code': 'service_unavailable',
        'message': 'Service Unavailable',
      });
    });

    test('401 and 403 keep their JSON shape', () async {
      http.Response guest = await api.get('/api/auth/me');
      expect(guest.statusCode, 401);
      expect(api.json(guest)['code'], 'unauthorized');

      http.Response key = await api.get('/api/system/env', withKey: false);
      expect(key.statusCode, 403);
      expect(api.json(key)['message'], 'invalid api key');
    });
  });

  group('3.1.0 core e2e: cookies, sessions, CSRF, signed urls', () {
    String themeValue = '';
    Browser? web;

    setUpAll(() async {
      http.Response res = await api.get('/api/system/cookie');
      themeValue = res.headers['set-cookie']!
          .split(';')
          .first
          .split('=')
          .sublist(1)
          .join('=');
      await api.post('/api/auth/register', <String, dynamic>{
        'name': 'Core Web',
        'email': 'core310web@mail.com',
        'password': 'secret123',
        'password_confirmation': 'secret123',
      });
    });

    Future<Browser> webLogin() async {
      Browser browser = Browser(api);
      await browser.send('GET', '/ping', <String, String>{});
      http.Response res = await browser.send(
        'POST',
        '/web-auth/login',
        <String, String>{'Content-Type': 'application/json'},
        jsonEncode(<String, String>{
          'email': 'core310web@mail.com',
          'password': 'secret123',
        }),
      );
      expect(res.statusCode, 200, reason: res.body);
      return browser;
    }

    test('DoxCookie.decrypt: right name only, a change gives null', () {
      String name = AppConstants.themeCookie;
      expect(DoxCookie.decrypt(name, themeValue), 'dark');
      expect(DoxCookie.decrypt('other_cookie', themeValue), isNull);
      String changed =
          themeValue.substring(0, themeValue.length - 2) +
          (themeValue.endsWith('AA') ? 'BB' : 'AA');
      expect(DoxCookie.decrypt(name, changed), isNull);
      for (String bad in <String>['', 'x', '%%%', 'é🙂', '.' * 5000]) {
        expect(DoxCookie.decrypt(name, bad), isNull, reason: bad);
      }
    });

    test('a bad cookie value is no value, not a 500', () async {
      for (String value in <String>[
        '',
        'garbage',
        '${themeValue}x',
        '%E2%9C%93',
        'a' * 3000,
      ]) {
        http.Response res = await api.get(
          '/api/system/cookie/read',
          headers: <String, String>{
            'Cookie': '${AppConstants.themeCookie}=$value',
          },
        );
        expect(res.statusCode, 200, reason: value);
        expect(api.json(res)['theme'], isNull, reason: value);
      }
      // the same cookie twice: the good one is still read, no 500
      http.Response twice = await api.get(
        '/api/system/cookie/read',
        headers: <String, String>{
          'Cookie':
              '${AppConstants.themeCookie}=$themeValue; '
              '${AppConstants.themeCookie}=$themeValue',
        },
      );
      expect(twice.statusCode, 200);
    });

    test('SessionMiddleware().fromCookie loads the web login', () async {
      Browser browser = await webLogin();
      web = browser;
      String raw = browser.cookies['dox_session']!;
      Session session = await const SessionMiddleware().fromCookie(raw);
      User? user = await Auth(guard: 'web').userFromSession<User>(session);
      expect(user?.email, 'core310web@mail.com');
    });

    test('fromCookie: null, changed or another cookie is no login', () async {
      String raw = web!.cookies['dox_session']!;
      for (String? value in <String?>[
        null,
        '',
        '${raw}x',
        raw.substring(1),
        themeValue,
      ]) {
        Session session = await const SessionMiddleware().fromCookie(value);
        User? user = await Auth(guard: 'web').userFromSession<User>(session);
        expect(user, isNull, reason: '$value');
      }
    });

    test('a changed session cookie on a guarded page is 401', () async {
      String raw = web!.cookies['dox_session']!;
      http.Response res = await api.get(
        '/web-auth/me',
        headers: <String, String>{'Cookie': 'dox_session=${raw}x'},
      );
      expect(res.statusCode, 401);
      http.Response ok = await web!.send(
        'GET',
        '/web-auth/me',
        <String, String>{},
      );
      expect(ok.statusCode, 200);
    });

    test('CSRF: a wrong or empty X-XSRF-TOKEN gets 419', () async {
      Browser browser = Browser(api);
      await browser.send('GET', '/ping', <String, String>{});
      for (String token in <String>['wrong', '', 'é']) {
        http.Response res = await api.send(
          'POST',
          '/web-auth/login',
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Cookie': cookieHeader(browser),
            'X-XSRF-TOKEN': Uri.encodeComponent(token),
          },
          body: jsonEncode(<String, String>{
            'email': 'core310web@mail.com',
            'password': 'secret123',
          }),
        );
        expect(res.statusCode, 419, reason: token);
      }
    });

    test('after logout, fromCookie of the old cookie is no login', () async {
      String raw = web!.cookies['dox_session']!;
      http.Response out = await web!.send(
        'POST',
        '/web-auth/logout',
        <String, String>{'Content-Type': 'application/json'},
        '{}',
      );
      expect(out.statusCode, 200, reason: out.body);
      Session session = await const SessionMiddleware().fromCookie(raw);
      User? user = await Auth(guard: 'web').userFromSession<User>(session);
      expect(user, isNull);
    });

    test('signed url: works as made, any change gives 403', () async {
      String url = api.json(await api.get('/core/e2e/sign/5'))['url'];
      http.Response ok = await api.get(url);
      expect(api.json(ok), <String, dynamic>{'id': '5'});

      String sig = Uri.parse(url).queryParameters['signature']!;
      String flipped =
          sig.substring(0, sig.length - 1) + (sig.endsWith('a') ? 'b' : 'a');
      for (String bad in <String>[
        url.replaceFirst('/signed/5', '/signed/6'),
        url.replaceFirst('/signed/5', '/signed/05'),
        url.replaceFirst(sig, flipped),
        url.replaceFirst(sig, sig.toUpperCase()),
        url.replaceFirst('?signature=$sig', ''),
        url.replaceFirst('signature=', 'SIGNATURE='),
        '$url&x=1',
        url.replaceFirst('?', '?x=1&'),
        '$url&signature=abc',
      ]) {
        http.Response res = await api.get(bad);
        expect(res.statusCode, 403, reason: bad);
        expect(api.json(res)['message'], 'Invalid signature', reason: bad);
      }
    });

    test('signed url: an expired or changed expires gives 403', () async {
      String live = api.json(await api.get('/core/e2e/sign/5?ttl=300'))['url'];
      expect((await api.get(live)).statusCode, 200);
      String longer = live.replaceFirst('expires=', 'expires=9');
      expect((await api.get(longer)).statusCode, 403);

      String old = api.json(await api.get('/core/e2e/sign/5?ttl=-10'))['url'];
      expect((await api.get(old)).statusCode, 403);
    });
  });

  group('3.1.0 core e2e: dox_auth edges', () {
    late User user;
    String jwt = '';

    Future<String> login({String path = '/api/auth/login'}) async {
      http.Response res = await api.post(path, <String, dynamic>{
        'email': 'core310@mail.com',
        'password': 'secret123',
      });
      expect(res.statusCode, 200, reason: res.body);
      return api.json(res)['token'];
    }

    Future<int> status(String path, String? auth) async {
      http.Response res = await api.get(
        path,
        headers: <String, String>{'Authorization': ?auth},
      );
      expect(res.statusCode, isNot(500), reason: '$auth: ${res.body}');
      return res.statusCode;
    }

    setUpAll(() async {
      http.Response res = await api.post(
        '/api/auth/register',
        <String, dynamic>{
          'name': 'Core Auth',
          'email': 'core310@mail.com',
          'password': 'secret123',
          'password_confirmation': 'secret123',
        },
      );
      expect(res.statusCode, 201, reason: res.body);
      user = (await User().find(api.json(res)['id']))!;
      jwt = await login();
    });

    tearDownAll(() async {
      await Auth(guard: 'tokens').revokeAllAccessTokens(user);
    });

    test('the default JWT keeps the user fields, a jti, no password', () {
      Map<String, dynamic> payload = jwtPart(jwt, 1);
      expect(payload['email'], 'core310@mail.com');
      expect(payload['name'], 'Core Auth');
      expect(payload['jti'], isA<String>());
      expect(payload['iat'], isA<int>());
      expect(payload['exp'], isA<int>());
      expect(payload.containsKey('password'), false);
    });

    test('a changed, unsigned or broken JWT is 401', () async {
      List<String> parts = jwt.split('.');
      Map<String, dynamic> payload = jwtPart(jwt, 1);
      payload['id'] = 999999;
      String otherBody = b64(jsonEncode(payload));
      String none = b64(jsonEncode(<String, String>{'alg': 'none'}));
      for (String token in <String>[
        '${parts[0]}.$otherBody.${parts[2]}',
        '$none.${parts[1]}.',
        '$none.${parts[1]}',
        '${parts[0]}.${parts[1]}.${parts[2]}x',
        '${parts[0]}.${parts[1]}',
        '..',
        'a.b.c',
        'x' * 8000,
      ]) {
        expect(
          await status('/api/auth/me', 'Bearer $token'),
          401,
          reason: token.length > 80 ? 'long token' : token,
        );
      }
    });

    test('an expired JWT is 401, also when its signature is good', () async {
      JwtAuthDriver old = JwtAuthDriver(
        secret: SecretKey(env.appKey),
        expiresIn: Duration(hours: -2),
      );
      String token = old.createToken(user.toJson(), 'api')!;
      expect(await status('/api/auth/me', 'Bearer $token'), 401);
      expect(await Auth(guard: 'api').userFromToken<User>(token), isNull);
    });

    test('a token with UTF-8 bytes in the header is 401, not 500', () async {
      for (String path in <String>['/api/auth/me', '/api/tokens']) {
        for (String token in <String>['é.🙂.x', 'oat_1.é🙂']) {
          String head = await rawRequest(
            api,
            'GET $path HTTP/1.1\r\n'
            'Host: 127.0.0.1\r\n'
            'Authorization: Bearer $token\r\n'
            'Connection: close\r\n\r\n',
          );
          expect(head, startsWith('HTTP/1.1 4'), reason: '$path $token');
        }
      }
    });

    test('two Authorization headers are a plain 401', () async {
      for (String path in <String>['/api/auth/me', '/api/tokens']) {
        String head = await rawRequest(
          api,
          'GET $path HTTP/1.1\r\n'
          'Host: 127.0.0.1\r\n'
          'Authorization: Bearer $jwt\r\n'
          'Authorization: Bearer $jwt\r\n'
          'Connection: close\r\n\r\n',
        );
        expect(head, startsWith('HTTP/1.1 401'), reason: path);
      }
    });

    test(
      'Auth.userFromToken: a JWT and an access token, null for bad',
      () async {
        User? byJwt = await Auth(guard: 'api').userFromToken<User>(jwt);
        expect(byJwt?.id, user.id);
        expect(await Auth(guard: 'api').userFromToken<User>(null), isNull);
        expect(await Auth(guard: 'api').userFromToken<User>(''), isNull);

        AccessToken made = await Auth(
          guard: 'tokens',
        ).createAccessToken(user, name: 'socket', abilities: <String>['a:b']);
        Auth auth = Auth(guard: 'tokens');
        User? byOat = await auth.userFromToken<User>(made.value);
        expect(byOat?.id, user.id);
        expect(auth.currentAccessToken?.id, made.id);
        expect(auth.tokenCan('a:b'), true);
        expect(auth.tokenCan('c:d'), false);

        // a JWT is no access token, and the other way round
        expect(await Auth(guard: 'tokens').userFromToken<User>(jwt), isNull);
        expect(
          await Auth(guard: 'api').userFromToken<User>(made.value),
          isNull,
        );
      },
    );

    test('a broken access token is 401, never a 500', () async {
      AccessToken made = await Auth(guard: 'tokens')
          .createAccessToken(user, name: 'shape');
      String value = made.value!;
      String secret = value.split('.').last;
      for (String token in <String>[
        'oat_',
        'oat_.',
        'oat_abc',
        'oat_${made.id}.',
        'oat_${made.id}',
        'oat_${made.id}.${secret}x',
        'oat_${made.id}.${secret.substring(1)}',
        'oat_-1.$secret',
        'oat_99999999999999999999.$secret',
        'oat_${made.id}.${'a' * 8000}',
        value.toUpperCase(),
      ]) {
        expect(
          await status('/api/tokens', 'Bearer $token'),
          401,
          reason: token.length > 80 ? 'long token' : token,
        );
      }
      expect(await status('/api/tokens', 'Bearer $value'), 200);
    });

    test(
      'an expired access token is 401 and pruneExpired removes it',
      () async {
        AccessToken made = await Auth(guard: 'tokens')
            .createAccessToken(user, name: 'old');
        String value = made.value!;
        expect(await status('/api/tokens', 'Bearer $value'), 200);

        await QueryBuilder.table('auth_access_tokens')
            .where('id', made.id)
            .update(<String, dynamic>{
              'expires_at': DateTime.now().toUtc().subtract(Duration(days: 1)),
            });
        expect(await status('/api/tokens', 'Bearer $value'), 401);

        // AuthMiddleware(optional: true): the expired token is a guest
        http.Response guest = await api.get(
          '/core/e2e/token-whoami',
          headers: <String, String>{'Authorization': 'Bearer $value'},
        );
        expect(guest.statusCode, 200);
        expect(api.json(guest), <String, dynamic>{'id': null});

        int pruned = await Auth(guard: 'tokens').pruneExpiredAccessTokens();
        expect(pruned, greaterThanOrEqualTo(1));
        List<Map<String, dynamic>> rows = await QueryBuilder.table(
          'auth_access_tokens',
        ).where('id', made.id).get();
        expect(rows, isEmpty);
      },
    );

    test('a token name: 255 is fine, 256 throws and writes nothing', () async {
      Auth auth = Auth(guard: 'tokens');
      int before = (await auth.accessTokens(user)).length;
      AccessToken ok = await auth.createAccessToken(user, name: 'n' * 255);
      expect(ok.name, 'n' * 255);
      await expectLater(
        auth.createAccessToken(user, name: 'n' * 256),
        throwsArgumentError,
      );
      // unicode names are kept as they are
      AccessToken uni = await auth.createAccessToken(user, name: 'ключ 🔑');
      List<AccessToken> all = await auth.accessTokens(user);
      expect(all.length, before + 2);
      expect(all.map((AccessToken t) => t.name), contains('ключ 🔑'));
      await auth.revokeAccessToken(user, ok.id);
      await auth.revokeAccessToken(user, uni.id);
      // a wrong id is false, not an error
      expect(await auth.revokeAccessToken(user, 999999999), false);
    });

    test('revokeAllAccessTokens: every token of the user stops', () async {
      Auth auth = Auth(guard: 'tokens');
      String a = (await auth.createAccessToken(user, name: 'a')).value!;
      String b = await login(path: '/api/tokens/login');
      expect(await status('/api/tokens', 'Bearer $a'), 200);
      expect(await status('/api/tokens', 'Bearer $b'), 200);
      expect(await auth.revokeAllAccessTokens(user), greaterThanOrEqualTo(2));
      expect(await status('/api/tokens', 'Bearer $a'), 401);
      expect(await status('/api/tokens', 'Bearer $b'), 401);
      // the JWT guard is not touched
      expect(await status('/api/auth/me', 'Bearer $jwt'), 200);
    });

    test('AuthMiddleware(optional) on the tokens guard', () async {
      String token = (await Auth(
        guard: 'tokens',
      ).createAccessToken(user, name: 'who')).value!;
      http.Response me = await api.get(
        '/core/e2e/token-whoami',
        headers: <String, String>{'Authorization': 'Bearer $token'},
      );
      expect('${api.json(me)['id']}', '${user.id}');
      // a JWT on the tokens guard is a guest, not a 401
      http.Response other = await api.get(
        '/core/e2e/token-whoami',
        headers: <String, String>{'Authorization': 'Bearer $jwt'},
      );
      expect(other.statusCode, 200);
      expect(api.json(other), <String, dynamic>{'id': null});
    });

    test('GuestMiddleware(redirectTo:) sends a user away', () async {
      http.Response guest = await api.send('GET', '/core/e2e/guest-redirect');
      expect(guest.statusCode, 200);
      expect(api.json(guest), <String, dynamic>{'page': 'guest'});

      http.Response user = await api.send(
        'GET',
        '/core/e2e/guest-redirect',
        headers: <String, String>{'Authorization': 'Bearer $jwt'},
      );
      expect(user.statusCode, 302);
      expect(user.headers['location'], '/core/new');
    });

    test('Auth().id() and guest() with no request', () async {
      Auth auth = Auth();
      expect(auth.guest(), true);
      expect(auth.id(), isNull);
      await auth.userFromToken<User>(jwt);
      expect(auth.guest(), false);
      expect('${auth.id()}', '${user.id}');
    });

    test('a JWT still works after a failed login of the same user', () async {
      http.Response bad = await api.post('/api/auth/login', <String, dynamic>{
        'email': 'core310@mail.com',
        'password': 'wrong',
      });
      expect(bad.statusCode, 401);
      expect(await status('/api/auth/me', 'Bearer $jwt'), 200);
    });
  });

  group('3.1.0 core e2e: Command and dox auth:tokens-table', () {
    late Directory dir;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('dox_e2e_migration_');
    });

    tearDown(() async {
      exitCode = 0;
      await dir.delete(recursive: true);
    });

    List<File> files() {
      return dir.listSync().whereType<File>().toList();
    }

    test('dox_auth has auth:tokens-table in its commands list', () {
      Command command = commands.singleWhere(
        (Command c) => c.name == 'auth:tokens-table',
      );
      expect(command, isA<TokensTableCommand>());
      expect(command.description, isNotEmpty);
      expect(command.usage, startsWith('auth:tokens-table'));
    });

    test('it writes one migration, a second run writes none', () async {
      TokensTableCommand cmd = TokensTableCommand(
        migrations: MigrationFile(folder: dir),
      );
      await cmd.run(<String>['--users-table=users']);
      expect(exitCode, 0);
      List<File> made = files();
      expect(made, hasLength(1));
      String name = made.single.uri.pathSegments.last;
      expect(
        name,
        matches(
          RegExp(r'^\d{4}_\d{2}_\d{2}_\d{6}_create_access_tokens_table\.dart$'),
        ),
      );
      String source = made.single.readAsStringSync();
      expect(source, contains('AccessTokenTables.up'));
      expect(source, contains('AccessTokenTables.down'));
      expect(source, contains("usersTable: 'users'"));

      await cmd.run(<String>[]);
      expect(exitCode, 1);
      expect(files(), hasLength(1));
    });

    test('bad flags write nothing and exit with 1', () async {
      for (List<String> args in <List<String>>[
        <String>['--uuid', '--uuid'],
        <String>['--uuid', '--string-ids'],
        <String>['--nope'],
        <String>['--users-table=users;drop'],
        <String>['--users-table='],
        <String>['--users-table=tåble'],
      ]) {
        exitCode = 0;
        await TokensTableCommand(migrations: MigrationFile(folder: dir))
            .run(args);
        expect(exitCode, 1, reason: '$args');
        expect(files(), isEmpty, reason: '$args');
      }
    });

    test('--uuid and --string-ids reach the migration', () async {
      await TokensTableCommand(migrations: MigrationFile(folder: dir))
          .run(<String>['--uuid']);
      expect(files().single.readAsStringSync(), contains('uuidIds: true'));
    });

    test('MigrationFile: names sort after the newest, no twin', () {
      MigrationFile migrations = MigrationFile(folder: dir);
      File('${dir.path}/2999_01_01_000000_create_x.dart').writeAsStringSync('');
      String? path = migrations.create('create_y', '// y');
      expect(path, isNotNull);
      expect(path, endsWith('2999_01_01_000001_create_y.dart'));
      expect(migrations.exists('create_y'), true);
      expect(migrations.exists('create_z'), false);
      expect(migrations.create('create_y', '// again'), isNull);
      expect(File(path!).readAsStringSync(), '// y');
    });
  });

  group('3.1.0 core e2e: cache file store prune_every', () {
    late Directory dir;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('dox_e2e_cache_');
    });

    tearDown(() async {
      await dir.delete(recursive: true);
    });

    /// a file store with these extra options, like in config/cache.dart
    CacheStore fileStore(Map<String, dynamic> options) {
      return CacheManager(
        CacheConfig(
          defaultStore: 'f',
          stores: <String, Map<String, dynamic>>{
            'f': <String, dynamic>{
              'driver': 'file',
              'path': dir.path,
              ...options,
            },
          },
        ),
      ).store('f');
    }

    /// the file of [key]. `FileDriver` is not exported by dox_core.
    File fileOf(CacheStore store, String key) {
      dynamic driver = store.driver;
      return driver.fileFor(key) as File;
    }

    /// put [key] with a short ttl and wait until it is expired
    Future<void> putExpired(CacheStore store, String key) async {
      await store.put(key, 'x', Duration(milliseconds: 30));
      for (int i = 0; i < 40 && await store.get(key) != null; i++) {
        await Future<void>.delayed(Duration(milliseconds: 20));
      }
      expect(await store.get(key), isNull);
    }

    test('prune_every runs prune() by itself after N writes', () async {
      CacheStore store = fileStore(<String, dynamic>{'prune_every': 3});
      await store.put('keep', 'y');
      await putExpired(store, 'old');
      File old = fileOf(store, 'old');
      File broken = fileOf(store, 'broken');
      await broken.writeAsString('not json');
      expect(await old.exists(), true);

      await store.put('third', 'z'); // the 3rd write
      bool gone = false;
      for (int i = 0; i < 40 && !gone; i++) {
        gone = !await old.exists() && !await broken.exists();
        if (!gone) await Future<void>.delayed(Duration(milliseconds: 50));
      }
      expect(gone, true, reason: 'expired and broken files are deleted');
      expect(await store.get('keep'), 'y');
      expect(await store.get('third'), 'z');
    });

    test('prune_every off (the default): expired files stay', () async {
      CacheStore store = fileStore(<String, dynamic>{});
      await putExpired(store, 'old');
      for (int i = 0; i < 5; i++) {
        await store.put('k$i', i);
      }
      await Future<void>.delayed(Duration(milliseconds: 100));
      expect(await fileOf(store, 'old').exists(), true);
      dynamic driver = store.driver;
      expect(await driver.prune(), 1);
      expect(await fileOf(store, 'old').exists(), false);
    });

    test('the Cache facade still works on every store', () async {
      for (String store in AppConstants.cacheStores) {
        Cache cache = Cache().store(store);
        String key = 'core310:${'ü' * 3}:${'k' * 200}';
        await cache.put(key, <String, dynamic>{'a': 1, 'b': 'é'});
        expect(await cache.get(key), <String, dynamic>{'a': 1, 'b': 'é'});
        expect(await cache.add(key, 'other'), false, reason: store);
        await cache.forget(key);
        expect(await cache.has(key), false, reason: store);
        expect(await cache.get('core310:missing'), isNull, reason: store);
      }
    });
  });

  group('3.1.0 core e2e: dox_socketio edges', () {
    String jwt = '';

    setUpAll(() async {
      http.Response res = await api.post('/api/auth/login', <String, dynamic>{
        'email': 'core310@mail.com',
        'password': 'secret123',
      });
      expect(res.statusCode, 200, reason: res.body);
      jwt = api.json(res)['token'];
    });

    Future<String?> connectError({
      Map<String, String>? auth,
      Map<String, String>? headers,
    }) async {
      SioClient client = await SioClient.connect(
        api.sioUri,
        nsp: '/secure',
        auth: auth,
        headers: headers,
        expectError: true,
      );
      String? error = client.connectError;
      if (error == null) {
        await client.next('hello');
      }
      await client.close();
      return error;
    }

    test('a BEARER header in capitals works', () async {
      expect(
        await connectError(
          headers: <String, String>{'Authorization': 'BEARER $jwt'},
        ),
        isNull,
      );
    });

    test('auth.token wins over the Authorization header', () async {
      expect(
        await connectError(
          auth: <String, String>{'token': 'bad'},
          headers: <String, String>{'Authorization': 'Bearer $jwt'},
        ),
        'Unauthorized',
      );
    });

    test('bad tokens are Unauthorized and the server goes on', () async {
      List<String> parts = jwt.split('.');
      String none = b64(jsonEncode(<String, String>{'alg': 'none'}));
      String expired =
          JwtAuthDriver(
            secret: SecretKey(env.appKey),
            expiresIn: Duration(hours: -2),
          ).createToken(
            (await User().where('email', 'core310@mail.com').getFirst())!
                .toJson(),
            'api',
          )!;
      AccessToken oat = await Auth(guard: 'tokens').createAccessToken(
        (await User().where('email', 'core310@mail.com').getFirst())!,
        name: 'socket edge',
      );
      for (String token in <String>[
        '$none.${parts[1]}.',
        '${parts[0]}.${parts[1]}.${parts[2]}x',
        expired,
        oat.value!,
        'é🙂',
        'x' * 20000,
      ]) {
        expect(
          await connectError(auth: <String, String>{'token': token}),
          'Unauthorized',
          reason: token.length > 80 ? 'long token' : token,
        );
      }
      // still serves a good login
      expect(await connectError(auth: <String, String>{'token': jwt}), isNull);
      await Auth(guard: 'tokens').revokeAccessToken(
        (await User().where('email', 'core310@mail.com').getFirst())!,
        oat.id,
      );
    });

    test('a session cookie after logout is Unauthorized', () async {
      Browser browser = Browser(api);
      await browser.send('GET', '/ping', <String, String>{});
      await browser.send(
        'POST',
        '/web-auth/login',
        <String, String>{'Content-Type': 'application/json'},
        jsonEncode(<String, String>{
          'email': 'core310@mail.com',
          'password': 'secret123',
        }),
      );
      String cookie = cookieHeader(browser);
      Map<String, String> headers = <String, String>{
        'Cookie': cookie,
        'Origin': api.base,
      };
      expect(await connectError(headers: headers), isNull);

      await browser.send('POST', '/web-auth/logout', <String, String>{
        'Content-Type': 'application/json',
      }, '{}');
      expect(await connectError(headers: headers), 'Unauthorized');
    });

    test('/chat still connects and acks (3.0.2)', () async {
      SioClient client = await SioClient.connect(api.sioUri);
      expect(await client.emitWithAck('ping', null), 'pong');
      await client.close();
    });
  });

  group('3.1.0 core e2e: more than one isolate', () {
    Process? server;
    StringBuffer log = StringBuffer();
    late Api child;

    tearDownAll(() async {
      Process? p = server;
      if (p == null) return;
      p.kill();
      await p.exitCode.timeout(
        Duration(seconds: 10),
        onTimeout: () {
          p.kill(ProcessSignal.sigkill);
          return -1;
        },
      );
    });

    test('bin/e2e_isolates.dart starts with 3 isolates', () async {
      ServerSocket free = await ServerSocket.bind('127.0.0.1', 0);
      int port = free.port;
      await free.close();
      child = PortApi(port);
      Process p = await Process.start(
        'dart',
        <String>['run', 'bin/e2e_isolates.dart'],
        environment: <String, String>{
          'APP_PORT': '$port',
          'APP_URL': 'http://127.0.0.1:$port',
          'APP_TOTAL_ISOLATE': '3',
        },
      );
      server = p;
      p.stdout.transform(utf8.decoder).listen(log.write);
      p.stderr.transform(utf8.decoder).listen(log.write);
      bool up = false;
      for (int i = 0; i < 1500 && !up; i++) {
        try {
          up = (await child.get('/ping')).statusCode == 200;
        } on Exception {
          await Future<void>.delayed(Duration(milliseconds: 100));
        }
      }
      expect(up, true, reason: log.toString());
      expect(log.toString(), contains('3 isolate'));
    }, timeout: Timeout(Duration(minutes: 4)));

    test('Route.staticFiles outside a Router works in every isolate', () async {
      // a new connection each time, so the isolates take turns
      for (int i = 0; i < 60; i++) {
        http.Response res = await child.get('/e2e-static/hello.txt');
        expect(res.statusCode, 200, reason: 'request $i');
        expect(res.body, 'hello static\n');
      }
    });

    test('40 requests at once: static files, routes and a JWT', () async {
      http.Response login = await child.post(
        '/api/auth/login',
        <String, dynamic>{'email': 'core310@mail.com', 'password': 'secret123'},
      );
      expect(login.statusCode, 200, reason: login.body);
      String jwt = child.json(login)['token'];
      Map<String, String> bearer = <String, String>{
        'Authorization': 'Bearer $jwt',
      };

      List<Future<http.Response>> calls = <Future<http.Response>>[];
      for (int i = 0; i < 10; i++) {
        calls.add(child.get('/e2e-static/hello.txt'));
        calls.add(child.get('/core/assets/hello.txt'));
        calls.add(child.get('/core/e2e/files/f$i'));
        calls.add(child.get('/api/auth/me', headers: bearer));
      }
      List<http.Response> all = await Future.wait(calls);
      for (int i = 0; i < all.length; i++) {
        expect(all[i].statusCode, 200, reason: 'call $i: ${all[i].body}');
      }
      expect(all[2].body, '{"name":"f0"}');
      expect(child.json(all[3])['email'], 'core310@mail.com');
    });

    test('a JWT logout stops the token in every isolate', () async {
      Future<String> login() async {
        http.Response res = await child.post(
          '/api/auth/login',
          <String, dynamic>{
            'email': 'core310@mail.com',
            'password': 'secret123',
          },
        );
        return child.json(res)['token'];
      }

      String gone = await login();
      String kept = await login();
      http.Response out = await http.post(
        child.uri('/api/auth/logout'),
        headers: <String, String>{'Authorization': 'Bearer $gone'},
      );
      expect(out.statusCode, 200, reason: out.body);
      for (int i = 0; i < 15; i++) {
        http.Response a = await child.get(
          '/api/auth/me',
          headers: <String, String>{'Authorization': 'Bearer $gone'},
        );
        expect(a.statusCode, 401, reason: 'revoked, request $i');
        http.Response b = await child.get(
          '/api/auth/me',
          headers: <String, String>{'Authorization': 'Bearer $kept'},
        );
        expect(b.statusCode, 200, reason: 'kept, request $i');
      }
    });

    test('a session login and logout count in every isolate', () async {
      Browser browser = Browser(child);
      await browser.send('GET', '/ping', <String, String>{});
      http.Response res = await browser.send(
        'POST',
        '/web-auth/login',
        <String, String>{'Content-Type': 'application/json'},
        jsonEncode(<String, String>{
          'email': 'core310@mail.com',
          'password': 'secret123',
        }),
      );
      expect(res.statusCode, 200, reason: res.body);
      for (int i = 0; i < 15; i++) {
        http.Response me = await browser.send(
          'GET',
          '/web-auth/me',
          <String, String>{},
        );
        expect(me.statusCode, 200, reason: 'request $i');
      }
      String old = cookieHeader(browser);
      await browser.send('POST', '/web-auth/logout', <String, String>{
        'Content-Type': 'application/json',
      }, '{}');
      for (int i = 0; i < 15; i++) {
        http.Response me = await child.get(
          '/web-auth/me',
          headers: <String, String>{'Cookie': old},
        );
        expect(me.statusCode, 401, reason: 'old cookie, request $i');
      }
    });

    test('a revoked access token stops in every isolate', () async {
      http.Response login = await child.post(
        '/api/tokens/login',
        <String, dynamic>{'email': 'core310@mail.com', 'password': 'secret123'},
      );
      String token = child.json(login)['token'];
      Map<String, String> bearer = <String, String>{
        'Authorization': 'Bearer $token',
      };
      for (int i = 0; i < 6; i++) {
        expect(
          (await child.get('/api/tokens', headers: bearer)).statusCode,
          200,
        );
      }
      http.Response out = await http.delete(
        child.uri('/api/tokens/current'),
        headers: bearer,
      );
      expect(child.json(out), <String, dynamic>{'revoked': true});
      for (int i = 0; i < 15; i++) {
        expect(
          (await child.get('/api/tokens', headers: bearer)).statusCode,
          401,
          reason: 'request $i',
        );
      }
    });
  });
}

/// [Api] on another port, for the second server.
class PortApi extends Api {
  PortApi(this.port);

  final int port;

  @override
  String get base => 'http://127.0.0.1:$port';
}

/// Send [request] as it is on a new socket, give the status line and
/// headers. For headers that package:http can not send (twice, odd).
Future<String> rawRequest(Api api, String request) async {
  Socket socket = await Socket.connect('127.0.0.1', Uri.parse(api.base).port);
  socket.write(request);
  String answer = await utf8.decoder
      .bind(socket)
      .join()
      .timeout(Duration(seconds: 5));
  socket.destroy();
  return answer.split('\r\n\r\n').first;
}

/// Part [n] of a JWT (0 header, 1 payload), not checked.
Map<String, dynamic> jwtPart(String token, int n) {
  String part = token.split('.')[n];
  return jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(part))));
}

/// base64url with no `=`, like a JWT part.
String b64(String text) {
  return base64Url.encode(utf8.encode(text)).replaceAll('=', '');
}
