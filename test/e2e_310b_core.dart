import 'dart:convert';

import 'package:dox_auth/dox_auth.dart';
import 'package:dox_core/dox_core.dart';
import 'package:dox_core/http/http_static_handler.dart' show StaticFolder;
import 'package:dox_openapi/dox_openapi.dart';
import 'package:dox_test/app/models/user/user.model.dart';
import 'package:dox_test/routes/e2e_core_b.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'e2e_test.dart' show Api, Browser;

/// 3.1.0 round 3: dox_core (dox#334, dox#335), dox_openapi (#4) and
/// dox_auth (#16). The routes are in lib/routes/e2e_core_b.dart
/// (/core/e2eb/...). `main()` of e2e_test.dart calls this.
void core310bTests(Api api) {
  group('3.1.0 core b: MethodOverride(header: true)', () {
    Future<http.Response> post(String path, {String? header, String? field}) {
      return api.send(
        'POST',
        path,
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
          'X-HTTP-Method-Override': ?header,
        },
        body: field == null ? '' : '_method=$field',
      );
    }

    test('off by default: the header is not read', () async {
      // the app has `const MethodOverride()`
      http.Response res = await post('/core/override', header: 'PUT');
      expect(res.statusCode, 405);

      // `_method` still works, and the header does not win over it
      http.Response field = await post(
        '/core/override',
        header: 'PUT',
        field: 'DELETE',
      );
      expect(api.json(field), <String, dynamic>{'method': 'DELETE'});
    });

    test('on: the header changes a POST, and wins over _method', () async {
      await withConfig(
        globalMiddleware: <dynamic>[
          ...Dox().config.globalMiddleware.where(
            (dynamic m) => m is! MethodOverride,
          ),
          const MethodOverride(header: true),
        ],
        body: () async {
          for (String method in <String>['PUT', 'patch', 'Delete']) {
            http.Response res = await post('/core/override', header: method);
            expect(res.statusCode, 200, reason: method);
            expect(api.json(res)['method'], method.toUpperCase());
          }

          http.Response both = await post(
            '/core/override',
            header: 'PATCH',
            field: 'DELETE',
          );
          expect(api.json(both)['method'], 'PATCH');

          // a header that is not PUT, PATCH or DELETE: `_method` is used
          for (String bad in <String>['GET', 'POST', 'TRACE', 'x', '']) {
            http.Response res = await post(
              '/core/override',
              header: bad,
              field: 'PUT',
            );
            expect(api.json(res)['method'], 'PUT', reason: bad);
          }
          http.Response none = await post('/core/override', header: 'GET');
          expect(none.statusCode, 405);

          // no route for the method: 405 that names it
          http.Response match = await post('/core/match', header: 'PUT');
          expect(match.statusCode, 405);
          expect(api.json(match)['message'], contains('PUT'));

          // a GET is never changed
          http.Response get = await api.send(
            'GET',
            '/core/match',
            headers: <String, String>{'X-HTTP-Method-Override': 'PUT'},
          );
          expect(api.json(get), <String, dynamic>{'method': 'GET'});

          // a JSON body works too
          http.Response json = await api.send(
            'POST',
            '/core/override',
            headers: <String, String>{
              'Content-Type': 'application/json',
              'X-HTTP-Method-Override': 'DELETE',
            },
            body: '{"name": "x"}',
          );
          expect(api.json(json)['method'], 'DELETE');
        },
      );

      // back to the app config: off again
      http.Response off = await post('/core/override', header: 'PUT');
      expect(off.statusCode, 405);
    });
  });

  group('3.1.0 core b: Hash and Crypt', () {
    test('Hash.check is Hash.verify', () {
      String hash = Hash.make('secret123', rounds: 4);
      expect(Hash.check('secret123', hash), true);
      expect(Hash.check('secret124', hash), false);
      expect(Hash.check('', hash), false);
      expect(Hash.check('secret123', hash), Hash.verify('secret123', hash));
    });

    test('encryptString and decryptString: a round trip', () {
      for (String text in <String>['card-1234', '', 'ü🙂 ' * 500]) {
        String secret = Crypt.encryptString(text);
        expect(secret, isNot(contains(text.isEmpty ? '#' : text)));
        expect(Crypt.decryptString(secret), text);
      }
      // a new IV each time
      expect(Crypt.encryptString('a'), isNot(Crypt.encryptString('a')));
      // the same text as AESEncryptor with the APP_KEY
      String key = Dox().config.appKey;
      expect(AESEncryptor.decode(Crypt.encryptString('same'), key), 'same');
      expect(Crypt.decryptString(AESEncryptor.encode('same', key)), 'same');
    });

    test('encrypt and decrypt keep JSON values', () {
      for (Object? value in <Object?>[
        <String, dynamic>{
          'a': 1,
          'b': <dynamic>[true, null, 'x'],
        },
        <dynamic>[1, 2.5, 'three'],
        42,
        'text',
        null,
        false,
      ]) {
        expect(Crypt.decrypt(Crypt.encrypt(value)), value);
      }
    });

    test('a changed or wrong value throws DecryptException', () {
      String secret = Crypt.encryptString('card-1234');
      String flipped =
          secret.substring(0, 20) +
          (secret[20] == 'A' ? 'B' : 'A') +
          secret.substring(21);
      for (String bad in <String>[
        flipped,
        secret.substring(1),
        '${secret}xx',
        '',
        'not base64 !',
        AESEncryptor.encode('card-1234', 'another-key-that-is-long-enough-123'),
      ]) {
        expect(
          () => Crypt.decryptString(bad),
          throwsA(isA<DecryptException>()),
          reason: bad,
        );
        expect(
          () => Crypt.decrypt(bad),
          throwsA(isA<DecryptException>()),
          reason: bad,
        );
      }
    });

    test('a value of an old key in previousKeys still decrypts', () async {
      String oldKey = 'old-app-key-0123456789abcdef0123456789';
      String text = AESEncryptor.encode('from the old key', oldKey);
      String json = AESEncryptor.encode('{"n": 1}', oldKey);
      expect(() => Crypt.decryptString(text), throwsA(isA<DecryptException>()));

      await withConfig(
        previousKeys: <String>[oldKey],
        body: () async {
          expect(Crypt.decryptString(text), 'from the old key');
          expect(Crypt.decrypt(json), <String, dynamic>{'n': 1});
          // new values use the APP_KEY, not the old key
          String fresh = Crypt.encryptString('new');
          expect(
            () => AESEncryptor.decode(fresh, oldKey),
            throwsA(isA<DecryptException>()),
          );
        },
      );
      // the old key is gone again
      expect(() => Crypt.decryptString(text), throwsA(isA<DecryptException>()));
    });

    test('decrypt of a plain text value throws DecryptException', () {
      // dox#335: was a FormatException (500)
      for (String text in <String>['plain text', '', '{broken', 'NaN']) {
        expect(
          () => Crypt.decrypt(Crypt.encryptString(text)),
          throwsA(isA<DecryptException>()),
          reason: text,
        );
      }
      // JSON text from encryptString is fine
      expect(Crypt.decrypt(Crypt.encryptString('"ok"')), 'ok');
      expect(Crypt.decrypt(Crypt.encryptString('7')), 7);
    });

    test('over HTTP: a bad value is 400 decrypt_failed, not 500', () async {
      Future<http.Response> send(String value) {
        return api.post('/core/e2eb/decrypt', <String, dynamic>{
          'value': value,
        });
      }

      http.Response ok = await send(Crypt.encrypt(<String, dynamic>{'id': 5}));
      expect(ok.statusCode, 200, reason: ok.body);
      expect(api.json(ok), <String, dynamic>{
        'value': <String, dynamic>{'id': 5},
      });

      String plain = Crypt.encryptString('not json');
      String changed = '${plain.substring(0, plain.length - 2)}AA';
      for (String bad in <String>[plain, changed, 'garbage', '']) {
        http.Response res = await send(bad);
        expect(res.statusCode, 400, reason: '$bad: ${res.body}');
        expect(api.json(res), <String, dynamic>{
          'code': 'decrypt_failed',
          'message': 'The encrypted value is not valid',
        });
      }
    });
  });

  group('3.1.0 core b: Cache many and putMany', () {
    test('putMany then many, a missing key is null', () async {
      await Cache().putMany(<String, Object?>{
        'e310b_core_a': 1,
        'e310b_core_b': 'two',
        'e310b_core_c': <String, dynamic>{
          'x': <int>[1, 2],
        },
      });
      Map<String, dynamic> values = await Cache().many(<String>[
        'e310b_core_a',
        'e310b_core_b',
        'e310b_core_c',
        'e310b_core_missing',
      ]);
      expect(values, <String, dynamic>{
        'e310b_core_a': 1,
        'e310b_core_b': 'two',
        'e310b_core_c': <String, dynamic>{
          'x': <int>[1, 2],
        },
        'e310b_core_missing': null,
      });
      // the keys are plain keys: get() reads them too
      expect(await Cache().get('e310b_core_b'), 'two');
    });

    test('many of only missing keys, and of no keys', () async {
      expect(
        await Cache().many(<String>['e310b_core_none1', 'e310b_core_none2']),
        <String, dynamic>{'e310b_core_none1': null, 'e310b_core_none2': null},
      );
      expect(await Cache().many(<String>[]), isEmpty);
    });

    test('putMany with a duration, and on another store', () async {
      await Cache().putMany(<String, Object?>{
        'e310b_core_d': 'd',
      }, duration: const Duration(minutes: 5));
      expect(await Cache().many(<String>['e310b_core_d']), <String, dynamic>{
        'e310b_core_d': 'd',
      });

      Cache redis = Cache().store('redis');
      await redis.putMany(<String, Object?>{
        'e310b_core_r1': 1,
        'e310b_core_r2': 'r',
      });
      expect(
        await redis.many(<String>['e310b_core_r1', 'e310b_core_r2', 'nope']),
        <String, dynamic>{
          'e310b_core_r1': 1,
          'e310b_core_r2': 'r',
          'nope': null,
        },
      );
      await Cache().forget('e310b_core_d');
      await redis.forget('e310b_core_r1');
      await redis.forget('e310b_core_r2');
    });
  });

  group('3.1.0 core b: routes', () {
    test('setStatics(Route().statics) keeps the list', () async {
      List<StaticFolder> before = List<StaticFolder>.of(Route().statics);
      expect(before, isNotEmpty);
      Route().setStatics(Route().statics);
      expect(Route().statics, before);
      http.Response res = await api.get('/core/assets/hello.txt');
      expect(res.statusCode, 200);
    });

    test('.where(".*") matches a decoded new line', () async {
      http.Response res = await api.get('/core/e2eb/docs/a%0Ab');
      expect(res.statusCode, 200, reason: res.body);
      expect(api.json(res), <String, dynamic>{'page': 'a\nb'});

      http.Response crlf = await api.get('/core/e2eb/docs/x%0D%0Ay');
      expect(api.json(crlf), <String, dynamic>{'page': 'x\r\ny'});

      // plain and %2F text still work (`.` matches a `/` too)
      expect(
        api.json(await api.get('/core/e2eb/docs/intro')),
        <String, dynamic>{'page': 'intro'},
      );
      expect(
        api.json(await api.get('/core/e2eb/docs/a%2Fb')),
        <String, dynamic>{'page': 'a/b'},
      );
    });

    test('the old .where("[^/]+") check is still strict', () async {
      // round 1 route: a decoded `/` does not match
      http.Response res = await api.get('/core/e2e/files/a%0Ab');
      expect(api.json(res), <String, dynamic>{'name': 'a\nb'});
      expect((await api.get('/core/e2e/files/a%2Fb')).statusCode, 404);
    });

    test('req.pathIs still works, also on a second call', () async {
      for (String path in <String>[
        '/core/e2eb/path-is/a',
        '/core/e2eb/path-is/a/',
        '/core//e2eb/path-is/a',
      ]) {
        http.Response res = await api.get(path);
        expect(api.json(res), <String, dynamic>{
          'exact': true,
          'slash': true,
          'wild': true,
          'other': false,
          'again': true,
        }, reason: path);
      }
      http.Response other = await api.get('/core/e2eb/path-is/b');
      expect(api.json(other), <String, dynamic>{
        'exact': false,
        'slash': false,
        'wild': true,
        'other': false,
        'again': false,
      });
    });

    test(
      'DTO @RequiredIf reads the converted value of a later field',
      () async {
        // ' PRO ' is 'pro' after @Trim and @Lowercase
        http.Response missing = await api.post(
          '/core/e2eb/plan',
          <String, dynamic>{'plan': ' PRO '},
        );
        expect(missing.statusCode, 422, reason: missing.body);
        expect(api.json(missing).keys, <String>['card']);

        http.Response ok = await api.post('/core/e2eb/plan', <String, dynamic>{
          'plan': ' PRO ',
          'card': '4242',
        });
        expect(api.json(ok), <String, dynamic>{'plan': 'pro', 'card': '4242'});

        for (String plan in <String>['basic', ' Basic ', 'prof']) {
          http.Response res = await api.post(
            '/core/e2eb/plan',
            <String, dynamic>{'plan': plan},
          );
          expect(res.statusCode, 200, reason: '$plan: ${res.body}');
          expect(api.json(res)['card'], isNull);
        }

        // a blank card counts as missing
        http.Response blank = await api.post(
          '/core/e2eb/plan',
          <String, dynamic>{'plan': 'pro', 'card': '  '},
        );
        expect(blank.statusCode, 422);

        // no plan: only plan is required
        http.Response none = await api.post(
          '/core/e2eb/plan',
          <String, dynamic>{},
        );
        expect(api.json(none).keys, <String>['plan']);
      },
    );
  });

  group('3.1.0 core b: OpenAPI', () {
    /// the dox_core document of the /core/e2eb routes
    Map<String, dynamic> coreDoc() {
      OpenApiConfig config = OpenApiConfig(
        info: const Info(title: 'e2eb', version: '1'),
        include: <String>['/core/e2eb/*'],
      );
      return OpenApiDocument(config).build(Route().routes).toJson();
    }

    /// the dox_openapi `DoxRouteAdapter` document of the same routes
    Map<String, dynamic> adapterDoc() {
      ApiDoc docs = ApiDoc();
      const DoxRouteAdapter().addTo(
        docs,
        Route().routes.where((dynamic r) => '${r.path}'.contains('core/e2eb/')),
      );
      return OpenApi(
        info: const Info(title: 'e2eb', version: '1'),
        docs: docs,
      ).toJson();
    }

    test('the router answers both paths of /opt/{x?}/b', () async {
      expect(api.json(await api.get('/core/e2eb/opt/7/b')), <String, dynamic>{
        'x': '7',
      });
      http.Response short = await api.get('/core/e2eb/opt/b');
      expect(short.statusCode, 200, reason: short.body);
      expect(api.json(short), <String, dynamic>{'x': null});
    });

    test('a middle optional param gives two paths in the spec', () {
      for (Map<String, dynamic> doc in <Map<String, dynamic>>[
        coreDoc(),
        adapterDoc(),
      ]) {
        Map<String, dynamic> paths = doc['paths'];
        expect(
          paths.keys,
          containsAll(<String>['/core/e2eb/opt/{x}/b', '/core/e2eb/opt/b']),
        );
        expect(paths.keys, isNot(contains('/core/e2eb/opt/{x?}/b')));
        Map<String, dynamic> long = paths['/core/e2eb/opt/{x}/b']['get'];
        Map<String, dynamic> short = paths['/core/e2eb/opt/b']['get'];
        expect(
          (long['parameters'] as List<dynamic>).map((dynamic p) => p['name']),
          <String>['x'],
        );
        expect(short['parameters'] ?? <dynamic>[], isEmpty);
        expect(short['operationId'], isNot(long['operationId']));
      }
    });

    test('the short path gets its own summary and operation id', () {
      Map<String, dynamic> long =
          adapterDoc()['paths']['/core/e2eb/hi/{name}']['get'];
      Map<String, dynamic> short =
          adapterDoc()['paths']['/core/e2eb/hi']['get'];
      expect(long['summary'], 'GET /core/e2eb/hi/{name}');
      expect(long['operationId'], 'getCoreE2ebHiByName');
      expect(short['summary'], 'GET /core/e2eb/hi');
      expect(short['operationId'], 'getCoreE2ebHi');
    });

    test(
      'dox_core docs: the short path gets its own summary and operation id',
      () {
        Map<String, dynamic> paths = coreDoc()['paths'];
        Map<String, dynamic> long = paths['/core/e2eb/hi/{name}']['get'];
        Map<String, dynamic> short = paths['/core/e2eb/hi']['get'];
        expect(long['summary'], 'GET /core/e2eb/hi/{name}');
        expect(short['summary'], 'GET /core/e2eb/hi');
        expect(short['operationId'], 'getCoreE2ebHi');
      },
    );

    test('dox#335: only the path with a param lists a 404', () async {
      Map<String, dynamic> doc = api.json(await api.get('/openapi.json'));
      Map<String, dynamic> long = doc['paths']['/api/greet/{name}']['get'];
      Map<String, dynamic> short = doc['paths']['/api/greet']['get'];
      expect((long['responses'] as Map<String, dynamic>).keys, contains('404'));
      expect(
        (short['responses'] as Map<String, dynamic>).keys,
        isNot(contains('404')),
      );
      expect(short['responses'], contains('200'));
      // a custom summary stays on both paths
      expect(short['summary'], long['summary']);

      Map<String, dynamic> paths = coreDoc()['paths'];
      expect(
        (paths['/core/e2eb/hi/{name}']['get']['responses']
                as Map<String, dynamic>)
            .keys,
        contains('404'),
      );
      expect(
        (paths['/core/e2eb/hi']['get']['responses'] as Map<String, dynamic>)
            .keys,
        isNot(contains('404')),
      );
      // a route with no param has no 404
      expect(
        (paths['/core/e2eb/decrypt']['post']['responses']
                as Map<String, dynamic>)
            .keys,
        isNot(contains('404')),
      );
    });

    test('a GET or DELETE body schema shows query params', () {
      for (Map<String, dynamic> doc in <Map<String, dynamic>>[
        coreDoc(),
        adapterDoc(),
      ]) {
        for (String method in <String>['get', 'delete']) {
          Map<String, dynamic> op = doc['paths']['/core/e2eb/search'][method];
          expect(op.containsKey('requestBody'), false, reason: method);
          List<dynamic> params = op['parameters'];
          expect(
            params.map((dynamic p) => '${p['in']}:${p['name']}'),
            unorderedEquals(<String>['query:q', 'query:page']),
            reason: method,
          );
        }
      }
      // POST keeps a request body
      expect(E2eCoreBRoutes.searchSchema['properties'], hasLength(2));
      Map<String, dynamic> post = adapterDoc()['paths']['/core/e2eb/decrypt'];
      expect(post['post'].containsKey('parameters'), false);
    });
  });

  group('3.1.0 core b: dox_auth', () {
    late User user;
    const String email = 'core310b@mail.com';
    const String password = 'secret123';

    Future<String> jwtLogin() async {
      http.Response res = await api.post('/api/auth/login', <String, dynamic>{
        'email': email,
        'password': password,
      });
      expect(res.statusCode, 200, reason: res.body);
      return api.json(res)['token'];
    }

    Future<Browser> webLogin() async {
      Browser browser = Browser(api);
      await browser.send('GET', '/ping', <String, String>{});
      http.Response res = await browser.send(
        'POST',
        '/web-auth/login',
        <String, String>{'Content-Type': 'application/json'},
        jsonEncode(<String, String>{'email': email, 'password': password}),
      );
      expect(res.statusCode, 200, reason: res.body);
      return browser;
    }

    setUpAll(() async {
      http.Response res = await api.post(
        '/api/auth/register',
        <String, dynamic>{
          'name': 'Core B',
          'email': email,
          'password': password,
          'password_confirmation': password,
        },
      );
      expect(res.statusCode, 201, reason: res.body);
      user = (await User().find(api.json(res)['id']))!;
    });

    test('Auth().check() is isLoggedIn()', () async {
      Auth auth = Auth();
      expect(auth.check(), false);
      expect(auth.check(), auth.isLoggedIn());
      await auth.userFromToken<User>(await jwtLogin());
      expect(auth.check(), true);
      expect(auth.check(), auth.isLoggedIn());
      expect(auth.guest(), false);
    });

    test('Auth().once(): true or false, and no token is made', () async {
      Auth tokens = Auth(guard: 'tokens');
      int before = (await tokens.accessTokens(user)).length;
      expect(
        await tokens.once(<String, dynamic>{
          'email': email,
          'password': password,
        }),
        true,
      );
      expect(tokens.check(), true);
      expect('${tokens.id()}', '${user.id}');
      expect((await tokens.accessTokens(user)).length, before);

      for (Map<String, dynamic> bad in <Map<String, dynamic>>[
        <String, dynamic>{'email': email, 'password': 'wrong'},
        <String, dynamic>{'email': 'nobody310b@mail.com', 'password': 'x'},
        <String, dynamic>{'email': email},
      ]) {
        Auth auth = Auth();
        expect(await auth.once(bad), false, reason: '$bad');
        expect(auth.check(), false);
        expect(auth.user<User>(), isNull);
      }

      // a good once after a bad one on the same Auth
      Auth jwt = Auth();
      expect(
        await jwt.once(<String, dynamic>{'email': email, 'password': 'no'}),
        false,
      );
      expect(
        await jwt.once(<String, dynamic>{'email': email, 'password': password}),
        true,
      );
      expect(jwt.user<User>()?.email, email);
    });

    test('Auth().once() on the web guard does not touch the session', () async {
      Browser browser = Browser(api);
      http.Response res = await browser.send(
        'POST',
        '/core/e2eb/once',
        <String, String>{'Content-Type': 'application/json'},
        jsonEncode(<String, String>{'email': email, 'password': password}),
      );
      expect(res.statusCode, 200, reason: res.body);
      expect(api.json(res), <String, dynamic>{
        'ok': true,
        'id': user.id,
        'session': null,
      });

      // the same browser is still a guest
      http.Response next = await browser.send(
        'GET',
        '/core/e2eb/multi',
        <String, String>{},
      );
      expect(next.statusCode, 401);

      http.Response bad = await browser.send(
        'POST',
        '/core/e2eb/once',
        <String, String>{'Content-Type': 'application/json'},
        jsonEncode(<String, String>{'email': email, 'password': 'wrong'}),
      );
      expect(api.json(bad), <String, dynamic>{
        'ok': false,
        'id': null,
        'session': null,
      });
    });

    test('AuthMiddleware(guards:): a session or a JWT passes', () async {
      Browser web = await webLogin();
      http.Response bySession = await web.send(
        'GET',
        '/core/e2eb/multi',
        <String, String>{},
      );
      expect(bySession.statusCode, 200, reason: bySession.body);
      expect('${api.json(bySession)['id']}', '${user.id}');

      String jwt = await jwtLogin();
      http.Response byToken = await api.get(
        '/core/e2eb/multi',
        headers: <String, String>{'Authorization': 'Bearer $jwt'},
      );
      expect(byToken.statusCode, 200, reason: byToken.body);
      expect('${api.json(byToken)['id']}', '${user.id}');

      // a session with a bad token: the web guard is first, so it passes
      http.Response both = await web.send(
        'GET',
        '/core/e2eb/multi',
        <String, String>{'Authorization': 'Bearer bad.token.here'},
      );
      expect(both.statusCode, 200, reason: both.body);
    });

    test('AuthMiddleware(guards:): nobody, or a bad token, gets 401', () async {
      Future<http.Response> get(Map<String, String> headers) {
        return api.get('/core/e2eb/multi', headers: headers);
      }

      for (Map<String, String> headers in <Map<String, String>>[
        <String, String>{},
        <String, String>{'Authorization': 'Bearer bad.token.here'},
        <String, String>{'Authorization': 'Bearer '},
        <String, String>{'Cookie': 'dox_session=changed'},
      ]) {
        http.Response res = await get(headers);
        expect(res.statusCode, 401, reason: '$headers: ${res.body}');
      }

      // an access token is not for the web or api guard
      String token = (await Auth(
        guard: 'tokens',
      ).createAccessToken(user, name: 'e310b')).value!;
      http.Response res = await get(<String, String>{
        'Authorization': 'Bearer $token',
      });
      expect(res.statusCode, 401);
      await Auth(guard: 'tokens').revokeAllAccessTokens(user);
    });

    test('guard and guards together, or no guards, throw', () {
      expect(
        () => AuthMiddleware(guard: 'api', guards: <String>['web']),
        throwsArgumentError,
      );
      expect(() => AuthMiddleware(guards: <String>[]), throwsArgumentError);
      expect(
        () => AuthMiddleware(guard: 'api', guards: <String>[]),
        throwsArgumentError,
      );
      // these are fine
      AuthMiddleware(guard: 'api');
      AuthMiddleware(guards: <String>['api']);
      AuthMiddleware();
    });

    test('logout on a JWT or tokens guard says to use revokeToken()', () async {
      for (String guard in <String>['api', 'tokens']) {
        http.Response res = await api.post(
          '/core/e2eb/logout/$guard',
          <String, dynamic>{},
        );
        expect(res.statusCode, 200, reason: res.body);
        String error = api.json(res)['error'];
        expect(error, contains("'$guard'"));
        expect(error, contains('revokeToken()'));
      }
    });

    test('revokeAllTokens: a token of the same second still works', () async {
      Future<int> me(String token) async {
        http.Response res = await api.get(
          '/api/auth/me',
          headers: <String, String>{'Authorization': 'Bearer $token'},
        );
        return res.statusCode;
      }

      // wait for the start of a new second, so the next steps all run in
      // one second
      Future<void> nextSecond() {
        DateTime now = DateTime.now();
        return Future<void>.delayed(
          Duration(milliseconds: 1000 - now.millisecond + 20),
        );
      }

      String old = Auth().login(user)!;
      await nextSecond();
      await Auth().revokeAllTokens(user.id);
      String fresh = Auth().login(user)!;
      expect(await me(old), 401);
      expect(await me(fresh), 200);

      await nextSecond();
      String later = Auth().login(user)!;
      expect(await me(later), 200);
      expect(await me(fresh), 200);
    });
  });
}

