import 'package:dox_test/app/models/badge/badge.model.dart';
import 'package:dox_test/app/models/tag/tag.model.dart';
import 'package:test/test.dart';

import 'e2e_test.dart' show Api;

/// 3.2: dirty tracking of models (dox_orm): isDirty, isClean, getDirty,
/// getOriginal, getChanges, wasChanged and wasRecentlyCreated, on the
/// real database. e2e_test.dart calls it.
void orm32Tests(Api api) {
  String stamp = '${DateTime.now().microsecondsSinceEpoch}';

  group('3.2 dox_orm: dirty tracking', () {
    test('a new model is dirty until save, then clean', () async {
      Tag tag = Tag();
      tag.name = 'dirty-new-$stamp';
      expect(tag.isDirty(), true);
      expect(tag.isDirty('name'), true);
      expect(tag.getDirty()['name'], 'dirty-new-$stamp');
      expect(tag.getOriginal(), isEmpty);
      expect(tag.getOriginal('name'), isNull);
      expect(tag.wasRecentlyCreated, false);

      await tag.save();
      expect(tag.wasRecentlyCreated, true);
      expect(tag.isClean(), true, reason: '${tag.getDirty()}');
      expect(tag.getOriginal('name'), 'dirty-new-$stamp');
      // an insert is not a change
      expect(tag.getChanges(), isEmpty);
      expect(tag.wasChanged(), false);
    });

    test('a read model tracks a change before and after save', () async {
      Tag made = Tag();
      made.name = 'dirty-old-$stamp';
      await made.save();

      Tag tag = (await Tag().find(made.id))!;
      expect(tag.wasRecentlyCreated, false);
      expect(tag.isClean(), true, reason: '${tag.getDirty()}');

      tag.name = 'dirty-changed-$stamp';
      expect(tag.isDirty('name'), true);
      expect(tag.isDirty(<String>['created_at', 'name']), true);
      expect(tag.isClean('created_at'), true);
      expect(tag.getDirty(), <String, dynamic>{'name': 'dirty-changed-$stamp'});
      expect(tag.getOriginal('name'), 'dirty-old-$stamp');
      // nothing saved yet
      expect(tag.wasChanged(), false);

      await tag.save();
      expect(tag.isClean(), true, reason: '${tag.getDirty()}');
      expect(tag.wasChanged('name'), true);
      expect(tag.wasChanged('created_at'), false);
      expect(tag.getChanges()['name'], 'dirty-changed-$stamp');
      expect(tag.getChanges().keys, contains('updated_at'));
      expect(tag.getOriginal('name'), 'dirty-changed-$stamp');
      expect((await Tag().find(made.id))!.name, 'dirty-changed-$stamp');

      // a save with no change sends no query and has no changes
      await tag.save();
      expect(tag.getChanges(), isEmpty);
      expect(tag.wasChanged(), false);
    });

    test('firstOrCreate sets wasRecentlyCreated only on insert', () async {
      Map<String, dynamic> where = <String, dynamic>{'name': 'foc-$stamp'};
      Badge first = await Badge().firstOrCreate(where);
      expect(first.wasRecentlyCreated, true);
      Badge again = await Badge().firstOrCreate(where);
      expect(again.wasRecentlyCreated, false);
      expect(again.id, first.id);
    });

    test('a JSON column is dirty only when its content changes', () async {
      Badge badge = await Badge().create(<String, dynamic>{
        'name': 'json-$stamp',
        'meta': <String, dynamic>{'level': 1},
      });
      Badge read = (await Badge().find(badge.id))!;
      read.meta = <String, dynamic>{'level': 1};
      expect(read.isClean('meta'), true, reason: '${read.getDirty()}');
      read.meta = <String, dynamic>{'level': 2};
      expect(read.isDirty('meta'), true);
      expect(read.getOriginal('meta'), <String, dynamic>{'level': 1});
      await read.save();
      expect(read.wasChanged('meta'), true);
    });
  });
}
