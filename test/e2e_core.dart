import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'e2e_test.dart';

/// End to end checks for the features of the 3.1.0 release.
/// `main()` of e2e_test.dart calls this after its own groups, so both
/// files share one server and one database.
void coreTests(Api api) {
  group('3.1.0 dox_core: routes', () {
    test('Route.match: GET and POST work, PUT gets 405', () async {
      http.Response get = await api.get('/core/match');
      expect(api.json(get), <String, dynamic>{'method': 'GET'});
      http.Response post = await api.post('/core/match', <String, dynamic>{});
      expect(api.json(post), <String, dynamic>{'method': 'POST'});
      http.Response put = await api.put('/core/match', <String, dynamic>{});
      expect(put.statusCode, 405);
    });

    test('Route.any: five methods, CORS preflight still works', () async {
      for (String method in <String>['GET', 'POST', 'PUT', 'PATCH', 'DELETE']) {
        http.Response res = await api.send(method, '/core/any');
        expect(res.statusCode, 200, reason: method);
        expect(api.json(res)['method'], method);
      }
      http.Response options = await api.send(
        'OPTIONS',
        '/core/any',
        headers: <String, String>{
          'Origin': 'x.com',
          'Access-Control-Request-Method': 'PUT',
        },
      );
      expect(options.statusCode, 204);
      expect(options.headers['access-control-allow-origin'], '*');
    });

    test('Route.redirect gives 302, permanentRedirect gives 301', () async {
      http.Response old = await api.send('GET', '/core/old');
      expect(old.statusCode, 302);
      expect(old.headers['location'], '/core/new');
      http.Response moved = await api.send('POST', '/core/moved');
      expect(moved.statusCode, 301);
      expect(moved.headers['location'], '/core/new');
      expect((await api.get('/core/new')).body, 'new page');
    });

    test('.where: digits go to the id route, text to the next', () async {
      http.Response id = await api.get('/core/items/12');
      expect(api.json(id), <String, dynamic>{'by': 'id', 'id': 12});
      http.Response slug = await api.get('/core/items/blue-shoe');
      expect(api.json(slug), <String, dynamic>{
        'by': 'slug',
        'slug': 'blue-shoe',
      });
    });

    test('Route.fallback answers a GET with no route in its group', () async {
      http.Response res = await api.get('/core/nothing/here');
      expect(res.statusCode, 404);
      expect(api.json(res), <String, dynamic>{
        'message': 'no page at /core/nothing/here',
      });

      // not for POST, and not outside the /core group
      http.Response post = await api.post('/core/nothing', <String, dynamic>{});
      expect(post.statusCode, 404);
      expect(post.body, isNot(contains('no page at')));
      http.Response other = await api.get('/api/nothing-here');
      expect(other.body, isNot(contains('no page at')));
    });

    test(
      'MethodOverride: a form POST with _method reaches PUT and DELETE',
      () async {
        Future<http.Response> form(String path, String method) {
          return api.send(
            'POST',
            path,
            headers: <String, String>{
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: '_method=$method&name=x',
          );
        }

        expect(api.json(await form('/core/override', 'PUT')), <String, dynamic>{
          'method': 'PUT',
        });
        expect(
          api.json(await form('/core/override', 'delete'))['method'],
          'DELETE',
        );

        // JSON works too
        http.Response json = await api.post('/core/override', <String, dynamic>{
          '_method': 'PATCH',
        });
        expect(api.json(json)['method'], 'PATCH');

        // GET is not a method to change to: the POST stays a POST (405)
        http.Response get = await form('/core/override', 'GET');
        expect(get.statusCode, 405);

        // a path with no route for any method is a plain 404
        http.Response none = await form('/core/no-route-here', 'PUT');
        expect(none.statusCode, 404);
      },
    );

    test('Route.mount: whole path parts, longest prefix wins', () async {
      expect((await api.get('/core-mount')).body, 'outer /core-mount');
      expect((await api.get('/core-mount/a/b')).body, 'outer /core-mount/a/b');
      http.Response inner = await api.get('/core-mount/inner/x');
      expect(inner.body, 'inner /core-mount/inner/x');

      // `//` counts as one `/`
      expect((await api.get('/core-mount//inner/y')).body, startsWith('inner'));

      // not a mount: /core-mountain is a normal (unknown) path
      http.Response near = await api.get('/core-mountain');
      expect(near.statusCode, 404);
      expect(near.body, isNot(contains('outer')));
    });

    test('Route.mount(middleware: true) runs the global middleware', () async {
      http.Response inner = await api.get('/core-mount/inner/x');
      expect(inner.headers['x-app-name'], 'dox-test');
      http.Response outer = await api.get('/core-mount/x');
      expect(outer.headers['x-app-name'], isNull);
    });
  });

  group('3.1.0 dox_core: static files', () {
    String? etag;

    test('a file gets ETag, Last-Modified and its content type', () async {
      http.Response res = await api.get('/core/assets/hello.txt');
      expect(res.statusCode, 200);
      expect(res.body, 'hello static\n');
      expect(res.headers['content-type'], startsWith('text/plain'));
      expect(res.headers['last-modified'], isNotNull);
      etag = res.headers['etag'];
      expect(etag, startsWith('W/'));
    });

    test('If-None-Match gets 304 with no body, same content type', () async {
      http.Response res = await api.get(
        '/core/assets/hello.txt',
        headers: <String, String>{'If-None-Match': etag!},
      );
      expect(res.statusCode, 304);
      expect(res.body, isEmpty);
      expect(res.headers['content-type'], startsWith('text/plain'));
    });

    test('HEAD works, a Range gives 206', () async {
      http.Response head = await api.send('HEAD', '/core/assets/hello.txt');
      expect(head.statusCode, 200);
      expect(head.body, isEmpty);
      http.Response range = await api.get(
        '/core/assets/hello.txt',
        headers: <String, String>{'Range': 'bytes=0-4'},
      );
      expect(range.statusCode, 206);
      expect(range.body, 'hello');
    });

    test('.well-known is served, other dot names are not', () async {
      http.Response known = await api.get(
        '/core/assets/.well-known/security.txt',
      );
      expect(known.statusCode, 200);
      expect(known.body, contains('Contact:'));

      for (String path in <String>[
        '/core/assets/.secret',
        '/core/assets/.well-known/.hidden',
        '/core/assets/%2e%2e/%2e%2e/pubspec.yaml',
        '/core/assets/.well-known',
      ]) {
        http.Response res = await api.get(path);
        expect(res.statusCode, 404, reason: path);
        expect(res.body, isNot(contains('SECRET')), reason: path);
        expect(res.body, isNot(startsWith('hidden')), reason: path);
      }
    });

    test('a route wins over a file with the same path', () async {
      http.Response res = await api.get('/core/assets/route.txt');
      expect(res.body, 'from the route');
    });
  });

  group('3.1.0 dox_core: request and response', () {
    test(
      'new request helpers: input dot keys, filled, exists, boolean',
      () async {
        http.Response res = await api.send(
          'POST',
          '/core/request/7?page=3',
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer abc.def',
          },
          body: jsonEncode(<String, dynamic>{
            'user': <String, dynamic>{'name': 'Ann'},
            'items': <dynamic>[
              <String, dynamic>{'id': 9},
            ],
            'name': 'x',
            'blank': '  ',
            'remember': 'on',
            'per_page': 'abc',
            'secret': 's',
          }),
        );
        expect(res.statusCode, 200, reason: res.body);
        Map<String, dynamic> body = api.json(res);
        expect(body['user_name'], 'Ann');
        expect(body['first_item'], 9);
        expect(body['city'], 'none');
        expect(body['filled_name'], true);
        expect(body['filled_blank'], false);
        expect(body['exists_blank'], true);
        expect(body['missing_other'], true);
        expect(body['except'], containsAll(<String>['name', 'blank']));
        expect(
          body['except'],
          isNot(anyOf(contains('user'), contains('items'), contains('secret'))),
        );
        expect(body['remember'], true);
        expect(body['page'], 3);
        expect(body['per_page'], 20);
        expect(body['bearer'], 'abc.def');
        expect(body['path'], '/core/request/7');
        expect(body['full_url'], '${api.base}/core/request/7?page=3');
        expect(body['path_is'], true);
        expect(body['path_is_other'], false);
        expect(body['route_is'], true);
      },
    );

    test(
      'res.header replaces a header in any case, withHeaders adds',
      () async {
        http.Response res = await api.get('/core/headers');
        // one Cache-Control, not the one of cache() plus a second one
        expect(res.headers['cache-control'], 'no-store');
        expect(res.headers['x-one'], 'one');
        expect(res.headers['x-two'], '2');
      },
    );

    test('withHeaders keeps the Content-Disposition of a download', () async {
      http.Response res = await api.get('/core/download');
      expect(res.body, 'file body');
      expect(
        res.headers['content-disposition'],
        'attachment; filename="report.txt"',
      );
      expect(res.headers['x-report'], 'yes');
    });

    test('reflash() as the first use of the session keeps the flash', () async {
      Browser browser = Browser(api);
      await browser.send('GET', '/core/flash/set', <String, String>{});
      await browser.send('GET', '/core/flash/keep', <String, String>{});
      http.Response read = await browser.send(
        'GET',
        '/core/flash/read',
        <String, String>{},
      );
      expect(api.json(read), <String, dynamic>{'note': 'kept'});
      read = await browser.send('GET', '/core/flash/read', <String, String>{});
      expect(api.json(read), <String, dynamic>{'note': null});
    });

    test(
      'WebSocket maxMessageSize: a bigger message closes with 1009',
      () async {
        WebSocket socket = await WebSocket.connect(
          'ws://127.0.0.1:${Uri.parse(api.base).port}/core/echo',
        );
        Completer<void> done = Completer<void>();
        List<dynamic> got = <dynamic>[];
        socket.listen(got.add, onDone: done.complete);

        socket.add('small');
        await Future<void>.delayed(Duration(milliseconds: 200));
        expect(got, <dynamic>['small']);

        socket.add('x' * 100);
        await done.future.timeout(Duration(seconds: 3));
        expect(socket.closeCode, 1009);
      },
    );
  });

  group('3.1.0 DTO rules', () {
    test('@RequiredIf: a company needs a company name', () async {
      http.Response person = await api.post('/core/contacts', <String, dynamic>{
        'account_type': 'person',
      });
      expect(person.statusCode, 200, reason: person.body);

      http.Response company = await api.post(
        '/core/contacts',
        <String, dynamic>{'account_type': 'company'},
      );
      expect(company.statusCode, 422);
      expect(api.json(company).keys, <String>['company_name']);

      http.Response ok = await api.post('/core/contacts', <String, dynamic>{
        'account_type': 'company',
        'company_name': 'Dox Ltd',
      });
      expect(api.json(ok)['company_name'], 'Dox Ltd');
    });

    test('@RequiredWith: a phone needs a country code', () async {
      http.Response res = await api.post('/core/contacts', <String, dynamic>{
        'account_type': 'person',
        'phone': '555 1234',
      });
      expect(res.statusCode, 422);
      expect(api.json(res).keys, <String>['country_code']);

      res = await api.post('/core/contacts', <String, dynamic>{
        'account_type': 'person',
        'phone': '555 1234',
        'country_code': '+95',
      });
      expect(res.statusCode, 200, reason: res.body);
      expect(api.json(res)['country_code'], '+95');
    });

    test('@MimeTypes, @MinSize and @Dimensions check an upload', () async {
      // 1x1 and under 100 bytes
      http.Response small = await api.uploadBytes(
        '/core/banner',
        'banner',
        Api.tinyPng,
        'tiny.png',
      );
      expect(small.statusCode, 422);
      expect(api.json(small).keys, <String>['banner']);

      // text with a .png name
      http.Response text = await api.uploadBytes(
        '/core/banner',
        'banner',
        List<int>.filled(200, 65),
        'fake.png',
      );
      expect(text.statusCode, 422);

      // a 4x3 PNG of 200 bytes
      http.Response ok = await api.uploadBytes(
        '/core/banner',
        'banner',
        pngOfSize(4, 3, 200),
        'banner.png',
      );
      expect(ok.statusCode, 200, reason: ok.body);
      expect(api.json(ok)['bytes'], 200);
    });
  });

  group('3.1.0 dox_auth', () {
    String coraId = '';

    Future<String> login(String email, {String guard = 'auth'}) async {
      http.Response res = await api.post(
        guard == 'tokens' ? '/api/tokens/login' : '/api/auth/login',
        <String, dynamic>{'email': email, 'password': 'secret123'},
      );
      expect(res.statusCode, 200, reason: res.body);
      return api.json(res)['token'];
    }

    test('a user and a JWT', () async {
      http.Response res = await api.post(
        '/api/auth/register',
        <String, dynamic>{
          'name': 'Cora',
          'email': 'cora@mail.com',
          'password': 'secret123',
          'password_confirmation': 'secret123',
        },
      );
      expect(res.statusCode, 201, reason: res.body);
      coraId = '${api.json(res)['id']}';
      api.tokens['cora'] = await login('cora@mail.com');
    });

    test('"bearer" in lower case works', () async {
      http.Response res = await api.get(
        '/api/auth/me',
        headers: <String, String>{
          'Authorization': 'bearer ${api.tokens['cora']}',
        },
      );
      expect(res.statusCode, 200, reason: res.body);
      expect(api.json(res)['name'], 'Cora');
    });

    test('AuthMiddleware(optional: true) and req.auth?.id()', () async {
      http.Response guest = await api.get('/core/whoami');
      expect(api.json(guest), <String, dynamic>{
        'auth_set': false,
        'id': null,
        'guest': null,
        'name': null,
      });

      http.Response bad = await api.get(
        '/core/whoami',
        headers: <String, String>{'Authorization': 'Bearer not-a-jwt'},
      );
      expect(bad.statusCode, 200);
      expect(api.json(bad)['auth_set'], false);

      http.Response user = await api.get('/core/whoami', token: 'cora');
      Map<String, dynamic> body = api.json(user);
      expect('${body['id']}', coraId);
      expect(body['guest'], false);
      expect(body['name'], 'Cora');
    });

    test('GuestMiddleware: guests in, a logged in user gets 403', () async {
      http.Response guest = await api.get('/core/guest-only');
      expect(guest.statusCode, 200);
      http.Response user = await api.get('/core/guest-only', token: 'cora');
      expect(user.statusCode, 403);
      expect(api.json(user)['code'], 'already_logged_in');
    });

    test('JWT logout: the token stops at once, others still work', () async {
      api.tokens['cora2'] = await login('cora@mail.com');
      http.Response out = await api.post(
        '/api/auth/logout',
        <String, dynamic>{},
        token: 'cora2',
      );
      expect(out.statusCode, 200, reason: out.body);
      expect((await api.get('/api/auth/me', token: 'cora2')).statusCode, 401);
      expect((await api.get('/api/auth/me', token: 'cora')).statusCode, 200);
    });

    test('access token: login gives oat_..., it can do all', () async {
      api.tokens['cora_oat'] = await login('cora@mail.com', guard: 'tokens');
      expect(api.tokens['cora_oat'], startsWith('oat_'));
      http.Response res = await api.get(
        '/api/tokens/can/posts:delete',
        token: 'cora_oat',
      );
      expect(res.statusCode, 200, reason: res.body);
      expect(api.json(res)['can'], true);
    });

    test('access token with abilities: tokenCan checks them', () async {
      http.Response res = await api.post('/api/tokens', <String, dynamic>{
        'name': 'reader',
        'abilities': <String>['posts:read'],
      }, token: 'cora_oat');
      expect(res.statusCode, 201, reason: res.body);
      api.tokens['cora_reader'] = api.json(res)['token'];

      http.Response read = await api.get(
        '/api/tokens/can/posts:read',
        token: 'cora_reader',
      );
      expect(api.json(read)['can'], true);
      http.Response write = await api.get(
        '/api/tokens/can/posts:write',
        token: 'cora_reader',
      );
      expect(api.json(write)['can'], false);

      http.Response list = await api.get('/api/tokens', token: 'cora_reader');
      List<dynamic> tokens = api.json(list);
      expect(tokens.length, 2);
      expect(api.names(tokens), contains('reader'));
      expect(tokens.first.containsKey('hash'), false);
    });

    test('access token and JWT do not mix, a bad token gives 401', () async {
      expect((await api.get('/api/tokens', token: 'cora')).statusCode, 401);
      expect(
        (await api.get('/api/auth/me', token: 'cora_oat')).statusCode,
        401,
      );
      String oat = api.tokens['cora_oat']!;
      http.Response wrong = await api.get(
        '/api/tokens',
        headers: <String, String>{
          'Authorization': 'Bearer ${oat.substring(0, oat.length - 2)}xx',
        },
      );
      expect(wrong.statusCode, 401);
    });

    test('revoke the current token, then revoke one by id', () async {
      http.Response res = await api.delete(
        '/api/tokens/current',
        token: 'cora_reader',
      );
      expect(api.json(res), <String, dynamic>{'revoked': true});
      expect(
        (await api.get('/api/tokens', token: 'cora_reader')).statusCode,
        401,
      );

      List<dynamic> left = api.json(
        await api.get('/api/tokens', token: 'cora_oat'),
      );
      expect(left.length, 1);
      res = await api.delete(
        '/api/tokens/${left.first['id']}',
        token: 'cora_oat',
      );
      expect(api.json(res), <String, dynamic>{'revoked': true});
      expect((await api.get('/api/tokens', token: 'cora_oat')).statusCode, 401);
    });

    test('login throttle: the 6th try in a minute gets 429', () async {
      Map<String, dynamic> wrong = <String, dynamic>{
        'email': 'throttle@mail.com',
        'password': 'wrong',
      };
      for (int i = 0; i < 5; i++) {
        http.Response res = await api.post('/api/auth/login', wrong);
        expect(res.statusCode, 401, reason: 'try ${i + 1}');
      }
      http.Response res = await api.post('/api/auth/login', wrong);
      expect(res.statusCode, 429, reason: res.body);

      // another account is not locked
      expect(await login('cora@mail.com'), isA<String>());
    });
  });

  group('3.1.0 dox_socketio: SocketAuth', () {
    Map<String, String> sameHost() {
      return <String, String>{'Origin': api.base};
    }

    test('a JWT in auth.token logs the socket in', () async {
      SioClient client = await SioClient.connect(
        api.sioUri,
        nsp: '/secure',
        auth: <String, String>{'token': api.tokens['cora']!},
      );
      expect((await client.next('hello'))['name'], 'Cora');
      await client.close();
    });

    test('a "bearer" header in lower case works too', () async {
      SioClient client = await SioClient.connect(
        api.sioUri,
        nsp: '/secure',
        headers: <String, String>{
          'Authorization': 'bearer ${api.tokens['cora']}',
        },
      );
      expect((await client.next('hello'))['name'], 'Cora');
      await client.close();
    });

    test('no login, a bad or a revoked token: Unauthorized', () async {
      for (Map<String, String> auth in <Map<String, String>>[
        <String, String>{},
        <String, String>{'token': 'bad'},
        <String, String>{'token': api.tokens['cora2']!},
      ]) {
        SioClient client = await SioClient.connect(
          api.sioUri,
          nsp: '/secure',
          auth: auth,
          expectError: true,
        );
        expect(client.connectError, 'Unauthorized', reason: '$auth');
        await client.close();
      }
    });

    test('the session cookie of the web login logs the socket in', () async {
      Browser browser = Browser(api);
      await browser.send('GET', '/ping', <String, String>{});
      http.Response res = await browser.send(
        'POST',
        '/web-auth/login',
        <String, String>{'Content-Type': 'application/json'},
        jsonEncode(<String, String>{
          'email': 'cora@mail.com',
          'password': 'secret123',
        }),
      );
      expect(res.statusCode, 200, reason: res.body);
      String cookie = cookieHeader(browser);

      SioClient client = await SioClient.connect(
        api.sioUri,
        nsp: '/secure',
        headers: <String, String>{'Cookie': cookie, ...sameHost()},
      );
      expect((await client.next('hello'))['name'], 'Cora');
      await client.close();

      // a changed cookie is no login
      SioClient changed = await SioClient.connect(
        api.sioUri,
        nsp: '/secure',
        headers: <String, String>{'Cookie': '${cookie}x'},
        expectError: true,
      );
      expect(changed.connectError, 'Unauthorized');
      await changed.close();
    });

    test('allowedOrigins: another site can not open a socket', () async {
      await expectLater(
        WebSocket.connect(
          api.sioUri.toString(),
          headers: <String, String>{'Origin': 'https://evil.example'},
        ),
        throwsA(isA<WebSocketException>()),
      );
      SioClient ok = await SioClient.connect(api.sioUri, headers: sameHost());
      expect(await ok.emitWithAck('ping', null), 'pong');
      await ok.close();
    });
  });

  group('3.1.0 dox_view, dox_inertia, dox_openapi', () {
    /// Like the dox_inertia group of e2e_test.dart: the Vite dev server
    /// url in public/hot, so the pages need no `npm run build`.
    File hot = File('public/hot');
    bool madeHot = false;

    setUpAll(() async {
      if (!await hot.exists()) {
        await hot.writeAsString('http://localhost:5173');
        madeHot = true;
      }
    });

    tearDownAll(() async {
      if (madeHot) await hot.delete();
    });

    test('dox_view: a form with _method=DELETE and _token works', () async {
      Browser browser = Browser(api);
      http.Response page = await browser.send(
        'GET',
        '/views',
        <String, String>{},
      );
      String token = RegExp(r'name="_token" value="([^"]+)"')
          .firstMatch(page.body)![1]!;

      /// like a browser form: the cookies and the fields, no XSRF header
      Future<http.Response> form(Map<String, String> fields) {
        return api.send(
          'POST',
          '/views/notes/999',
          headers: <String, String>{
            'Content-Type': 'application/x-www-form-urlencoded',
            'Cookie': cookieHeader(browser),
          },
          body: Uri(queryParameters: fields).query,
        );
      }

      http.Response noToken = await form(<String, String>{'_method': 'DELETE'});
      expect(noToken.statusCode, 419);

      http.Response res = await form(<String, String>{
        '_method': 'DELETE',
        '_token': token,
      });
      expect(res.statusCode, 302, reason: res.body);
      expect(res.headers['location'], '/views');
    });

    test('dox_view: errors.email prints nothing with no session', () async {
      http.Response res = await api.get('/core/plain-view');
      expect(res.statusCode, 200, reason: res.body);
      expect(res.body, contains('Hello Dox'));
      expect(res.body, contains('<p class="error"></p>'));
    });

    test('dox_inertia: auth.user is a nested function prop', () async {
      http.Response html = await api.get('/inertia/notes');
      expect(html.statusCode, 200, reason: html.body);
      String page = RegExp(
        r'data-page="app" type="application/json">(.*?)</script>',
      ).firstMatch(html.body)![1]!;
      Map<String, dynamic> props = jsonDecode(page)['props'];
      expect(props['auth'], <String, dynamic>{'user': null});
    });

    test('dox_inertia: the flash is kept over a 409', () async {
      Browser browser = Browser(api);
      http.Response html = await browser.send(
        'GET',
        '/inertia/notes',
        <String, String>{},
      );
      String version =
          jsonDecode(
            RegExp(r'data-page="app" type="application/json">(.*?)</script>')
                .firstMatch(html.body)![1]!,
          )['version'] ??
          '';
      Map<String, String> headers(String v) {
        return <String, String>{
          'X-Inertia': 'true',
          'X-Inertia-Version': v,
          'Content-Type': 'application/json',
        };
      }

      http.Response post = await browser.send(
        'POST',
        '/inertia/notes',
        headers(version),
        jsonEncode(<String, String>{'text': 'kept over a deploy'}),
      );
      expect(post.statusCode, 302, reason: post.body);

      // a new deploy: the client has an old version
      http.Response stale = await browser.send(
        'GET',
        '/inertia/notes',
        headers('old'),
      );
      expect(stale.statusCode, 409);

      http.Response next = await browser.send(
        'GET',
        '/inertia/notes',
        headers(version),
      );
      expect(api.json(next)['flash'], <String, dynamic>{
        'message': 'Note saved',
      });
    });

    test(
      'an optional route param {name?} matches with and without it',
      () async {
        expect(api.json(await api.get('/api/greet')), <String, dynamic>{
          'hello': 'guest',
        });
        expect(api.json(await api.get('/api/greet/Ann')), <String, dynamic>{
          'hello': 'Ann',
        });
      },
    );

    test(
      'dox_openapi: {name?} gives two paths',
      () async {
        Map<String, dynamic> doc = api.json(await api.get('/openapi.json'));
        Map<String, dynamic> paths = doc['paths'];
        expect(
          paths.keys,
          containsAll(<String>['/api/greet', '/api/greet/{name}']),
        );
        expect(paths['/api/greet'].toString(), isNot(contains('{name}')));
      },
    );
  });
}

/// The cookies of [browser] as one `Cookie` header.
String cookieHeader(Browser browser) {
  List<String> pairs = <String>[];
  for (MapEntry<String, String> c in browser.cookies.entries) {
    pairs.add('${c.key}=${c.value}');
  }
  return pairs.join('; ');
}

/// A PNG header with [width] x [height] in its IHDR chunk, padded with
/// zero bytes to [bytes] long. Enough for the file type and size checks.
List<int> pngOfSize(int width, int height, int bytes) {
  List<int> head = <int>[
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // signature
    0, 0, 0, 13, 0x49, 0x48, 0x44, 0x52, // IHDR, 13 bytes
    ..._be32(width),
    ..._be32(height),
    8, 6, 0, 0, 0, // bit depth, color type, ...
  ];
  return <int>[...head, ...List<int>.filled(bytes - head.length, 0)];
}

List<int> _be32(int n) {
  return <int>[n >> 24 & 255, n >> 16 & 255, n >> 8 & 255, n & 255];
}
