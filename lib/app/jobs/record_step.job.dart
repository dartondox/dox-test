import 'package:dox_queue/dox_queue.dart';
import 'package:dox_test/app/models/tag/tag.model.dart';

/// Saves a tag named [step], so a test can see which jobs ran and in
/// which order. With [fail] it throws, and it has one try only.
/// Used by the batch and chain checks (test/e2e_32_packages.dart).
/// As the catch job of a chain or a batch, the tag name ends with
/// `:caught`.
@Job()
class RecordStep extends DoxJob with Batchable, CatchesError {
  RecordStep({required this.step, this.fail = false});

  final String step;
  final bool fail;

  @override
  int? get tries => 1;

  @override
  Future<void> handle() async {
    if (fail) {
      throw StateError('step $step failed');
    }
    Tag tag = Tag();
    tag.name = caughtError == null ? step : '$step:caught';
    await tag.save();
  }
}
