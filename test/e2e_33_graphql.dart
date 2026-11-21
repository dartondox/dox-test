import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dox_orm/dox_orm.dart'
    show QueryBuilder, QueryEvent, SqlQueryBuilder;
import 'package:dox_test/app/graphql/e33.resolver.dart';
import 'package:dox_test/app/models/comment/comment.model.dart';
import 'package:dox_test/app/models/gql_secret/gql_secret.model.dart';
import 'package:dox_test/app/models/post/post.model.dart';
import 'package:dox_test/app/policies/post.policy.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'e2e_310_core.dart' show PortApi, registerUser;
import 'e2e_test.dart' show Api;

/// 3.3 GraphQL checks (dox_graphql): the HTTP rules of /graphql, auth,
/// PostPolicy and GqlSecretPolicy, and the limits. e2e_test.dart calls
/// it, so it shares the server and the database of that file.
void graphqlTests(Api api) {
  // one group, so the setUpAll runs only when these tests start
  group('3.3 dox_graphql', () {
    Gql gql = Gql(api);

    /// the user ids, by short name
    Map<String, int> ids = <String, int>{};

    /// post ids: ann's public, bob's public, bob's secret, bob's big one
    late int annPost, bobPost, bobSecret, bigPost;

    /// ann's two secrets: one to bob's secret post, one to bob's public one
    late int annSecretA, bobSecretRow;

    setUpAll(() async {
      Map<String, String> users = <String, String>{
        'ann': 'GQL Ann',
        'bob': 'GQL Bob',
        'blind': PostPolicy.blind,
        'nocreate': PostPolicy.noCreate,
      };
      for (MapEntry<String, String> u in users.entries) {
        String email = 'gql.${u.key}@mail.com';
        await registerUser(api, u.value, email);
        http.Response res = await api.post('/api/auth/login', <String, dynamic>{
          'email': email,
          'password': 'secret123',
        });
        expect(res.statusCode, 200, reason: res.body);
        Map<String, dynamic> body = api.json(res);
        api.tokens['gql.${u.key}'] = body['token'];
        ids[u.key] = body['user']['id'] as int;
      }
      Future<int> post(
        String who,
        String title, {
        String status = 'draft',
      }) async {
        Post p = Post()
          ..userId = ids[who]
          ..title = title
          ..body = 'body of $title'
          ..status = status;
        await p.save();
        return p.id as int;
      }

      annPost = await post('ann', 'gql ann public');
      bobPost = await post('bob', 'gql bob public');
      bobSecret = await post(
        'bob',
        'gql bob hidden',
        status: PostPolicy.secret,
      );
      bigPost = await post('bob', 'gql bob big');
      // 21 more posts of ann, so the list has more than 20 rows
      for (int i = 0; i < 21; i++) {
        await post('ann', 'gql ann filler $i');
      }
      // 1 comment on ann's post; 3 posts of `nocreate` with 1 comment
      // each (3 rows in one batch); the big post with 6
      await (Comment()
            ..postId = annPost
            ..userId = ids['ann']
            ..body = 'gql ann comment')
          .save();
      for (int i = 0; i < 3; i++) {
        await (Comment()
              ..postId = await post('nocreate', 'gql few $i')
              ..userId = ids['ann']
              ..body = 'gql comment $i')
            .save();
      }
      for (int i = 0; i < 6; i++) {
        await (Comment()
              ..postId = bigPost
              ..userId = ids['bob']
              ..body = 'gql big comment $i')
            .save();
      }
      Future<int> secret(String who, int postId) async {
        GqlSecret s = GqlSecret()
          ..userId = ids[who]
          ..postId = postId
          ..body = '$who secret';
        await s.save();
        return s.id as int;
      }

      annSecretA = await secret('ann', bobSecret);
      await secret('ann', bobPost);
      bobSecretRow = await secret('bob', bobPost);
    });

    group('HTTP', () {
      test('POST {__typename} gives the root type', () async {
        http.Response res = await gql.post('{ __typename }');
        expect(res.statusCode, 200, reason: res.body);
        expect(jsonDecode(res.body), <String, dynamic>{
          'data': <String, dynamic>{'__typename': 'Query'},
        });
      });

      test('GET runs a query', () async {
        http.Response res = await gql.get(<String, String>{
          'query': '{ __typename }',
        });
        expect(res.statusCode, 200, reason: res.body);
        expect(jsonDecode(res.body)['data'], <String, dynamic>{
          '__typename': 'Query',
        });
      });

      test('GET with a mutation gives 405 and Allow: POST', () async {
        http.Response res = await gql.get(<String, String>{
          'query': 'mutation { deletePost(id: "1") }',
        });
        expect(res.statusCode, 405, reason: res.body);
        expect(res.headers['allow'], 'POST');
      });

      test('text/plain gives 415', () async {
        http.Response res = await http.post(
          gql.uri(),
          headers: <String, String>{'Content-Type': 'text/plain'},
          body: '{ __typename }',
        );
        expect(res.statusCode, 415, reason: res.body);
      });

      test('a bad JSON body gives 400', () async {
        http.Response res = await gql.raw('{"query": ');
        expect(res.statusCode, 400, reason: res.body);
      });

      test('a JSON array body gives 400', () async {
        http.Response res = await gql.raw('[{"query": "{ __typename }"}]');
        expect(res.statusCode, 400, reason: res.body);
      });

      test('graphql-response+json: a syntax error gives 400', () async {
        http.Response res = await gql.post(
          '{ posts { ',
          headers: <String, String>{
            'Accept': 'application/graphql-response+json',
          },
        );
        expect(res.statusCode, 400, reason: res.body);
        expect(res.headers['content-type'], contains('graphql-response+json'));
        expect(jsonDecode(res.body)['errors'], isNotEmpty);
      });

      test('GraphiQL is served in development', () async {
        http.Response res = await http.get(
          gql.uri(),
          headers: <String, String>{'Accept': 'text/html'},
        );
        expect(res.statusCode, 200);
        expect(res.headers['content-type'], contains('text/html'));
        expect(res.body.toLowerCase(), contains('graphiql'));
      });

      test('development shows the text of an internal error', () async {
        Map<String, dynamic> body = await gql.run('{ gqlBoom }');
        expect(body['errors'].first['message'], contains('e33 secret detail'));
      });
    });

    group('a production server', () {
      Process? server;
      StringBuffer log = StringBuffer();
      late Gql prod;

      setUpAll(() async {
        ServerSocket free = await ServerSocket.bind('127.0.0.1', 0);
        int p = free.port;
        await free.close();
        prod = Gql(PortApi(p));
        Process proc = await Process.start(
          'dart',
          <String>['run', 'bin/e2e_isolates.dart'],
          environment: <String, String>{
            'APP_PORT': '$p',
            'APP_URL': 'http://127.0.0.1:$p',
            'APP_ENV': 'production',
          },
        );
        server = proc;
        proc.stdout.transform(utf8.decoder).listen(log.write);
        proc.stderr.transform(utf8.decoder).listen(log.write);
        for (int i = 0; i < 240; i++) {
          try {
            http.Response res = await prod.post('{ __typename }');
            if (res.statusCode == 200) return;
          } on Object {
            // not up yet
          }
          await Future<void>.delayed(Duration(milliseconds: 250));
        }
        fail('the production server did not start: $log');
      });

      tearDownAll(() async {
        server?.kill();
        await server?.exitCode;
      });

      test('introspection is off', () async {
        Map<String, dynamic> body = await prod.run(
          '{ __schema { types { name } } }',
        );
        expect(body['data'], isNull, reason: '$body');
        expect(body['errors'], isNotEmpty);
      });

      test('the text of an internal error is hidden', () async {
        Map<String, dynamic> body = await prod.run('{ gqlBoom }');
        String text = jsonEncode(body);
        expect(text, isNot(contains('e33 secret detail')));
        expect(body['errors'].first['message'], 'Internal server error');
      });

      test('GraphiQL is not served', () async {
        http.Response res = await http.get(
          prod.uri(),
          headers: <String, String>{'Accept': 'text/html'},
        );
        expect(res.headers['content-type'] ?? '', isNot(contains('text/html')));
      });
    }, timeout: Timeout(Duration(minutes: 3)));

    group('auth', () {
      test('a guest lists posts', () async {
        Map<String, dynamic> body = await gql.run('{ posts { id title } }');
        expect(body['errors'], isNull, reason: '$body');
        expect(body['data']['posts'], isNotEmpty);
      });

      test('a guest gets UNAUTHENTICATED for users', () async {
        Map<String, dynamic> body = await gql.run('{ users { id } }');
        expect(codes(body), <Object?>['UNAUTHENTICATED']);
        Map<String, dynamic> ok = await gql.run(
          '{ users { id } }',
          token: 'gql.ann',
        );
        expect(ok['errors'], isNull, reason: '$ok');
      });

      for (MapEntry<String, String> c in <String, String>{
        'a field': '{ post(id: "ID") { title author { id } } }',
        'an alias': '{ post(id: "ID") { title who: author { id } } }',
        'a named fragment': '{ post(id: "ID") { title ...F } } fragment F on Post { author { id } }',
        'an inline fragment':
            '{ post(id: "ID") { title ... on Post { author { id } } } }',
      }.entries) {
        test('a guest gets partial data for post.author through '
            '${c.key}', () async {
          Map<String, dynamic> body = await gql.run(
            c.value.replaceAll('ID', '$annPost'),
          );
          expect(
            body['data']['post']['title'],
            'gql ann public',
            reason: '$body',
          );
          expect(codes(body), <Object?>['UNAUTHENTICATED']);
          expect(
            jsonEncode(body['data']),
            isNot(contains('"id":"${ids['ann']}"')),
          );
        });
      }

      test(
        'a guest gets partial data for post.comments (login needed)',
        () async {
          Map<String, dynamic> body = await gql.run(
            '{ post(id: "$annPost") { title comments { id } } }',
          );
          expect(codes(body), <Object?>['UNAUTHENTICATED'], reason: '$body');
          // comments is nullable (`[Comment!]`), so `post` keeps its title
          expect(
            body['data']['post']?['title'],
            'gql ann public',
            reason: '$body',
          );
          expect(body['data']['post']?['comments'], isNull);
        },
      );

      test('a bad token on a public field still gives data', () async {
        http.Response res = await gql.post(
          '{ post(id: "$annPost") { title } }',
          headers: <String, String>{'Authorization': 'Bearer not-a-token'},
        );
        Map<String, dynamic> body = jsonDecode(res.body);
        expect(
          body['data']['post']['title'],
          'gql ann public',
          reason: res.body,
        );
        expect(body['errors'], isNull);
      });

      test('password is not in the schema', () async {
        Map<String, dynamic> type = await gql.run(
          '{ __type(name: "User") { fields { name } } }',
        );
        List<dynamic> fields = type['data']['__type']['fields'];
        List<String> names = <String>[for (dynamic f in fields) f['name']];
        expect(names, contains('email'));
        expect(names, isNot(contains('password')));
        Map<String, dynamic> body = await gql.run(
          '{ users { password } }',
          token: 'gql.ann',
        );
        expect(body['data'], isNull);
        expect(body['errors'].first['message'], contains('password'));
      });
    });

    group('policies', () {
      Future<Map<String, dynamic>?> row(int id) async {
        return await QueryBuilder.table('posts').where('id', id).getFirst();
      }

      test('createPost sets userId to the caller', () async {
        Map<String, dynamic> body = await gql.run(
          'mutation { createPost(input: {title: "gql made", body: "b"}) '
          '{ id title userId } }',
          token: 'gql.ann',
        );
        expect(body['errors'], isNull, reason: '$body');
        Map<String, dynamic> made = body['data']['createPost'];
        expect(made['userId'], ids['ann']);
        Map<String, dynamic>? saved = await row(int.parse('${made['id']}'));
        expect(saved?['user_id'], ids['ann']);
      });

      test('userId in the input is a validation error', () async {
        int before = await postCount();
        Map<String, dynamic> body = await gql.run(
          'mutation { createPost(input: {title: "gql hack", '
          'userId: ${ids['bob']}}) { id } }',
          token: 'gql.ann',
        );
        expect(body['data'], isNull, reason: '$body');
        expect(body['errors'].first['message'], contains('userId'));
        expect(await postCount(), before);
      });

      test('a guest create is UNAUTHENTICATED and saves no row', () async {
        int before = await postCount();
        Map<String, dynamic> body = await gql.run(
          'mutation { createPost(input: {title: "gql guest"}) { id } }',
        );
        expect(codes(body), <Object?>['UNAUTHENTICATED']);
        expect(await postCount(), before);
      });

      test(
        'a create the policy denies is FORBIDDEN and saves no row',
        () async {
          int before = await postCount();
          Map<String, dynamic> body = await gql.run(
            'mutation { createPost(input: {title: "gql denied"}) { id } }',
            token: 'gql.nocreate',
          );
          expect(codes(body), <Object?>['FORBIDDEN']);
          expect(await postCount(), before);
        },
      );

      test(
        'the owner updates and deletes, another user is FORBIDDEN',
        () async {
          Map<String, dynamic> made = await gql.run(
            'mutation { createPost(input: {title: "gql mine"}) { id } }',
            token: 'gql.ann',
          );
          String id = made['data']['createPost']['id'];
          Map<String, dynamic> other = await gql.run(
            'mutation { updatePost(id: "$id", input: {title: "gql stolen"}) '
            '{ title } }',
            token: 'gql.bob',
          );
          expect(codes(other), <Object?>['FORBIDDEN']);
          Map<String, dynamic> del = await gql.run(
            'mutation { deletePost(id: "$id") }',
            token: 'gql.bob',
          );
          expect(codes(del), <Object?>['FORBIDDEN']);
          expect((await row(int.parse(id)))?['title'], 'gql mine');
          expect((await row(int.parse(id)))?['deleted_at'], isNull);

          Map<String, dynamic> up = await gql.run(
            'mutation { updatePost(id: "$id", input: {title: "gql renamed"}) '
            '{ title } }',
            token: 'gql.ann',
          );
          expect(
            up['data']['updatePost']['title'],
            'gql renamed',
            reason: '$up',
          );
          Map<String, dynamic> gone = await gql.run(
            'mutation { deletePost(id: "$id") }',
            token: 'gql.ann',
          );
          expect(gone['data']['deletePost'], true, reason: '$gone');
        },
      );

      test('a guest update is UNAUTHENTICATED before the lookup', () async {
        List<String> sql = <String>[];
        void listen(QueryEvent e) => sql.add(e.sql);
        SqlQueryBuilder().listen(listen);
        try {
          for (String id in <String>['$annPost', '99999999']) {
            Map<String, dynamic> body = await gql.run(
              'mutation { updatePost(id: "$id", input: {title: "gql x"}) '
              '{ id } }',
            );
            expect(codes(body), <Object?>['UNAUTHENTICATED'], reason: id);
          }
        } finally {
          SqlQueryBuilder().removeListener(listen);
        }
        expect(sql.where((String q) => q.contains('posts')), isEmpty);
        expect((await row(annPost))?['title'], 'gql ann public');
      });

      test('a missing id and the id of another user give the same '
          'answer', () async {
        Map<String, dynamic> answer(Map<String, dynamic> body) =>
            <String, dynamic>{'data': body['data'], 'codes': codes(body)};
        for (String q in <String>[
          'mutation { updatePost(id: "ID", input: {title: "gql x"}) { id } }',
          'mutation { deletePost(id: "ID") }',
          '{ post(id: "ID") { title } }',
        ]) {
          Map<String, dynamic> other = await gql.run(
            q.replaceAll('ID', '$bobSecret'),
            token: 'gql.ann',
          );
          Map<String, dynamic> missing = await gql.run(
            q.replaceAll('ID', '99999999'),
            token: 'gql.ann',
          );
          expect(answer(missing), answer(other), reason: q);
          expect(codes(other), <Object?>['FORBIDDEN'], reason: q);
        }
        expect((await row(bobSecret))?['title'], 'gql bob hidden');
      });

      test(
        'viewAny denied: the list is FORBIDDEN, a relation only filters',
        () async {
          Map<String, dynamic> body = await gql.run(
            '{ posts { id } }',
            token: 'gql.blind',
          );
          // only the refused field is null: every root field is nullable
          expect(body['data'], <String, dynamic>{
            'posts': null,
          }, reason: '$body');
          expect(codes(body), <Object?>['FORBIDDEN']);
          Map<String, dynamic> rel = await gql.run(
            '{ user(id: "${ids['ann']}") { name posts { id } } }',
            token: 'gql.blind',
          );
          // a relation asks no viewAny: `filter: view` keeps ann's posts
          expect(rel['errors'], isNull, reason: '$rel');
          expect(rel['data']['user']?['name'], 'GQL Ann', reason: '$rel');
          expect(rel['data']['user']?['posts'], isNotEmpty);
        },
      );

      test('view drops a secret post from the list and every relation '
          'path', () async {
        List<String> titles = <String>[];
        for (int offset = 0; ; offset += 100) {
          Map<String, dynamic> page = await gql.run(
            '{ posts(limit: 100, offset: $offset) { title } }',
            token: 'gql.ann',
          );
          List<dynamic> rows = page['data']['posts'];
          titles.addAll(<String>[for (dynamic r in rows) r['title']]);
          if (rows.length < 100) break;
        }
        expect(titles, contains('gql bob public'));
        expect(titles, isNot(contains('gql bob hidden')));

        Map<String, dynamic> body = await gql.run(
          '{ user(id: "${ids['bob']}") { posts { title } } '
          'gqlSecrets { id post { title author { posts { title } } } } }',
          token: 'gql.ann',
        );
        expect(body['errors'], isNull, reason: '$body');
        String text = jsonEncode(body);
        expect(text, contains('gql bob public'));
        expect(text, isNot(contains('gql bob hidden')));
        // the single relation of ann's secret to bob's secret post is null
        Map<String, dynamic> a = (body['data']['gqlSecrets'] as List<dynamic>)
            .firstWhere((dynamic s) => s['id'] == '$annSecretA');
        expect(a['post'], isNull);

        // bob sees his own secret post
        Map<String, dynamic> mine = await gql.run(
          '{ post(id: "$bobSecret") { title } }',
          token: 'gql.bob',
        );
        expect(mine['data']['post']['title'], 'gql bob hidden');
      });

      test('a policy with renamed methods is enforced', () async {
        Map<String, dynamic> list = await gql.run(
          '{ gqlSecrets { id userId } }',
          token: 'gql.ann',
        );
        List<dynamic> rows = list['data']['gqlSecrets'];
        expect(rows, hasLength(2), reason: '$list');
        for (dynamic r in rows) {
          expect(r['userId'], ids['ann']);
        }
        Map<String, dynamic> one = await gql.run(
          '{ gqlSecret(id: "$bobSecretRow") { body } }',
          token: 'gql.ann',
        );
        expect(codes(one), <Object?>['FORBIDDEN']);
        Map<String, dynamic> blind = await gql.run(
          '{ gqlSecrets { id } }',
          token: 'gql.blind',
        );
        expect(codes(blind), <Object?>['FORBIDDEN']);
      });

      test('VALIDATION_FAILED names the fields', () async {
        Map<String, dynamic> body = await gql.run(
          'mutation { createPost(input: {title: "ab"}) { id } }',
          token: 'gql.ann',
        );
        expect(codes(body), <Object?>['VALIDATION_FAILED'], reason: '$body');
        Map<String, dynamic> ext = body['errors'].first['extensions'];
        expect(ext['fields'], contains('title'));
      });

      test('two mutations run in order', () async {
        Map<String, dynamic> body = await gql.run(
          'mutation { a: createPost(input: {title: "gql order 1"}) { id } '
          'b: createPost(input: {title: "gql order 2"}) { id } }',
          token: 'gql.ann',
        );
        expect(body['errors'], isNull, reason: '$body');
        int a = int.parse(body['data']['a']['id']);
        int b = int.parse(body['data']['b']['id']);
        expect(b, greaterThan(a));
      });
    });

    group('limits', () {
      test('limit 101 and -1 are errors, the default is 20', () async {
        Map<String, dynamic> big = await gql.run(
          '{ posts(limit: 101) { id } }',
        );
        expect(big['errors'].first['message'], contains('at most 100'));
        Map<String, dynamic> neg = await gql.run('{ posts(limit: -1) { id } }');
        expect(neg['errors'].first['message'], contains('negative'));
        // as bob: he sees every post, also his secret one
        Map<String, dynamic> def = await gql.run(
          '{ posts { id } }',
          token: 'gql.bob',
        );
        expect(def['data']['posts'], hasLength(20));
      });

      test('51 root aliases are rejected before any resolver, 50 run', () async {
        String aliases(int n) =>
            '{ ${<String>[for (int i = 0; i < n; i++) 'h$i: gqlHits'].join(' ')} }';
        int before = E33Resolver.hits;
        Map<String, dynamic> no = await gql.run(aliases(51));
        expect(no['data'], isNull, reason: '$no');
        expect(no['errors'], isNotEmpty);
        expect(E33Resolver.hits, before);
        Map<String, dynamic> ok = await gql.run(aliases(50));
        expect(ok['errors'], isNull, reason: '$ok');
        expect(E33Resolver.hits, before + 50);
      });

      test('a query nested 65 deep is rejected', () async {
        // posts { author { posts { author ... } } }: 65 selection sets
        StringBuffer q = StringBuffer();
        for (int i = 0; i < 64; i++) {
          q.write(i.isEven ? 'posts { ' : 'author { ');
        }
        q.write('id');
        q.write(' }' * 64);
        Map<String, dynamic> body = await gql.run('{ $q }', token: 'gql.ann');
        expect(body['data'], isNull);
        expect(body['errors'].first['message'], contains('too deep'));
      });

      test('a fragment cycle is rejected', () async {
        Map<String, dynamic> body = await gql.run(
          '{ posts { ...A } } '
          'fragment A on Post { author { ...B } } '
          'fragment B on User { posts { ...A } }',
          token: 'gql.ann',
        );
        expect(body['data'], isNull, reason: '$body');
        expect(body['errors'], isNotEmpty);
      });

      test('a relation over maxRelationRows is an error, many small ones '
          'are not', () async {
        Map<String, dynamic> big = await gql.run(
          '{ post(id: "$bigPost") { title comments { id } } }',
          token: 'gql.bob',
          path: '/graphql-small',
        );
        // only the capped relation is null: every relation is nullable
        expect(big['data'], <String, dynamic>{
          'post': <String, dynamic>{'title': 'gql bob big', 'comments': null},
        }, reason: '$big');
        expect(big['errors'].first['message'], contains('Post.comments'));
        Map<String, dynamic> small = await gql.run(
          '{ user(id: "${ids['nocreate']}") { posts { comments { id } } } }',
          token: 'gql.ann',
          path: '/graphql-small',
        );
        expect(small['errors'], isNull, reason: '$small');
        List<dynamic> posts = small['data']['user']['posts'];
        int comments = 0;
        for (dynamic p in posts) {
          comments += (p['comments'] as List<dynamic>).length;
        }
        expect(comments, 3);
      });

      test('no N+1: the query count does not grow with the rows', () async {
        Future<int> count(int limit) async {
          List<String> sql = <String>[];
          // the listener sees every query of the isolate, also the queue
          // worker and the scheduler (eg. a user count). Count only the
          // row reads of the tables in this GraphQL query.
          RegExp tables = RegExp(r'\b(posts|comments|users)\b');
          void listen(QueryEvent e) {
            String q = e.sql.toLowerCase();
            if (tables.hasMatch(q) && !q.contains('count(')) sql.add(e.sql);
          }
          SqlQueryBuilder().listen(listen);
          try {
            Map<String, dynamic> body = await gql.run(
              '{ user(id: "${ids['ann']}") { posts { comments { id user '
              '{ id } } author { id } } } posts(limit: $limit) '
              '{ comments { id } author { id } } }',
              token: 'gql.ann',
            );
            expect(body['errors'], isNull, reason: '$body');
          } finally {
            SqlQueryBuilder().removeListener(listen);
          }
          printOnFailure('limit $limit: ${sql.join('\n')}');
          return sql.length;
        }

        // one query per relation and level (some batch together), never
        // one per row: 25 posts with N+1 would be more than 25 queries
        int few = await count(2);
        int many = await count(25);
        expect(few, lessThan(12));
        expect(many, lessThan(12));
        expect(many, lessThanOrEqualTo(few));
      });
    });
  });
}

