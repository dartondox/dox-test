import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/models/user/user.model.dart';

/// Public shape of a user.
class UserSerializer extends Serializer<User> {
  UserSerializer(super.data);

  @override
  Map<String, dynamic> convert(User m) {
    return <String, dynamic>{
      'id': m.id,
      'name': m.name,
      'email': m.email,
    };
  }
}
