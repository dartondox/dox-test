import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dox_core/dox_core.dart';
import 'package:dox_test/bootstrap.dart';
import 'package:dox_test/config/app.dart';
import 'package:dox_test/config/env.dart';
import 'package:dox_test/constants/app_constants.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../db/migration/migrations.dart';

/// End to end checks. Starts the real server on a fresh database,
/// then calls every endpoint over HTTP and the websocket.
/// Tests run in order and share state (users, token, post ids).
void main() {
  Api api = Api();

  setUpAll(api.boot);

  group('routing, middleware, cors', () {
    test('GET /ping works and global middleware adds a header', () async {
      http.Response res = await api.get('/ping');
      expect(res.statusCode, 200);
      expect(res.body, 'pong');
      expect(res.headers[AppConstants.appHeader.toLowerCase()], 'dox-test');
    });

    test('CORS headers are sent', () async {
      http.Response res = await api.get(
        '/ping',
        headers: <String, String>{'Origin': 'x.com'},
      );
      expect(res.headers['access-control-allow-origin'], '*');
      expect(
        res.headers['access-control-allow-methods'],
        'GET,POST,PUT,DELETE',
      );
    });

    test('Route.disabledCors removes CORS headers', () async {
      http.Response res = await api.get('/no-cors');
      expect(res.body, 'no cors here');
      expect(res.headers['access-control-allow-origin'], isNull);
    });

    test('CORS preflight (OPTIONS) gets CORS headers', () async {
      http.Response res = await api.send(
        'OPTIONS',
        '/api/posts',
        headers: <String, String>{
          'Origin': 'x.com',
          'Access-Control-Request-Method': 'POST',
        },
      );
      expect(res.statusCode, 204);
      expect(res.headers['access-control-allow-origin'], '*');
    });

    test('unknown route gives 404', () async {
      http.Response res = await api.get('/api/nothing-here');
      expect(res.statusCode, 404);
    });

    test('route middleware blocks a missing api key (403)', () async {
      http.Response res = await api.get('/api/system/env', withKey: false);
      expect(res.statusCode, 403);
      expect(api.json(res)['message'], 'invalid api key');
    });
  });

  group('request handling', () {
    test('query string', () async {
      http.Response res = await api.get('/api/system/query?a=1&b=two');
      expect(res.statusCode, 200);
      Map<String, dynamic> body = api.json(res);
      expect(body['query'], <String, dynamic>{'a': '1', 'b': 'two'});
      expect(body['only'], <String, dynamic>{'a': '1'});
      expect(body['has_a'], true);
      expect(body['method'], 'GET');
    });

    test('JSON body', () async {
      http.Response res = await api.post('/api/system/echo', <String, dynamic>{
        'name': 'dox',
        'list': <int>[1, 2],
      });
      Map<String, dynamic> body = api.json(res);
      expect(body['is_json'], true);
      expect(body['body'], <String, dynamic>{
        'name': 'dox',
        'list': <int>[1, 2],
      });
    });

    test('form-data with file upload, then download it', () async {
      http.MultipartRequest req = http.MultipartRequest(
        'POST',
        api.uri('/api/files'),
      );
      req.fields['note'] = 'my note';
      req.files.add(
        http.MultipartFile.fromString(
          'file',
          'hello dox file',
          filename: 'hello.txt',
        ),
      );
      http.Response res = await http.Response.fromStream(await req.send());
      expect(res.statusCode, 201, reason: res.body);
      Map<String, dynamic> body = api.json(res);
      expect(body['note'], 'my note');
      expect(body['is_form_data'], true);
      expect(body['original_name'], 'hello.txt');
      expect(body['extension'], 'txt');
      expect(body['bytes'], 14);

      http.Response file = await api.get('/api/files/${body['name']}');
      expect(file.statusCode, 200);
      expect(file.body, 'hello dox file');
      expect(file.headers['content-type'], startsWith('text/plain'));
    });

    test('uploaded file size_kb is the file size', () async {
      http.MultipartRequest req = http.MultipartRequest(
        'POST',
        api.uri('/api/files'),
      );
      req.fields['note'] = 'size';
      req.files.add(
        http.MultipartFile.fromBytes(
          'file',
          List<int>.filled(2048, 65),
          filename: 'a.txt',
        ),
      );
      http.Response res = await http.Response.fromStream(await req.send());
      expect(api.json(res)['size_kb'], 2);
    });

    test('missing file in form-data fails validation (422)', () async {
      http.MultipartRequest req = http.MultipartRequest(
        'POST',
        api.uri('/api/files'),
      );
      req.fields['note'] = 'no file';
      http.Response res = await http.Response.fromStream(await req.send());
      expect(res.statusCode, 422);
      expect(api.json(res), contains('file'));
    });
  });

  group('auth + FormRequest validation', () {
    test('register fails validation (422)', () async {
      http.Response res = await api.post(
        '/api/auth/register',
        <String, dynamic>{'email': 'not-an-email', 'password': '123'},
      );
      expect(res.statusCode, 422);
      Map<String, dynamic> errors = api.json(res);
      expect(errors['name'], 'name is missing');
      expect(errors['email'], 'The email is not a valid email');
      expect(errors['password'], contains('at least 6'));
    });

    test('register passes (201, serializer hides password)', () async {
      for (String name in <String>['Alice', 'Bob', 'Carol']) {
        http.Response res = await api.post(
          '/api/auth/register',
          <String, dynamic>{
            'name': name,
            'email': '${name.toLowerCase()}@mail.com',
            'password': 'secret123',
          },
        );
        expect(res.statusCode, 201, reason: res.body);
        Map<String, dynamic> user = api.json(res);
        expect(user['name'], name);
        expect(user.containsKey('password'), false);
        api.userIds[name] = user['id'];
      }
    });

    test('register with a used email fails (422)', () async {
      http.Response res = await api.post(
        '/api/auth/register',
        <String, dynamic>{
          'name': 'Alice',
          'email': 'alice@mail.com',
          'password': 'secret123',
        },
      );
      expect(res.statusCode, 422);
      expect(api.json(res)['email'], 'email is already taken');
    });

    test('login with wrong password gives 401', () async {
      http.Response res = await api.post('/api/auth/login', <String, dynamic>{
        'email': 'alice@mail.com',
        'password': 'wrong',
      });
      expect(res.statusCode, 401);
    });

    test('login works for Alice and Bob', () async {
      for (String name in <String>['Alice', 'Bob']) {
        http.Response res = await api.post('/api/auth/login', <String, dynamic>{
          'email': '${name.toLowerCase()}@mail.com',
          'password': 'secret123',
        });
        expect(res.statusCode, 200, reason: res.body);
        Map<String, dynamic> body = api.json(res);
        expect(body['token'], isA<String>());
        expect(body['user']['email'], '${name.toLowerCase()}@mail.com');
        expect(
          (body['user'] as Map<String, dynamic>).containsKey('password'),
          false,
        );
        api.tokens[name] = body['token'];
      }
    });

    test('protected route without token gives 401', () async {
      http.Response res = await api.get('/api/auth/me');
      expect(res.statusCode, 401);
    });

    test('protected route gives the current user', () async {
      http.Response res = await api.get('/api/auth/me', token: 'Alice');
      expect(res.statusCode, 200, reason: res.body);
      expect(api.json(res)['name'], 'Alice');
    });
  });

  group('ORM: CRUD, relations, soft delete', () {
    test('create posts with tags (FormRequest + manyToMany pivot)', () async {
      List<List<dynamic>> rows = <List<dynamic>>[
        <dynamic>[
          'Alice',
          'Dart tips',
          'published',
          <String>['dart', 'tips'],
        ],
        <dynamic>[
          'Alice',
          'Draft post',
          'draft',
          <String>['dart'],
        ],
        <dynamic>[
          'Bob',
          'Bob first',
          'published',
          <String>['life'],
        ],
      ];
      for (List<dynamic> row in rows) {
        http.Response res = await api.post('/api/posts', <String, dynamic>{
          'title': row[1],
          'body': 'body of ${row[1]}',
          'status': row[2],
          'tags': row[3],
        }, token: row[0]);
        expect(res.statusCode, 201, reason: res.body);
        Map<String, dynamic> post = api.json(res);
        expect(post['title'], row[1]);
        expect(post['author']['name'], row[0]);
        expect(api.names(post['tags']), unorderedEquals(row[3]));
        api.postIds[row[1]] = post['id'];
      }
    });

    test('create post fails validation (422)', () async {
      http.Response res = await api.post('/api/posts', <String, dynamic>{
        'status': 'unknown',
      }, token: 'Alice');
      expect(res.statusCode, 422);
      Map<String, dynamic> errors = api.json(res);
      expect(errors.keys, containsAll(<String>['title', 'body', 'status']));
    });

    test('optional field (status) can be left out', () async {
      int id = api.postIds['Draft post']!;
      http.Response res = await api.put('/api/posts/$id', <String, dynamic>{
        'title': 'Draft post',
        'body': 'b',
      }, token: 'Alice');
      expect(res.statusCode, 200, reason: res.body);
      expect(api.json(res)['status'], 'draft');
    });

    test('create post without token gives 401', () async {
      http.Response res = await api.post('/api/posts', <String, dynamic>{
        'title': 't',
        'body': 'b',
      });
      expect(res.statusCode, 401);
    });

    test('show post: belongsTo, hasMany, manyToMany', () async {
      int id = api.postIds['Dart tips']!;
      http.Response res = await api.get('/api/posts/$id');
      expect(res.statusCode, 200, reason: res.body);
      Map<String, dynamic> post = api.json(res);
      expect(post['author']['name'], 'Alice');
      expect(post['comments'], isEmpty);
      expect(
        api.names(post['tags']),
        unorderedEquals(<String>['dart', 'tips']),
      );
    });

    test('serializer response', () async {
      int id = api.postIds['Dart tips']!;
      http.Response res = await api.get('/api/posts/$id/summary');
      expect(api.json(res), <String, dynamic>{
        'id': id,
        'title': 'Dart tips',
        'status': 'published',
        'author': 'Alice',
        'tags': unorderedEquals(<String>['dart', 'tips']),
      });
    });

    test('missing post gives 404', () async {
      http.Response res = await api.get('/api/posts/99999');
      expect(res.statusCode, 404);
      expect(res.body, 'post not found');
    });

    test('update post (owner) and replace tags', () async {
      int id = api.postIds['Draft post']!;
      http.Response res = await api.put('/api/posts/$id', <String, dynamic>{
        'title': 'Draft post v2',
        'body': 'new body',
        'status': 'draft',
        'tags': <String>['news'],
      }, token: 'Alice');
      expect(res.statusCode, 200, reason: res.body);
      Map<String, dynamic> post = api.json(res);
      expect(post['title'], 'Draft post v2');
      expect(post['body'], 'new body');
      expect(api.names(post['tags']), <String>['news']);
    });

    test('update post of another user gives 403', () async {
      int id = api.postIds['Dart tips']!;
      http.Response res = await api.put('/api/posts/$id', <String, dynamic>{
        'title': 'x',
        'body': 'y',
        'status': 'draft',
      }, token: 'Bob');
      expect(res.statusCode, 403);
    });

    test('comments: create, eager user, two route params', () async {
      int id = api.postIds['Dart tips']!;
      http.Response res = await api.post(
        '/api/posts/$id/comments',
        <String, dynamic>{'body': 'Nice post'},
        token: 'Bob',
      );
      expect(res.statusCode, 201, reason: res.body);
      Map<String, dynamic> comment = api.json(res);
      expect(comment['body'], 'Nice post');
      expect(comment['user']['name'], 'Bob');

      http.Response one = await api.get(
        '/api/posts/$id/comments/${comment['id']}',
      );
      expect(one.statusCode, 200, reason: one.body);
      expect(api.json(one)['id'], comment['id']);

      http.Response post = await api.get('/api/posts/$id');
      List<dynamic> comments = api.json(post)['comments'];
      expect(comments.length, 1);
      expect(comments.first['body'], 'Nice post');
    });

    test('comment on a missing post gives 404', () async {
      http.Response res = await api.post(
        '/api/posts/99999/comments',
        <String, dynamic>{'body': 'x'},
        token: 'Bob',
      );
      expect(res.statusCode, 404);
    });

    test('list posts: pagination, orderBy desc, whereIn', () async {
      http.Response res = await api.get('/api/posts?page=1&limit=2');
      expect(res.statusCode, 200, reason: res.body);
      Map<String, dynamic> page = api.json(res);
      expect(page['total'], 3);
      expect(page['per_page'], 2);
      expect(page['last_page'], 2);
      expect(page['current_page'], 1);
      List<dynamic> data = page['data'];
      expect(data.length, 2);
      expect(data.first['title'], 'Bob first');
      expect(data.first['author']['name'], 'Bob');

      http.Response page2 = await api.get('/api/posts?page=2&limit=2');
      expect((api.json(page2)['data'] as List<dynamic>).length, 1);

      http.Response published = await api.get('/api/posts?status=published');
      expect(api.json(published)['total'], 2);
    });

    test('tag side of manyToMany', () async {
      http.Response res = await api.get('/api/tags/dart/posts');
      expect(res.statusCode, 200, reason: res.body);
      expect(api.titles(api.json(res)['posts']), <String>['Dart tips']);
    });

    test('users: where/orWhere search, pagination, count', () async {
      http.Response res = await api.get('/api/users?search=bo&page=1&limit=10');
      expect(res.statusCode, 200, reason: res.body);
      Map<String, dynamic> page = api.json(res);
      expect(page['total'], 1);
      expect(page['data'].first['name'], 'Bob');

      http.Response all = await api.get('/api/users?page=1&limit=2');
      expect(api.json(all)['total'], 3);
      expect((api.json(all)['data'] as List<dynamic>).length, 2);
    });

    test('users list without page fails inline validation (422)', () async {
      http.Response res = await api.get('/api/users');
      expect(res.statusCode, 422);
    });

    test('hasOne profile: create, then show user with relations', () async {
      http.Response res = await api.put(
        '/api/auth/me/profile',
        <String, dynamic>{'bio': 'I write Dart', 'website': 'a.dev'},
        token: 'Alice',
      );
      expect(res.statusCode, 200, reason: res.body);
      Map<String, dynamic> profile = api.json(res);
      expect(profile['bio'], 'I write Dart');
      expect(profile['user']['name'], 'Alice');

      http.Response user = await api.get('/api/users/${api.userIds['Alice']}');
      Map<String, dynamic> body = api.json(user);
      expect(body['profile']['website'], 'a.dev');
      expect(
        api.titles(body['posts']),
        unorderedEquals(<String>['Dart tips', 'Draft post v2']),
      );
      expect(body.containsKey('password'), false);
    });

    test('missing user gives 404', () async {
      http.Response res = await api.get('/api/users/99999');
      expect(res.statusCode, 404);
    });

    test('stats: count, join + groupBy, cached', () async {
      http.Response res = await api.get('/api/posts/stats');
      expect(res.statusCode, 200, reason: res.body);
      Map<String, dynamic> stats = api.json(res);
      expect(stats['cached'], false);
      expect(stats['total'], 3);
      expect(stats['published'], 2);
      expect(api.authorTotals(stats['per_author']), <String, int>{
        'Alice': 2,
        'Bob': 1,
      });

      http.Response again = await api.get('/api/posts/stats');
      expect(api.json(again)['cached'], true);
    });

    test('soft delete: hidden from list, shown in trashed', () async {
      int id = api.postIds['Bob first']!;
      http.Response del = await api.delete('/api/posts/$id', token: 'Bob');
      expect(del.statusCode, 200, reason: del.body);

      expect((await api.get('/api/posts/$id')).statusCode, 404);
      expect(api.json(await api.get('/api/posts?page=1&limit=10'))['total'], 2);

      http.Response trashed = await api.get('/api/posts/trashed');
      List<dynamic> rows = api.json(trashed);
      expect(api.titles(rows), <String>['Bob first']);
      expect(rows.first['deleted_at'], isNotNull);

      http.Response stats = await api.get('/api/posts/stats');
      expect(api.json(stats)['cached'], false);
      expect(api.json(stats)['total'], 2);
    });
  });

  group('responses and core tools', () {
    test('custom status code and header', () async {
      http.Response res = await api.get('/api/system/teapot');
      expect(res.statusCode, 418);
      expect(res.headers['x-custom'], 'yes');
      expect(api.json(res)['message'], 'I am a teapot');
    });

    test('unhandled error gives 500', () async {
      http.Response res = await api.get('/api/system/crash');
      expect(res.statusCode, 500);
      expect(res.body, contains('boom'));
    });

    test('cookie is set (encrypted) and read back (decrypted)', () async {
      http.Response res = await api.get('/api/system/cookie');
      String setCookie = res.headers['set-cookie'] ?? '';
      expect(setCookie, startsWith('${AppConstants.themeCookie}='));
      String value = setCookie.split(';').first.split('=').sublist(1).join('=');
      expect(value, isNot('dark'), reason: 'cookie should be encrypted');

      http.Response read = await api.get(
        '/api/system/cookie/read',
        headers: <String, String>{
          'Cookie': '${AppConstants.themeCookie}=$value',
        },
      );
      expect(api.json(read)['theme'], 'dark');
    });

    test('env', () async {
      http.Response res = await api.get('/api/system/env');
      expect(api.json(res), <String, dynamic>{
        'app_name': 'dox-test',
        'missing_with_default': 'fallback',
      });
    });

    test('hashing', () async {
      http.Response res = await api.post('/api/system/hash', <String, dynamic>{
        'password': 'pw123',
      });
      Map<String, dynamic> body = api.json(res);
      expect(body['hash'], startsWith(r'$2'));
      expect(body['verified'], true);
      expect(body['wrong_verified'], false);
    });

    test('IoC container keeps one service instance', () async {
      int first = api.json(await api.get('/api/system/container'))['calls'];
      int second = api.json(await api.get('/api/system/container'))['calls'];
      expect(second, first + 1);
    });

    test('cache: put, get, has, forget', () async {
      Cache cache = Cache();
      await cache.put('greeting', 'hello');
      expect(await cache.get('greeting'), 'hello');
      expect(await cache.has('greeting'), true);
      await cache.forget('greeting');
      expect(await cache.has('greeting'), false);
    });
  });

  group('websocket', () {
    test('connect gets an id, echo goes to sender only', () async {
      WsClient a = await WsClient.connect(api.wsUri);
      expect(await a.next('connected'), contains('id'));
      a.send('echo', 'hello');
      expect(await a.next('echo'), 'hello');
      await a.close();
    });

    test('broadcast reaches others, not the sender', () async {
      WsClient a = await WsClient.connect(api.wsUri);
      WsClient b = await WsClient.connect(api.wsUri);
      await a.next('connected');
      await b.next('connected');
      a.send('broadcast', <String, String>{'text': 'hi all'});
      expect(await b.next('broadcast'), <String, dynamic>{'text': 'hi all'});
      expect(await a.nothing('broadcast'), true);
      await a.close();
      await b.close();
    });

    test('join room, then emit to the room', () async {
      WsClient a = await WsClient.connect(api.wsUri);
      WsClient b = await WsClient.connect(api.wsUri);
      WsClient outsider = await WsClient.connect(api.wsUri);
      await a.next('connected');
      await b.next('connected');
      await outsider.next('connected');
      a.send('joinRoom', 'lobby');
      b.send('joinRoom', 'lobby');
      await Future<void>.delayed(Duration(milliseconds: 200));
      a.send('chat', <String, String>{'room': 'lobby', 'text': 'hi lobby'});
      expect(await b.next('chat'), 'hi lobby');
      expect(await outsider.nothing('chat'), true);
      await a.close();
      await b.close();
      await outsider.close();
    });
  });
}

