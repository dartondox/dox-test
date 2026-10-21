import 'package:dox_core/dox_core.dart';
import 'package:dox_orm/dox_orm.dart';
import 'package:dox_test/app/models/profile/profile.model.dart';
import 'package:dox_test/app/models/user/user.model.dart';
import 'package:dox_test/app/services/user.service.dart';
import 'package:dox_test/constants/app_constants.dart';

class UserController {
  final UserService service;

  UserController(this.service);

  /// GET /api/users?search=&page=&limit=
  Future<Pagination> index(DoxRequest req) async {
    req.validate(<String, String>{
      'page': 'required|integer',
      'limit': 'required|integer'
    });
    return await service.list(
      req.input('search')?.toString() ?? '',
      int.parse(req.input('page')?.toString() ?? '1'),
      int.parse(
          req.input('limit')?.toString() ?? '${AppConstants.defaultPerPage}'),
    );
  }

  /// GET /api/users/{id}
  Future<User> show(DoxRequest req, String id) async {
    return await service.show(id);
  }

  /// PUT /api/me/profile (needs token)
  Future<Profile?> saveProfile(DoxRequest req) async {
    User user = req.auth!.user<User>()!;
    return await service.saveProfile(
      user.id!,
      req.input('bio')?.toString(),
      req.input('website')?.toString(),
    );
  }
}
