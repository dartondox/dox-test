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
        'GET,POST,PUT,PATCH,DELETE',
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
      expect(api.json(res), <String, dynamic>{'file': 'The file is required'});
    });

    test('DTO file: text instead of a file, missing note (422)', () async {
      http.MultipartRequest req = http.MultipartRequest(
        'POST',
        api.uri('/api/files'),
      );
      req.fields['file'] = 'just text';
      http.Response res = await http.Response.fromStream(await req.send());
      expect(res.statusCode, 422);
      expect(api.json(res), <String, dynamic>{
        'file': 'The file must be a file',
        'note': 'The note is required',
      });
    });

    test('DTO @MaxSize: a file over 1MB gives 422', () async {
      http.Response res = await api.uploadBytes(
        '/api/files',
        'file',
        List<int>.filled(1024 * 1024 + 1, 65),
        'big.txt',
        fields: <String, String>{'note': 'big'},
      );
      expect(res.statusCode, 422);
      expect(api.json(res), <String, dynamic>{
        'file': 'The file may not be larger than 1MB',
      });
    });

    test('DTO @Image: a png passes, a text file and a big png fail', () async {
      http.Response ok = await api.uploadBytes(
        '/api/files/avatar',
        'avatar',
        Api.tinyPng,
        'me.png',
      );
      expect(ok.statusCode, 201, reason: ok.body);
      expect(api.json(ok)['extension'], 'png');

      http.Response text = await api.uploadBytes(
        '/api/files/avatar',
        'avatar',
        utf8.encode('not an image'),
        'fake.png',
      );
      expect(text.statusCode, 422);
      expect(api.json(text), <String, dynamic>{
        'avatar': 'The avatar must be an image',
      });

      http.Response big = await api.uploadBytes(
        '/api/files/avatar',
        'avatar',
        <int>[...Api.tinyPng, ...List<int>.filled(70 * 1024, 0)],
        'big.png',
      );
      expect(big.statusCode, 422);
      expect(api.json(big), <String, dynamic>{
        'avatar': 'The avatar may not be larger than 64KB',
      });
    });
  });

  group('auth + DTO validation', () {
    test('register: missing keys use the @Dto(messages:) text (422)', () async {
      http.Response res = await api.post(
        '/api/auth/register',
        <String, dynamic>{'email': 'ann@mail.com', 'name': '   '},
      );
      expect(res.statusCode, 422);
      expect(api.json(res), <String, dynamic>{
        'name': 'name is missing',
        'password': 'password is missing',
        'password_confirmation': 'password_confirmation is missing',
      });
    });

    test('register: @Length, @Email, @MinLength (422)', () async {
      http.Response res = await api.post(
        '/api/auth/register',
        <String, dynamic>{
          'name': 'A',
          'email': 'not-an-email',
          'password': '123',
          'password_confirmation': '123',
        },
      );
      expect(res.statusCode, 422);
      expect(api.json(res), <String, dynamic>{
        'name': 'The name must be between 2 and 100 characters',
        'email': 'The email is not a valid email',
        'password': 'The password must be at least 6 characters',
      });
    });

    test('register: JSON is strict, "name": 5 is not a string (422)', () async {
      http.Response res = await api.post(
        '/api/auth/register',
        <String, dynamic>{
          'name': 5,
          'email': 'a@mail.com',
          'password': 'secret123',
          'password_confirmation': 'secret123',
        },
      );
      expect(res.statusCode, 422);
      expect(api.json(res), <String, dynamic>{
        'name': 'The name must be a string',
      });
    });

    test('register: validate() checks password_confirmation (422)', () async {
      http.Response res = await api.post(
        '/api/auth/register',
        <String, dynamic>{
          'name': 'Ann',
          'email': 'ann@mail.com',
          'password': 'secret123',
          'password_confirmation': 'secret999',
        },
      );
      expect(res.statusCode, 422);
      expect(api.json(res), <String, dynamic>{
        'password_confirmation': 'The passwords do not match',
      });
    });

    test('a JSON body that is not an object gives _root (422)', () async {
      http.Response res = await api.postRaw('/api/auth/register', '[1, 2]');
      expect(res.statusCode, 422);
      expect(api.json(res), contains('_root'));
    });

    test('register passes (201, serializer hides password)', () async {
      for (String name in <String>['Alice', 'Bob', 'Carol']) {
        http.Response res = await api.post(
          '/api/auth/register',
          <String, dynamic>{
            'name': name,
            'email': '${name.toLowerCase()}@mail.com',
            'password': 'secret123',
            'password_confirmation': 'secret123',
          },
        );
        expect(res.statusCode, 201, reason: res.body);
        Map<String, dynamic> user = api.json(res);
        expect(user['name'], name);
        expect(user.containsKey('password'), false);
        api.userIds[name] = user['id'];
      }
    });

    test(
      'register with a used email fails: @Unique after @Lowercase',
      () async {
        for (String email in <String>['alice@mail.com', ' ALICE@Mail.com ']) {
          http.Response res = await api.post(
            '/api/auth/register',
            <String, dynamic>{
              'name': 'Alice',
              'email': email,
              'password': 'secret123',
              'password_confirmation': 'secret123',
            },
          );
          expect(res.statusCode, 422, reason: email);
          expect(api.json(res), <String, dynamic>{
            'email': 'The email has already been taken',
          });
        }
      },
    );

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

    test('update user: @Unique ignoreParam skips your own row', () async {
      int alice = api.userIds['Alice']!;
      http.Response same = await api.put('/api/users/$alice', <String, dynamic>{
        'name': 'Alice',
        'email': 'ALICE@mail.com',
      }, token: 'Alice');
      expect(same.statusCode, 200, reason: same.body);
      expect(api.json(same)['email'], 'alice@mail.com');

      http.Response taken = await api.put(
        '/api/users/$alice',
        <String, dynamic>{'name': 'Alice', 'email': 'bob@mail.com'},
        token: 'Alice',
      );
      expect(taken.statusCode, 422);
      expect(api.json(taken), <String, dynamic>{
        'email': 'The email has already been taken',
      });
    });

    test('update user: another user gives 403, bad id gives 404', () async {
      int alice = api.userIds['Alice']!;
      Map<String, dynamic> body = <String, dynamic>{
        'name': 'Bob',
        'email': 'free@mail.com',
      };
      http.Response other = await api.put(
        '/api/users/$alice',
        body,
        token: 'Bob',
      );
      expect(other.statusCode, 403);
      http.Response bad = await api.put('/api/users/abc', body, token: 'Bob');
      expect(bad.statusCode, 404);
    });
  });

  group('ORM: CRUD, relations, soft delete', () {
    test('create posts with tags (DTO + manyToMany pivot)', () async {
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
      expect(errors.keys, unorderedEquals(<String>['title', 'body', 'status']));
      expect(errors['title'], 'The title is required');
      expect(errors['status'], startsWith('The selected status is invalid'));
    });

    test(
      'post tags: custom @Slug rule, @MaxItems, @Trim + @Lowercase',
      () async {
        Map<String, dynamic> post = <String, dynamic>{
          'title': 't',
          'body': 'b',
        };
        http.Response slug = await api.post('/api/posts', <String, dynamic>{
          ...post,
          'tags': <String>['ok', 'not a slug'],
        }, token: 'Alice');
        expect(slug.statusCode, 422);
        expect(api.json(slug), <String, dynamic>{
          'tags.1': 'The tags must be a slug, like dart-tips',
        });

        http.Response many = await api.post('/api/posts', <String, dynamic>{
          ...post,
          'tags': <String>['a', 'b', 'c', 'd', 'e', 'f'],
        }, token: 'Alice');
        expect(many.statusCode, 422);
        expect(api.json(many), <String, dynamic>{
          'tags': 'The tags may not have more than 5 items',
        });
      },
    );

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
      expect(jsonDecode(res.body), <String, dynamic>{
        'code': 'not_found',
        'message': 'post not found',
      });
    });

    test('update post (owner) and replace tags', () async {
      int id = api.postIds['Draft post']!;
      http.Response res = await api.put('/api/posts/$id', <String, dynamic>{
        'title': '  Draft post v2  ',
        'body': 'new body',
        'status': 'draft',
        'tags': <String>[' NEWS '],
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

    test('comment with an empty body gives 422', () async {
      int id = api.postIds['Dart tips']!;
      http.Response res = await api.post(
        '/api/posts/$id/comments',
        <String, dynamic>{'body': '   '},
        token: 'Bob',
      );
      expect(res.statusCode, 422);
      expect(api.json(res), <String, dynamic>{'body': 'The body is required'});
    });

    test('typed path params: /posts/abc gives 404', () async {
      expect((await api.get('/api/posts/abc')).statusCode, 404);
      expect((await api.get('/api/posts/4.5')).statusCode, 404);
      expect((await api.get('/api/posts/1/comments/x')).statusCode, 404);
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
      http.Response res = await api.get('/api/posts?page=1&per_page=2');
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

      http.Response page2 = await api.get('/api/posts?page=2&per_page=2');
      expect((api.json(page2)['data'] as List<dynamic>).length, 1);

      http.Response published = await api.get('/api/posts?status=published');
      expect(api.json(published)['total'], 2);
    });

    test('list posts: query DTO with enum list and @Exists', () async {
      http.Response both = await api.get(
        '/api/posts?status=draft&status=published',
      );
      expect(api.json(both)['total'], 3);

      http.Response bob = await api.get(
        '/api/posts?author_id=${api.userIds['Bob']}',
      );
      expect(bob.statusCode, 200, reason: bob.body);
      expect(api.titles(api.json(bob)['data']), <String>['Bob first']);

      http.Response nobody = await api.get('/api/posts?author_id=99999');
      expect(nobody.statusCode, 422);
      expect(api.json(nobody), <String, dynamic>{
        'author_id': 'The selected author_id is invalid',
      });

      http.Response bad = await api.get('/api/posts?status=nope&per_page=abc');
      expect(bad.statusCode, 422);
      Map<String, dynamic> errors = api.json(bad);
      expect(errors['per_page'], 'The per_page must be an integer');
      expect(errors['status.0'], startsWith('The selected status is invalid'));
    });

    test('tag side of manyToMany', () async {
      http.Response res = await api.get('/api/tags/dart/posts');
      expect(res.statusCode, 200, reason: res.body);
      expect(api.titles(api.json(res)['posts']), <String>['Dart tips']);
    });

    test('users: where/orWhere search, pagination, count', () async {
      http.Response res = await api.get(
        '/api/users?search=%20bo%20&page=1&per_page=10',
      );
      expect(res.statusCode, 200, reason: res.body);
      Map<String, dynamic> page = api.json(res);
      expect(page['total'], 1);
      expect(page['data'].first['name'], 'Bob');

      http.Response all = await api.get('/api/users?per_page=2');
      expect(api.json(all)['total'], 3);
      expect((api.json(all)['data'] as List<dynamic>).length, 2);
    });

    test('users list: defaults, @Min, @Max, integer (422)', () async {
      http.Response plain = await api.get('/api/users');
      expect(plain.statusCode, 200, reason: plain.body);
      expect(api.json(plain)['per_page'], AppConstants.defaultPerPage);

      http.Response bad = await api.get('/api/users?page=0&per_page=101');
      expect(bad.statusCode, 422);
      expect(api.json(bad), <String, dynamic>{
        'page': 'The page must be greater than or equal 1',
        'per_page': 'The per_page must be less than or equal 100',
      });

      http.Response text = await api.get('/api/users?page=abc');
      expect(api.json(text), <String, dynamic>{
        'page': 'The page must be an integer',
      });
    });

    test('hasOne profile: create, then show user with relations', () async {
      http.Response res = await api.put(
        '/api/auth/me/profile',
        <String, dynamic>{'bio': 'I write Dart', 'website': 'https://a.dev'},
        token: 'Alice',
      );
      expect(res.statusCode, 200, reason: res.body);
      Map<String, dynamic> profile = api.json(res);
      expect(profile['bio'], 'I write Dart');
      expect(profile['user']['name'], 'Alice');

      http.Response user = await api.get('/api/users/${api.userIds['Alice']}');
      Map<String, dynamic> body = api.json(user);
      expect(body['profile']['website'], 'https://a.dev');
      expect(
        api.titles(body['posts']),
        unorderedEquals(<String>['Dart tips', 'Draft post v2']),
      );
      expect(body.containsKey('password'), false);
    });

    test('profile: @Url fails (422)', () async {
      http.Response res = await api.put(
        '/api/auth/me/profile',
        <String, dynamic>{'website': 'a.dev'},
        token: 'Alice',
      );
      expect(res.statusCode, 422);
      expect(api.json(res), <String, dynamic>{
        'website': 'The website must be a url',
      });
    });

    test('profile PATCH: Maybe<T> knows missing from null', () async {
      http.Response clear = await api.patch(
        '/api/auth/me/profile',
        <String, dynamic>{'bio': null},
        token: 'Alice',
      );
      expect(clear.statusCode, 200, reason: clear.body);
      expect(api.json(clear)['bio'], isNull);
      expect(api.json(clear)['website'], 'https://a.dev');

      http.Response set = await api.patch(
        '/api/auth/me/profile',
        <String, dynamic>{'bio': 'Back again'},
        token: 'Alice',
      );
      expect(api.json(set)['bio'], 'Back again');
      expect(api.json(set)['website'], 'https://a.dev');

      http.Response bad = await api.patch(
        '/api/auth/me/profile',
        <String, dynamic>{'website': 'nope'},
        token: 'Alice',
      );
      expect(bad.statusCode, 422);
      expect(api.json(bad), <String, dynamic>{
        'website': 'The website must be a url',
      });
    });

    test('missing user gives 404, /users/abc gives 404', () async {
      http.Response res = await api.get('/api/users/99999');
      expect(res.statusCode, 404);
      expect((await api.get('/api/users/abc')).statusCode, 404);
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
        'app_port': env.appPort,
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

      http.Response missing = await api.post(
        '/api/system/hash',
        <String, dynamic>{},
      );
      expect(missing.statusCode, 422);
      expect(api.json(missing), <String, dynamic>{
        'password': 'The password is required',
      });
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

  group('ORM: computed values, observers, transactions, whereNotIn', () {
    test('@Computed full_name and observer lowercases the email', () async {
      http.Response res = await api.post(
        '/api/auth/register',
        <String, dynamic>{
          'name': 'Dave',
          'first_name': 'Dave',
          'last_name': 'Grohl',
          'email': 'Dave@Mail.COM',
          'password': 'secret123',
          'password_confirmation': 'secret123',
        },
      );
      expect(res.statusCode, 201, reason: res.body);
      Map<String, dynamic> user = api.json(res);
      expect(user['email'], 'dave@mail.com');
      expect(user['full_name'], 'Dave Grohl');

      http.Response show = await api.get('/api/users/${user['id']}');
      Map<String, dynamic> body = api.json(show);
      expect(body['first_name'], 'Dave');
      expect(body['full_name'], 'Dave Grohl');
      expect(body.containsKey('password'), false);
    });

    test('login works with the lower case email', () async {
      http.Response res = await api.post('/api/auth/login', <String, dynamic>{
        'email': 'dave@mail.com',
        'password': 'secret123',
      });
      expect(res.statusCode, 200, reason: res.body);
      expect(api.json(res)['user']['full_name'], 'Dave Grohl');
    });

    test('transaction rolls back when it throws', () async {
      int before = api.json(await api.get('/api/tags?limit=100')).length;
      http.Response res = await api.post('/api/tags', <String, dynamic>{
        'names': <String>['alpha', 'beta'],
        'fail': true,
      });
      expect(res.statusCode, 200, reason: res.body);
      expect(api.json(res), <String, dynamic>{'saved': false, 'total': before});
    });

    test('transaction commits; DTO trims and lowercases', () async {
      int before = api.json(await api.get('/api/tags?limit=100')).length;
      http.Response res = await api.post('/api/tags', <String, dynamic>{
        'names': <String>[' Alpha ', 'BETA'],
      });
      expect(api.json(res), <String, dynamic>{
        'saved': true,
        'total': before + 2,
      });
      http.Response list = await api.get('/api/tags?limit=100');
      expect(api.names(api.json(list)), containsAll(<String>['alpha', 'beta']));
    });

    test('whereNotIn and limit from a coerced query', () async {
      http.Response res = await api.get(
        '/api/tags?limit=100&except=alpha,dart',
      );
      List<String> names = api.names(api.json(res));
      expect(names, isNot(contains('alpha')));
      expect(names, isNot(contains('dart')));
      expect(names, contains('beta'));

      http.Response two = await api.get('/api/tags?limit=2');
      expect((api.json(two) as List<dynamic>).length, 2);
    });
  });

  group('DTO validation', () {
    test('tags: @MinItems, @Length on items, @Range on a query', () async {
      http.Response res = await api.post('/api/tags', <String, dynamic>{
        'names': <String>[],
      });
      expect(res.statusCode, 422);
      expect(api.json(res), <String, dynamic>{
        'names': 'The names must have at least 1 items',
      });

      http.Response short = await api.post('/api/tags', <String, dynamic>{
        'names': <String>['ok', ' x '],
      });
      expect(api.json(short), <String, dynamic>{
        'names.1': 'The names must be between 2 and 100 characters',
      });

      http.Response query = await api.get('/api/tags?limit=abc');
      expect(query.statusCode, 422);
      expect(api.json(query), <String, dynamic>{
        'limit': 'The limit must be an integer',
      });

      http.Response range = await api.get('/api/tags?limit=0');
      expect(api.json(range), <String, dynamic>{
        'limit': 'The limit must be between 1 and 100',
      });
    });

    test('typed path param: int n, and abc gives 404', () async {
      http.Response ok = await api.get('/api/system/twice/21');
      expect(api.json(ok), <String, dynamic>{'result': 42});
      http.Response bad = await api.get('/api/system/twice/abc');
      expect(bad.statusCode, 404);
    });

    test('nested DTO and List<Dto> pass', () async {
      http.Response res = await api.post(
        '/api/system/orders',
        <String, dynamic>{
          'address': <String, dynamic>{
            'city': ' Bangkok ',
            'post_code': '10110',
          },
          'items': <dynamic>[
            <String, dynamic>{'name': 'Shoes', 'quantity': 2},
            <String, dynamic>{'name': 'Socks', 'quantity': 3},
          ],
        },
      );
      expect(res.statusCode, 200, reason: res.body);
      expect(api.json(res), <String, dynamic>{
        'city': 'Bangkok',
        'post_code': '10110',
        'items': <dynamic>[
          <String, dynamic>{'name': 'Shoes', 'quantity': 2},
          <String, dynamic>{'name': 'Socks', 'quantity': 3},
        ],
        'total_quantity': 5,
      });
    });

    test('nested DTO and List<Dto> fail with dotted keys', () async {
      http.Response res = await api.post(
        '/api/system/orders',
        <String, dynamic>{
          'address': <String, dynamic>{'city': 'Bangkok', 'post_code': '1011a'},
          'items': <dynamic>[
            <String, dynamic>{'name': 'Shoes', 'quantity': 2},
            <String, dynamic>{'name': 'Socks', 'quantity': 0},
            <String, dynamic>{'quantity': 100},
          ],
        },
      );
      expect(res.statusCode, 422);
      expect(api.json(res), <String, dynamic>{
        'address.post_code': 'The post_code format is invalid',
        'items.1.quantity': 'The quantity must be greater than or equal 1',
        'items.2.name': 'The name is required',
      });
    });

    test(
      '@Dto(strict: true) refuses unknown keys, @MinItems on a list',
      () async {
        http.Response res = await api.post(
          '/api/system/orders',
          <String, dynamic>{
            'address': <String, dynamic>{
              'city': 'Bangkok',
              'post_code': '10110',
            },
            'items': <dynamic>[],
            'coupon': 'FREE',
          },
        );
        expect(res.statusCode, 422);
        expect(api.json(res), <String, dynamic>{
          'coupon': 'The coupon field is not allowed',
        });
      },
    );

    test('cache: @Positive ttl, required owner (422)', () async {
      http.Response ttl = await api.put(
        '/api/cache/memory/items/x',
        <String, dynamic>{'value': 1, 'ttl': -5},
      );
      expect(ttl.statusCode, 422);
      expect(api.json(ttl), <String, dynamic>{
        'ttl': 'The ttl must be greater than 0',
      });

      http.Response owner = await api.delete('/api/cache/memory/locks/x');
      expect(owner.statusCode, 422);
      expect(api.json(owner), <String, dynamic>{
        'owner': 'The owner is required',
      });
    });
  });

  group('dox_openapi', () {
    test(
      '/docs (Scalar), /openapi.json and /openapi.yaml are served',
      () async {
        http.Response docs = await api.get('/docs');
        expect(docs.statusCode, 200);
        expect(docs.headers['content-type'], startsWith('text/html'));
        expect(docs.body.toLowerCase(), contains('scalar'));

        http.Response yaml = await api.get('/openapi.yaml');
        expect(yaml.statusCode, 200);
        expect(yaml.body, contains('openapi: "3.1.0"'));
      },
    );

    test('annotations and doc comments are in the document', () async {
      Map<String, dynamic> doc = api.json(await api.get('/openapi.json'));
      Map<String, dynamic> paths = doc['paths'];

      Map<String, dynamic> login = paths['/api/auth/login']['post'];
      expect(login['summary'], 'Log in');
      expect(login['description'], contains('Bearer'));
      expect(login['responses'], contains('401'));

      Map<String, dynamic> lock = paths['/api/cache/{store}/locks/{name}'];
      expect(lock['post']['tags'], <String>['Cache']);
      expect(lock['post']['responses'], contains('422'));

      expect(paths['/api/tags']['post']['tags'], <String>['Tag', 'ORM']);
      expect(paths['/api/auth/me']['get']['security'], isNotEmpty);
      expect(paths['/api/system/env']['get']['security'], <dynamic>[
        <String, dynamic>{'apiKey': <dynamic>[]},
      ]);

      Map<String, dynamic> user = doc['components']['schemas']['User'];
      expect(user['properties'], contains('first_name'));
      expect(user['properties'], isNot(contains('password')));

      // index routes inside a group have their own docs
      expect(paths['/api/users']['get']['summary'], 'List users');
      expect(paths['/api/posts']['get']['summary'], 'List posts');
    });

    test('request bodies and query params come from the DTOs', () async {
      Map<String, dynamic> doc = api.json(await api.get('/openapi.json'));
      Map<String, dynamic> paths = doc['paths'];

      Map<String, dynamic> register = paths['/api/auth/register']['post'];
      expect(register['responses'], contains('422'));
      Map<String, dynamic> schema = api.resolve(
        doc,
        register['requestBody']['content']['application/json']['schema'],
      );
      expect(
        schema['properties'].keys,
        containsAll(<String>['password_confirmation', 'first_name']),
      );
      expect(
        schema['required'],
        containsAll(<String>['name', 'email', 'password']),
      );

      List<dynamic> params = paths['/api/users']['get']['parameters'];
      expect(
        api.names(params),
        containsAll(<String>['page', 'per_page', 'search']),
      );
    });
  });

  group('dox_cache', () {
    for (String store in AppConstants.cacheStores) {
      test('$store: put, get, forget', () async {
        String path = '/api/cache/$store/items/user';
        http.Response put = await api.put(path, <String, dynamic>{
          'value': <String, dynamic>{'name': 'Ann'},
          'ttl': 60,
        });
        expect(put.statusCode, 200, reason: put.body);
        expect(api.json(await api.get(path)), <String, dynamic>{
          'key': 'user',
          'value': <String, dynamic>{'name': 'Ann'},
          'has': true,
        });
        expect(api.json(await api.delete(path))['forgot'], true);
        expect(api.json(await api.get(path))['has'], false);
      });

      test('$store: remember computes once', () async {
        String path = '/api/cache/$store/remember/now';
        Map<String, dynamic> first = api.json(
          await api.post(path, <String, dynamic>{}),
        );
        Map<String, dynamic> second = api.json(
          await api.post(path, <String, dynamic>{}),
        );
        expect(first['computed'], true);
        expect(second['computed'], false);
        expect(second['value'], first['value']);
      });

      test('$store: increment', () async {
        String path = '/api/cache/$store/increment/hits';
        expect(api.json(await api.post(path, <String, dynamic>{}))['value'], 1);
        expect(
          api.json(await api.post(path, <String, dynamic>{'by': 5}))['value'],
          6,
        );
      });

      test('$store: tags flush only their items', () async {
        String base = '/api/cache/$store/tags';
        await api.put('$base/users/a', <String, dynamic>{'value': 'Ann'});
        await api.put('$base/posts/a', <String, dynamic>{'value': 'Post'});
        await api.delete('$base/users');
        expect(api.json(await api.get('$base/users/a'))['value'], isNull);
        expect(api.json(await api.get('$base/posts/a'))['value'], 'Post');
      });
    }

    for (String store in <String>['memory', 'redis']) {
      test('$store: lock is held until its owner releases it', () async {
        String path = '/api/cache/$store/locks/report';
        Map<String, dynamic> first = api.json(
          await api.post(path, <String, dynamic>{}),
        );
        expect(first['got'], true);
        expect(
          api.json(await api.post(path, <String, dynamic>{}))['got'],
          false,
        );

        http.Response wrong = await api.delete('$path?owner=nobody');
        expect(api.json(wrong)['released'], false);
        http.Response right = await api.delete('$path?owner=${first['owner']}');
        expect(api.json(right)['released'], true);
        expect(
          api.json(await api.post(path, <String, dynamic>{}))['got'],
          true,
        );
      });
    }

    test('file store has no locks (422), unknown store (404)', () async {
      http.Response lock = await api.post(
        '/api/cache/file/locks/x',
        <String, dynamic>{},
      );
      expect(lock.statusCode, 422);
      http.Response unknown = await api.get('/api/cache/nope/items/x');
      expect(unknown.statusCode, 404);
    });
  });

  group('dox_storage', () {
    for (String disk in AppConstants.storageDisks) {
      test('$disk: upload, stream, download, signed URL, delete', () async {
        http.Response up = await api.upload(
          '/api/storage/$disk',
          'hello $disk',
          'note.txt',
        );
        expect(up.statusCode, 201, reason: up.body);
        String key = api.json(up)['key'];
        expect(key, startsWith('uploads/'));
        expect(key, endsWith('.txt'));

        http.Response stream = await api.get('/api/storage/$disk/stream/$key');
        expect(stream.statusCode, 200);
        expect(stream.body, 'hello $disk');

        http.Response down = await api.get('/api/storage/$disk/download/$key');
        expect(down.body, 'hello $disk');
        expect(down.headers['content-disposition'], startsWith('attachment'));

        String url = api.json(
          await api.get('/api/storage/$disk/signed/$key'),
        )['url'];
        if (disk != 'memory') {
          http.Response signed = await http.get(Uri.parse(url));
          expect(signed.statusCode, 200, reason: url);
          expect(signed.body, 'hello $disk');
        }

        http.Response del = await api.delete('/api/storage/$disk/files/$key');
        expect(api.json(del)['deleted'], true);
        http.Response gone = await api.get('/api/storage/$disk/stream/$key');
        expect(gone.statusCode, 404);
      });
    }

    test('Route.files: a changed signature gives 403', () async {
      http.Response up = await api.upload('/api/storage/local', 'x', 'a.txt');
      String key = api.json(up)['key'];
      String url = api.json(
        await api.get('/api/storage/local/signed/$key'),
      )['url'];
      expect((await http.get(Uri.parse('${url}0'))).statusCode, 403);
      expect((await api.get('/files/$key')).statusCode, 403);
    });
  });

  group('core: limits, ranges, proxies, playground', () {
    test('a JSON body over maxBodySize gives 413', () async {
      String big = 'a' * (1024 * 1024 + 10);
      http.Response res = await api.post('/api/system/echo', <String, dynamic>{
        'text': big,
      });
      expect(res.statusCode, 413);
    });

    test('an upload over maxMultipartSize gives 413', () async {
      http.Response res = await api.upload(
        '/api/storage/memory',
        'a' * (5 * 1024 * 1024 + 10),
        'big.txt',
      );
      expect(res.statusCode, 413);
    });

    test('a File response answers Range with 206', () async {
      http.Response up = await api.upload('/api/files', 'hello range', 'r.txt');
      String name = api.json(up)['name'];
      http.Response res = await api.get(
        '/api/files/$name/raw',
        headers: <String, String>{'Range': 'bytes=0-4'},
      );
      expect(res.statusCode, 206);
      expect(res.body, 'hello');
      expect(res.headers['content-range'], 'bytes 0-4/11');
      expect(res.headers['accept-ranges'], 'bytes');
    });

    test('trusted proxy: X-Forwarded-For and -Proto are used', () async {
      http.Response plain = await api.get('/api/system/ip');
      // dox_core gives the IPv4-mapped form here: ::ffff:127.0.0.1
      expect(api.json(plain)['ip'], endsWith('127.0.0.1'));
      expect(api.json(plain)['scheme'], 'http');

      http.Response proxied = await api.get(
        '/api/system/ip',
        headers: <String, String>{
          'X-Forwarded-For': '203.0.113.9',
          'X-Forwarded-Proto': 'https',
        },
      );
      expect(api.json(proxied), <String, dynamic>{
        'ip': '203.0.113.9',
        'scheme': 'https',
        'secure': true,
      });
    });

    test('GET /playground serves the test page', () async {
      http.Response res = await api.get('/playground');
      expect(res.statusCode, 200);
      expect(res.headers['content-type'], startsWith('text/html'));
      expect(res.body, contains('socket.io'));
    });
  });

  group('dox_socketio', () {
    test('connect to /chat gets welcome; ping is acked', () async {
      SioClient a = await SioClient.connect(api.sioUri);
      expect(await a.next('welcome'), contains('id'));
      expect(await a.emitWithAck('ping', null), 'pong');
      await a.close();
    });

    test('rooms: message reaches the room, not the sender', () async {
      SioClient a = await SioClient.connect(api.sioUri);
      SioClient b = await SioClient.connect(api.sioUri);
      SioClient outsider = await SioClient.connect(api.sioUri);
      expect(await a.emitWithAck('join', 'lobby'), <String, dynamic>{
        'joined': 'lobby',
      });
      await b.emitWithAck('join', 'lobby');
      Object? ack = await a.emitWithAck('message', <String, String>{
        'room': 'lobby',
        'text': 'hi',
      });
      expect(ack, 'sent');
      expect((await b.next('message'))['text'], 'hi');
      expect(await a.nothing('message'), true);
      expect(await outsider.nothing('message'), true);
      await a.close();
      await b.close();
      await outsider.close();
    });

    test('namespace middleware refuses an empty name', () async {
      SioClient c = await SioClient.connect(
        api.sioUri,
        auth: <String, String>{'name': ' '},
        expectError: true,
      );
      expect(c.connectError, 'name is empty');
      await c.close();
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
  Uri get sioUri => Uri.parse(
    'ws://127.0.0.1:${appConfig.serverPort}/socket.io/?EIO=4&transport=websocket',
  );

  Future<void> boot() async {
    await Bootstrap(migrations).start(freshDatabase: true);
    for (String store in AppConstants.cacheStores) {
      await Cache().store(store).flush();
    }
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
      headers[AppConstants.apiKeyHeader] = env.apiKey;
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

  /// A 1x1 png, to pass `@Image()`.
  static final List<int> tinyPng = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
  );

  Future<http.Response> patch(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) {
    return http.patch(
      uri(path),
      headers: _headers(token, true),
      body: jsonEncode(body),
    );
  }

  /// POST a raw JSON text, like `[1, 2]`.
  Future<http.Response> postRaw(String path, String body) {
    return http.post(uri(path), headers: _headers(null, true), body: body);
  }

  /// multipart/form-data with one file field and some text fields
  Future<http.Response> uploadBytes(
    String path,
    String field,
    List<int> bytes,
    String filename, {
    Map<String, String> fields = const <String, String>{},
  }) async {
    http.MultipartRequest req = http.MultipartRequest('POST', uri(path));
    req.fields.addAll(fields);
    req.files.add(
      http.MultipartFile.fromBytes(field, bytes, filename: filename),
    );
    return http.Response.fromStream(await req.send());
  }

  /// Follows a `$ref` to `#/components/schemas/...`.
  Map<String, dynamic> resolve(
    Map<String, dynamic> doc,
    Map<String, dynamic> schema,
  ) {
    String? ref = schema[r'$ref'];
    if (ref == null) {
      return schema;
    }
    return doc['components']['schemas'][ref.split('/').last];
  }

  /// multipart/form-data with one `file` field
  Future<http.Response> upload(
    String path,
    String text,
    String filename,
  ) async {
    http.MultipartRequest req = http.MultipartRequest('POST', uri(path));
    req.fields['note'] = 'upload';
    req.files.add(
      http.MultipartFile.fromString('file', text, filename: filename),
    );
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

/// Tiny Socket.IO client on a raw websocket (Engine.IO v4, Socket.IO v5),
/// for the /chat namespace. The browser playground uses the real JS client.
class SioClient {
  static const String nsp = AppConstants.chatNamespace;

  final WebSocket socket;
  final List<List<dynamic>> _events = <List<dynamic>>[];
  final Map<int, Object?> _acks = <int, Object?>{};
  final Completer<void> _ready = Completer<void>();
  String? connectError;
  int _nextAck = 0;

  SioClient(this.socket) {
    socket.listen(_onData);
  }

  static Future<SioClient> connect(
    Uri uri, {
    Map<String, String>? auth,
    bool expectError = false,
  }) async {
    SioClient client = SioClient(await WebSocket.connect(uri.toString()));
    client.socket.add('40$nsp,${jsonEncode(auth ?? <String, String>{})}');
    await client._ready.future.timeout(Duration(seconds: 2));
    if (!expectError && client.connectError != null) {
      throw StateError('connect_error: ${client.connectError}');
    }
    return client;
  }

  void _onData(dynamic data) {
    String text = data.toString();
    if (text == '2') {
      socket.add('3'); // Engine.IO ping -> pong
      return;
    }
    if (!text.startsWith('4')) {
      return; // Engine.IO open packet
    }
    String packet = text.substring(1);
    String type = packet[0];
    String rest = packet.substring(1);
    if (rest.startsWith('$nsp,')) {
      rest = rest.substring(nsp.length + 1);
    }
    if (type == '0') {
      _ready.complete();
    } else if (type == '4') {
      connectError = jsonDecode(rest)['message'];
      _ready.complete();
    } else if (type == '2') {
      _events.add(jsonDecode(rest));
    } else if (type == '3') {
      int start = rest.indexOf('[');
      List<dynamic> args = jsonDecode(rest.substring(start));
      _acks[int.parse(rest.substring(0, start))] = args.isEmpty
          ? null
          : args.first;
    }
  }

  /// Emit an event and wait up to 2 seconds for the server ack.
  Future<Object?> emitWithAck(String event, Object? data) async {
    int id = _nextAck++;
    List<Object?> args = data == null
        ? <Object?>[event]
        : <Object?>[event, data];
    socket.add('42$nsp,$id${jsonEncode(args)}');
    for (int i = 0; i < 40; i++) {
      if (_acks.containsKey(id)) {
        return _acks.remove(id);
      }
      await Future<void>.delayed(Duration(milliseconds: 50));
    }
    throw TimeoutException('no ack for "$event"');
  }

  /// Wait up to 2 seconds for an event, return its first argument.
  Future<dynamic> next(String event) async {
    for (int i = 0; i < 40; i++) {
      for (List<dynamic> e in _events) {
        if (e.first == event) {
          _events.remove(e);
          return e.length > 1 ? e[1] : null;
        }
      }
      await Future<void>.delayed(Duration(milliseconds: 50));
    }
    throw TimeoutException('no "$event" event');
  }

  /// True when the event does not come within 300 ms.
  Future<bool> nothing(String event) async {
    await Future<void>.delayed(Duration(milliseconds: 300));
    for (List<dynamic> e in _events) {
      if (e.first == event) {
        return false;
      }
    }
    return true;
  }

  Future<void> close() async {
    await socket.close();
  }
}
