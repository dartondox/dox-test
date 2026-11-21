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

  /// Writes [text] to [path] in the temp app.
  void write(String path, String text) {
    File('$app/$path')
      ..createSync(recursive: true)
      ..writeAsStringSync(text);
  }

  /// `dart analyze --fatal-infos <path>` in the temp app finds nothing.
  Future<void> analyzeClean(String path) async {
    ProcessResult r = await Process.run('dart', <String>[
      'analyze',
      '--fatal-infos',
      path,
    ], workingDirectory: app);
    expect(r.exitCode, 0, reason: '${r.stdout}${r.stderr}');
  }

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
        expect(option.stdout, contains('Unknown option --x'));
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
            'lib/app/serializers/gadget.serializer.dart': 'Gadget',
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

    group('3.2.y registries skip abstract classes (dox-cli#40)', () {
      setUpAll(() => resolve(app));

      test('seeders.dart lists only the seeders it can build', () async {
        write(
          'db/seeders/base.seeder.dart',
          "import 'package:dox_migration/dox_migration.dart';\n\n"
              'abstract class BaseSeeder extends Seeder {\n'
              "  String get who => 'base';\n"
              '}\n',
        );
        write(
          'db/seeders/e32y_user.seeder.dart',
          "import 'base.seeder.dart';\n\n"
              'class E32yUserSeeder extends BaseSeeder {\n'
              '  @override\n'
              '  Future<void> run() async {}\n'
              '}\n',
        );
        ProcessResult r = await dox(<String>['make:seeder', 'E32yOtherSeeder']);
        expect(r.exitCode, 0, reason: '${r.stdout}${r.stderr}');
        String list = read('db/seeders/seeders.dart');
        expect(list, contains('E32yUserSeeder()'));
        expect(list, contains('E32yOtherSeeder()'));
        expect(list, isNot(contains('BaseSeeder()')));
        expect(list, isNot(contains('base.seeder.dart')));
        await analyzeClean('db/seeders');
      });

      test('migrations.dart lists only the migrations it can build', () async {
        write(
          'db/migration/base_migration.dart',
          "import 'package:dox_migration/dox_migration.dart';\n\n"
              'abstract class E32yBaseMigration extends Migration {\n'
              "  String get table => 'e32y_child';\n\n"
              '  @override\n'
              '  Future<void> down(Schema schema) async {\n'
              '    await schema.dropIfExists(table);\n'
              '  }\n'
              '}\n',
        );
        write(
          'db/migration/2099_01_01_000001_e32y_child.dart',
          '// ignore_for_file: file_names\n'
              "import 'package:dox_migration/dox_migration.dart';\n\n"
              "import 'base_migration.dart';\n\n"
              'abstract class E32yAbstractOne extends E32yBaseMigration {}\n\n'
              'class E32yChild extends E32yAbstractOne {\n'
              '  @override\n'
              '  Future<void> up(Schema schema) async {\n'
              '    await schema.create(table, (Table t) => t.id());\n'
              '  }\n'
              '}\n',
        );
        ProcessResult r = await dox(<String>['make:migration', 'e32y_other']);
        expect(r.exitCode, 0, reason: '${r.stdout}${r.stderr}');
        String list = read('db/migration/migrations.dart');
        expect(list, contains('E32yChild()'));
        expect(list, isNot(contains('E32yAbstractOne()')));
        expect(list, isNot(contains('E32yBaseMigration()')));
        expect(list, isNot(contains("'base_migration.dart'")));
        await analyzeClean('db/migration');
      });
    });

    group('3.2.y dox inertia:install --ssr and inertia:start-ssr', () {
      /// a copy of the temp app in [name], with [packageJson] and [files]
      Future<String> copy(
        String name,
        String? packageJson, [
        Map<String, String> files = const <String, String>{},
      ]) async {
        await resolve(app);
        String dir = '${temp!.path}/$name';
        await _run('cp', <String>['-R', app, dir]);
        if (packageJson != null) {
          File('$dir/package.json').writeAsStringSync(packageJson);
        }
        files.forEach((String path, String text) {
          File('$dir/$path')
            ..createSync(recursive: true)
            ..writeAsStringSync(text);
        });
        return dir;
      }

      Future<ProcessResult> doxIn(String dir, List<String> args) {
        return Process.run('dart', <String>[
          dill,
          ...args,
        ], workingDirectory: dir);
      }

      String react =
          '{\n  "name": "e32y",\n  "scripts": {\n'
          '    "build": "vite build"\n  },\n  "dependencies": {\n'
          '    "@inertiajs/react": "^3.1.0"\n  }\n}\n';

      test(
        'a React app gets ssr.jsx and build:ssr, a second run changes nothing',
        () async {
          String dir = await copy('react', react);
          ProcessResult r = await doxIn(dir, <String>[
            'inertia:install',
            '--ssr',
          ]);
          expect(r.exitCode, 0, reason: '${r.stdout}${r.stderr}');
          expect(File('$dir/resources/js/ssr.jsx').existsSync(), true);
          String pkg = File('$dir/package.json').readAsStringSync();
          expect(pkg, contains('"build:ssr"'));
          expect(pkg, contains('resources/js/ssr.jsx'));
          Map<String, String> before = snapshot(dir);
          ProcessResult again = await doxIn(dir, <String>[
            'inertia:install',
            '--ssr',
          ]);
          expect(again.exitCode, 0, reason: '${again.stdout}${again.stderr}');
          expect(snapshot(dir), before);
        },
        timeout: Timeout(Duration(minutes: 5)),
      );

      test('an app with app.tsx gets ssr.tsx', () async {
        String dir = await copy('tsx', react, <String, String>{
          'resources/js/app.tsx': '// the app entry\n',
        });
        ProcessResult r = await doxIn(dir, <String>[
          'inertia:install',
          '--ssr',
        ]);
        expect(r.exitCode, 0, reason: '${r.stdout}${r.stderr}');
        expect(File('$dir/resources/js/ssr.tsx').existsSync(), true);
        expect(File('$dir/resources/js/ssr.jsx').existsSync(), false);
        String pkg = File('$dir/package.json').readAsStringSync();
        expect(pkg, contains('resources/js/ssr.tsx'));
      }, timeout: Timeout(Duration(minutes: 5)));

      test('a Vue app gets no SSR file, exit code 0', () async {
        String dir = await copy(
          'vue',
          '{\n  "name": "e32y",\n  "dependencies": {\n'
              '    "@inertiajs/vue3": "^2.0.0"\n  }\n}\n',
        );
        ProcessResult r = await doxIn(dir, <String>[
          'inertia:install',
          '--ssr',
        ]);
        expect(r.exitCode, 0, reason: '${r.stdout}${r.stderr}');
        expect(r.stdout, contains('React only'));
        expect(File('$dir/resources/js/ssr.jsx').existsSync(), false);
        expect(File('$dir/resources/js/ssr.tsx').existsSync(), false);
        String pkg = File('$dir/package.json').readAsStringSync();
        expect(pkg, isNot(contains('build:ssr')));
      }, timeout: Timeout(Duration(minutes: 5)));

      test('inertia:start-ssr with no build: exit code 1', () async {
        String dir = await copy('nossr', react);
        ProcessResult r = await doxIn(dir, <String>['inertia:start-ssr']);
        expect(r.exitCode, 1, reason: '${r.stdout}${r.stderr}');
        expect(r.stdout, contains('bootstrap/ssr/ssr.js'));
      }, timeout: Timeout(Duration(minutes: 5)));
    });
  }, skip: skip ? why : false);
}

