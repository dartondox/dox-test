import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dox_core/dox_core.dart' show KeyDerivation;
import 'package:dox_orm/dox_orm.dart';
import 'package:dox_test/app/models/badge/badge.model.dart';
import 'package:dox_test/app/models/post/post.model.dart';
import 'package:dox_test/app/models/reaction/reaction.model.dart';
import 'package:dox_test/app/models/tag/tag.model.dart';
import 'package:dox_test/app/models/user/user.model.dart';
import 'package:dox_test/config/database.dart';
import 'package:dox_test/config/env.dart';
import 'package:dox_test/constants/app_constants.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'e2e_test.dart' show Api;

/// End to end checks of the 3.1.0 ORM, validation, driver and storage
/// features. They run after the other groups of e2e_test.dart, on the same
/// server and database, and share state in the order they are written.
void ormTests(Api api) {
  OrmData data = OrmData();

  group('3.1 ORM: badges over HTTP', () {
    setUpAll(data.seed);

    test(
      'create: fillable map, json column, attach with pivot values',
      () async {
        http.Response res = await api.post('/api/badges', <String, dynamic>{
          'name': ' Gold ',
          'code': '0042',
          'meta': '{"color":"gold","tags":["top","new"]}',
          'score': 90,
          'post_ids': <int>[data.posts[0], data.posts[1]],
        });
        expect(res.statusCode, 201, reason: res.body);
        Map<String, dynamic> body = api.json(res);
        data.badges['Gold'] = body['id'];
        expect(body['name'], 'Gold');
        expect(body['meta'], <String, dynamic>{
          'color': 'gold',
          'tags': <String>['top', 'new'],
        });
        expect(body['reactions_count'], 0);
        expect(body['posts_exists'], true);
        List<dynamic> posts = body['posts'];
        // a preload has no ORDER BY, so compare as a set
        expect(posts.map(_id).toSet(), <int>{data.posts[0], data.posts[1]});
        // the pivot is not in the JSON (see todo.md), so read it in code
        for (Post post in await data.postsOf('Gold')) {
          expect(post.pivot['note'], 'first');
          expect(post.pivot['created_at'], isNotNull);
          expect(post.pivot['badge_id'], data.badges['Gold']);
        }
      },
    );

    test('create: Laravel-style rules (422)', () async {
      http.Response res = await api.post('/api/badges', <String, dynamic>{
        'name': 'Gold',
        'code': '42',
        'meta': '{bad json',
      });
      expect(res.statusCode, 422);
      expect(api.json(res), <String, dynamic>{
        'code': 'The code must be 4 digits',
        'meta': 'The meta is not a valid json',
      });
    });

    test('create: the database rules run when the rest is good', () async {
      http.Response res = await api.post('/api/badges', <String, dynamic>{
        'name': 'Gold',
        'aliases': <String>['Free name', 'Gold'],
        'post_ids': <int>[data.posts[0], 999999],
      });
      expect(res.statusCode, 422);
      // a list is one query, and the error names the bad item
      expect(api.json(res), <String, dynamic>{
        'name': 'The name has already been taken',
        'aliases.1': 'The aliases has already been taken',
        'post_ids.1': 'The selected post_ids is invalid',
      });
    });

    test('create more badges for the pages', () async {
      Map<String, int> scores = <String, int>{
        'Silver': 70,
        'Bronze': 50,
        'Iron': 50,
        'Wood': 10,
      };
      for (MapEntry<String, int> e in scores.entries) {
        http.Response res = await api.post('/api/badges', <String, dynamic>{
          'name': e.key,
          'score': e.value,
          'aliases': <String>['${e.key} 2'],
        });
        expect(res.statusCode, 201, reason: res.body);
        data.badges[e.key] = api.json(res)['id'];
      }
    });

    test(
      'cursorPaginate: the page break falls between two equal scores',
      () async {
        // Bronze and Iron both have 50. With 3 a page, the break is
        // between them, so the id decides who comes first.
        Map<String, dynamic> one = api.json(
          await api.get('/api/badges?per_page=3'),
        );
        expect(_names(one['data']), <String>['Gold', 'Silver', 'Bronze']);
        expect(one['prev_cursor'], isNull);
        expect(one['per_page'], 3);

        String next = Uri.encodeQueryComponent(one['next_cursor']);
        Map<String, dynamic> two = api.json(
          await api.get('/api/badges?per_page=3&cursor=$next'),
        );
        expect(_names(two['data']), <String>['Iron', 'Wood']);
        expect(two['next_cursor'], isNull);

        String prev = Uri.encodeQueryComponent(two['prev_cursor']);
        Map<String, dynamic> back = api.json(
          await api.get('/api/badges?per_page=3&cursor=$prev'),
        );
        expect(_names(back['data']), <String>['Gold', 'Silver', 'Bronze']);
      },
    );

    test('cursorPaginate: a bad cursor from the user gives page 1', () async {
      for (String bad in <String>['abc', 'eyJ4IjoxfQ', '%00%01']) {
        http.Response res = await api.get('/api/badges?per_page=2&cursor=$bad');
        expect(res.statusCode, 200, reason: '$bad: ${res.body}');
        expect(_names(api.json(res)['data']), <String>['Gold', 'Silver']);
      }
    });

    test('simplePaginate: no total, has_more_pages', () async {
      Map<String, dynamic> one = api.json(
        await api.get('/api/badges/simple?page=1&per_page=2'),
      );
      expect(_names(one['data']), <String>['Gold', 'Silver']);
      expect(one['has_more_pages'], true);
      expect(one.containsKey('total'), false);
      Map<String, dynamic> three = api.json(
        await api.get('/api/badges/simple?page=3&per_page=2'),
      );
      expect(_names(three['data']), <String>['Wood']);
      expect(three['has_more_pages'], false);
      expect(three['current_page'], 3);
    });

    test('sync: attached, detached and updated, with pivot values', () async {
      int gold = data.badges['Gold']!;
      http.Response res = await api.put(
        '/api/badges/$gold/posts',
        <String, dynamic>{
          'post_ids': <int>[data.posts[1], data.posts[2]],
          'note': 'again',
        },
      );
      expect(res.statusCode, 200, reason: res.body);
      expect(api.json(res), <String, dynamic>{
        'attached': <int>[data.posts[2]],
        'detached': <int>[data.posts[0]],
        'updated': <int>[data.posts[1]],
      });

      Map<String, dynamic> badge = api.json(await api.get('/api/badges/$gold'));
      List<dynamic> posts = badge['posts'];
      expect(posts.map(_id).toSet(), <int>{data.posts[1], data.posts[2]});
      for (Post post in await data.postsOf('Gold')) {
        expect(post.pivot['note'], 'again');
      }

      // the same values again change nothing
      res = await api.put('/api/badges/$gold/posts', <String, dynamic>{
        'post_ids': <int>[data.posts[1], data.posts[2]],
        'note': 'again',
      });
      expect(api.json(res), <String, dynamic>{
        'attached': <int>[],
        'detached': <int>[],
        'updated': <int>[],
      });
    });

    test('syncWithoutDetaching keeps the other posts', () async {
      int gold = data.badges['Gold']!;
      http.Response res = await api.put(
        '/api/badges/$gold/posts',
        <String, dynamic>{
          'post_ids': <int>[data.posts[0]],
          'note': 'back',
          'detaching': false,
        },
      );
      expect(api.json(res)['attached'], <int>[data.posts[0]]);
      expect(api.json(res)['detached'], <int>[]);
      expect(
        await QueryBuilder.table('badge_post').where('badge_id', gold).count(),
        3,
      );
    });

    test(
      'sync: a post that does not exist is a 422, no link changes',
      () async {
        int gold = data.badges['Gold']!;
        http.Response res = await api.put(
          '/api/badges/$gold/posts',
          <String, dynamic>{
            'post_ids': <int>[999999],
          },
        );
        expect(res.statusCode, 422);
        expect(
          await QueryBuilder.table('badge_post')
              .where('badge_id', gold)
              .count(),
          3,
        );
      },
    );

    test('attach, detach, toggle and updateExistingPivot on a model', () async {
      Badge silver = (await Badge().find(data.badges['Silver']))!;
      await silver.attach(
        'posts',
        <int>[data.posts[0], data.posts[1]],
        <String, dynamic>{'note': 'a'},
      );
      expect(
        await silver.updateExistingPivot(
          'posts',
          data.posts[1],
          <String, dynamic>{'note': 'b'},
        ),
        1,
      );
      // text and number ids are one id
      PivotSyncResult toggled = await silver.toggle('posts', <dynamic>[
        '${data.posts[0]}',
        data.posts[2],
      ]);
      expect(toggled.detached, <int>[data.posts[0]]);
      expect(toggled.attached, <int>[data.posts[2]]);

      Badge loaded = (await Badge().preload('posts').find(silver.id))!;
      Map<int, dynamic> notes = <int, dynamic>{};
      for (Post post in loaded.posts) {
        notes[post.id as int] = post.pivot['note'];
      }
      expect(notes, <int, dynamic>{data.posts[1]: 'b', data.posts[2]: null});

      expect(await silver.detach('posts', null), 0);
      expect(await silver.detach('posts'), 2);
    });

    test('polymorphic: morphMany, morphTo with the morph map', () async {
      int gold = data.badges['Gold']!;
      http.Response res = await api.post(
        '/api/badges/$gold/reactions',
        <String, dynamic>{'emoji': 'fire'},
      );
      expect(res.statusCode, 201, reason: res.body);
      expect(api.json(res)['reactable_type'], 'badge');

      // a reaction on a post, saved in code
      await Reaction().create(<String, dynamic>{
        'emoji': 'heart',
        'reactable_id': data.posts[0],
        'reactable_type': Model.morphTypeOf(Post()),
      });

      List<dynamic> all = api.json(await api.get('/api/badges/reactions'));
      expect(all.length, 2);
      expect(all[0]['type'], 'badge');
      expect(all[0]['target']['name'], 'Gold');
      expect(all[1]['type'], 'post');
      expect(all[1]['target']['title'], 'post 1');

      Map<String, dynamic> badge = api.json(await api.get('/api/badges/$gold'));
      expect(badge['reactions_count'], 1);
      expect((badge['reactions'] as List<dynamic>).single['emoji'], 'fire');

      // whereHas and withCount work on a morphMany
      expect(await Badge().whereHas('reactions').count(), 1);
    });

    test('soft delete, onlyTrashed, restore', () async {
      int wood = data.badges['Wood']!;
      expect((await api.delete('/api/badges/$wood')).statusCode, 200);

      List<dynamic> trashed = api.json(await api.get('/api/badges/trashed'));
      expect(_names(trashed), <String>['Wood']);
      expect(trashed.single['deleted_at'], isNotNull);
      expect((await api.get('/api/badges/$wood')).statusCode, 404);

      Map<String, dynamic> restored = api.json(
        await api.post('/api/badges/$wood/restore', <String, dynamic>{}),
      );
      expect(restored['restored'], true);
      restored = api.json(
        await api.post('/api/badges/$wood/restore', <String, dynamic>{}),
      );
      expect(restored['restored'], false);
      expect(api.json(await api.get('/api/badges/trashed')), <dynamic>[]);
    });

    test('onlyTrashed().forceDelete() deletes only the trashed rows', () async {
      Badge iron = (await Badge().find(data.badges['Iron']))!;
      await iron.delete();
      expect(iron.deletedAt, isNotNull);
      await Badge().onlyTrashed().forceDelete();
      expect(await Badge().withTrash().count(), 4);
      expect(await Badge().find(data.badges['Iron']), isNull);
    });
  });

  group('3.1 ORM: mass assignment and safe writes', () {
    test('a model with no fillable throws MassAssignmentException', () async {
      int before = await Tag().count();
      await expectLater(
        Tag().create(<String, dynamic>{'name': 'nope'}),
        throwsA(isA<MassAssignmentException>()),
      );
      expect(await Tag().count(), before);
    });

    test('fillable drops keys that are not in the list', () async {
      Badge badge = await Badge().create(<String, dynamic>{
        'name': 'Sneaky',
        'score': 1,
        'deleted_at': DateTime.utc(2020),
      });
      Badge? fresh = await Badge().find(badge.id);
      expect(fresh?.deletedAt, isNull);
      await fresh?.forceDelete();
    });

    test('forceCreate, forceUpdate, forceFill and Model.unguarded', () async {
      Tag a = await Tag().forceCreate(<String, dynamic>{'name': 'forced'});
      expect(a.id, isNotNull);
      expect(
        await Tag().where('name', 'forced').forceUpdate(<String, dynamic>{
          'name': 'forced-2',
        }),
        1,
      );

      Tag b = Tag();
      b.forceFill(<String, dynamic>{'name': 'filled'});
      expect(b.name, 'filled');
      await b.save();

      expect(Model.isUnguarded, false);
      Tag c = await Model.unguarded(() async {
        expect(Model.isUnguarded, true);
        return await Tag().create(<String, dynamic>{'name': 'unguarded'});
      });
      expect(c.id, isNotNull);
      expect(Model.isUnguarded, false);
      expect(
        _names(
          await Tag()
              .whereIn('name', <String>['forced-2', 'filled', 'unguarded'])
              .orderBy('name')
              .get(),
        ),
        <String>['filled', 'forced-2', 'unguarded'],
      );
    });

    test('forceFill with a wrong type throws', () {
      expect(
        () => Badge().forceFill(<String, dynamic>{'score': 'not a number'}),
        throwsArgumentError,
      );
    });

    test(
      'a write with no key and no where throws and changes nothing',
      () async {
        int tags = await Tag().count();
        // Future.sync: some of them throw before they give a future
        await expectLater(Future<dynamic>.sync(Tag().delete), throwsStateError);
        await expectLater(
          Future<dynamic>.sync(
            () => Badge().update(<String, dynamic>{'score': 0}),
          ),
          throwsStateError,
        );
        await expectLater(
          Future<dynamic>.sync(() => Badge().increment('score')),
          throwsStateError,
        );
        await expectLater(
          Future<dynamic>.sync(Badge().touch),
          throwsStateError,
        );
        await expectLater(
          Future<dynamic>.sync(Badge().forceDelete),
          throwsStateError,
        );
        expect(await Tag().count(), tags);
        expect(await Badge().where('score', 0).count(), 0);
      },
    );

    test('a name with SQL in it is not put in the query', () async {
      await expectLater(
        Future<List<Badge>>.sync(
          () => Badge().orderBy('name; DROP TABLE badges').get(),
        ),
        throwsArgumentError,
      );
      await expectLater(
        Future<List<Badge>>.sync(
          () => Badge().where('score) OR (1=1', 1).get(),
        ),
        throwsArgumentError,
      );
      expect(await Badge().count(), greaterThan(0));
    });
  });

  group('3.1 ORM: queries', () {
    test('union and unionAll, order and count of the whole result', () async {
      QueryBuilder<Badge> high = Badge()
          .select('name')
          .where('score', '>=', 70);
      QueryBuilder<Badge> low = Badge().select('name').where('score', '<', 20);
      List<Badge> rows = await high.union(low).orderBy('name').get();
      expect(_names(rows), <String>['Gold', 'Silver', 'Wood']);

      QueryBuilder<Badge> again = Badge()
          .select('name')
          .where('score', '>=', 70);
      QueryBuilder<Badge> same = Badge()
          .select('name')
          .where('score', '>=', 70);
      expect(await again.unionAll(same).count(), 4);
      await expectLater(
        Badge()
            .select('name')
            .union(Badge().select('name'))
            .cursorPaginate(perPage: 2),
        throwsStateError,
      );
    });

    test('paginate() on a union counts the whole result', () async {
      QueryBuilder<Badge> high = Badge()
          .select('name')
          .where('score', '>=', 70);
      QueryBuilder<Badge> low = Badge().select('name').where('score', '<', 20);
      Pagination<Badge> page = await high
          .union(low)
          .orderBy('name')
          .paginate(currentPage: 2, perPage: 2);
      expect(page.total, 3);
      expect(_names(page.data), <String>['Wood']);
    });

    test('cursor and simple pages keep preload and withCount', () async {
      CursorPagination<Badge> cursor = await Badge()
          .preload('posts')
          .withCount('reactions')
          .orderBy('score', 'desc')
          .cursorPaginate(perPage: 1);
      Badge gold = cursor.data.single;
      expect(gold.name, 'Gold');
      expect(gold.posts.length, 3);
      expect(gold.aggregate('reactions_count'), 1);

      SimplePagination<Badge> simple = await Badge()
          .preload('posts')
          .orderBy('id')
          .simplePaginate(currentPage: 1, perPage: 1);
      expect(simple.data.single.posts.length, 3);
      expect(simple.hasMorePages, true);
    });

    test('sub queries: whereIn, joinSub, fromSub', () async {
      List<Post> linked = await Post()
          .whereIn('id', QueryBuilder.table('badge_post').select('post_id'))
          .orderBy('id')
          .get();
      expect(linked.map((Post p) => p.id), data.posts);

      QueryBuilder<Map<String, dynamic>> counts =
          QueryBuilder.table('reactions')
              .selectRaw('reactable_id, COUNT(*) AS total')
              .where('reactable_type', 'badge')
              .groupBy('reactable_id');
      List<Badge> withReactions = await Badge()
          .select(<String>['badges.name', 'r.total'])
          .joinSub(counts, 'r', 'r.reactable_id', 'badges.id')
          .get();
      expect(_names(withReactions), <String>['Gold']);

      int strong = await QueryBuilder.table('b')
          .fromSub(Badge().select('name').where('score', '>', 40), 'b')
          .count();
      expect(strong, 3);
    });

    test('whereDate, whereYear, whereMonth, whereDay, whereTime', () async {
      await QueryBuilder.table('badges').where('name', 'Gold').update(
        <String, dynamic>{'created_at': DateTime.utc(2024, 5, 3, 10)},
      );
      List<String> gold = <String>['Gold'];
      Future<List<String>> names(QueryBuilder<Badge> q) async {
        return _names(await q.orderBy('name').get());
      }

      expect(await names(Badge().whereDate('created_at', '2024-05-03')), gold);
      expect(
        await names(Badge().whereDate('created_at', DateTime.utc(2024, 5, 3))),
        gold,
      );
      expect(await names(Badge().whereYear('created_at', 2024)), gold);
      expect(
        await names(
          Badge().whereMonth('created_at', 5).whereYear('created_at', 2024),
        ),
        gold,
      );
      expect(
        await names(
          Badge().whereDay('created_at', 3).whereYear('created_at', 2024),
        ),
        gold,
      );
      expect(await names(Badge().whereTime('created_at', '10:00:00')), gold);
      expect(
        await names(Badge().whereDate('created_at', '<', '2024-05-03')),
        <String>[],
      );
    });

    test('whereJsonContains and whereJsonDoesntContain', () async {
      expect(
        _names(await Badge().whereJsonContains('meta->tags', 'top').get()),
        <String>['Gold'],
      );
      expect(
        _names(
          await Badge()
              .whereNotNull('meta')
              .whereJsonDoesntContain('meta->tags', 'old')
              .get(),
        ),
        <String>['Gold'],
      );
      expect(await Badge().whereJsonContains('meta->tags', 'old').count(), 0);
    });

    test('insertOrIgnore skips rows that clash with a unique key', () async {
      int added = await Badge().insertOrIgnore(<Map<String, dynamic>>[
        <String, dynamic>{'name': 'Gold', 'score': 1},
        <String, dynamic>{'name': 'Steel', 'score': 30},
      ]);
      expect(added, 1);
      expect((await Badge().where('name', 'Gold').getFirst())?.score, 90);
      expect((await Badge().where('name', 'Steel').getFirst())?.score, 30);
    });

    test('withAvg, withMin, withMax, withSum, withExists', () async {
      await QueryBuilder.table('posts')
          .where('id', data.posts[1])
          .update(<String, dynamic>{'views': 4});
      await QueryBuilder.table('posts')
          .where('id', data.posts[2])
          .update(<String, dynamic>{'views': 11});
      User? user = await User()
          .withAvg('posts', 'views')
          .withMin('posts', 'views')
          .withMax('posts', 'views')
          .withSum('posts', 'views')
          .withExists('posts')
          .find(data.userId);
      expect(num.parse('${user?.aggregate('posts_avg_views')}'), 5);
      expect(num.parse('${user?.aggregate('posts_min_views')}'), 0);
      expect(num.parse('${user?.aggregate('posts_max_views')}'), 11);
      expect(num.parse('${user?.aggregate('posts_sum_views')}'), 15);
      expect(user?.aggregate('posts_exists'), true);

      List<Badge> badges = await Badge()
          .withExists('posts')
          .whereIn('name', <String>['Gold', 'Wood'])
          .orderBy('name')
          .get();
      expect(badges.map((Badge b) => b.aggregate('posts_exists')), <bool>[
        true,
        false,
      ]);
    });

    test('touch() on a model and on a query', () async {
      DateTime old = DateTime.utc(2020);
      await QueryBuilder.table('badges')
          .whereIn('name', <String>['Silver', 'Bronze'])
          .update(<String, dynamic>{'updated_at': old});
      Badge silver = (await Badge().where('name', 'Silver').getFirst())!;
      await silver.touch();
      expect(silver.updatedAt!.isAfter(old), true);
      Badge bronze = (await Badge().where('name', 'Bronze').getFirst())!;
      expect(bronze.updatedAt!.year, 2020);

      expect(await Badge().where('name', 'Bronze').touch(), 1);
      bronze = (await Badge().where('name', 'Bronze').getFirst())!;
      expect(bronze.updatedAt!.year, greaterThan(2020));
    });

    test('replicate() makes an unsaved copy without id and dates', () async {
      Badge gold = (await Badge().where('name', 'Gold').getFirst())!;
      Badge copy = gold.replicate();
      expect(copy.id, isNull);
      expect(copy.createdAt, isNull);
      expect(copy.score, 90);
      expect(copy.meta, gold.meta);
      copy.name = 'Gold copy';
      await copy.save();
      expect(copy.id, isNot(gold.id));
      expect((await Badge().find(copy.id))?.score, 90);
      await copy.forceDelete();
    });

    test('restore() on a loaded model sets updated_at too', () async {
      Badge steel = (await Badge().where('name', 'Steel').getFirst())!;
      await steel.delete();
      await QueryBuilder.table('badges')
          .where('name', 'Steel')
          .update(<String, dynamic>{'updated_at': DateTime.utc(2020)});
      Badge trashed = (await Badge()
          .onlyTrashed()
          .where('name', 'Steel')
          .getFirst())!;
      expect(await trashed.restore(), true);
      Badge back = (await Badge().where('name', 'Steel').getFirst())!;
      expect(back.deletedAt, isNull);
      expect(back.updatedAt!.year, greaterThan(2020));
    });
  });

  group('3.1 database drivers', () {
    test('a statement is made again after the table changes', () async {
      const String table = 'e2e_retype';
      await Schema().dropIfExists(table);
      await Schema().create(table, (Table t) {
        t.id();
        t.integer('v');
      });
      await QueryBuilder.table(table).insert(<String, dynamic>{'v': 7});
      expect(await QueryBuilder.table(table).where('v', 7).count(), 1);

      await Schema().drop(table);
      await Schema().create(table, (Table t) {
        t.id();
        t.string('v', 10);
      });
      await QueryBuilder.table(table).insert(<String, dynamic>{'v': '007'});
      List<Map<String, dynamic>> rows = await QueryBuilder.table(table)
          .where('v', '007')
          .get();
      expect(rows.single['v'], '007');
      await Schema().drop(table);
    });

    test('ALTER TABLE: the same select sees the new column', () async {
      const String table = 'e2e_alter';
      await Schema().dropIfExists(table);
      await Schema().create(table, (Table t) {
        t.id();
        t.string('name', 20);
      });
      await QueryBuilder.table(table).insert(<String, dynamic>{'name': 'a'});
      Future<Map<String, dynamic>> first() async {
        return (await QueryBuilder.table(table).where('name', 'a').get()).first;
      }

      expect((await first()).containsKey('extra'), false);
      await Schema().table(table, (Table t) {
        t.string('extra', 20).nullable();
      });
      Map<String, dynamic> row = await first();
      expect(row.containsKey('extra'), true);
      expect(row['extra'], isNull);
      await Schema().drop(table);
    });

    test('the same SQL with a number, then a text param', () async {
      // the first run has a number type, the second a text type
      await QueryBuilder.table('users').where('email', 0).count();
      expect(
        await QueryBuilder.table('users').where('email', 'zzz').count(),
        0,
      );
    });

    test('a database that is not there gives a clear error', () async {
      ConnectionConfig base = databaseConfig.getConnectionConfig();
      if (base.driver == Driver.sqlite) {
        markTestSkipped('sqlite has no server');
        return;
      }
      DBDriver driver = ConnectionConfig(
        driver: base.driver,
        host: '127.0.0.1',
        port: 1,
        user: base.user,
        password: base.password,
        database: base.database,
        debug: false,
      ).createDriver();
      Object? error;
      try {
        await driver.query('SELECT 1');
      } catch (e) {
        error = e;
      }
      expect(error, isNotNull);
      expect('$error'.toLowerCase(), contains('connect'));
    });
  });

  group('3.1 validation over HTTP', () {
    Map<String, dynamic> good() {
      return <String, dynamic>{
        'kind': 'team',
        'team_name': 'Blue',
        'email': 'ann@mail.com',
        'phone': '0811',
        'pin': '1234',
        'starts_on': '2024-02-29',
        'password': 'Secret123',
        'password_confirmation': 'Secret123',
        'code': 'A1',
        'code_again': 'A1',
        'ip': '::1',
        'data': '{"a":[1,2]}',
        'slug': 'my-slug_1',
      };
    }

    test('every rule passes', () async {
      http.Response res = await api.post('/api/system/rules', good());
      expect(res.statusCode, 200, reason: res.body);
      expect(api.json(res)['ok'], true);
    });

    test(
      'required_if and required_with only when the other key is set',
      () async {
        Map<String, dynamic> body = good()
          ..['kind'] = 'solo'
          ..remove('team_name')
          ..remove('email')
          ..remove('phone');
        http.Response res = await api.post('/api/system/rules', body);
        expect(res.statusCode, 200, reason: res.body);
      },
    );

    test('required_if and required_with fail first (422)', () async {
      Map<String, dynamic> body = good()
        ..remove('team_name')
        ..remove('phone');
      http.Response res = await api.post('/api/system/rules', body);
      expect(res.statusCode, 422);
      expect(api.json(res), <String, dynamic>{
        'team_name': 'The team_name is required when kind is team',
        'phone': 'The phone is required when email is present',
      });
    });

    test('every other rule fails with its own key (422)', () async {
      http.Response res = await api.post('/api/system/rules', <String, dynamic>{
        ...good(),
        'pin': '12a',
        'starts_on': '2023-02-29',
        'password': 'password',
        'password_confirmation': 'password',
        'code_again': 'B2',
        'ip': '01.1.1.1',
        'data': '{',
        'slug': 'a b',
      });
      expect(res.statusCode, 422);
      expect((api.json(res) as Map<String, dynamic>).keys.toSet(), <String>{
        'pin',
        'starts_on',
        'password',
        'code_again',
        'ip',
        'data',
        'slug',
      }, reason: res.body);
    });

    test('password: a good password with a wrong confirmation fails', () async {
      Map<String, dynamic> body = good()
        ..['password_confirmation'] = 'Secret124';
      http.Response res = await api.post('/api/system/rules', body);
      expect(res.statusCode, 422);
      expect((api.json(res) as Map<String, dynamic>).keys, <String>[
        'password',
      ]);
    });

    test(
      'fluent schema: exists, unique and between read the database',
      () async {
        http.Response ok = await api.post(
          '/api/system/rules/fluent',
          <String, dynamic>{
            'badge': 'Gold',
            'email': 'free@mail.com',
            'level': 5,
          },
        );
        expect(ok.statusCode, 200, reason: ok.body);
        expect(api.json(ok), <String, dynamic>{
          'badge': 'Gold',
          'email': 'free@mail.com',
          'level': 5,
        });

        User user = (await User().find(data.userId))!;
        http.Response bad = await api.post(
          '/api/system/rules/fluent',
          <String, dynamic>{'badge': 'Nope', 'email': user.email, 'level': 11},
        );
        expect(bad.statusCode, 422);
        expect((api.json(bad) as Map<String, dynamic>).keys.toSet(), <String>{
          'badge',
          'email',
          'level',
        }, reason: bad.body);
      },
    );

    test('file rules: real MIME type, min size, image size', () async {
      Future<http.Response> send(List<int> bytes, String name) {
        return api.uploadBytes('/api/files/photo', 'photo', bytes, name);
      }

      http.Response ok = await send(OrmData.png(4, 4, 2048), 'a.png');
      expect(ok.statusCode, 201, reason: ok.body);

      // the bytes decide: a png with no known extension passes
      http.Response blob = await send(OrmData.png(4, 4, 2048), 'blob');
      expect(blob.statusCode, 201, reason: blob.body);

      // a png named .gif: the name and the bytes do not agree
      String typeError =
          'The photo must be a file of type: image/png, image/gif';
      Map<String, dynamic> gif = api.json(
        await send(OrmData.png(4, 4, 2048), 'a.gif'),
      );
      expect(gif, <String, dynamic>{'photo': typeError});

      // text bytes with a .png name
      Map<String, dynamic> text = api.json(
        await send(List<int>.filled(2048, 65), 'a.png'),
      );
      expect(text, <String, dynamic>{'photo': typeError});

      // too small in bytes, and 1x1 is below the min width
      expect((await send(Api.tinyPng, 'a.png')).statusCode, 422);
      // 4x2 is not ratio 1
      expect((await send(OrmData.png(4, 2, 2048), 'a.png')).statusCode, 422);
      // 200x200 is over the max width
      expect(
        (await send(OrmData.png(200, 200, 2048), 'a.png')).statusCode,
        422,
      );
    });
  });

  group('3.1 storage', () {
    for (String disk in <String>['local', 's3', 'memory', 'public']) {
      test('$disk: append, prepend', () async {
        String key = 'notes/$disk-log.txt';
        Future<String> add(String text, {bool atStart = false}) async {
          http.Response res = await api.post(
            '/api/storage/$disk/text/$key',
            <String, dynamic>{'text': text, 'at_start': atStart},
          );
          expect(res.statusCode, 200, reason: res.body);
          return api.json(res)['text'];
        }

        await api.delete('/api/storage/$disk/files/$key');
        expect(await add('b'), 'b');
        expect(await add('c'), 'b\nc');
        expect(await add('a', atStart: true), 'a\nb\nc');
      });
    }

    for (String disk in <String>['local', 's3', 'public']) {
      test('$disk: size, lastModified, url', () async {
        String key = 'notes/$disk-log.txt';
        http.Response res = await api.get('/api/storage/$disk/info/$key');
        expect(res.statusCode, 200, reason: res.body);
        Map<String, dynamic> info = api.json(res);
        expect(info['size'], 5);
        DateTime changed = DateTime.parse(info['last_modified']);
        expect(DateTime.now().difference(changed).inMinutes.abs(), lessThan(5));
        String url = info['url'];
        if (disk == 'local') {
          expect(url, '${env.appUrl}/files/$key');
        } else if (disk == 'public') {
          // no `url` option: like Laravel, `/storage/<path>`
          expect(url, '/storage/$key');
          http.Response file = await api.get(url);
          expect(file.statusCode, 200);
          expect(file.body, 'a\nb\nc');
        } else {
          expect(url, contains(key));
        }
      });
    }

    test('size of a missing file is a 404', () async {
      for (String disk in <String>['local', 's3']) {
        http.Response res = await api.get(
          '/api/storage/$disk/info/nope/none.txt',
        );
        expect(res.statusCode, 404, reason: '$disk: ${res.body}');
      }
    });

    test('makeDirectory: a real folder on local, nothing on s3', () async {
      http.Response res = await api.post(
        '/api/storage/local/dirs/made/here',
        <String, dynamic>{},
      );
      expect(res.statusCode, 200, reason: res.body);
      expect(
        Directory('${AppConstants.storageRoot}/made/here').existsSync(),
        true,
      );
      res = await api.post(
        '/api/storage/s3/dirs/made/here',
        <String, dynamic>{},
      );
      expect(res.statusCode, 200, reason: res.body);
    });

    test('a signed URL works only on the route of its own disk', () async {
      String key = 'shared/a.txt';
      for (String disk in <String>['local', 'public']) {
        await api.delete('/api/storage/$disk/files/$key');
        await api.post('/api/storage/$disk/text/$key', <String, dynamic>{
          'text': 'on $disk',
        });
      }
      String url = api.json(
        await api.get('/api/storage/local/signed/$key'),
      )['url'];
      http.Response own = await http.get(Uri.parse(url));
      expect(own.statusCode, 200);
      expect(own.body, 'on local');

      String other = url.replaceFirst('/files/', '/public-files/');
      expect((await http.get(Uri.parse(other))).statusCode, 403);
    });

    test('an old signed URL (made before 3.1) still works', () async {
      String key = 'shared/a.txt';
      int expires = DateTime.now()
          .add(Duration(minutes: 5))
          .millisecondsSinceEpoch;
      // the 3.0 signature: no disk name in it
      // the key: APP_KEY made into a signed URL key, as Dox does
      String secret = base64.encode(
        KeyDerivation.forAppKey(KeyDerivation.signedUrl),
      );
      String signature = Hmac(
        sha256,
        utf8.encode(secret),
      ).convert(utf8.encode('$key\n$expires')).toString();
      http.Response res = await api.get(
        '/files/$key?expires=$expires&signature=$signature',
      );
      expect(res.statusCode, 200);
      expect(res.body, 'on local');

      http.Response bad = await api.get(
        '/files/$key?expires=$expires&signature=${signature}0',
      );
      expect(bad.statusCode, 403);
    });
  });
}

