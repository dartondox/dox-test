import 'package:dox_test/bootstrap.dart';

import '../db/migration/migrations.dart';

void main() async {
  await Bootstrap(migrations).start();
}