/// Set up [dir] so `dart analyze` and package commands work: the
/// overrides of this app with full paths, its lock file, and
/// `dart pub get --offline` (this app's `dart pub get` filled the cache).
/// Runs once per folder.
Future<void> resolve(String dir) {
  return _resolved[dir] ??= _resolve(dir);
}

final Map<String, Future<void>> _resolved = <String, Future<void>>{};

Future<void> _resolve(String dir) async {
  String parent = Directory.current.parent.path;
  String overrides = File('pubspec_overrides.yaml')
      .readAsStringSync()
      .replaceAll('path: ../', 'path: $parent/');
  File('$dir/pubspec_overrides.yaml').writeAsStringSync(overrides);
  File('pubspec.lock').copySync('$dir/pubspec.lock');
  ProcessResult r = await Process.run('dart', <String>[
    'pub',
    'get',
    '--offline',
  ], workingDirectory: dir);
  if (r.exitCode != 0) fail('dart pub get failed:\n${r.stdout}${r.stderr}');
}

/// the text of every file in [dir], but not .dart_tool
Map<String, String> snapshot(String dir) {
  Map<String, String> files = <String, String>{};
  for (FileSystemEntity e in Directory(dir).listSync(recursive: true)) {
    String path = e.path.substring(dir.length + 1);
    if (e is! File || path.startsWith('.dart_tool/')) continue;
    files[path] = e.readAsStringSync();
  }
  return files;
}

/// Runs [cmd] and fails with its output when it fails.
Future<void> _run(String cmd, List<String> args) async {
  ProcessResult r = await Process.run(cmd, args);
  if (r.exitCode != 0) {
    fail('$cmd ${args.join(' ')} failed:\n${r.stdout}${r.stderr}');
  }
}
