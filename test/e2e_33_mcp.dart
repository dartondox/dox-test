import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' show sha256;
import 'package:dox_core/dox_core.dart';
import 'package:dox_mcp/dox_mcp.dart';
import 'package:dox_test/app/mcp/mcp_oauth_parts.dart';
import 'package:dox_test/config/env.dart';
import 'package:dox_test/config/mcp.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'e2e_310_core.dart' show registerUser;
import 'e2e_test.dart' show Api;

const String newVersion = '2026-07-28';

/// 3.3 MCP checks: dox_mcp on /mcp (lib/routes/mcp.dart), behind
/// AuthMiddleware, with the user id as the scope. Legacy clients with a
/// session, stateless 2026-07-28 clients, MRTR questions and OAuth with
/// client ID metadata documents (a fake fetcher, lib/config/mcp.dart).
/// e2e_test.dart calls it.
void mcpTests(Api api) {
  McpCalls mcp = McpCalls(api);

  group('3.3 dox_mcp: legacy clients with a session', () {
    setUpAll(mcp.login);

    test('initialize gives 200, a session id and 2025-11-25', () async {
      http.Response res = await mcp.initialize('Ann');
      expect(res.statusCode, 200, reason: res.body);
      expect(res.headers['mcp-session-id'], isNotEmpty);
      Map<String, dynamic> result = mcp.json(res)['result'];
      expect(result['protocolVersion'], '2025-11-25');
      expect(result['serverInfo']['name'], 'dox-test');
    });

    test('tools/list works with the session, 400 without', () async {
      String session = await mcp.session('Ann');
      http.Response ok = await mcp.post(
        'Ann',
        mcp.rpc('tools/list'),
        session: session,
      );
      expect(ok.statusCode, 200, reason: ok.body);
      List<dynamic> tools = mcp.json(ok)['result']['tools'];
      expect(
        <String>[for (dynamic t in tools) t['name']],
        <String>['echo', 'delete_note', 'fail'],
      );
      http.Response none = await mcp.post('Ann', mcp.rpc('tools/list'));
      expect(none.statusCode, 400);
    });

    test('a tool gets the user of the request', () async {
      String session = await mcp.session('Ann');
      http.Response res = await mcp.post(
        'Ann',
        mcp.call('echo', <String, dynamic>{'text': 'hi'}),
        session: session,
      );
      expect(mcp.text(res), 'hi (user ${mcp.ids['Ann']})');
    });

    test("another user's session id gives 404", () async {
      String session = await mcp.session('Ann');
      http.Response res = await mcp.post(
        'Bob',
        mcp.rpc('tools/list'),
        session: session,
      );
      expect(res.statusCode, 404);
    });

    test('without a token: 401 from AuthMiddleware', () async {
      http.Response res = await http.post(
        api.uri('/mcp'),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(mcp.rpc('tools/list')),
      );
      expect(res.statusCode, 401);
    });

    test('a batch of 51 gives 400 -32600, 50 runs', () async {
      String session = await mcp.session('Ann');
      List<Map<String, dynamic>> big = <Map<String, dynamic>>[
        for (int i = 0; i < 51; i++) mcp.rpc('ping', id: i),
      ];
      http.Response tooBig = await mcp.post('Ann', big, session: session);
      expect(tooBig.statusCode, 400);
      expect(mcp.json(tooBig)['error']['code'], -32600);
      http.Response ok = await mcp.post(
        'Ann',
        big.sublist(0, 50),
        session: session,
      );
      expect(ok.statusCode, 200, reason: ok.body);
      expect(jsonDecode(ok.body), hasLength(50));
    });

    test('GET gives 405, DELETE ends the session with 200', () async {
      http.Response get = await http.get(
        api.uri('/mcp'),
        headers: mcp.auth('Ann'),
      );
      expect(get.statusCode, 405);
      expect(get.headers['allow'], 'POST, DELETE');
      String session = await mcp.session('Ann');
      http.Response del = await http.delete(
        api.uri('/mcp'),
        headers: <String, String>{
          ...mcp.auth('Ann'),
          'mcp-session-id': session,
        },
      );
      expect(del.statusCode, 200, reason: del.body);
    });

    test('a question tool tells an old client to update', () async {
      String session = await mcp.session('Ann');
      http.Response res = await mcp.post(
        'Ann',
        mcp.call('delete_note', <String, dynamic>{'id': 1}),
        session: session,
      );
      Map<String, dynamic> result = mcp.json(res)['result'];
      expect(result['isError'], true);
      expect(result['content'][0]['text'], contains('2026-07-28'));
    });
  });

  group('3.3 dox_mcp: stateless clients (2026-07-28)', () {
    setUpAll(mcp.login);

    test('server/discover lists the versions, no session', () async {
      http.Response res = await mcp.stateless('Ann', 'server/discover');
      expect(res.statusCode, 200, reason: res.body);
      expect(res.headers['mcp-session-id'], isNull);
      Map<String, dynamic> result = mcp.json(res)['result'];
      expect(result['resultType'], 'complete');
      expect(result['supportedVersions'], contains(newVersion));
      expect(result['ttlMs'], 0);
      expect(
        result['_meta']['io.modelcontextprotocol/serverInfo']['name'],
        'dox-test',
      );
    });

    test('tools/call works without initialize', () async {
      http.Response res = await mcp.stateless(
        'Ann',
        'tools/call',
        params: <String, dynamic>{
          'name': 'echo',
          'arguments': <String, dynamic>{'text': 'new'},
        },
      );
      expect(mcp.text(res), 'new (user ${mcp.ids['Ann']})');
    });

    test('a notification gives 202 and no body', () async {
      Map<String, dynamic> body = mcp.statelessBody('notifications/initialized')
        ..remove('id');
      http.Response res = await mcp.post(
        'Ann',
        body,
        headers: mcp.statelessHeaders('notifications/initialized'),
      );
      expect(res.statusCode, 202);
      expect(res.body, isEmpty);
    });

    test('a missing Mcp-Method header gives 400 -32020', () async {
      http.Response res = await mcp.stateless(
        'Ann',
        'tools/list',
        dropHeader: 'Mcp-Method',
      );
      expect(res.statusCode, 400);
      expect(mcp.json(res)['error']['code'], -32020);
    });

    test('an unknown version gives -32022 with data.supported', () async {
      http.Response res = await mcp.stateless(
        'Ann',
        'tools/list',
        version: '2099-01-01',
      );
      expect(res.statusCode, 400);
      Map<String, dynamic> error = mcp.json(res)['error'];
      expect(error['code'], -32022);
      expect(error['data']['supported'], contains(newVersion));
    });

    test('a batch gives 400', () async {
      Map<String, dynamic> one = mcp.statelessBody('tools/list');
      http.Response res = await mcp.post('Ann', <Object>[
        one,
        one,
      ], headers: mcp.statelessHeaders('tools/list'));
      expect(res.statusCode, 400);
      expect(mcp.json(res)['error']['code'], -32600);
    });

    test('Origin: another site 403, own site and none 200', () async {
      http.Response evil = await mcp.stateless(
        'Ann',
        'tools/list',
        extra: <String, String>{'Origin': 'https://evil.example'},
      );
      expect(evil.statusCode, 403);
      http.Response own = await mcp.stateless(
        'Ann',
        'tools/list',
        extra: <String, String>{'Origin': env.appUrl},
      );
      expect(own.statusCode, 200, reason: own.body);
      http.Response none = await mcp.stateless('Ann', 'tools/list');
      expect(none.statusCode, 200);
    });

    test(
      'a throwing tool: its text in development, "Tool failed" in '
      'production',
      () async {
        Map<String, dynamic> params = <String, dynamic>{'name': 'fail'};
        http.Response dev = await mcp.stateless(
          'Ann',
          'tools/call',
          params: params,
        );
        expect(mcp.json(dev)['result']['isError'], true);
        expect(mcp.text(dev), contains('e2e secret db host'));
        String? before = Env().env['APP_ENV'];
        Env().env['APP_ENV'] = 'production';
        try {
          http.Response prod = await mcp.stateless(
            'Ann',
            'tools/call',
            params: params,
          );
          expect(mcp.text(prod), 'Tool failed');
        } finally {
          if (before == null) {
            Env().env.remove('APP_ENV');
          } else {
            Env().env['APP_ENV'] = before;
          }
        }
      },
      skip: Platform.environment.containsKey('APP_ENV')
          ? 'APP_ENV is a real env variable'
          : false,
    );
  });

  group('3.3 dox_mcp: asking the user (MRTR)', () {
    setUpAll(mcp.login);

    Map<String, dynamic> form = <String, dynamic>{
      'elicitation': <String, dynamic>{},
    };

    test('round 1 asks, round 2 with the answer completes', () async {
      Map<String, dynamic> first = await mcp.ask('Ann', 7);
      expect(first['resultType'], 'input_required');
      Map<String, dynamic> requests = first['inputRequests'];
      expect(requests, hasLength(1));
      String key = requests.keys.first;
      expect(requests[key]['method'], 'elicitation/create');
      expect(requests[key]['params']['message'], 'Delete this note?');

      http.Response second = await mcp.answer(
        'Ann',
        7,
        first['requestState'],
        key,
      );
      Map<String, dynamic> result = mcp.json(second)['result'];
      expect(result['resultType'], 'complete', reason: second.body);
      expect(result['content'][0]['text'], 'Deleted note 7');
    });

    test('a changed, moved or stolen state gives -32602', () async {
      Map<String, dynamic> first = await mcp.ask('Ann', 8);
      String state = first['requestState'];
      String key = (first['inputRequests'] as Map<String, dynamic>).keys.first;
      String last = state.substring(state.length - 1);
      String tampered =
          state.substring(0, state.length - 1) + (last == 'A' ? 'B' : 'A');

      List<http.Response> bad = <http.Response>[
        await mcp.answer('Ann', 8, tampered, key),
        // other arguments
        await mcp.answer('Ann', 9, state, key),
        // another tool
        await mcp.answer('Ann', 8, state, key, tool: 'echo'),
        // another user
        await mcp.answer('Bob', 8, state, key),
      ];
      for (http.Response res in bad) {
        expect(mcp.json(res)['error']['code'], -32602, reason: res.body);
      }
    });

    test('a client with no elicitation gets 400 -32021', () async {
      http.Response res = await mcp.stateless(
        'Ann',
        'tools/call',
        params: <String, dynamic>{
          'name': 'delete_note',
          'arguments': <String, dynamic>{'id': 1},
        },
      );
      expect(res.statusCode, 400);
      Map<String, dynamic> error = mcp.json(res)['error'];
      expect(error['code'], -32021);
      expect(error['data']['requiredCapabilities'], contains('elicitation'));
    });

    test('a client with elicitation is asked', () async {
      http.Response res = await mcp.stateless(
        'Ann',
        'tools/call',
        params: <String, dynamic>{
          'name': 'delete_note',
          'arguments': <String, dynamic>{'id': 1},
        },
        capabilities: form,
      );
      expect(mcp.json(res)['result']['resultType'], 'input_required');
    });
  });

  group('3.3 dox_mcp: OAuth with client metadata documents', () {
    setUpAll(mcp.login);

    String docUrl = 'https://client.example/oauth/meta.json';
    String redirect = 'http://127.0.0.1:33418/callback';
    String verifier = 'v' * 50;
    String challenge = base64Url
        .encode(sha256.convert(utf8.encode(verifier)).bytes)
        .replaceAll('=', '');
    FakeClientFetcher fetcher = mcpClientFetcher;

    Map<String, dynamic> doc(String url, {Map<String, dynamic>? extra}) {
      return <String, dynamic>{
        'client_id': url,
        'client_name': 'E2E Client',
        'redirect_uris': <String>[redirect],
        'token_endpoint_auth_method': 'none',
        ...?extra,
      };
    }

    Future<http.Response> consent(String path, String id, String uri) {
      return http.get(
        api
            .uri('/mcp-consent/$path')
            .replace(
              queryParameters: <String, String>{
                'client_id': id,
                'redirect_uri': uri,
                'state': 's1',
              },
            ),
      );
    }

    Future<http.Response> tokenCall(Map<String, String> body) {
      return http.post(api.uri('/oauth/token'), body: body);
    }

    Future<String> approve(String id) async {
      http.Response res = await http.post(
        api.uri('/mcp-consent/approve'),
        headers: mcp.auth('Ann'),
        body: jsonEncode(<String, dynamic>{
          'client_id': id,
          'redirect_uri': redirect,
          'code_challenge': challenge,
          'state': 'xyz',
        }),
      );
      expect(res.statusCode, 200, reason: res.body);
      Uri back = Uri.parse(mcp.json(res)['redirect']);
      expect(back.queryParameters['state'], 'xyz');
      return back.queryParameters['code']!;
    }

    setUpAll(() {
      fetcher.serve(docUrl, doc(docUrl));
    });

    test('discovery says documents are supported', () async {
      http.Response res = await http.get(
        api.uri('/.well-known/oauth-authorization-server'),
      );
      expect(res.statusCode, 200);
      Map<String, dynamic> meta = mcp.json(res);
      expect(meta['client_id_metadata_document_supported'], true);
      expect(meta['code_challenge_methods_supported'], <String>['S256']);
    });

    test('verify, approve, token (PKCE), and the code works once', () async {
      http.Response check = await consent('verify', docUrl, redirect);
      expect(check.statusCode, 200, reason: check.body);
      expect(mcp.json(check), <String, dynamic>{
        'name': 'E2E Client',
        'host': 'client.example',
      });

      String code = await approve(docUrl);
      Map<String, String> body = <String, String>{
        'grant_type': 'authorization_code',
        'code': code,
        'code_verifier': verifier,
        'client_id': docUrl,
        'redirect_uri': redirect,
      };
      http.Response token = await tokenCall(body);
      expect(token.statusCode, 200, reason: token.body);
      String access = mcp.json(token)['access_token'];
      expect(mcpTokens.subjects[access], '${mcp.ids['Ann']}');
      expect(token.headers['cache-control'], 'no-store');

      http.Response again = await tokenCall(body);
      expect(again.statusCode, 400);
      expect(mcp.json(again)['error'], 'invalid_grant');
    });

    test('a wrong verifier gives invalid_grant', () async {
      String code = await approve(docUrl);
      http.Response res = await tokenCall(<String, String>{
        'grant_type': 'authorization_code',
        'code': code,
        'code_verifier': 'w' * 50,
        'client_id': docUrl,
        'redirect_uri': redirect,
      });
      expect(mcp.json(res)['error'], 'invalid_grant');
    });

    test('a document with another client_id or a secret is refused', () async {
      String moved = 'https://client.example/moved.json';
      fetcher.serve(moved, doc('https://other.example/meta.json'));
      String secret = 'https://client.example/secret.json';
      fetcher.serve(
        secret,
        doc(secret, extra: <String, dynamic>{'client_secret': 'x'}),
      );
      for (String url in <String>[moved, secret]) {
        http.Response res = await consent('verify', url, redirect);
        expect(res.statusCode, 400);
        expect(mcp.json(res)['error'], 'invalid_client', reason: url);
      }
    });

    test('a client secret in the token request gives 401', () async {
      http.Response res = await tokenCall(<String, String>{
        'grant_type': 'authorization_code',
        'code': 'any-code',
        'code_verifier': verifier,
        'client_id': docUrl,
        'redirect_uri': redirect,
        'client_secret': 'guess',
      });
      expect(res.statusCode, 401);
      expect(mcp.json(res)['error'], 'invalid_client');
    });

    test('a redirect not in the document gives invalid_request', () async {
      http.Response res = await consent(
        'verify',
        docUrl,
        'https://evil.example/callback',
      );
      expect(mcp.json(res)['error'], 'invalid_request');
    });

    test('a loopback redirect may use any port, only for documents', () async {
      http.Response other = await consent(
        'verify',
        docUrl,
        'http://127.0.0.1:5999/callback',
      );
      expect(other.statusCode, 200, reason: other.body);
      http.Response path = await consent(
        'verify',
        docUrl,
        'http://127.0.0.1:5999/other',
      );
      expect(mcp.json(path)['error'], 'invalid_request');

      // a signed (registered) client stays exact, and has no host
      http.Response reg = await http.post(
        api.uri('/oauth/register'),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, dynamic>{
          'client_name': 'Old Client',
          'redirect_uris': <String>[redirect],
        }),
      );
      expect(reg.statusCode, 201, reason: reg.body);
      String signed = mcp.json(reg)['client_id'];
      http.Response exact = await consent('verify', signed, redirect);
      expect(mcp.json(exact), <String, dynamic>{
        'name': 'Old Client',
        'host': null,
      });
      http.Response port = await consent(
        'verify',
        signed,
        'http://127.0.0.1:5999/callback',
      );
      expect(mcp.json(port)['error'], 'invalid_request');
    });

    test('old checkClient and deny work for a document once loaded', () async {
      String url = 'https://client.example/sync.json';
      fetcher.serve(url, doc(url));
      http.Response first = await consent('check', url, redirect);
      expect(mcp.json(first)['error'], 'invalid_client');
      // the first call started the load
      await Future<void>.delayed(Duration(milliseconds: 100));
      http.Response second = await consent('check', url, redirect);
      expect(second.statusCode, 200, reason: second.body);
      expect(mcp.json(second)['host'], 'client.example');

      http.Response denied = await consent('deny', url, redirect);
      expect(denied.statusCode, 200, reason: denied.body);
      Uri back = Uri.parse(mcp.json(denied)['redirect']);
      expect(back.queryParameters['error'], 'access_denied');
      expect(back.queryParameters['state'], 's1');
    });

    test('a failing URL is loaded once, then the failure is kept', () async {
      String url = 'https://client.example/missing.json';
      for (int i = 0; i < 3; i++) {
        http.Response res = await consent('verify', url, redirect);
        expect(mcp.json(res)['error'], 'invalid_client');
      }
      expect(fetcher.calls.where((String c) => c == url), hasLength(1));
    });

    test('the real fetcher refuses inside addresses', () async {
      McpOAuth real = McpOAuth(issuer: env.appUrl, tokens: mcpTokens);
      for (String url in <String>[
        'https://127.0.0.1/x',
        'https://169.254.169.254/x',
        'https://[::1]/x',
      ]) {
        await expectLater(
          real.verifyClient(url, redirect),
          throwsA(
            isA<McpOAuthException>().having(
              (McpOAuthException e) => e.error,
              'error',
              'invalid_client',
            ),
          ),
          reason: url,
        );
      }
    });
  });
}

