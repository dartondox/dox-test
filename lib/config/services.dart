import 'package:dox_core/dox_core.dart';
import 'package:dox_test/providers/auth_service_provider.dart';
import 'package:dox_test/providers/orm_service_provider.dart';

/// Services that dox runs on start (and again on each isolate).
/// The ORM first. Dox also finds every DoxService by itself
/// (lib/container.g.dart), so this list only sets the order.
List<DoxService> services = <DoxService>[
  OrmServiceProvider(),
  AuthServiceProvider(),
];
