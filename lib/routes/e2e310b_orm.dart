import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/dtos/e2e310b_orm/e2e310b_orm.dto.dart';
import 'package:dox_test/app/models/e2e310b/e2e310b.model.dart';

/// Routes for test/e2e_310b_orm.dart. CoreRouter adds them in the group
/// `/e310b`, so they all start with /core/e310b. Plain functions, so they
/// need no container entry.
class E310bOrmRoutes {
  void register() {
    Route.get('/items/{id}', findItem);
    Route.get('/items-by-name/{name}', firstItem);
    Route.post('/profile', profile);
  }

  /// GET /core/e310b/items/{id}: `findOrFail`, 404 when there is no row.
  Future<Map<String, dynamic>> findItem(DoxRequest req) async {
    E310bItem item = await E310bItem().findOrFail(req.param['id']);
    return <String, dynamic>{'name': item.name};
  }

  /// GET /core/e310b/items-by-name/{name}: `firstOrFail` on a where.
  Future<Map<String, dynamic>> firstItem(DoxRequest req) async {
    E310bItem item = await E310bItem()
        .where('name', req.param['name'])
        .firstOrFail();
    return <String, dynamic>{'id': item.id};
  }

  /// POST /core/e310b/profile: the DTO with full path messages.
  Future<Map<String, dynamic>> profile(DoxRequest req) async {
    E310bProfileForm form = await req.validateSchema(E310bProfileForm.schema);
    return <String, dynamic>{
      'name': form.name,
      'city': form.address.city,
      'tags': form.tags,
    };
  }
}
