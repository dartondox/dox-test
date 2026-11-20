import 'package:dox_auth/dox_auth.dart';
import 'package:dox_core/dox_core.dart';
import 'package:dox_grpc/dox_grpc.dart';
import 'package:dox_test/app/grpc/echo.service.dart';

/// The gRPC services. No prefix: a gRPC client calls
/// `POST /<package.Service>/<Method>`. The health service comes first,
/// outside any middleware, so the fallback for unknown services
/// (UNIMPLEMENTED) needs no token.
class GrpcRouter extends Router {
  /// the health service of the app, so a test can set a status
  static final HealthService health = HealthService();

  @override
  void register() {
    Grpc.register(health);
    Grpc.register(EchoService());
    Grpc.register(
      IdleEchoService(),
      options: const GrpcOptions(idleTimeout: Duration(milliseconds: 400)),
    );
    Grpc.register(
      NoIdleEchoService(),
      options: const GrpcOptions(idleTimeout: null),
    );
    Route.middleware(<dynamic>[AuthMiddleware()], registerProtected);
  }

  void registerProtected() {
    Grpc.register(ProtectedEchoService());
  }
}
