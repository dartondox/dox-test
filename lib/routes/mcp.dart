import 'package:dox_auth/dox_auth.dart';
import 'package:dox_core/dox_core.dart';
import 'package:dox_mcp/dox_mcp.dart';
import 'package:dox_test/config/mcp.dart';

/// MCP at /mcp, and the OAuth routes of McpOAuth. No prefix: the
/// discovery paths are fixed. The /mcp-consent routes stand in for the
/// app's own consent page.
class McpRouter extends Router {
  @override
  void register() {
    mcpOAuth.routes();
    Route.match(
      <String>['GET', 'POST', 'DELETE'],
      '/mcp',
      <dynamic>[AuthMiddleware(), handle],
    );
    Route.get('/mcp-consent/verify', verify);
    Route.get('/mcp-consent/check', check);
    Route.get('/mcp-consent/deny', deny);
    Route.post('/mcp-consent/approve', <dynamic>[AuthMiddleware(), approve]);
  }

  /// The session and the question state are tied to the user.
  Future<DoxResponse> handle(DoxRequest req) {
    return mcp.handle(req, auth: req.auth, scope: 'user:${req.auth?.id()}');
  }

  /// GET /mcp-consent/verify: the async check of the consent page.
  Future<dynamic> verify(DoxRequest req) {
    return guard(() async {
      McpOAuthClient client = await mcpOAuth.verifyClient(
        '${req.input('client_id')}',
        '${req.input('redirect_uri')}',
      );
      return <String, dynamic>{'name': client.name, 'host': client.host};
    });
  }

  /// GET /mcp-consent/check: the old sync checkClient.
  Future<dynamic> check(DoxRequest req) {
    return guard(() async {
      McpOAuthClient client = mcpOAuth.checkClient(
        '${req.input('client_id')}',
        '${req.input('redirect_uri')}',
      );
      return <String, dynamic>{'name': client.name, 'host': client.host};
    });
  }

  /// GET /mcp-consent/deny: the old sync deny.
  Future<dynamic> deny(DoxRequest req) {
    return guard(() async {
      return <String, dynamic>{
        'redirect': mcpOAuth.deny(
          clientId: '${req.input('client_id')}',
          redirectUri: '${req.input('redirect_uri')}',
          state: req.input('state')?.toString(),
        ),
      };
    });
  }

  /// POST /mcp-consent/approve: the signed-in user says yes.
  Future<dynamic> approve(DoxRequest req) {
    return guard(() async {
      return <String, dynamic>{
        'redirect': await mcpOAuth.approve(
          subject: '${req.auth?.id()}',
          clientId: '${req.input('client_id')}',
          redirectUri: '${req.input('redirect_uri')}',
          codeChallenge: '${req.input('code_challenge')}',
          state: req.input('state')?.toString(),
        ),
      };
    });
  }

  /// An OAuth error as `400 {"error": ...}`.
  Future<dynamic> guard(Future<Map<String, dynamic>> Function() body) async {
    try {
      return await body();
    } on McpOAuthException catch (e) {
      return response(<String, dynamic>{
        'error': e.error,
        'error_description': e.description,
      }).statusCode(400);
    }
  }
}
