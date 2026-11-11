import 'dart:io';

import 'package:dox_core/dox_core.dart'
    as vd
    show ObjectSchema, ParseResult, Schema, v;
import 'package:dox_migration/dox_migration.dart';
import 'package:dox_orm/dox_orm.dart';
import 'package:dox_test/app/dtos/e2e310/e2e310.dto.dart';
import 'package:dox_test/app/models/badge/badge.model.dart';
import 'package:dox_test/app/models/e2e310/e2e310.model.dart';
import 'package:dox_test/app/models/post/post.model.dart';
import 'package:dox_test/app/models/reaction/reaction.model.dart';
import 'package:dox_test/app/models/user/user.model.dart';
import 'package:dox_test/config/database.dart';
import 'package:test/test.dart';

import 'e2e_test.dart' show Api;

/// 3.1.0 checks of dox_orm, dox_migration, dox_validation, the native
/// drivers and the dox_builder model and DTO code that the other files do
/// not check: missing features, edge values and 3.0.2 behavior that must
/// still work. Every table here is made and dropped by this file.
void orm310Tests(Api api) {
  Driver driver = databaseConfig.getConnectionConfig().driver;

  /// MySQL compares text without case by default. The SQLite pivot table
  /// below uses `COLLATE NOCASE`. Postgres compares the exact text.
  bool caseless = driver != Driver.postgres;

  group('3.1.0 e2e: ORM features', () {
    setUpAll(_Tables.create);
    tearDownAll(_Tables.drop);

    test('a digit stays with the word before it: oauth2_client', () async {
      expect(Oauth2Client().tableName, 'oauth2_client');
      Oauth2Client c = await Oauth2Client().forceCreate(<String, dynamic>{
        'name': 'app',
      });
      expect((await Oauth2Client().find(c.id))?.name, 'app');
    });

    test('find, pluck and the first-or helpers throw on a union', () async {
      E2eBook q() => E2eBook()
        ..where('sku', 'A1')
        ..union(E2eBook().where('sku', 'A2'));
      int before = await E2eBook().count();
      Map<String, dynamic> where = <String, dynamic>{'sku': 'U1'};
      Map<String, dynamic> values = <String, dynamic>{'title': 'u'};
      List<Future<dynamic> Function()> calls = <Future<dynamic> Function()>[
        () => q().find(1),
        () => q().find('sku', 'A1'),
        () => q().findOrFail(1),
        () => q().pluck('sku'),
        () => q().pluckMap('sku', 'id'),
        () => q().valueOf('sku'),
        () => q().firstOrNew(where),
        () => q().firstOrCreate(where, values),
        () => q().updateOrCreate(where, values),
      ];
      for (Future<dynamic> Function() call in calls) {
        await expectLater(Future<dynamic>.sync(call), throwsStateError);
      }
      expect(await E2eBook().count(), before);

      // get() and getFirst() still work on a union
      List<E2eBook> rows =
          await (E2eBook()
                ..where('sku', 'A1')
                ..union(E2eBook().where('sku', 'A2'))
                ..orderBy('sku'))
              .get();
      expect(rows.map((E2eBook b) => b.sku), <String>['A1', 'A2']);
      expect((await q().getFirst())?.sku, isNotNull);
    });

    test('fromSub on a soft delete model: reads use the alias', () async {
      List<String> names = <String>['E2E310 a', 'E2E310 b', 'E2E310 c'];
      _removeBadgesAfter(names);
      for (String name in names) {
        await Badge().create(<String, dynamic>{'name': name, 'score': 3});
      }
      await (await Badge().where('name', 'E2E310 b').getFirst())!.delete();
      QueryBuilder<Map<String, dynamic>> sub() =>
          QueryBuilder.table('badges')
              .select('id, name, deleted_at')
              .whereIn('name', names);

      // the soft delete check is `b.deleted_at`, so b is hidden
      List<Badge> rows = await Badge()
          .fromSub(sub(), 'b')
          .orderBy('name')
          .get();
      expect(rows.map((Badge b) => b.name), <String>['E2E310 a', 'E2E310 c']);
      expect(await Badge().fromSub(sub(), 'b').count(), 2);
      List<String?> chunked = <String?>[];
      await Badge().fromSub(sub(), 'b').chunk(1, (List<Badge> page) {
        chunked.addAll(page.map((Badge b) => b.name));
        return true;
      });
      expect(chunked, <String>['E2E310 a', 'E2E310 c']);
    });

    test('fromSub on a soft delete model: writes use the table', () async {
      _removeBadgesAfter(<String>['E2E310 w']);
      Badge badge = await Badge().create(<String, dynamic>{
        'name': 'E2E310 w',
        'score': 1,
      });
      Badge q() => Badge()
        ..fromSub(QueryBuilder.table('badges').select('id'), 'b')
        ..where('name', 'E2E310 w');
      expect(await q().update(<String, dynamic>{'score': 7}), 1);
      expect((await Badge().find(badge.id))?.score, 7);
      expect(await q().delete(), 1);
      expect(await Badge().find(badge.id), isNull);
      expect((await Badge().withTrash().find(badge.id))?.deletedAt, isNotNull);
      expect(await q().restore(), true);
      expect((await Badge().find(badge.id))?.score, 7);
    });

    test('a relation that is gone is cleared on the same model', () async {
      E2eShelf shelf = await E2eShelf().create(<String, dynamic>{
        'name': 'reload',
      });
      await shelf.attach('books', <String>['A1']);
      await shelf.$getRelation<dynamic>('books');
      expect(shelf.books.map((E2eBook b) => b.sku), <String>['A1']);
      await shelf.detach('books');
      await shelf.$getRelation<dynamic>('books');
      expect(shelf.books, isEmpty);

      _removeBadgesAfter(<String>['E2E310 morph']);
      Badge badge = await Badge().create(<String, dynamic>{
        'name': 'E2E310 morph',
        'score': 1,
      });
      Reaction reaction = await Reaction().create(<String, dynamic>{
        'emoji': 'star',
        'reactable_id': badge.id,
        'reactable_type': Model.morphTypeOf(Badge()),
      });
      addTearDown(() async {
        await Reaction().where('id', reaction.id).delete();
      });
      Reaction loaded = (await Reaction().find(reaction.id))!;
      await loaded.$getRelation<dynamic>('reactable');
      expect((loaded.reactable as Badge?)?.name, 'E2E310 morph');
      await Badge().where('id', badge.id).forceDelete();
      await loaded.$getRelation<dynamic>('reactable');
      expect(loaded.reactable, isNull);
    });

    test('update and delete with orderBy and limit', () async {
      for (String sku in <String>['L1', 'L2', 'L3']) {
        await E2eBook().create(<String, dynamic>{'sku': sku, 'title': 't'});
      }
      expect(
        await E2eBook()
            .where('sku', 'like', 'L%')
            .orderBy('sku', 'desc')
            .limit(1)
            .update(<String, dynamic>{'title': 'last'}),
        1,
      );
      List<E2eBook> rows = await E2eBook()
          .where('sku', 'like', 'L%')
          .orderBy('sku')
          .get();
      expect(rows.map((E2eBook b) => b.title), <String>['t', 't', 'last']);

      await E2eBook()
          .where('sku', 'like', 'L%')
          .orderBy('sku')
          .limit(2)
          .delete();
      expect(
        (await E2eBook().where('sku', 'like', 'L%').get()).map(
          (E2eBook b) => b.sku,
        ),
        <String>['L3'],
      );

      await expectLater(
        Future<dynamic>.sync(
          () => E2eBook().where('sku', 'L3').groupBy('sku').update(
            <String, dynamic>{'title': 'x'},
          ),
        ),
        throwsArgumentError,
      );
      await E2eBook().where('sku', 'L3').delete();
    });

    test('whereRaw: @name inside a quoted text is not a param', () async {
      await QueryBuilder.table('e2e_values')
          .insertMultiple(<Map<String, dynamic>>[
            <String, dynamic>{'s': '@who'},
            <String, dynamic>{'s': 'bob'},
          ]);
      expect(
        await QueryBuilder.table('e2e_values')
            .whereRaw("s = '@who' OR s = @who", <String, dynamic>{'who': 'bob'})
            .count(),
        2,
      );
      await QueryBuilder.table('e2e_values')
          .whereIn('s', <String>['@who', 'bob'])
          .delete();
    });

    test('sub queries and sets in whereIn, whereNotIn, orWhereIn', () async {
      QueryBuilder<Map<String, dynamic>> idOf(String sku) {
        return QueryBuilder.table('e2e_books').select('id').where('sku', sku);
      }

      Future<List<String?>> skus(QueryBuilder<E2eBook> q) async {
        return (await q.orderBy('sku').get())
            .map((E2eBook b) => b.sku)
            .toList();
      }

      expect(
        await skus(E2eBook().whereIn('sku', <String>{'A1', 'B1'})),
        <String>['A1', 'B1'],
      );
      expect(
        await skus(
          E2eBook()
              .whereIn('sku', <String>['A1', 'A2', 'B1'])
              .whereNotIn('id', idOf('A1')),
        ),
        <String>['A2', 'B1'],
      );
      expect(
        await skus(E2eBook().where('sku', 'A1').orWhereIn('id', idOf('B1'))),
        <String>['A1', 'B1'],
      );
    });

    test('leftJoinSub keeps the rows with no match', () async {
      E2eShelf shelf = await E2eShelf().create(<String, dynamic>{
        'name': 'join',
      });
      await shelf.attach('books', <String>['A1']);
      QueryBuilder<Map<String, dynamic>> counts = QueryBuilder.table(
        'e2e_shelf_book',
      ).selectRaw('book_sku, COUNT(*) AS n').groupBy('book_sku');
      List<Map<String, dynamic>> rows = await QueryBuilder.table('e2e_books')
          .select(<String>['e2e_books.sku', 'c.n'])
          .leftJoinSub(counts, 'c', 'c.book_sku', 'e2e_books.sku')
          .whereIn('e2e_books.sku', <String>['A1', 'A2'])
          .orderBy('e2e_books.sku')
          .get();
      expect(rows.map((Map<String, dynamic> r) => r['sku']), <String>[
        'A1',
        'A2',
      ]);
      expect('${rows[0]['n']}', '1');
      expect(rows[1]['n'], isNull);
      await shelf.detach('books');
    });

    test('a failed nested transaction does not stop the outer one', () async {
      Future<void> add(String s) async {
        await QueryBuilder.table('e2e_values')
            .insert(<String, dynamic>{'s': s});
      }

      await QueryBuilder.transaction(() async {
        await add('tx outer');
        for (int i = 0; i < 3; i++) {
          try {
            await QueryBuilder.transaction(() async {
              await add('tx inner $i');
              throw StateError('undo $i');
            });
          } on StateError {
            // only the savepoint is rolled back
          }
        }
        await QueryBuilder.transaction(() async {
          await add('tx kept');
        });
      });
      List<Map<String, dynamic>> rows = await QueryBuilder.table('e2e_values')
          .where('s', 'like', 'tx %')
          .orderBy('s')
          .get();
      expect(rows.map((Map<String, dynamic> r) => r['s']), <String>[
        'tx kept',
        'tx outer',
      ]);
      await QueryBuilder.table('e2e_values')
          .where('s', 'like', 'tx %')
          .delete();
    });

    test('logRedact hides values, a buffered file log keeps order', () async {
      SqlQueryBuilder sql = SqlQueryBuilder();
      bool oldDebug = sql.debug;
      QueryPrinter oldPrinter = sql.printer;
      List<String> oldRedact = sql.logRedact;
      Directory dir = await Directory.systemTemp.createTemp('e2e310-log');
      File file = File('${dir.path}/query.log');
      FileQueryPrinter printer = FileQueryPrinter(file: file, buffered: true);
      try {
        sql.debug = true;
        sql.printer = printer;
        sql.logRedact = <String>['token'];
        await QueryBuilder.table('e2e_values').whereRaw(
          's = @api_token OR s = @who',
          <String, dynamic>{'api_token': 'hush-123', 'who': 'visible-9'},
        ).count();
        await QueryBuilder.table('e2e_values').where('s', 'second-7').count();
      } finally {
        sql.debug = oldDebug;
        sql.printer = oldPrinter;
        sql.logRedact = oldRedact;
      }
      await printer.flush();
      String log = await file.readAsString();
      await dir.delete(recursive: true);
      expect(log, contains('***'));
      expect(log, contains('visible-9'));
      expect(log, isNot(contains('hush-123')));
      expect(log.indexOf('visible-9'), lessThan(log.indexOf('second-7')));
    });
  });

  group('3.1.0 e2e: dox_migration', () {
    /// drops the test tables and their `dox_db_migration` rows, also
    /// when a test fails
    Future<void> cleanMigrations() async {
      await Schema().dropIfExists('e2e_mig_a');
      await Schema().dropIfExists('e2e_mig_b');
      await QueryBuilder.table('dox_db_migration')
          .whereIn('migration', <String>[_migA.name, _migB.name])
          .delete();
    }

    setUp(cleanMigrations);
    tearDown(cleanMigrations);

    test('migrate and rollback a batch, up and down', () async {
      Migrator m = _migrator(<MigrationEntry>[_migA, _migB]);
      await m.migrate();
      expect(await Schema().hasTable('e2e_mig_a'), true);
      expect(await Schema().hasTable('e2e_mig_b'), true);
      await m.rollback();
      expect(await Schema().hasTable('e2e_mig_a'), false);
      expect(await Schema().hasTable('e2e_mig_b'), false);
      expect(
        await QueryBuilder.table('dox_db_migration')
            .whereIn('migration', <String>[_migA.name, _migB.name])
            .count(),
        0,
      );
    });

    test('rollback goes on when the file of a migration is gone', () async {
      await _migrator(<MigrationEntry>[_migA, _migB]).migrate();

      // b is gone from the list: its row stays, a is rolled back
      Migrator onlyA = _migrator(<MigrationEntry>[_migA]);
      List<MigrationStatus> status = await onlyA.status();
      MigrationStatus b = status.firstWhere(
        (MigrationStatus s) => s.name == _migB.name,
      );
      expect(b.ran, true);
      expect(b.exists, false);
      await onlyA.rollback();
      expect(await Schema().hasTable('e2e_mig_a'), false);
      expect(await Schema().hasTable('e2e_mig_b'), true);
      expect(
        await QueryBuilder.table('dox_db_migration')
            .where('migration', _migB.name)
            .count(),
        1,
      );

      // with the file back, b rolls back too
      await _migrator(<MigrationEntry>[_migB]).rollback();
      expect(await Schema().hasTable('e2e_mig_b'), false);
      expect(
        await QueryBuilder.table('dox_db_migration')
            .where('migration', _migB.name)
            .count(),
        0,
      );
    });

    test('foreignId keeps constrained() after unique()', () async {
      // SQLite checks foreign keys only with this pragma on
      bool sqlite = driver == Driver.sqlite;
      if (sqlite) {
        List<Map<String, dynamic>> fk = await QueryBuilder.query(
          'PRAGMA foreign_keys',
        );
        if ('${fk.first.values.first}' != '1') {
          await QueryBuilder.query('PRAGMA foreign_keys = ON');
          addTearDown(() async {
            await QueryBuilder.query('PRAGMA foreign_keys = OFF');
          });
        }
      }
      addTearDown(() async {
        await Schema().dropIfExists('e2e_fk');
        await Schema().dropIfExists('e2e_members');
      });
      await Schema().dropIfExists('e2e_fk');
      await Schema().dropIfExists('e2e_members');
      await Schema().create('e2e_members', _Tables.members);
      await Schema().create('e2e_fk', (Table t) {
        t.id();
        t.foreignId('member_id').unique().constrained('e2e_members');
      });

      E2eMember m = await E2eMember().create(<String, dynamic>{'name': 'fk'});
      await QueryBuilder.table('e2e_fk')
          .insert(<String, dynamic>{'member_id': m.id});
      // unique(): the same member twice is rejected
      await expectLater(
        QueryBuilder.table('e2e_fk')
            .insert(<String, dynamic>{'member_id': m.id}),
        throwsA(driverError),
      );
      // constrained(): a member that does not exist is rejected
      await expectLater(
        QueryBuilder.table('e2e_fk')
            .insert(<String, dynamic>{'member_id': 999999}),
        throwsA(driverError),
      );
      expect(await QueryBuilder.table('e2e_fk').count(), 1);
    });
  });

  group('3.1.0 e2e: dox_validation', () {
    setUpAll(_Tables.create);
    tearDownAll(_Tables.drop);

    vd.ObjectSchema form = vd.v.object(<String, vd.Schema<Object?>>{
      // vat comes before type: the key order does not matter
      'vat': vd.v.string().optional().requiredIf('type', 'company').nullable(),
      'type': vd.v.string().trim().toLowerCase(),
      'phone': vd.v.string().optional().requiredWith(<String>['email']),
      'email': vd.v.string().trim().optional(),
    });

    test('fluent requiredIf reads the converted value of the other key', () {
      Set<String> keys(Map<String, dynamic> input) {
        return form.safeParse(input).errors.keys.toSet();
      }

      expect(keys(<String, dynamic>{'type': ' Company '}), <String>{'vat'});
      // nullable() after requiredIf keeps the check
      expect(keys(<String, dynamic>{'type': 'COMPANY', 'vat': null}), <String>{
        'vat',
      });
      expect(keys(<String, dynamic>{'type': ' person '}), <String>{});
      expect(
        keys(<String, dynamic>{'type': 'person', 'email': 'a@b.co'}),
        <String>{'phone'},
      );
      expect(
        keys(<String, dynamic>{'type': 'company', 'vat': 'V1', 'phone': '1'}),
        <String>{},
      );
    });

    test('DTO @RequiredIf and @RequiredWith read the trimmed value', () async {
      Future<Map<String, String>> errors(Map<String, dynamic> input) async {
        vd.ParseResult<E2eTeamForm> r = await E2eTeamForm.schema
            .safeValidateMap(input);
        return r.errors;
      }

      Map<String, String> team = await errors(<String, dynamic>{
        'kind': ' Team ',
      });
      expect(team.keys, <String>['team_name']);
      expect(team['team_name'], contains('required'));

      vd.ParseResult<E2eTeamForm> solo = await E2eTeamForm.schema
          .safeValidateMap(<String, dynamic>{'kind': ' Solo '});
      expect(solo.success, true);
      expect(solo.value?.kind, 'solo');

      expect(
        (await errors(<String, dynamic>{'kind': 'solo', 'email': ' a@b.co '}))
            .keys,
        <String>['phone'],
      );
      // blank after trim is not there, so phone is not needed
      expect(
        await errors(<String, dynamic>{'kind': 'solo', 'email': '   '}),
        <String, String>{},
      );
    });

    test('exists and unique ask the database, with its case rules', () async {
      vd.ObjectSchema s = vd.v.object(<String, vd.Schema<Object?>>{
        'have': vd.v.string().exists('e2e_books', column: 'sku'),
        'free': vd.v.string().unique('e2e_books', column: 'sku'),
      });
      vd.ParseResult<Map<String, dynamic>> ok = await s.safeParseAsync(
        <String, dynamic>{'have': 'A1', 'free': 'ZZ9'},
      );
      expect(ok.success, true, reason: '${ok.errors}');

      vd.ParseResult<Map<String, dynamic>> bad = await s.safeParseAsync(
        <String, dynamic>{'have': 'ZZ9', 'free': 'A1'},
      );
      expect(bad.errors.keys.toSet(), <String>{'have', 'free'});

      // MySQL compares without case, so `a1` is taken there
      vd.ParseResult<Map<String, dynamic>> lower = await s.safeParseAsync(
        <String, dynamic>{'have': 'A1', 'free': 'a1'},
      );
      expect(lower.success, driver != Driver.mysql, reason: '${lower.errors}');
    });

    test('same, confirmed, digits, between, dateFormat, password, json', () {
      vd.ObjectSchema s = vd.v.object(<String, vd.Schema<Object?>>{
        'code': vd.v.string(),
        'code_again': vd.v.string().same('code'),
        'pass': vd.v
            .string()
            .password(mixedCase: true, numbers: true)
            .confirmed(),
        'pin': vd.v.string().digits(4),
        'otp': vd.v.string().digitsBetween(4, 6),
        'level': vd.v.int().between(1, 10),
        'day': vd.v.string().dateFormat('Y-m-d'),
        'data': vd.v.string().json(),
      });
      Map<String, dynamic> good = <String, dynamic>{
        'code': 'A1',
        'code_again': 'A1',
        'pass': 'Secret123',
        'pass_confirmation': 'Secret123',
        'pin': '0042',
        'otp': '12345',
        'level': 10,
        'day': '2024-02-29',
        'data': '[1, {"a": "世"}]',
      };
      expect(
        s.safeParse(good).success,
        true,
        reason: '${s.safeParse(good).errors}',
      );
      Map<String, dynamic> bad = <String, dynamic>{
        'code': 'A1',
        'code_again': 'a1',
        'pass': 'Secret123',
        'pass_confirmation': 'Secret124',
        'pin': '42',
        'otp': '1234567',
        'level': 11,
        'day': '2023-02-29',
        'data': '{"a":',
      };
      expect(s.safeParse(bad).errors.keys.toSet(), <String>{
        'code_again',
        'pass',
        'pin',
        'otp',
        'level',
        'day',
        'data',
      });
    });
  });

  group('3.1.0 e2e: edge values', () {
    setUpAll(_Tables.create);
    tearDownAll(_Tables.drop);

    Future<Map<String, dynamic>> roundTrip(Map<String, dynamic> row) async {
      await QueryBuilder.table('e2e_values').insert(row);
      return (await QueryBuilder.table(
        'e2e_values',
      ).where('tag', row['tag']).get()).single;
    }

    test('null and empty text are not the same', () async {
      Map<String, dynamic> row = await roundTrip(<String, dynamic>{
        'tag': 'empty',
        's': '',
        'txt': null,
        'i': 0,
      });
      expect(row['s'], '');
      expect(row['txt'], isNull);
      expect('${row['i']}', '0');
      expect(
        await QueryBuilder.table('e2e_values')
            .where('tag', 'empty')
            .where('txt', null)
            .count(),
        1,
      );
      expect(
        await QueryBuilder.table('e2e_values')
            .where('tag', 'empty')
            .where('s', null)
            .count(),
        0,
      );
      expect(
        await QueryBuilder.table('e2e_values')
            .where('tag', 'empty')
            .where('s', '')
            .count(),
        1,
      );
    });

    test('unicode text, in a model and in a json column', () async {
      const String text = 'héllo 世界 \u{1F436} é שלום';
      Map<String, dynamic> row = await roundTrip(<String, dynamic>{
        'tag': 'unicode',
        's': text,
        'txt': text,
      });
      expect(row['s'], text);
      expect(row['txt'], text);
      expect(
        await QueryBuilder.table('e2e_values').where('s', text).count(),
        1,
      );

      E2eBook book = await E2eBook().create(<String, dynamic>{
        'sku': 'UÉ',
        'title': text,
        'meta': <String, dynamic>{
          'name': text,
          'list': <dynamic>[1, '\u{1F436}', null, true],
        },
      });
      E2eBook fresh = (await E2eBook().find(book.id))!;
      expect(fresh.title, text);
      expect(fresh.meta, <String, dynamic>{
        'name': text,
        'list': <dynamic>[1, '\u{1F436}', null, true],
      });
      expect((await E2eBook().where('sku', 'UÉ').getFirst())?.id, book.id);
      await E2eBook().where('id', book.id).delete();
    });

    test('very long text and a full varchar(255)', () async {
      String long = 'x' * 200000;
      String full = '世' * 255;
      Map<String, dynamic> row = await roundTrip(<String, dynamic>{
        'tag': 'long',
        'txt': long,
        's': full,
      });
      expect((row['txt'] as String).length, 200000);
      expect(row['txt'], long);
      expect(row['s'], full);
    });

    test('boundary numbers keep their exact value', () async {
      const int maxBig = 9223372036854775807;
      const int minBig = -9223372036854775808;
      Map<String, dynamic> row = await roundTrip(<String, dynamic>{
        'tag': 'max',
        'big': maxBig,
        'i': 2147483647,
        'd': 1.5e300,
      });
      expect(row['big'], maxBig);
      expect(row['i'], 2147483647);
      expect(row['d'], 1.5e300);
      row = await roundTrip(<String, dynamic>{
        'tag': 'min',
        'big': minBig,
        'i': -2147483648,
        'd': -0.000001,
      });
      expect(row['big'], minBig);
      expect(row['i'], -2147483648);
      expect(row['d'], -0.000001);
      expect(
        await QueryBuilder.table('e2e_values').where('big', maxBig).count(),
        1,
      );
      expect(
        await QueryBuilder.table('e2e_values')
            .where('big', '>', maxBig - 1)
            .count(),
        1,
      );
    });

    test('empty and duplicate id lists in whereIn and whereNotIn', () async {
      int all = await E2eBook().count();
      expect(await E2eBook().whereIn('sku', <String>[]).count(), 0);
      expect(await E2eBook().whereNotIn('sku', <String>[]).count(), all);
      expect(await E2eBook().whereIn('sku', <String>['A1', 'A1']).count(), 1);
      expect(
        await E2eBook().whereIn('id', <int>[
          for (int i = 0; i < 1500; i++) i,
        ]).count(),
        all,
      );
    });

    test('the same SQL with int, text, bool and null params', () async {
      await roundTrip(<String, dynamic>{
        'tag': 'types',
        's': '5',
        'i': 5,
        'flag': true,
      });
      QueryBuilder<Map<String, dynamic>> q() {
        return QueryBuilder.table('e2e_values').where('tag', 'types');
      }

      expect(await q().where('i', 5).count(), 1);
      expect(await q().where('i', '5').count(), 1);
      expect(await q().where('s', '5').count(), 1);
      expect(await q().where('s', 5).count(), 1);
      expect(await q().where('s', 0).count(), 0);
      expect(await q().where('s', 'zzz').count(), 0);
      expect(await q().where('s', null).count(), 0);
      expect(await q().where('s', '5').count(), 1);

      // a bool column: bool params, then an int on the same SQL
      expect(await q().where('flag', true).count(), 1);
      expect(await q().where('flag', false).count(), 0);
      expect(await q().where('flag', 1).count(), 1);
      expect(await q().where('flag', 0).count(), 0);
      expect(await q().where('flag', true).count(), 1);
    });
  });

  group('3.1.0 e2e: mass assignment (guarded fix)', () {
    setUpAll(_Tables.create);
    tearDownAll(_Tables.drop);

    Future<bool?> adminOf(String name) async {
      return (await E2eMember().where('name', name).getFirst())?.isAdmin;
    }

    test('a changed key can not set a guarded column', () async {
      List<String> keys = <String>[
        'is_admin',
        ' is_admin',
        'is_admin\t',
        'IS_ADMIN',
        'Is_Admin',
        'e2e_members.is_admin',
      ];
      for (int i = 0; i < keys.length; i++) {
        E2eMember m = await E2eMember().create(<String, dynamic>{
          'name': 'create $i',
          keys[i]: true,
        });
        expect(await adminOf('create $i'), false, reason: keys[i]);

        await E2eMember().where('id', m.id).update(<String, dynamic>{
          'name': 'query $i',
          keys[i]: true,
        });
        expect(await adminOf('query $i'), false, reason: keys[i]);

        E2eMember loaded = (await E2eMember().find(m.id))!;
        await loaded.update(<String, dynamic>{
          'name': 'model $i',
          keys[i]: true,
        });
        expect(await adminOf('model $i'), false, reason: keys[i]);
      }
    });

    test('upsert, insertOrIgnore and insertMultiple drop it too', () async {
      await E2eMember().upsert(
        <Map<String, dynamic>>[
          <String, dynamic>{'name': 'up', 'IS_ADMIN': true},
        ],
        <String>['name'],
      );
      expect(await adminOf('up'), false);
      await E2eMember().insertOrIgnore(<Map<String, dynamic>>[
        <String, dynamic>{'name': 'ignore', ' is_admin': true},
      ]);
      expect(await adminOf('ignore'), false);
      await E2eMember().insertMultiple(<Map<String, dynamic>>[
        <String, dynamic>{'name': 'multi', 'e2e_members.is_admin': true},
      ]);
      expect(await adminOf('multi'), false);
    });

    test('a key that is not a column is dropped, not sent', () async {
      E2eMember m = await E2eMember().create(<String, dynamic>{
        'name': 'unknown',
        'nope': 1,
        'name; DROP TABLE e2e_members': 'x',
      });
      expect((await E2eMember().find(m.id))?.name, 'unknown');
    });

    test('forceUpdate and unguarded still set it', () async {
      E2eMember m = await E2eMember().create(<String, dynamic>{
        'name': 'force',
      });
      await E2eMember().where('id', m.id).forceUpdate(<String, dynamic>{
        'is_admin': true,
      });
      expect(await adminOf('force'), true);
      await Model.unguarded(() async {
        await E2eMember().create(<String, dynamic>{
          'name': 'open',
          'is_admin': true,
        });
      });
      expect(await adminOf('open'), true);
    });
  });

  group('3.1.0 e2e: many to many edge cases', () {
    setUpAll(_Tables.create);
    tearDownAll(_Tables.drop);

    late E2eShelf shelf;

    setUp(() async {
      shelf = await E2eShelf().create(<String, dynamic>{'name': 'edge'});
    });

    Future<List<String>> stored() async {
      List<Map<String, dynamic>> rows = await QueryBuilder.table(
        'e2e_shelf_book',
      ).where('shelf_id', shelf.id).get();
      return rows.map((Map<String, dynamic> r) => '${r['book_sku']}').toList()
        ..sort();
    }

    test('duplicate ids give one row and are listed once', () async {
      await shelf.attach('books', <String>['A1', 'A1']);
      expect(await stored(), <String>['A1']);
      PivotSyncResult r = await shelf.sync('books', <String>['A1', 'A2', 'A2']);
      expect(r.attached, <String>['A2']);
      expect(r.detached, <String>[]);
      expect(await stored(), <String>['A1', 'A2']);
    });

    test('empty id lists', () async {
      await shelf.attach('books', <String>[]);
      expect(await stored(), <String>[]);
      await shelf.attach('books', <String>['A1', 'A2']);
      expect(await shelf.detach('books', <String>[]), 0);
      PivotSyncResult t = await shelf.toggle('books', <String>[]);
      expect(t.attached, isEmpty);
      expect(t.detached, isEmpty);
      expect(await stored(), <String>['A1', 'A2']);

      // a null in the list would detach every other link: it throws
      await expectLater(
        shelf.sync('books', <String?>['A1', null]),
        throwsArgumentError,
      );
      expect(await stored(), <String>['A1', 'A2']);

      PivotSyncResult r = await shelf.sync('books', <String>[]);
      expect(r.detached.toSet(), <String>{'A1', 'A2'});
      expect(await stored(), <String>[]);
    });

    test('text keys that differ only by case', () async {
      await shelf.attach('books', <String>['ABC']);
      PivotSyncResult r = await shelf.sync('books', <String>['abc']);
      if (caseless) {
        // the database sees abc as the row ABC: it keeps it
        expect(r.attached, <String>[]);
        expect(r.detached, <String>[]);
        expect(await stored(), <String>['ABC']);
        PivotSyncResult t = await shelf.toggle('books', <String>['abc']);
        expect(t.detached, <String>['ABC']);
        expect(await stored(), <String>[]);
      } else {
        expect(r.attached, <String>['abc']);
        expect(r.detached, <String>['ABC']);
        expect(await stored(), <String>['abc']);
      }
    });

    test('more than 100 text ids in one sync and toggle', () async {
      List<String> upper = <String>[
        for (int i = 0; i < 150; i++) 'K${'$i'.padLeft(3, '0')}',
      ];
      await shelf.attach('books', upper);
      expect((await stored()).length, 150);

      // 149 ids that differ by case (two parts of 100), K149 is left out
      List<String> lower = <String>[
        for (String s in upper.take(149)) s.toLowerCase(),
        'Z999',
      ];
      PivotSyncResult r = await shelf.sync('books', lower);
      if (caseless) {
        expect(r.attached, <String>['Z999']);
        expect(r.detached, <String>['K149']);
        expect(await stored(), <String>[...upper.take(149), 'Z999']);

        PivotSyncResult t = await shelf.toggle('books', lower);
        expect(t.attached, <String>[]);
        expect(t.detached.length, 150);
        expect(await stored(), <String>[]);
      } else {
        expect(r.attached.length, 150);
        expect(r.detached.toSet(), upper.toSet());
        expect(await stored(), (List<String>.of(lower)..sort()));
      }
    });

    test('attach and detach of 1200 ids in one call', () async {
      List<String> many = <String>[for (int i = 0; i < 1200; i++) 'M$i'];
      await shelf.attach('books', many);
      expect((await stored()).length, 1200);
      expect(await shelf.detach('books', many.take(1100).toList()), 1100);
      expect((await stored()).length, 100);
      expect(await shelf.detach('books'), 100);
    });
  });

  group('3.1.0 e2e: drivers after a schema change', () {
    const String table = 'e2e_ddl';

    tearDown(() async {
      await Schema().dropIfExists(table);
    });

    Future<List<int>> countsOnManyConnections(Object value) {
      return Future.wait(<Future<int>>[
        for (int i = 0; i < 20; i++)
          QueryBuilder.table(table).where('v', value).count(),
      ]);
    }

    test('drop and make again with a new type, under load', () async {
      await Schema().dropIfExists(table);
      await Schema().create(table, (Table t) {
        t.id();
        t.integer('v');
      });
      await QueryBuilder.table(table).insert(<String, dynamic>{'v': 7});
      // the same SQL is now prepared on many connections of the pool
      expect(await countsOnManyConnections(7), List<int>.filled(20, 1));

      await Schema().drop(table);
      await Schema().create(table, (Table t) {
        t.id();
        t.string('v', 10);
      });
      await Future.wait(<Future<void>>[
        for (int i = 0; i < 10; i++)
          QueryBuilder.table(table).insert(<String, dynamic>{'v': '007'}),
      ]);
      expect(await countsOnManyConnections('007'), List<int>.filled(20, 10));
      List<Map<String, dynamic>> rows = await QueryBuilder.table(table).get();
      expect(rows.map((Map<String, dynamic> r) => r['v']).toSet(), <String>{
        '007',
      });
    });

    test('ALTER and RENAME in the middle of traffic', () async {
      // its own table, so it does not need the test before it
      await Schema().dropIfExists(table);
      await Schema().create(table, (Table t) {
        t.id();
        t.string('v', 10);
      });
      await QueryBuilder.table(table).insert(<String, dynamic>{'v': '007'});

      Future<List<Map<String, dynamic>>> read() {
        return QueryBuilder.table(table).where('v', '007').limit(1).get();
      }

      // reads and an ALTER run at the same time: none may fail
      List<Object> results = await Future.wait(<Future<Object>>[
        for (int i = 0; i < 10; i++) read(),
        Schema()
            .table(table, (Table t) {
              t.string('extra', 20).nullable();
            })
            .then((_) => 'altered'),
        for (int i = 0; i < 10; i++) read(),
      ]);
      // the ALTER worked, and every read found the row
      expect(results[10], 'altered');
      for (Object rows in <Object>[...results.take(10), ...results.skip(11)]) {
        expect((rows as List<Map<String, dynamic>>).single['v'], '007');
      }

      // after it, every connection sees the new column
      for (List<Map<String, dynamic>> rows in await Future.wait(
        <Future<List<Map<String, dynamic>>>>[
          for (int i = 0; i < 20; i++) read(),
        ],
      )) {
        expect(rows.single.containsKey('extra'), true);
      }

      await Schema().table(table, (Table t) {
        t.renameColumn('extra', 'note');
      });
      for (List<Map<String, dynamic>> rows in await Future.wait(
        <Future<List<Map<String, dynamic>>>>[
          for (int i = 0; i < 20; i++) read(),
        ],
      )) {
        expect(rows.single.containsKey('extra'), false);
        expect(rows.single.containsKey('note'), true);
      }
    });
  });

  group('3.1.0 e2e: 3.0.2 behavior that must still work', () {
    setUpAll(_Tables.create);
    tearDownAll(_Tables.drop);

    test('CRUD and timestamps on a model', () async {
      E2eBook book = await E2eBook().create(<String, dynamic>{
        'sku': 'C1',
        'title': 'first',
      });
      expect(book.id, isNotNull);
      expect(book.createdAt, isNotNull);
      expect(book.updatedAt, isNotNull);

      await QueryBuilder.table('e2e_books')
          .where('id', book.id)
          .update(<String, dynamic>{'updated_at': DateTime.utc(2020)});
      E2eBook loaded = (await E2eBook().find(book.id))!;
      loaded.title = 'second';
      await loaded.save();
      E2eBook fresh = (await E2eBook().find(book.id))!;
      expect(fresh.title, 'second');
      expect(fresh.updatedAt!.year, greaterThan(2020));
      expect(fresh.createdAt, isNotNull);

      expect(
        await E2eBook().where('sku', 'C1').update(<String, dynamic>{
          'title': 'third',
        }),
        1,
      );
      expect((await E2eBook().find('sku', 'C1'))?.title, 'third');
      await fresh.delete();
      expect(await E2eBook().find(book.id), isNull);
    });

    test('firstOrCreate, updateOrCreate, upsert, increment', () async {
      E2eBook a = await E2eBook().firstOrCreate(
        <String, dynamic>{'sku': 'F1'},
        <String, dynamic>{'title': 'made'},
      );
      E2eBook b = await E2eBook().firstOrCreate(
        <String, dynamic>{'sku': 'F1'},
        <String, dynamic>{'title': 'not used'},
      );
      expect(b.id, a.id);
      expect(b.title, 'made');

      await E2eBook().updateOrCreate(
        <String, dynamic>{'sku': 'F1'},
        <String, dynamic>{'title': 'changed'},
      );
      expect((await E2eBook().find(a.id))?.title, 'changed');

      await E2eBook().upsert(
        <Map<String, dynamic>>[
          <String, dynamic>{'sku': 'F1', 'title': 'upserted'},
          <String, dynamic>{'sku': 'F2', 'title': 'new'},
        ],
        <String>['sku'],
        <String>['title'],
      );
      expect(
        (await E2eBook()
                .whereIn('sku', <String>['F1', 'F2'])
                .orderBy('sku')
                .get())
            .map((E2eBook x) => x.title),
        <String>['upserted', 'new'],
      );

      await QueryBuilder.table('e2e_values')
          .insert(<String, dynamic>{'tag': 'counter', 'i': 1});
      await QueryBuilder.table('e2e_values')
          .where('tag', 'counter')
          .increment('i', 4);
      await QueryBuilder.table('e2e_values')
          .where('tag', 'counter')
          .decrement('i');
      expect(
        '${(await QueryBuilder.table('e2e_values').where('tag', 'counter').get()).single['i']}',
        '4',
      );
      await E2eBook().whereIn('sku', <String>['F1', 'F2']).delete();
    });

    test('scopes, casts and a bool column', () async {
      expect(await E2eBook().skuStarts('A').count(), 2);
      expect(
        await E2eBook().where('sku', '!=', 'A1').skuStarts('A').count(),
        1,
      );

      E2eMember m = await E2eMember().forceCreate(<String, dynamic>{
        'name': 'cast',
        'is_admin': true,
      });
      E2eMember loaded = (await E2eMember().find(m.id))!;
      expect(loaded.isAdmin, true);
      expect(loaded.toJson()['is_admin'], true);
      expect(loaded.createdAt, isA<DateTime>());

      E2eBook book = (await E2eBook().find('sku', 'A1'))!;
      expect(book.meta, <String, dynamic>{'shelf': 1});
    });

    test('eager load, withCount and whereHas', () async {
      User user = await User().forceCreate(<String, dynamic>{
        'name': 'E2E310',
        'email': 'e2e310@mail.com',
        'password': 'x',
      });
      List<int> posts = <int>[];
      addTearDown(() async {
        await Post().withTrash().where('user_id', user.id).forceDelete();
        await User().where('id', user.id).delete();
      });
      for (int i = 0; i < 2; i++) {
        Post post = await Post().forceCreate(<String, dynamic>{
          'user_id': user.id,
          'title': 'e2e310 $i',
          'body': 'b',
          'status': 'draft',
        });
        posts.add(post.id as int);
      }
      User? loaded = await User()
          .preload('posts')
          .withCount('posts')
          .find(user.id);
      expect(loaded?.posts.length, 2);
      expect(loaded?.aggregate('posts_count'), 2);
      expect(await User().whereHas('posts').where('id', user.id).count(), 1);

      Post? post = await Post().preload('author').find(posts.first);
      expect(post?.author?.name, 'E2E310');

      // the soft deleted post is not counted
      await Post().where('id', posts.last).delete();
      loaded = await User().withCount('posts').find(user.id);
      expect(loaded?.aggregate('posts_count'), 1);
    });

    // 'a failed nested transaction does not stop the outer one' checks
    // the other way: an inner rollback keeps the outer work.
    test(
      'an outer rollback also undoes a nested transaction that worked',
      () async {
        Future<void> add(String s) async {
          await QueryBuilder.table('e2e_values')
              .insert(<String, dynamic>{'tag': s});
        }

        await expectLater(
          QueryBuilder.transaction(() async {
            await add('rb outer');
            await QueryBuilder.transaction(() async {
              await add('rb inner');
            });
            throw StateError('undo');
          }),
          throwsStateError,
        );
        expect(
          await QueryBuilder.table('e2e_values')
              .where('tag', 'like', 'rb %')
              .count(),
          0,
        );
      },
    );

    test('paginate gives total, last page and the rows', () async {
      Pagination<E2eBook> page = await E2eBook()
          .whereIn('sku', <String>['A1', 'A2', 'B1'])
          .orderBy('sku')
          .paginate(currentPage: 2, perPage: 2);
      expect(page.total, 3);
      expect(page.lastPage, 2);
      expect(page.currentPage, 2);
      expect(page.data.map((E2eBook b) => b.sku), <String>['B1']);
      expect(
        page.toJson().keys.toSet(),
        containsAll(<String>[
          'total',
          'per_page',
          'last_page',
          'current_page',
          'data',
        ]),
      );
    });

    test(
      'soft delete hides a row, withTrash and restore bring it back',
      () async {
        _removeBadgesAfter(<String>['E2E310 soft']);
        Badge badge = await Badge().create(<String, dynamic>{
          'name': 'E2E310 soft',
          'score': 2,
        });
        await badge.delete();
        expect(await Badge().find(badge.id), isNull);
        expect(await Badge().withTrash().where('id', badge.id).count(), 1);
        expect(await badge.restore(), true);
        expect((await Badge().find(badge.id))?.name, 'E2E310 soft');
      },
    );
  });
}

