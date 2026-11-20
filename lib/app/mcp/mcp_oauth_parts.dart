import 'dart:convert';

import 'package:dox_mcp/dox_mcp.dart';

/// Gives client metadata documents from a map, never from the network.
/// test/e2e_33_mcp.dart puts documents in [docs] and reads [calls].
class FakeClientFetcher extends McpOAuthClientFetcher {
  final Map<String, McpOAuthFetchedDocument> docs =
      <String, McpOAuthFetchedDocument>{};

  /// every URL that was loaded, in order
  final List<String> calls = <String>[];

  @override
  Future<McpOAuthFetchedDocument> fetch(Uri url) async {
    calls.add('$url');
    McpOAuthFetchedDocument? doc = docs['$url'];
    if (doc == null) throw const McpOAuthFetchException('no such document');
    return doc;
  }

  /// Serve [body] as JSON at [url].
  void serve(String url, Map<String, dynamic> body) {
    docs[url] = McpOAuthFetchedDocument(
      statusCode: 200,
      body: jsonEncode(body),
      contentType: 'application/json',
    );
  }
}

/// Keeps the grants in memory. A token is `mcp-<n>`.
// ponytail: in memory, one isolate. A real app keeps a hash in a table.
class MemoryMcpTokens extends McpOAuthTokens {
  final Map<String, String> subjects = <String, String>{};

  @override
  Future<String> issue(McpOAuthGrant grant) async {
    String token = 'mcp-${subjects.length + 1}';
    subjects[token] = grant.subject;
    return token;
  }

  @override
  Future<Object?> verify(String token) async => subjects[token];
}
