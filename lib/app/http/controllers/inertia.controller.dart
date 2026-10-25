import 'package:dox_core/dox_core.dart';
import 'package:dox_inertia/dox_inertia.dart';
import 'package:dox_test/app/http/dtos/note.dto.dart';
import 'package:dox_test/app/services/note.service.dart';

/// The Inertia pages (resources/js/Pages).
@Inject()
class InertiaController {
  final NoteService notes;

  InertiaController(this.notes);

  /// GET /inertia
  Future<DoxResponse> home(DoxRequest req) {
    return inertia(req, 'Home', <String, dynamic>{
      'greeting': 'Hello from Dox',
      'time': () => DateTime.now(),

      /// loads right after the first visit
      'stats': Inertia.defer(() => <String, int>{'notes': notes.all().length}),

      /// only when the page asks for it: router.reload({ only: ['tip'] })
      'tip': Inertia.optional(() => 'Props can load later.'),
    });
  }

  /// GET /inertia/notes
  Future<DoxResponse> index(DoxRequest req) {
    return _notesPage(req, <String, dynamic>{});
  }

  /// POST /inertia/notes
  /// Dox has no session, so a bad form renders the page again with errors.
  Future<DoxResponse> store(DoxRequest req) async {
    try {
      CreateNote body = await req.validate<CreateNote>();
      notes.add(body.text);
    } on ValidationException catch (e) {
      return _notesPage(req, e.message as Map<String, dynamic>);
    }
    return Inertia.redirect(req, '/inertia/notes');
  }

  /// DELETE /inertia/notes/{id}
  DoxResponse destroy(DoxRequest req, int id) {
    notes.remove(id);
    return Inertia.redirect(req, '/inertia/notes');
  }

  Future<DoxResponse> _notesPage(DoxRequest req, Map<String, dynamic> errors) {
    return inertia(req, 'Notes', <String, dynamic>{
      'notes': notes.all(),
      'errors': Inertia.always(errors),
    });
  }
}