/// The two test migrations. Their names sort after every real one.
final MigrationEntry _migA = MigrationEntry(
  '2099_01_01_000001_e2e310_mig_a',
  _CreateTable('e2e_mig_a'),
);
final MigrationEntry _migB = MigrationEntry(
  '2099_01_01_000002_e2e310_mig_b',
  _CreateTable('e2e_mig_b'),
);

/// A migrator for [list] only, on the app connection. The empty folder
/// means no `.sql` file is read.
Migrator _migrator(List<MigrationEntry> list) {
  Directory dir = Directory.systemTemp.createTempSync('e2e310-mig');
  addTearDown(() async {
    await dir.delete(recursive: true);
  });
  return Migrator(
    migrations: list,
    connection: SqlQueryBuilder().getDBDriver(),
    directory: dir,
  );
}

/// makes one table on up, drops it on down
class _CreateTable extends Migration {
  _CreateTable(this.table);

  final String table;

  @override
  Future<void> up(Schema schema) async {
    await schema.create(table, (Table t) {
      t.id();
      t.string('name', 20).nullable();
    });
  }

  @override
  Future<void> down(Schema schema) async {
    await schema.dropIfExists(table);
  }
}

/// The tables of the e2e310 models. Each group makes them fresh and drops
/// them after.
class _Tables {
  static const List<String> names = <String>[
    'e2e_shelf_book',
    'e2e_shelves',
    'e2e_books',
    'e2e_members',
    'e2e_values',
    'oauth2_client',
  ];

