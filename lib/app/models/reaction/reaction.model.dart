import 'package:dox_orm/dox_orm.dart';

part 'reaction.model.g.dart';

/// One row in the `reactions` table. It points to a badge or a post
/// with `reactable_type` and `reactable_id`.
@DoxModel(table: 'reactions')
class Reaction extends ReactionGenerator {
  @override
  List<String> get fillable => <String>[
    'emoji',
    'reactable_id',
    'reactable_type',
  ];

  @Column()
  String? emoji;

  @Column()
  int? reactableId;

  @Column()
  String? reactableType;

  /// The badge or the post. The names are in `Model.morphMap()`.
  @MorphTo()
  Model<dynamic>? reactable;
}
