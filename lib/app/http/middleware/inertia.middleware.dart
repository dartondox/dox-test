import 'package:dox_auth/dox_auth.dart';
import 'package:dox_core/dox_core.dart';
import 'package:dox_inertia/dox_inertia.dart';
import 'package:dox_test/app/http/serializers/user.serializer.dart';
import 'package:dox_test/app/models/user/user.model.dart';
import 'package:dox_test/config/env.dart';

/// Props for every Inertia page.
class HandleInertiaRequests extends InertiaMiddleware {
  /// `auth.user` is the user of the session login (`web` guard), or null.
  @override
  Future<Map<String, dynamic>> share(DoxRequest req) async {
    Auth auth = Auth(guard: 'web');
    await auth.verifyToken(req);
    User? user = auth.user<User>();
    return <String, dynamic>{
      'appName': env.appName,
      'auth': <String, dynamic>{
        'user': user == null ? null : UserSerializer(user).toJson(),
      },
    };
  }
}
