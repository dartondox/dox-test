import 'dart:io';

import 'package:dox_core/dox_core.dart'
    as vd
    show ObjectSchema, ParseResult, Schema, ValidationIssue, v;
import 'package:dox_migration/dox_migration.dart';
import 'package:dox_orm/dox_orm.dart';
import 'package:dox_test/app/models/e2e310b/e2e310b.model.dart';
import 'package:dox_test/config/database.dart';
import 'package:dox_test/config/env.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'e2e_310_orm.dart' show driverError;
import 'e2e_test.dart' show Api;

/// 3.1.0 round 3: the dox_orm, dox_validation and native driver changes
/// that merged on 2026-11-06 (dox-orm#41, #42, dox-validation#11,
/// dox-postgres-native#11, dox-mysql-native#12). Every table here starts
/// with `e310b_orm_`, and this file makes and drops it.
void orm310bTests(Api api) {
  Driver driver = databaseConfig.getConnectionConfig().driver;
  bool sqlite = driver == Driver.sqlite;

  group('3.1.0 round 3 e2e: findOrFail over HTTP', () {
    setUpAll(_Tables.create);
    tearDownAll(_Tables.drop);

    test('findOrFail with no row answers 404, no table or id', () async {
      http.Response res = await api.get('/core/e310b/items/987654');
      expect(res.statusCode, 404, reason: res.body);
      expect(api.json(res), <String, dynamic>{
        'code': 'not_found',
        'message': 'Not Found',
      });
      expect(res.body, isNot(contains('e310b_orm_items')));
      expect(res.body, isNot(contains('987654')));
    });

    test('firstOrFail with no row answers 404, no value', () async {
      http.Response res = await api.get('/core/e310b/items-by-name/nobody77');
      expect(res.statusCode, 404, reason: res.body);
      expect(api.json(res), <String, dynamic>{
        'code': 'not_found',
        'message': 'Not Found',
      });
      expect(res.body, isNot(contains('e310b_orm_items')));
      expect(res.body, isNot(contains('nobody77')));
    });

    test('a row that is there still answers 200', () async {
      E310bItem item = await E310bItem().create(<String, dynamic>{
        'name': 'found-1',
      });
      http.Response res = await api.get('/core/e310b/items/${item.id}');
      expect(res.statusCode, 200, reason: res.body);
      expect(api.json(res), <String, dynamic>{'name': 'found-1'});
      res = await api.get('/core/e310b/items-by-name/found-1');
      expect(res.statusCode, 200, reason: res.body);
      expect(api.json(res), <String, dynamic>{'id': item.id});
    });

    test('the exception keeps its fields for a catch in Dart', () async {
      try {
        await E310bItem().findOrFail(987654);
        fail('no throw');
      } on ModelNotFoundException catch (e) {
        expect(e.table, 'e310b_orm_items');
        expect(e.id, 987654);
        expect(e.code, 404);
        expect(e.toString(), contains('e310b_orm_items'));
      }
      await expectLater(
        E310bItem().where('name', 'nobody').firstOrFail(),
        throwsA(isA<ModelNotFoundException>()),
      );
    });
  });

  group('3.1.0 round 3 e2e: new query helpers', () {
    setUpAll(_Tables.create);
    tearDownAll(_Tables.drop);
    setUp(() async {
      await QueryBuilder.table('e310b_orm_items').delete();
    });

    Future<List<String?>> names(QueryBuilder<E310bItem> q) async {
      return (await q.orderBy('name').get())
          .map((E310bItem i) => i.name)
          .toList();
    }

    test('insertGetId on a model drops keys that are not fillable', () async {
      dynamic id = await E310bItem().insertGetId(<String, dynamic>{
        'name': 'g1',
        'qty': 3,
        'secret': 'hidden',
      });
      expect(id, isA<int>());
      E310bItem row = (await E310bItem().find(id))!;
      expect(row.name, 'g1');
      expect(row.qty, 3);
      expect(row.secret, isNull);
      // no model events and no timestamps
      expect(row.createdAt, isNull);

      dynamic next = await E310bItem().insertGetId(<String, dynamic>{
        'name': 'g2',
      });
      expect(next as int, greaterThan(id as int));
    });

    test('insertGetId on a table keeps every key', () async {
      dynamic id = await QueryBuilder.table('e310b_orm_items')
          .insertGetId(<String, dynamic>{'name': 't1', 'secret': 'kept'});
      expect(id, isA<int>());
      expect((await E310bItem().find(id))?.secret, 'kept');
    });

    test('insertMany: fillable, empty list, a table with no id', () async {
      expect(
        await E310bItem().insertMany(<Map<String, dynamic>>[
          <String, dynamic>{'name': 'm1', 'qty': 1, 'secret': 'no'},
          <String, dynamic>{'name': 'm2', 'qty': 2},
        ]),
        true,
      );
      List<E310bItem> rows = await E310bItem().orderBy('name').get();
      expect(rows.map((E310bItem i) => i.name), <String>['m1', 'm2']);
      expect(rows.map((E310bItem i) => i.secret), <String?>[null, null]);
      expect(rows.first.createdAt, isNull);

      // an empty list runs no query and still gives true
      expect(await E310bItem().insertMany(<Map<String, dynamic>>[]), true);
      expect(await E310bItem().count(), 2);

      // the pivot table has no id column: no RETURNING
      expect(
        await QueryBuilder.table('e310b_orm_item_tag')
            .insertMany(<Map<String, dynamic>>[
              <String, dynamic>{'item_id': 1, 'tag_id': 1},
              <String, dynamic>{'item_id': 1, 'tag_id': 2},
            ]),
        true,
      );
      expect(
        await QueryBuilder.table('e310b_orm_item_tag')
            .where('item_id', 1)
            .count(),
        2,
      );
      await QueryBuilder.table('e310b_orm_item_tag').delete();
    });

    test('insert() and delete() return the same types as before', () async {
      E310bItem made = await E310bItem().insert(<String, dynamic>{
        'name': 'old-insert',
      });
      expect(made.id, isA<int>());
      Map<String, dynamic> row = await QueryBuilder.table('e310b_orm_items')
          .insert(<String, dynamic>{'name': 'old-map'});
      expect(row['id'], isNotNull);
      int deleted = await E310bItem().whereIn('name', <String>[
        'old-insert',
        'old-map',
      ]).delete();
      expect(deleted, 2);
    });

    test('toRawSql quotes values and runs as it is', () async {
      List<String> odd = <String>["it's", r'back\slash', "@who'x", 'plain'];
      for (String name in odd) {
        await E310bItem().create(<String, dynamic>{'name': name, 'qty': 5});
      }
      for (String name in odd) {
        QueryBuilder<E310bItem> q() =>
            E310bItem().where('name', name).where('qty', 5);
        String raw = q().toRawSql();
        List<Map<String, dynamic>> rows = await QueryBuilder.query(raw);
        expect(rows.map((Map<String, dynamic> r) => r['name']), <String>[
          name,
        ], reason: raw);
      }
      expect(E310bItem().where('name', "it's").toRawSql(), contains("'it''s'"));
      // null, bool and numbers have no quotes
      String mixed = E310bItem().where('qty', 5).whereRaw(
        'secret IS NULL OR secret = @s',
        <String, dynamic>{'s': null},
      ).toRawSql();
      expect(mixed, contains('5'));
      // the bound null spot, not the `IS NULL` in the text
      expect(mixed, contains('secret = NULL'));
      expect(mixed, isNot(contains("'5'")));

      // toSql() puts the value in as it is, with no quotes
      String plain = E310bItem().where('name', "it's").toSql();
      expect(plain, contains("it's"));
      expect(plain, isNot(contains("'it''s'")));
    });

    test('first() and doesntExist()', () async {
      expect(await E310bItem().first(), isNull);
      expect(await E310bItem().doesntExist(), true);
      await E310bItem().create(<String, dynamic>{'name': 'b'});
      await E310bItem().create(<String, dynamic>{'name': 'a'});
      expect((await E310bItem().orderBy('name').first())?.name, 'a');
      expect(await E310bItem().doesntExist(), false);
      expect(await E310bItem().where('name', 'zzz').doesntExist(), true);
      expect(await E310bItem().where('name', 'a').hasRows(), true);
      expect((await E310bItem().orderBy('name').getFirst())?.name, 'a');
    });

    test('unless() and whenValue()', () async {
      for (String n in <String>['a', 'b', 'c']) {
        await E310bItem().create(<String, dynamic>{
          'name': n,
          'qty': n.codeUnitAt(0) - 96,
        });
      }
      void onlyA(QueryBuilder<E310bItem> q) => q.where('name', 'a');
      void onlyB(QueryBuilder<E310bItem> q) => q.where('name', 'b');

      expect(await names(E310bItem().unless(false, onlyA)), <String>['a']);
      expect(await names(E310bItem().unless(true, onlyA)), <String>[
        'a',
        'b',
        'c',
      ]);
      expect(await names(E310bItem().unless(true, onlyA, onlyB)), <String>[
        'b',
      ]);

      Future<List<String?>> byValue(Object? value) {
        return names(
          E310bItem().whenValue<Object>(value, (
            QueryBuilder<E310bItem> q,
            Object v,
          ) {
            q.where('qty', v);
          }, onlyB),
        );
      }

      expect(await byValue(3), <String>['c']);
      // null runs the otherwise callback
      expect(await byValue(null), <String>['b']);
      // 0 and an empty text are not null: the callback runs
      expect(await byValue(0), <String>[]);

      // when() works as before
      expect(await names(E310bItem().when(true, onlyA)), <String>['a']);
    });

    test('whereNot and orWhereNot with a column and value', () async {
      for (String n in <String>['a', 'b', 'c']) {
        await E310bItem().create(<String, dynamic>{
          'name': n,
          'qty': n.codeUnitAt(0) - 96,
        });
      }
      // a null qty matches neither the where nor NOT of it
      await E310bItem().create(<String, dynamic>{'name': 'n'});

      expect(await names(E310bItem().whereNot('name', 'a')), <String>[
        'b',
        'c',
        'n',
      ]);
      expect(await names(E310bItem().whereNot('qty', '<', 2)), <String>[
        'b',
        'c',
      ]);
      expect(
        await names(E310bItem().where('name', 'a').orWhereNot('qty', '<=', 2)),
        <String>['a', 'c'],
      );
      // the callback form works as before
      expect(
        await names(
          E310bItem().whereNot((QueryBuilder<E310bItem> q) {
            q.where('name', 'a').orWhere('name', 'b');
          }),
        ),
        <String>['c', 'n'],
      );
      expect(() => E310bItem().whereNot(42), throwsArgumentError);
    });

    test('find() on a union fails in the Future, not before', () async {
      await E310bItem().create(<String, dynamic>{'name': 'u'});
      E310bItem union() => E310bItem()
        ..where('name', 'u')
        ..union(E310bItem().where('name', 'v'));

      // no throw here: the error is in the Future
      Future<E310bItem?> found = union().find(1);
      await expectLater(found, throwsStateError);

      Future<E310bItem?> badArgs = E310bItem().find(5, null);
      await expectLater(badArgs, throwsArgumentError);

      // find by a column still works
      expect((await E310bItem().find('name', 'u'))?.name, 'u');
    });
  });

  group('3.1.0 round 3 e2e: timestamps and many to many', () {
    setUpAll(_Tables.create);
    tearDownAll(_Tables.drop);

    DateTime old = DateTime.utc(2001, 2, 3, 4, 5, 6);

    test('save() keeps an updated_at that the user set', () async {
      E310bItem item = await E310bItem().create(<String, dynamic>{
        'name': 'keep',
      });
      item.name = 'keep 2';
      item.updatedAt = old;
      await item.save();
      E310bItem row = (await E310bItem().find(item.id))!;
      expect(row.name, 'keep 2');
      expect(row.updatedAt?.toUtc(), old);

      // only the time changes: it is saved too
      DateTime older = DateTime.utc(1999, 12, 31, 23);
      row.updatedAt = older;
      await row.save();
      expect((await E310bItem().find(item.id))!.updatedAt?.toUtc(), older);

      // no time set: now, as before
      E310bItem again = (await E310bItem().find(item.id))!;
      again.name = 'keep 3';
      await again.save();
      E310bItem last = (await E310bItem().find(item.id))!;
      expect(last.updatedAt!.year, greaterThan(2020));
      expect(again.updatedAt!.year, greaterThan(2020));
    });

    test('update() with a custom updated_at column', () async {
      E310bNote note = await E310bNote().create(<String, dynamic>{
        'body': 'first',
      });
      expect(note.updatedAt, isNotNull);

      expect(
        await note.update(<String, dynamic>{
          'body': 'given',
          'changed_at': old,
        }),
        1,
      );
      expect(note.updatedAt?.toUtc(), old);
      E310bNote row = (await E310bNote().find(note.id))!;
      expect(row.body, 'given');
      expect(row.updatedAt?.toUtc(), old);

      // no time in the map: now
      await note.update(<String, dynamic>{'body': 'now'});
      expect(note.updatedAt!.year, greaterThan(2020));
      row = (await E310bNote().find(note.id))!;
      expect(row.updatedAt!.year, greaterThan(2020));
    });

    Future<List<int>> stored(E310bItem item) async {
      List<Map<String, dynamic>> rows = await QueryBuilder.table(
        'e310b_orm_item_tag',
      ).where('item_id', item.id).get();
      return rows.map((Map<String, dynamic> r) => r['tag_id'] as int).toList()
        ..sort();
    }

    test('sync with two pivot rows of one id detaches both', () async {
      E310bItem item = await E310bItem().create(<String, dynamic>{
        'name': 'dup',
      });
      await item.attach('tags', <int>[1, 2]);
      await QueryBuilder.table('e310b_orm_item_tag')
          .insert(<String, dynamic>{'item_id': item.id, 'tag_id': 1});
      expect(await stored(item), <int>[1, 1, 2]);

      PivotSyncResult r = await item.sync('tags', <int>[2]);
      expect(r.detached, <int>[1]);
      expect(r.attached, isEmpty);
      expect(await stored(item), <int>[2]);
    });

    test('more than 100 int ids, with duplicate pivot rows', () async {
      E310bItem item = await E310bItem().create(<String, dynamic>{
        'name': 'many',
      });
      List<int> ids = <int>[for (int i = 1; i <= 250; i++) i];
      await item.attach('tags', ids);
      // a second row for 120 of the ids
      await QueryBuilder.table('e310b_orm_item_tag')
          .insertMany(<Map<String, dynamic>>[
            for (int i = 1; i <= 120; i++)
              <String, dynamic>{'item_id': item.id, 'tag_id': i},
          ]);
      expect((await stored(item)).length, 370);

      List<int> keep = <int>[for (int i = 101; i <= 300; i++) i];
      PivotSyncResult r = await item.sync('tags', keep);
      expect((r.detached.cast<int>()..sort()), <int>[
        for (int i = 1; i <= 100; i++) i,
      ]);
      expect((r.attached.cast<int>()..sort()), <int>[
        for (int i = 251; i <= 300; i++) i,
      ]);
      // 101..120 keep their two rows: sync does not dedupe kept rows
      List<int> left = await stored(item);
      expect(left.toSet(), keep.toSet());
      expect(left.length, 220);

      PivotSyncResult t = await item.toggle('tags', keep);
      expect(t.detached.length, 200);
      expect(t.attached, isEmpty);
      expect(await stored(item), <int>[]);

      // an empty sync on an empty pivot
      PivotSyncResult e = await item.sync('tags', <int>[]);
      expect(e.detached, isEmpty);
    });
  });

  group('3.1.0 round 3 e2e: logRedact of a named connection', () {
    setUpAll(_Tables.create);
    tearDownAll(_Tables.drop);

    test('a query on the named connection hides its names', () async {
      SqlQueryBuilder sql = SqlQueryBuilder();
      String name = env.dbConnection.name;
      ConnectionConfig config = databaseConfig.connections[name]!;
      bool oldDebug = sql.debug;
      QueryPrinter oldPrinter = sql.printer;
      List<String> oldNamed = config.logRedact;
      Directory dir = await Directory.systemTemp.createTemp('e310b-log');
      File file = File('${dir.path}/query.log');
      FileQueryPrinter printer = FileQueryPrinter(file: file, buffered: true);
      Map<String, dynamic> values = <String, dynamic>{
        'pin': 'secret-pin-1',
        'who': 'shown-2',
      };
      try {
        sql.debug = true;
        sql.printer = printer;
        // only the named connection hides `pin`
        config.logRedact = <String>['pin'];
        await QueryBuilder.table('e310b_orm_items')
            .withConnection(name)
            .whereRaw('name = @pin OR name = @who', values)
            .count();
        await printer.flush();
        String named = await file.readAsString();
        expect(named, contains('***'));
        expect(named, contains('shown-2'));
        expect(named, isNot(contains('secret-pin-1')));

        // the default connection does not use the named list
        await QueryBuilder.table('e310b_orm_items').whereRaw(
          'name = @pin OR name = @who',
          <String, dynamic>{'pin': 'open-pin-3', 'who': 'shown-4'},
        ).count();
      } finally {
        sql.debug = oldDebug;
        sql.printer = oldPrinter;
        config.logRedact = oldNamed;
      }
      await printer.flush();
      String log = await file.readAsString();
      await dir.delete(recursive: true);
      expect(log, contains('open-pin-3'));
    });
  });

  group('3.1.0 round 3 e2e: schema helpers in a real migration', () {
    Future<void> clean() async {
      for (String t in <String>[
        'e310b_orm_kids',
        'e310b_orm_parents',
        'e310b_orm_codes',
      ]) {
        await Schema().dropIfExists(t);
      }
      await QueryBuilder.table('dox_db_migration')
          .whereIn('migration', <String>[_migCreate.name, _migAlter.name])
          .delete();
    }

    setUp(() async {
      await _Tables.create();
      await clean();
      // SQLite checks foreign keys only with this pragma on
      if (sqlite) {
        await QueryBuilder.query('PRAGMA foreign_keys = ON');
      }
    });
    tearDown(() async {
      await clean();
      await _Tables.drop();
      if (sqlite) {
        await QueryBuilder.query('PRAGMA foreign_keys = OFF');
      }
    });

    test('create, then alter, then roll back', () async {
      await _migrator(<MigrationEntry>[_migCreate]).migrate();
      List<String> cols = await Schema().getColumnListing('e310b_orm_kids');
      expect(
        cols,
        containsAll(<String>[
          'e310b_item_id',
          'code',
          'parent_code',
          'born',
          'ip_address',
          'deleted_at',
          'owner_id',
          'owner_type',
          'target_id',
          'target_type',
          'created_at',
          'updated_at',
        ]),
      );

      // data in the new columns
      String ulid = '01ARZ3NDEKTSV4RRFFQ69G5FAV';
      String ip6 = '0000:0000:0000:0000:0000:ffff:192.168.100.228';
      expect(ip6.length, 45);
      await QueryBuilder.table('e310b_orm_parents')
          .insert(<String, dynamic>{'code': ulid});
      E310bItem item = await E310bItem().create(<String, dynamic>{
        'name': 'fk',
      });
      await QueryBuilder.table('e310b_orm_kids').insert(<String, dynamic>{
        'e310b_item_id': item.id,
        'code': '01BX5ZZKBKACTAV9WEVGEMMVRZ',
        'parent_code': ulid,
        'born': 2026,
        'ip_address': ip6,
        'target_id': '6f1c1d2e-3b4a-4c5d-8e9f-a0b1c2d3e4f5',
        'target_type': 'post',
      });
      Map<String, dynamic> kid = (await QueryBuilder.table(
        'e310b_orm_kids',
      ).get()).single;
      expect('${kid['born']}', '2026');
      expect(kid['ip_address'], ip6);
      expect(kid['owner_id'], isNull);
      expect(kid['owner_type'], isNull);
      expect(kid['deleted_at'], isNull);
      expect(kid['parent_code'], ulid);

      // uuidMorphs: both columns are needed
      await expectLater(
        QueryBuilder.table('e310b_orm_kids')
            .insert(<String, dynamic>{'code': 'x', 'target_type': 'post'}),
        throwsA(driverError),
      );

      // restrictOnUpdate: the parent code can not change
      await expectLater(
        QueryBuilder.table('e310b_orm_parents')
            .where('code', ulid)
            .update(<String, dynamic>{'code': 'NEW'}),
        throwsA(driverError),
      );
      // the stored rules: RESTRICT, not the default NO ACTION
      expect(await _updateRules('e310b_orm_kids'), <String, String>{
        'e310b_item_id': 'SET NULL',
        'parent_code': 'RESTRICT',
      });
      // nullOnUpdate: a new item id clears the kid column
      await QueryBuilder.table('e310b_orm_items')
          .where('id', item.id)
          .update(<String, dynamic>{'id': 900001});
      kid = (await QueryBuilder.table('e310b_orm_kids').get()).single;
      expect(kid['e310b_item_id'], isNull);

      Set<String> indexes = await _indexes('e310b_orm_kids');
      expect(indexes, contains('e310b_orm_kids_label_old'));
      if (!sqlite) {
        expect(indexes, contains('e310b_orm_kids_label_fulltext'));
        // the primary key of codes is still there
        await QueryBuilder.table('e310b_orm_codes')
            .insert(<String, dynamic>{'code': 'same'});
        await expectLater(
          QueryBuilder.table('e310b_orm_codes')
              .insert(<String, dynamic>{'code': 'same'}),
          throwsA(driverError),
        );
      }

      // the second migration drops and renames
      await _migrator(<MigrationEntry>[_migCreate, _migAlter]).migrate();
      cols = await Schema().getColumnListing('e310b_orm_kids');
      for (String gone in <String>[
        'created_at',
        'updated_at',
        'deleted_at',
        'parent_code',
      ]) {
        expect(cols, isNot(contains(gone)));
      }
      expect(cols, contains('e310b_item_id'));
      indexes = await _indexes('e310b_orm_kids');
      expect(indexes, contains('e310b_orm_kids_label_new'));
      expect(indexes, isNot(contains('e310b_orm_kids_label_old')));
      // the kid row is still there
      expect(await QueryBuilder.table('e310b_orm_kids').count(), 1);
      if (!sqlite) {
        // dropPrimary: the same code twice is fine now
        await QueryBuilder.table('e310b_orm_codes')
            .insert(<String, dynamic>{'code': 'same'});
        expect(
          await QueryBuilder.table('e310b_orm_codes')
              .where('code', 'same')
              .count(),
          2,
        );
      }
      // the parent is free to change now: no foreign key
      await QueryBuilder.table('e310b_orm_parents')
          .where('code', ulid)
          .update(<String, dynamic>{'code': 'NEW'});

      // two batches: the first rollback undoes only the alter
      Migrator both = _migrator(<MigrationEntry>[_migCreate, _migAlter]);
      await both.rollback();
      expect(await Schema().hasTable('e310b_orm_kids'), true);
      await both.rollback();
      expect(await Schema().hasTable('e310b_orm_kids'), false);
      expect(await Schema().hasTable('e310b_orm_parents'), false);
    });

    test('SQLite: fullText and dropPrimary throw UnsupportedError', () async {
      await Schema().create('e310b_orm_codes', (Table t) {
        t.string('code', 10).primary();
        t.string('label', 30).nullable();
      });
      await expectLater(
        Schema().table('e310b_orm_codes', (Table t) {
          t.fullText('label');
        }),
        throwsUnsupportedError,
      );
      await expectLater(
        Schema().table('e310b_orm_codes', (Table t) {
          t.dropPrimary();
        }),
        throwsUnsupportedError,
      );
      // nothing changed: the primary key is still there
      await QueryBuilder.table('e310b_orm_codes')
          .insert(<String, dynamic>{'code': 'one'});
      await expectLater(
        QueryBuilder.table('e310b_orm_codes')
            .insert(<String, dynamic>{'code': 'one'}),
        throwsA(driverError),
      );
    }, skip: sqlite ? false : 'SQLite only');
  });

  group('3.1.0 round 3 e2e: dox_validation wrappers and messages', () {
    test('a nullable after any wrapper lets null pass', () async {
      vd.ObjectSchema s = vd.v.object(<String, vd.Schema<Object?>>{
        'type': vd.v.string(),
        'a': vd.v
            .string()
            .optional()
            .requiredIf('type', 'company')
            .transform((String? x) => x)
            .nullable(),
        'b': vd.v
            .string()
            .optional()
            .requiredIf('type', 'company')
            .nullable()
            .nullable(),
        'c': vd.v.string().nullable().nullable(),
      });
      Map<String, dynamic> person = <String, dynamic>{
        'type': 'person',
        'a': null,
        'b': null,
        'c': null,
      };
      Map<String, dynamic> company = <String, dynamic>{...person}
        ..['type'] = 'company';
      for (vd.ParseResult<Map<String, dynamic>> r
          in <vd.ParseResult<Map<String, dynamic>>>[
            s.safeParse(person),
            await s.safeParseAsync(person),
          ]) {
        expect(r.success, true, reason: '${r.errors}');
      }
      // requiredIf still asks for a and b when type is company
      for (vd.ParseResult<Map<String, dynamic>> r
          in <vd.ParseResult<Map<String, dynamic>>>[
            s.safeParse(company),
            await s.safeParseAsync(company),
          ]) {
        expect(_paths(r), <String>['a', 'b']);
      }
      // a value still passes through the transform
      expect(
        s.safeParse(<String, dynamic>{...company, 'a': 'x', 'b': 'y'}).success,
        true,
      );
    });

    test('issues of an object with requiredIf keep the shape order', () async {
      vd.ObjectSchema s = vd.v.object(<String, vd.Schema<Object?>>{
        'vat': vd.v.string().optional().requiredIf('type', 'company'),
        'type': vd.v.string(),
        'age': vd.v.int(),
        'phone': vd.v.string().optional().requiredWith(<String>['type']),
        'name': vd.v.string(),
      });
      Map<String, dynamic> input = <String, dynamic>{'type': 'company'};
      for (vd.ParseResult<Map<String, dynamic>> r
          in <vd.ParseResult<Map<String, dynamic>>>[
            s.safeParse(input),
            await s.safeParseAsync(input),
          ]) {
        expect(_paths(r), <String>['vat', 'age', 'phone', 'name']);
      }
      // an empty map: no rule fires, the order is the same
      expect(_paths(s.safeParse(<String, dynamic>{})), <String>[
        'type',
        'age',
        'name',
      ]);
    });

    test('DTO messages with the full path, over HTTP', () async {
      http.Response res = await api.post(
        '/core/e310b/profile',
        <String, dynamic>{
          'address': <String, dynamic>{},
          'tags': <String?>['ok', null, 'fine', null],
        },
      );
      expect(res.statusCode, 422, reason: res.body);
      expect(api.json(res), <String, dynamic>{
        'name': 'Outer: the name',
        'address.city': 'Outer: the city',
        'address.street': 'Inner: the street',
        // the outer last key message does not reach the nested DTO
        'address.zip': 'The zip is required',
        'tags.1': 'Outer: each tag',
        'tags.3': 'Outer: each tag',
      });
    });

    test('a good DTO body passes, an empty tag list is fine', () async {
      http.Response res = await api.post(
        '/core/e310b/profile',
        <String, dynamic>{
          'name': 'n',
          'address': <String, dynamic>{'city': 'c', 'street': 's', 'zip': 'z'},
          'tags': <String>[],
        },
      );
      expect(res.statusCode, 200, reason: res.body);
      expect(api.json(res), <String, dynamic>{
        'name': 'n',
        'city': 'c',
        'tags': <String>[],
      });

      // a missing address: the outer message for `address` is the code
      res = await api.post('/core/e310b/profile', <String, dynamic>{
        'name': 'n',
      });
      expect(res.statusCode, 422, reason: res.body);
      expect(api.json(res), <String, dynamic>{
        'address': 'The address is required',
      });
    });
  });

  group('3.1.0 round 3 e2e: drivers after DDL', () {
    const String table = 'e310b_orm_ddl';

    tearDown(() async {
      await Schema().dropIfExists(table);
    });

    /// [sql] on many connections of the pool at once
    Future<void> onMany(String sql, Map<String, dynamic> values) async {
      await Future.wait(<Future<void>>[
        for (int i = 0; i < 20; i++)
          QueryBuilder.query(sql, substitutionValues: values),
      ]);
    }

    Future<Set<String>> values() async {
      List<Map<String, dynamic>> rows = await QueryBuilder.query(
        'SELECT v FROM $table',
      );
      return rows.map((Map<String, dynamic> r) => '${r['v']}').toSet();
    }

    String insert = 'INSERT INTO $table (v) VALUES (@v)';

    test('Postgres: a table rebuilt inside DO keeps 007 as text', () async {
      await QueryBuilder.query('DROP TABLE IF EXISTS $table');
      await QueryBuilder.query('CREATE TABLE $table (v int)');
      // the insert is prepared with an int param on every connection
      await onMany(insert, <String, dynamic>{'v': '7'});
      await QueryBuilder.query(
        'DO \$\$ BEGIN DROP TABLE $table; '
        'CREATE TABLE $table (v text); END \$\$',
      );
      await onMany(insert, <String, dynamic>{'v': '007'});
      expect(await values(), <String>{'007'});
    }, skip: driver == Driver.postgres ? false : 'Postgres only');

    test(
      'Postgres: a changed result type in a transaction gives 0A000',
      () async {
        // a pool with other settings: a pool with the same settings is
        // the same native pool, and it would see the change
        const String other = 'e310b_other';
        ConnectionConfig base = databaseConfig.getConnectionConfig();
        databaseConfig.connections[other] = ConnectionConfig(
          driver: base.driver,
          host: base.host,
          port: base.port,
          user: base.user,
          password: base.password,
          database: base.database,
          debug: false,
          extra: <String, dynamic>{'maxConnectionCount': 2},
        );
        // tear downs run last first: the pool closes, then the entry goes
        addTearDown(() => databaseConfig.connections.remove(other));
        addTearDown(() => SqlQueryBuilder().getDBDriver(other).close());
        // a param, so the select is a cached prepared statement
        String select = 'SELECT v FROM $table WHERE @one = 1';
        Map<String, dynamic> one = <String, dynamic>{'one': 1};
        await QueryBuilder.query('DROP TABLE IF EXISTS $table');
        await QueryBuilder.query('CREATE TABLE $table (v int)');
        await QueryBuilder.query('INSERT INTO $table (v) VALUES (7)');
        // cache the select on every connection of the default pool
        for (int i = 0; i < 3; i++) {
          await onMany(select, one);
        }
        // the change comes from another pool: the default one can not
        // see it
        await QueryBuilder.query(
          'ALTER TABLE $table ALTER COLUMN v TYPE text',
          connection: other,
        );
        Object? error;
        try {
          await QueryBuilder.transaction(() async {
            await QueryBuilder.query(select, substitutionValues: one);
          });
        } catch (e) {
          error = e;
        }
        expect(error, isNotNull);
        expect('$error', contains('0A000'));
        expect('$error', isNot(contains('25P02')));

        // outside a transaction the driver prepares it again
        for (int i = 0; i < 3; i++) {
          await onMany(select, one);
        }
        List<Map<String, dynamic>> rows = await QueryBuilder.query(
          select,
          substitutionValues: one,
        );
        expect(rows.single['v'], '7');
      },
      skip: driver == Driver.postgres ? false : 'Postgres only',
    );

    test('MySQL: ALTER after a comment counts as DDL', () async {
      await QueryBuilder.query('DROP TABLE IF EXISTS $table');
      await QueryBuilder.query('CREATE TABLE $table (v int)');
      await onMany(insert, <String, dynamic>{'v': '7'});
      await QueryBuilder.query(
        '/* migration */ ALTER TABLE $table MODIFY v VARCHAR(10)',
      );
      await onMany(insert, <String, dynamic>{'v': '007'});
      expect(await values(), <String>{'7', '007'});

      // a line comment before DDL counts too
      await QueryBuilder.query('DELETE FROM $table');
      await QueryBuilder.query(
        '-- back to int\nALTER TABLE $table MODIFY v int',
      );
      await onMany(insert, <String, dynamic>{'v': '7'});
      await QueryBuilder.query(
        '# text again\nALTER TABLE $table MODIFY v VARCHAR(10)',
      );
      await onMany(insert, <String, dynamic>{'v': '008'});
      expect(await values(), <String>{'7', '008'});
    }, skip: driver == Driver.mysql ? false : 'MySQL only');
  });
}