/// Small HTTP helper for the tests.
class Api {
  final Map<String, int> userIds = <String, int>{};
  final Map<String, int> postIds = <String, int>{};
  final Map<String, String> tokens = <String, String>{};

  String get base => 'http://127.0.0.1:${appConfig.serverPort}';
  Uri get wsUri => Uri.parse('ws://127.0.0.1:${appConfig.serverPort}/ws');

  Future<void> boot() async {
    await Bootstrap(migrations).start(freshDatabase: true);
    await Cache().flush();
  }

  Uri uri(String path) {
    return Uri.parse('$base$path');
  }

  Map<String, String> _headers(
    String? token,
    bool withKey, [
    Map<String, String>? extra,
  ]) {
    Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json',
      ...?extra,
    };
    if (withKey) {
      headers[AppConstants.apiKeyHeader] = AppEnv.get('API_KEY');
    }
    if (token != null) {
      headers['Authorization'] = 'Bearer ${tokens[token]}';
    }
    return headers;
  }

  Future<http.Response> get(
    String path, {
    String? token,
    bool withKey = true,
    Map<String, String>? headers,
  }) {
    return http.get(uri(path), headers: _headers(token, withKey, headers));
  }

  Future<http.Response> post(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) {
    return http.post(
      uri(path),
      headers: _headers(token, true),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> put(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) {
    return http.put(
      uri(path),
      headers: _headers(token, true),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> delete(String path, {String? token}) {
    return http.delete(uri(path), headers: _headers(token, true));
  }

  Future<http.Response> send(
    String method,
    String path, {
    Map<String, String>? headers,
  }) async {
    http.Request req = http.Request(method, uri(path));
    req.headers.addAll(headers ?? <String, String>{});
    return http.Response.fromStream(await req.send());
  }

  dynamic json(http.Response res) {
    return jsonDecode(res.body);
  }

  List<String> names(List<dynamic> rows) {
    List<String> ret = <String>[];
    for (dynamic row in rows) {
      ret.add(row['name'].toString());
    }
    return ret;
  }

  List<String> titles(List<dynamic> rows) {
    List<String> ret = <String>[];
    for (dynamic row in rows) {
      ret.add(row['title'].toString());
    }
    return ret;
  }

  Map<String, int> authorTotals(List<dynamic> rows) {
    Map<String, int> ret = <String, int>{};
    for (dynamic row in rows) {
      ret[row['author'].toString()] = int.parse(row['total'].toString());
    }
    return ret;
  }
}

/// Websocket client that keeps every message it gets.
class WsClient {
  final WebSocket socket;
  final List<Map<String, dynamic>> _messages = <Map<String, dynamic>>[];

  WsClient(this.socket) {
    socket.listen(_onData);
  }

  static Future<WsClient> connect(Uri uri) async {
    return WsClient(await WebSocket.connect(uri.toString()));
  }

  void _onData(dynamic data) {
    _messages.add(jsonDecode(data.toString()));
  }

  void send(String event, dynamic message) {
    socket.add(
      jsonEncode(<String, dynamic>{'event': event, 'message': message}),
    );
  }

  /// Wait up to 2 seconds for an event, return its message.
  Future<dynamic> next(String event) async {
    for (int i = 0; i < 40; i++) {
      for (Map<String, dynamic> m in _messages) {
        if (m['event'] == event) {
          _messages.remove(m);
          return m['message'];
        }
      }
      await Future<void>.delayed(Duration(milliseconds: 50));
    }
    throw TimeoutException('no "$event" event');
  }

  /// True when the event does not come within 300 ms.
  Future<bool> nothing(String event) async {
    await Future<void>.delayed(Duration(milliseconds: 300));
    for (Map<String, dynamic> m in _messages) {
      if (m['event'] == event) {
        return false;
      }
    }
    return true;
  }

  Future<void> close() async {
    await socket.close();
  }
}
