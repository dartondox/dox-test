import 'package:dox_test/bootstrap.dart';

/// Run the database migrations only.
void main() async {
  await Bootstrap().migrate();
}
