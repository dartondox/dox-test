import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/dtos/system/system.dto.dart';
import 'package:dox_test/config/env.dart';

/// Small helpers to check env, hashing and the IoC container.
@Inject()
class SystemService {
  /// Counts calls. Same number across requests proves one shared instance.
  int _calls = 0;

  int nextCall() {
    _calls++;
    return _calls;
  }

  Map<String, dynamic> envInfo() {
    return <String, dynamic>{
      'app_name': env.appName,
      'app_port': env.appPort,
      // Env.get() is still there for keys only known at run time.
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

  /// Gives the typed order back, with the total quantity.
  Map<String, dynamic> order(CreateOrder order) {
    int total = 0;
    List<Map<String, dynamic>> items = <Map<String, dynamic>>[];
    for (OrderItem item in order.items) {
      total += item.quantity;
      items.add(<String, dynamic>{
        'name': item.name,
        'quantity': item.quantity,
      });
    }
    return <String, dynamic>{
      'city': order.address.city,
      'post_code': order.address.postCode,
      'items': items,
      'total_quantity': total,
    };
  }
}