List<String> _paths(vd.ParseResult<Map<String, dynamic>> r) {
  return r.issues.map((vd.ValidationIssue i) => i.path.join('.')).toList();
}

/// The index names of [table].
Future<Set<String>> _indexes(String table) async {
  Driver driver = databaseConfig.getConnectionConfig().driver;
  String sql = switch (driver) {
    Driver.postgres =>
      'SELECT indexname AS name FROM pg_indexes WHERE tablename = @t',
    Driver.mysql =>
      'SELECT DISTINCT index_name AS name FROM information_schema.statistics '
          'WHERE table_schema = DATABASE() AND table_name = @t',
    _ =>
      "SELECT name FROM sqlite_master WHERE type = 'index' AND tbl_name = @t",
  };
  List<Map<String, dynamic>> rows = await QueryBuilder.query(
    sql,
    substitutionValues: <String, dynamic>{'t': table},
  );
  return rows.map((Map<String, dynamic> r) => '${r['name']}').toSet();
}

/// The ON UPDATE rule of each foreign key column of [table], like
/// `RESTRICT` or `SET NULL`.
Future<Map<String, String>> _updateRules(String table) async {
  Driver driver = databaseConfig.getConnectionConfig().driver;
  Map<String, dynamic> t = <String, dynamic>{'t': table};
  List<Map<String, dynamic>> rows = switch (driver) {
    Driver.postgres => await QueryBuilder.query(
      'SELECT a.attname AS col, c.confupdtype::text AS rule '
      'FROM pg_constraint c JOIN pg_attribute a '
      'ON a.attrelid = c.conrelid AND a.attnum = ANY (c.conkey) '
      "WHERE c.contype = 'f' AND c.conrelid = @t::regclass",
      substitutionValues: t,
    ),
    Driver.mysql => await QueryBuilder.query(
      'SELECT k.COLUMN_NAME AS col, r.UPDATE_RULE AS rule '
      'FROM information_schema.REFERENTIAL_CONSTRAINTS r '
      'JOIN information_schema.KEY_COLUMN_USAGE k '
      'ON k.CONSTRAINT_SCHEMA = r.CONSTRAINT_SCHEMA '
      'AND k.CONSTRAINT_NAME = r.CONSTRAINT_NAME '
      'AND k.TABLE_NAME = r.TABLE_NAME '
      'WHERE r.CONSTRAINT_SCHEMA = DATABASE() AND r.TABLE_NAME = @t',
      substitutionValues: t,
    ),
    _ => <Map<String, dynamic>>[
      for (Map<String, dynamic> r in await QueryBuilder.query(
        "PRAGMA foreign_key_list('$table')",
      ))
        <String, dynamic>{'col': r['from'], 'rule': r['on_update']},
    ],
  };
  const Map<String, String> pg = <String, String>{
    'a': 'NO ACTION',
    'r': 'RESTRICT',
    'c': 'CASCADE',
    'n': 'SET NULL',
    'd': 'SET DEFAULT',
  };
  return <String, String>{
    for (Map<String, dynamic> r in rows)
      '${r['col']}': pg['${r['rule']}'] ?? '${r['rule']}'.toUpperCase(),
  };
}