Future<int> postCount() async {
  return await QueryBuilder.table('posts').count();
}

/// The `extensions.code` of each error.
List<Object?> codes(Map<String, dynamic> body) {
  List<dynamic> errors = body['errors'] as List<dynamic>? ?? <dynamic>[];
  return <Object?>[
    for (dynamic e in errors)
      (e['extensions'] as Map<String, dynamic>?)?['code'],
  ];
}

/// Calls /graphql of [api].
class Gql {
  Gql(this.api);

  final Api api;

  Uri uri([String path = '/graphql']) => api.uri(path);

  Future<http.Response> post(
    String query, {
    String? token,
    Map<String, String>? headers,
    String path = '/graphql',
  }) {
    return http.post(
      uri(path),
      headers: <String, String>{
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer ${api.tokens[token]}',
        ...?headers,
      },
      body: jsonEncode(<String, dynamic>{'query': query}),
    );
  }

  Future<http.Response> get(Map<String, String> params) {
    return http.get(uri().replace(queryParameters: params));
  }

  Future<http.Response> raw(String body) {
    return http.post(
      uri(),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: body,
    );
  }

  /// POST [query], give the JSON answer.
  Future<Map<String, dynamic>> run(
    String query, {
    String? token,
    String path = '/graphql',
  }) async {
    http.Response res = await post(query, token: token, path: path);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