/// Rows the 3.1 groups make and read.
class OrmData {
  int userId = 0;

  /// ids of `post 1`, `post 2` and `post 3`
  List<int> posts = <int>[];

  /// badge ids by name
  Map<String, int> badges = <String, int>{};

  /// The posts of a badge, read in code, so `pivot` is there.
  Future<List<Post>> postsOf(String badge) async {
    Badge? found = await Badge().preload('posts').find(badges[badge]);
    return found?.posts ?? <Post>[];
  }

  /// One user with three posts. `forceCreate()`: the models have no
  /// `fillable`.
  Future<void> seed() async {
    User user = await User().forceCreate(<String, dynamic>{
      'name': 'Orm',
      'email': 'orm@mail.com',
      'password': 'not-a-real-hash',
    });
    userId = user.id as int;
    for (int i = 1; i <= 3; i++) {
      Post post = await Post().forceCreate(<String, dynamic>{
        'user_id': userId,
        'title': 'post $i',
        'body': 'body $i',
        'status': 'published',
      });
      posts.add(post.id as int);
    }
  }

  /// A png header of [width] x [height], padded with zeros to [length]
  /// bytes. The rules read only the header.
  static List<int> png(int width, int height, int length) {
    List<int> bytes = List<int>.of(Api.tinyPng);
    void put(int at, int value) {
      bytes[at] = (value >> 24) & 255;
      bytes[at + 1] = (value >> 16) & 255;
      bytes[at + 2] = (value >> 8) & 255;
      bytes[at + 3] = value & 255;
    }

    put(16, width);
    put(20, height);
    return <int>[...bytes, ...List<int>.filled(length - bytes.length, 0)];
  }
}

int _id(dynamic row) {
  return row['id'] as int;
}

/// The `name` of each row: a model or a JSON map.
List<String> _names(Iterable<dynamic> rows) {
  List<String> out = <String>[];
  for (dynamic row in rows) {
    Map<String, dynamic> map = row is Model ? row.toJson() : row;
    out.add('${map['name']}');
  }
  return out;
}
