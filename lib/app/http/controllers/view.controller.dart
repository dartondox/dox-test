import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/http/dtos/note/note.dto.dart';
import 'package:dox_test/app/services/note.service.dart';
import 'package:dox_view/dox_view.dart';

/// The dox_view pages (resources/views). Same notes as the Inertia demo.
@Inject()
@ApiIgnore()
class ViewController {
  final NoteService notes;

  ViewController(this.notes);

  /// GET /views
  /// A failed form comes back here with `errors` and `old()`.
  DoxResponse index(DoxRequest req) {
    return view(req, 'notes/index', <String, dynamic>{'notes': notes.all()});
  }

  /// POST /views/notes
  /// A bad form redirects back with the errors in the session.
  Future<DoxResponse> store(DoxRequest req) async {
    CreateNote body = await req.validate<CreateNote>();
    notes.add(body.text);
    req.session.flash('message', 'Note saved');
    return redirect('/views');
  }
}
