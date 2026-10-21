import 'package:dox_core/dox_core.dart';

/// Small helpers to check env, hashing and the IoC container.
class SystemService {
  /// Counts calls. Same number across requests proves one shared instance.
  int _calls = 0;

  int nextCall() {
    _calls++;
    return _calls;
  }

  Map<String, dynamic> env() {
    return <String, dynamic>{
      'app_name': Env.get('APP_NAME'),
      'missing_with_default': Env.get('NOT_SET_KEY', 'fallback'),
    };
  }

  Map<String, dynamic> hash(String password) {
    String hashed = Hash.make(password);
    return <String, dynamic>{
      'hash': hashed,
      'verified': Hash.verify(password, hashed),
      'wrong_verified': Hash.verify('$password-wrong', hashed),
    };
  }
}