/// JSON-RPC calls to /mcp for the users of these checks.
class McpCalls {
  McpCalls(this.api);

  final Api api;
  final Map<String, int> ids = <String, int>{};
  bool _ready = false;
  int _id = 0;

  /// Registers and logs in Ann and Bob, once.
  Future<void> login() async {
    if (_ready) return;
    for (String name in <String>['Ann', 'Bob']) {
      String email = 'mcp.${name.toLowerCase()}@mail.com';
      await registerUser(api, 'Mcp $name', email);
      http.Response res = await api.post('/api/auth/login', <String, dynamic>{
        'email': email,
        'password': 'secret123',
      });
      expect(res.statusCode, 200, reason: res.body);
      api.tokens['mcp$name'] = json(res)['token'];
      ids[name] = json(res)['user']['id'] as int;
    }
    _ready = true;
  }

  Map<String, String> auth(String user) {
    return <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${api.tokens['mcp$user']}',
    };
  }

  Map<String, dynamic> rpc(
    String method, {
    Map<String, dynamic>? params,
    int? id,
  }) {
    return <String, dynamic>{
      'jsonrpc': '2.0',
      'id': id ?? _id++,
      'method': method,
      'params': ?params,
    };
  }

  Map<String, dynamic> call(String tool, Map<String, dynamic> args) {
    return rpc(
      'tools/call',
      params: <String, dynamic>{'name': tool, 'arguments': args},
    );
  }

  Future<http.Response> post(
    String user,
    Object body, {
    String? session,
    Map<String, String>? headers,
  }) {
    return http.post(
      api.uri('/mcp'),
      headers: <String, String>{
        ...auth(user),
        'mcp-session-id': ?session,
        ...?headers,
      },
      body: jsonEncode(body),
    );
  }

  Future<http.Response> initialize(String user) {
    return post(
      user,
      rpc(
        'initialize',
        params: <String, dynamic>{
          'protocolVersion': '2025-11-25',
          'capabilities': <String, dynamic>{},
          'clientInfo': <String, dynamic>{'name': 'e2e', 'version': '1'},
        },
      ),
    );
  }

  Future<String> session(String user) async {
    http.Response res = await initialize(user);
    return res.headers['mcp-session-id']!;
  }

  /// A 2026-07-28 request body: version and capabilities in `_meta`.
  Map<String, dynamic> statelessBody(
    String method, {
    Map<String, dynamic>? params,
    String version = newVersion,
    Map<String, dynamic>? capabilities,
  }) {
    return rpc(
      method,
      params: <String, dynamic>{
        ...?params,
        '_meta': <String, dynamic>{
          'io.modelcontextprotocol/protocolVersion': version,
          'io.modelcontextprotocol/clientCapabilities':
              capabilities ?? <String, dynamic>{},
        },
      },
    );
  }

  Map<String, String> statelessHeaders(
    String method, {
    String? tool,
    String version = newVersion,
  }) {
    return <String, String>{
      'MCP-Protocol-Version': version,
      'Mcp-Method': method,
      'Mcp-Name': ?tool,
    };
  }

  Future<http.Response> stateless(
    String user,
    String method, {
    Map<String, dynamic>? params,
    String version = newVersion,
    Map<String, dynamic>? capabilities,
    String? dropHeader,
    Map<String, String>? extra,
  }) {
    Map<String, String> headers = statelessHeaders(
      method,
      tool: params?['name'] as String?,
      version: version,
    )..remove(dropHeader);
    return post(
      user,
      statelessBody(
        method,
        params: params,
        version: version,
        capabilities: capabilities,
      ),
      headers: <String, String>{...headers, ...?extra},
    );
  }

  /// Round 1 of delete_note: the `input_required` result.
  Future<Map<String, dynamic>> ask(String user, int id) async {
    http.Response res = await stateless(
      user,
      'tools/call',
      params: <String, dynamic>{
        'name': 'delete_note',
        'arguments': <String, dynamic>{'id': id},
      },
      capabilities: <String, dynamic>{'elicitation': <String, dynamic>{}},
    );
    expect(res.statusCode, 200, reason: res.body);
    return json(res)['result'];
  }

  /// Round 2: call [tool] again with [state] and a yes for [key].
  Future<http.Response> answer(
    String user,
    int id,
    String state,
    String key, {
    String tool = 'delete_note',
  }) {
    return stateless(
      user,
      'tools/call',
      params: <String, dynamic>{
        'name': tool,
        'arguments': tool == 'echo'
            ? <String, dynamic>{'text': 'x'}
            : <String, dynamic>{'id': id},
        'requestState': state,
        'inputResponses': <String, dynamic>{
          key: <String, dynamic>{
            'action': 'accept',
            'content': <String, dynamic>{'value': true},
          },
        },
      },
      capabilities: <String, dynamic>{'elicitation': <String, dynamic>{}},
    );
  }

  dynamic json(http.Response res) => jsonDecode(res.body);

  /// The first text of a tool result.
  String text(http.Response res) {
    return json(res)['result']['content'][0]['text'] as String;
  }
}