/// Run [body] with a copy of the app config that has other
/// [previousKeys] or [globalMiddleware], then put the old config back.
/// One isolate: the server reads `Dox().config` on each request.
Future<void> withConfig({
  List<String>? previousKeys,
  List<dynamic>? globalMiddleware,
  required Future<void> Function() body,
}) async {
  AppConfig old = Dox().config;
  Dox().config = AppConfig(
    appKey: old.appKey,
    previousKeys: previousKeys ?? old.previousKeys,
    serverPort: old.serverPort,
    host: old.host,
    totalIsolate: old.totalIsolate,
    providers: old.providers,
    dtos: old.dtos,
    validationMessages: old.validationMessages,
    globalMiddleware: globalMiddleware ?? old.globalMiddleware,
    routers: old.routers,
    container: old.container,
    cors: old.cors,
    logger: old.logger,
    cache: old.cache,
    session: old.session,
    openApi: old.openApi,
    exceptionHandler: old.exceptionHandler,
    responseHandler: old.responseHandler,
    maxBodySize: old.maxBodySize,
    maxMultipartSize: old.maxMultipartSize,
    bodyTimeout: old.bodyTimeout,
    idleTimeout: old.idleTimeout,
    maxConnections: old.maxConnections,
    trustedProxies: old.trustedProxies,
    compress: old.compress,
    shutdownTimeout: old.shutdownTimeout,
    webSocketAllowedOrigins: old.webSocketAllowedOrigins,
  );
  try {
    await body();
  } finally {
    Dox().config = old;
  }
}
