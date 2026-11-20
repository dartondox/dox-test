import 'package:dox_mcp/dox_mcp.dart';
import 'package:dox_test/app/mcp/mcp_oauth_parts.dart';
import 'package:dox_test/app/mcp/mcp_tools.dart';
import 'package:dox_test/config/env.dart';

/// The MCP server at /mcp (lib/routes/mcp.dart). Browsers may only call
/// it from the app's own origin.
final McpServer mcp = McpServer(
  name: 'dox-test',
  version: '1.0.0',
  allowedOrigins: <String>[env.appUrl],
  tools: <McpTool>[EchoTool(), DeleteNoteTool(), FailTool()],
);

/// The client metadata documents of the OAuth checks. A fake: the tests
/// never load a real URL.
final FakeClientFetcher mcpClientFetcher = FakeClientFetcher();

final MemoryMcpTokens mcpTokens = MemoryMcpTokens();

/// OAuth sign-in for MCP clients: discovery, register and token routes.
final McpOAuth mcpOAuth = McpOAuth(
  issuer: env.appUrl,
  tokens: mcpTokens,
  clientFetcher: mcpClientFetcher,
);
