import 'package:dox_core/dox_core.dart';

/// Typed `dox_validation` schemas for the tag routes.
// TODO(dto): @Dto classes will replace these schemas when DTOs land on develop.
class TagSchemas {
  /// Body of POST /api/tags. `fail: true` throws inside the transaction.
  static final ObjectSchema create = v.object(<String, Schema<Object?>>{
    'names': v
        .list(v.string().trim().toLowerCase().min(2).max(100))
        .min(1)
        .max(10),
    'fail': v.coerce.bool().defaultTo(false),
  });

  /// Query of GET /api/tags. Query values are text, so `v.coerce`.
  static final ObjectSchema list = v.object(<String, Schema<Object?>>{
    'limit': v.coerce.int().min(1).max(100).defaultTo(10),
    'except': v.string().optional(),
  });
}