/// The two test migrations. Their names sort after every real one.
final MigrationEntry _migCreate = MigrationEntry(
  '2099_02_01_000001_e310b_orm_create',
  _CreateKids(),
);
final MigrationEntry _migAlter = MigrationEntry(
  '2099_02_01_000002_e310b_orm_alter',
  _AlterKids(),
);

/// A migrator for [list] only, on the app connection. The empty folder
/// means no `.sql` file is read.
Migrator _migrator(List<MigrationEntry> list) {
  Directory dir = Directory.systemTemp.createTempSync('e310b-mig');
  addTearDown(() async {
    await dir.delete(recursive: true);
  });
  return Migrator(
    migrations: list,
    connection: SqlQueryBuilder().getDBDriver(),
    directory: dir,
  );
}

bool get _sqlite =>
    databaseConfig.getConnectionConfig().driver == Driver.sqlite;

/// Uses every new column helper. SQLite has no full text index and can
/// not drop a primary key, so those parts are left out there.
class _CreateKids extends Migration {
  @override
  Future<void> up(Schema schema) async {
    await schema.create('e310b_orm_parents', (Table t) {
      t.id();
      t.ulid('code').unique();
    });
    await schema.create('e310b_orm_kids', (Table t) {
      t.id();
      t.foreignIdFor(E310bItem()).nullable().constrained().nullOnUpdate();
      t.ulid('code');
      t
          .foreignUlid('parent_code')
          .nullable()
          .constrained('e310b_orm_parents', 'code')
          .restrictOnUpdate();
      t.year('born').nullable();
      t.ipAddress().nullable();
      t.softDeletesTz();
      t.nullableMorphs('owner');
      t.uuidMorphs('target');
      t.string('label', 30).nullable();
      t.index('label', 'e310b_orm_kids_label_old');
      if (!_sqlite) t.fullText('label');
      t.timestamps();
    });
    if (!_sqlite) {
      await schema.create('e310b_orm_codes', (Table t) {
        t.string('code', 10).primary();
      });
    }
  }

