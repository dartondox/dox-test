import 'package:dox_core/dox_core.dart';
import 'package:dox_orm/dox_orm.dart';
import 'package:dox_test/app/http/dtos/user.dto.dart';
import 'package:dox_test/app/models/profile/profile.model.dart';
import 'package:dox_test/app/models/user/user.model.dart';
import 'package:dox_test/app/services/user.service.dart';

@Inject()
class UserController {
  final UserService service;

  UserController(this.service);

  /// List users
  ///
  /// Search by name or email, one page at a time.
  Future<Pagination<User>> index(ListUsers query) async {
    return await service.list(query);
  }

  /// Get one user
  Future<User> show(int id) async {
    return await service.show(id);
  }

  /// Update a user (needs token, only yourself)
  Future<User> update(DoxRequest req, int id, UpdateUser body) async {
    return await service.update(_userId(req), id, body);
  }

  /// Save the profile (needs token)
  Future<Profile?> saveProfile(DoxRequest req, SaveProfile body) async {
    return await service.saveProfile(_userId(req), body);
  }

  /// Change part of the profile (needs token)
  ///
  /// A missing key keeps the old value. `null` clears it.
  Future<Profile?> patchProfile(DoxRequest req, PatchProfile body) async {
    return await service.patchProfile(_userId(req), body);
  }

  int _userId(DoxRequest req) {
    return req.auth!.user<User>()!.id!;
  }
}
