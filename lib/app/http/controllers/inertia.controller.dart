import 'package:dox_core/dox_core.dart';
import 'package:dox_inertia/dox_inertia.dart';
import 'package:dox_test/app/http/dtos/note/note.dto.dart';
import 'package:dox_test/app/services/note.service.dart';

/// The Inertia pages (resources/js/Pages).
@Inject()
@ApiIgnore()
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
  /// A failed form comes back here with `errors` from the session.
  Future<DoxResponse> index(DoxRequest req) {
    return inertia(req, 'Notes', <String, dynamic>{'notes': notes.all()});
  }

  /// POST /inertia/notes
  /// A bad form redirects back with the errors in the session.
  Future<DoxResponse> store(DoxRequest req) async {
    CreateNote body = await req.validate<CreateNote>();
    notes.add(body.text);
    Inertia.flash(req, 'message', 'Note saved');
    return redirect('/inertia/notes');
  }

  /// DELETE /inertia/notes/{id}
  /// InertiaMiddleware turns the 302 into 303.
  DoxResponse destroy(DoxRequest req, int id) {
    notes.remove(id);
    return redirect('/inertia/notes');
  }
}
