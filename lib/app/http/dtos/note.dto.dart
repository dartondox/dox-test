import 'package:dox_core/dox_core.dart';

part 'note.dto.g.dart';

/// Body of POST /inertia/notes.
@Dto()
class CreateNote {
  @Trim()
  @Length(min: 2, max: 100)
  final String text;

  const CreateNote({required this.text});

  static const DtoSchema<CreateNote> schema = $CreateNoteDto;
}
