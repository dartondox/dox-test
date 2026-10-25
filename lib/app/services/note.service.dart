import 'package:dox_core/dox_core.dart';

/// Notes of the Inertia demo.
// ponytail: kept in memory, per isolate. Use a table if the demo needs
// to keep them.
@Inject()
class NoteService {
  final List<Map<String, dynamic>> _notes = <Map<String, dynamic>>[];
  int _nextId = 1;

  List<Map<String, dynamic>> all() => _notes;

  void add(String text) {
    _notes.add(<String, dynamic>{'id': _nextId++, 'text': text});
  }

  void remove(int id) {
    _notes.removeWhere((Map<String, dynamic> n) => n['id'] == id);
  }
}
