import 'package:dox_orm/dox_orm.dart';
import 'package:dox_test/app/models/post/post.model.dart';

part 'tag.model.g.dart';

/// One row in the `tags` table.
@DoxModel(table: 'tags')
class Tag extends TagGenerator {
  @Column()
  String? name;

  @ManyToMany(
    Post,
    pivotTable: 'post_tag',
    localKey: 'id',
    relatedKey: 'id',
    pivotForeignKey: 'tag_id',
    pivotRelatedForeignKey: 'post_id',
  )
  List<Post> posts = <Post>[];
}
