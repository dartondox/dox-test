import 'dart:io';

import 'package:test/test.dart';

/// Checks of the `dox` CLI (the dox-cli repo next to this one): exit codes
/// of bad input and the `make:*` generators. The other CLI checks are in
/// e2e_310_packages.dart. The CLI runs in a temp copy of this app,
/// so the app itself does not change. No server or database is needed.
void main() {
  // CI clones dox-cli next to dox-test and runs `dart pub get` there.
  // DOX_CLI points to another one, like in e2e_310_packages.dart.
  String cli = Platform.environment['DOX_CLI'] ?? '../dox-cli/bin/dox.dart';
  Directory? temp;
  late String app;
  late String dill;

  /// Runs `dox <args>` in the temp app.
  Future<ProcessResult> dox(List<String> args) {
    return Process.run('dart', <String>[dill, ...args], workingDirectory: app);
  }

  /// The text of [path] in the temp app.
  String read(String path) => File('$app/$path').readAsStringSync();

  // a local run without the CLI skips, CI fails
  String why = 'no dox CLI at $cli';
  bool skip =
      !File(cli).existsSync() && !Platform.environment.containsKey('CI');
  group('dox CLI', () {
    setUpAll(() async {
      if (!File(cli).existsSync()) fail(why);
      Directory made = temp = await Directory.systemTemp.createTemp(
        'dox_cli_test',
      );
      // compile once, so each check starts in a moment
      dill = '${made.path}/dox.dill';
      await _run('dart', <String>['compile', 'kernel', cli, '-o', dill]);
      app = '${made.path}/app';
      Directory(app).createSync();
      await _run('cp', <String>['-R', 'pubspec.yaml', 'lib', 'db', 'bin', app]);
    });

    tearDownAll(() {
      temp?.deleteSync(recursive: true);
    });

    group('exit codes', () {
      test('no command: exit code 1', () async {
        ProcessResult r = await dox(<String>[]);
        expect(r.exitCode, 1);
        expect(r.stdout, contains('Could not find a command'));
      });

      test('too few arguments: exit code 1', () async {
        ProcessResult r = await dox(<String>['make:controller']);
        expect(r.exitCode, 1);
        expect(r.stdout, contains('Invalid number of arguments'));
      });

      test('a bad name or a bad option: exit code 1, no file', () async {
        ProcessResult bad = await dox(<String>['make:model', '1bad']);
        expect(bad.exitCode, 1);
        expect(bad.stdout, contains('is not a valid name'));

        ProcessResult option = await dox(<String>['make:model', 'Odd', '--x']);
        expect(option.exitCode, 1);
        expect(option.stdout, contains('Invalid option --x'));
        expect(Directory('$app/lib/app/models/odd').existsSync(), false);
      });
    });

    group('make:*', () {
      /// Runs `dox <args>`, expects exit code 0 and that each of [files]
      /// is there and has its [files] text.
      Future<void> make(List<String> args, Map<String, String> files) async {
        ProcessResult r = await dox(args);
        expect(r.exitCode, 0, reason: '${r.stdout}${r.stderr}');
        files.forEach((String path, String text) {
          expect(read(path), contains(text), reason: path);
        });
      }

      test('make:controller -r', () async {
        await make(
          <String>['make:controller', 'Gadget', '-r'],
          <String, String>{
            'lib/app/http/controllers/gadget.controller.dart':
                'class GadgetController',
          },
        );
      });

      test('make:middleware, make:dto, make:serializer', () async {
        await make(
          <String>['make:middleware', 'Gadget'],
          <String, String>{
            'lib/app/http/middleware/gadget.middleware.dart': 'Gadget',
          },
        );
        await make(
          <String>['make:dto', 'Gadget'],
          <String, String>{'lib/app/dtos/gadget/gadget.dto.dart': 'Gadget'},
        );
        await make(
          <String>['make:serializer', 'Gadget'],
          <String, String>{
            'lib/app/http/serializers/gadget.serializer.dart': 'Gadget',
          },
        );
      });

      test('make:model -m makes the model and its migration', () async {
        await make(
          <String>['make:model', 'Gadget', '-m'],
          <String, String>{
            'lib/app/models/gadget/gadget.model.dart': 'class Gadget',
          },
        );
        List<String> made = Directory('$app/db/migration')
            .listSync()
            .map((FileSystemEntity e) => e.uri.pathSegments.last)
            .where((String name) => name.endsWith('_create_gadgets_table.dart'))
            .toList();
        expect(made, hasLength(1));
        expect(read('db/migration/migrations.dart'), contains(made.single));
      });

      test('make:migration --sql, make:factory, make:seeder', () async {
        ProcessResult sql = await dox(<String>[
          'make:migration',
          'add_gadget_note',
          '--sql',
        ]);
        expect(sql.exitCode, 0, reason: '${sql.stdout}');
        expect(
          Directory('$app/db/migration').listSync().where(
            (FileSystemEntity e) => e.path.endsWith('_add_gadget_note.sql'),
          ),
          hasLength(1),
        );
        await make(
          <String>['make:factory', 'Gadget'],
          <String, String>{'db/factories/gadget.factory.dart': 'Gadget'},
        );
        await make(
          <String>['make:seeder', 'GadgetSeeder'],
          <String, String>{
            'db/seeders/gadget.seeder.dart': 'GadgetSeeder',
            'db/seeders/seeders.dart': 'GadgetSeeder',
            'bin/seed.dart': 'SeederRunner',
          },
        );
      });

      test('make:job', () async {
        await make(
          <String>['make:job', 'SendGadget'],
          <String, String>{
            'lib/app/jobs/send_gadget.job.dart': 'class SendGadget',
          },
        );
      });

      test('a second make: keeps the file that is there', () async {
        String path = 'lib/app/http/middleware/keep.middleware.dart';
        await make(
          <String>['make:middleware', 'Keep'],
          <String, String>{path: 'Keep'},
        );
        File('$app/$path').writeAsStringSync('// mine');
        ProcessResult r = await dox(<String>['make:middleware', 'Keep']);
        expect(r.stdout, contains('already exists'));
        expect(read(path), '// mine');
      });
    });
  }, skip: skip ? why : false);
}

/// Runs [cmd] and fails with its output when it fails.
Future<void> _run(String cmd, List<String> args) async {
  ProcessResult r = await Process.run(cmd, args);
  if (r.exitCode != 0) {
    fail('$cmd ${args.join(' ')} failed:\n${r.stdout}${r.stderr}');
  }
}