  static void members(Table t) {
    t.id();
    t.string('name', 100).unique();
    t.boolean('is_admin').withDefault(false);
    t.timestamps();
  }

  static Future<void> create() async {
    await drop();
    Schema schema = Schema();
    await schema.create('oauth2_client', (Table t) {
      t.id();
      t.string('name', 50).nullable();
      t.timestamps();
    });
    await schema.create('e2e_members', members);
    await schema.create('e2e_shelves', (Table t) {
      t.id();
      t.string('name', 50).nullable();
      t.timestamps();
    });
    await schema.create('e2e_books', (Table t) {
      t.id();
      t.string('sku', 20).unique();
      t.text('title').nullable();
      t.json('meta').nullable();
      t.timestamps();
    });
    // SQLite: NOCASE, so the case rules are like MySQL
    if (databaseConfig.getConnectionConfig().driver == Driver.sqlite) {
      await QueryBuilder.query(
        'CREATE TABLE e2e_shelf_book (id INTEGER PRIMARY KEY AUTOINCREMENT, '
        'shelf_id INTEGER NOT NULL, '
        'book_sku VARCHAR(20) COLLATE NOCASE NOT NULL)',
      );
    } else {
      await schema.create('e2e_shelf_book', (Table t) {
        t.id();
        t.bigInteger('shelf_id');
        t.string('book_sku', 20);
      });
    }
    await schema.create('e2e_values', (Table t) {
      t.id();
      t.string('tag', 50).nullable();
      t.string('s').nullable();
      t.longText('txt').nullable();
      t.bigInteger('big').nullable();
      t.integer('i').nullable();
      t.double('d').nullable();
      t.boolean('flag').nullable();
    });
    for (String sku in <String>['A1', 'A2', 'B1']) {
      await E2eBook().create(<String, dynamic>{
        'sku': sku,
        'title': 'book $sku',
        'meta': <String, dynamic>{'shelf': 1},
      });
    }
  }

  static Future<void> drop() async {
    for (String name in names) {
      await Schema().dropIfExists(name);
    }
  }
}

/// force deletes the badges with these names after the test, also when
/// it fails. `badges` is an app table, shared with the other files.
void _removeBadgesAfter(List<String> names) {
  addTearDown(() async {
    await Badge().withTrash().whereIn('name', names).forceDelete();
  });
}

/// The error of the database driver for a write the database refuses, eg.
/// a unique or a foreign key violation. dox_orm does not export
/// SqliteException, so it is checked by its name.
final Matcher driverError = predicate<Object>(
  (Object e) =>
      e is PgServerException ||
      e is MysqlException ||
      e.runtimeType.toString() == 'SqliteException',
  'a PgServerException, MysqlException or SqliteException',
);
