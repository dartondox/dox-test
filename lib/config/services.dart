import 'package:dox_core/dox_core.dart';
import 'package:dox_test/providers/auth_service_provider.dart';
import 'package:dox_test/providers/container_service_provider.dart';
import 'package:dox_test/providers/orm_service_provider.dart';
import 'package:dox_test/providers/websocket_service_provider.dart';

/// Services that dox runs on start (and again on each isolate).
/// The container must run last, because routes need its classes.
List<DoxService> services = <DoxService>[
  OrmServiceProvider(),
  AuthServiceProvider(),
  WebsocketServiceProvider(),
  ContainerServiceProvider(),
];