  @override
  Future<void> down(Schema schema) async {
    await schema.dropIfExists('e310b_orm_codes');
    await schema.dropIfExists('e310b_orm_kids');
    await schema.dropIfExists('e310b_orm_parents');
  }
}

/// The drop and rename helpers, all in one change of the table.
class _AlterKids extends Migration {
  @override
  Future<void> up(Schema schema) async {
    await schema.table('e310b_orm_kids', (Table t) {
      t.dropTimestamps();
      t.dropSoftDeletes();
      t.dropConstrainedForeignId('parent_code');
      t.renameIndex('e310b_orm_kids_label_old', 'e310b_orm_kids_label_new');
    });
    if (!_sqlite) {
      await schema.table('e310b_orm_codes', (Table t) {
        t.dropPrimary();
      });
    }
  }

  @override
  Future<void> down(Schema schema) async {}
}

/// The tables of the e2e310b models. Each group makes them fresh and
/// drops them after.
class _Tables {
  static Future<void> create() async {
    await drop();
    Schema schema = Schema();
    await schema.create('e310b_orm_items', (Table t) {
      t.id();
      t.string('name', 50).nullable();
      t.integer('qty').nullable();
      t.string('secret', 50).nullable();
      t.timestamps();
    });
    await schema.create('e310b_orm_tags', (Table t) {
      t.id();
      t.string('name', 50).nullable();
    });
    await schema.create('e310b_orm_item_tag', (Table t) {
      t.bigInteger('item_id');
      t.bigInteger('tag_id');
    });
    await schema.create('e310b_orm_notes', (Table t) {
      t.id();
      t.text('body').nullable();
      t.timestampTz('made_at').nullable();
      t.timestampTz('changed_at').nullable();
    });
  }

  static Future<void> drop() async {
    for (String name in <String>[
      'e310b_orm_kids',
      'e310b_orm_item_tag',
      'e310b_orm_tags',
      'e310b_orm_notes',
      'e310b_orm_items',
    ]) {
      await Schema().dropIfExists(name);
    }
  }
}
