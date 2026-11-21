import 'dart:async';
import 'dart:io';

import 'package:dox_core/dox_core.dart';
// ignore: depend_on_referenced_packages
import 'package:dox_http_native/dox_http_native.dart' show NativeResponse;

/// Routes for test/e2e_33_http2_grpc.dart (HTTP/2 on the app port).
/// CoreRouter adds them in the group `/e33`, so they all start with
/// /core/e33. Plain methods, so they need no container entry.
class E33Routes {
  void register() {
    Route.get('/proto', proto);
    Route.post('/echo', echo);
    Route.post('/form', form);
    Route.get('/empty', empty);
    Route.get('/not-modified', notModified);
    Route.get('/cookie', cookie);
    Route.get('/big', big);
    Route.get('/slow', slow);
    Route.post('/hold', hold);
    Route.get('/trailers', trailers);
    Route.get('/takeover', takeover);
    Route.post('/rpc', rpc).renderErrorsWith(rpcError);

    /// any method, with the X-E33-Fallback header: a JSON answer of its own
    Route.fallback(fallback, when: hasFallbackHeader);
  }

  /// GET /core/e33/proto: the HTTP version of the request
  Map<String, dynamic> proto(DoxRequest req) {
    return <String, dynamic>{'version': req.protocolVersion};
  }

  /// POST /core/e33/echo: the JSON body back
  Map<String, dynamic> echo(DoxRequest req) {
    return req.body;
  }

  /// POST /core/e33/form: a multipart field and the size of its file
  Future<Map<String, dynamic>> form(DoxRequest req) async {
    RequestFile? file = req.file('file');
    return <String, dynamic>{
      'note': req.input('note'),
      'name': file?.filename,
      'size': file == null ? null : (await file.bytes).length,
    };
  }

  DoxResponse empty(DoxRequest req) {
    return response().statusCode(HttpStatus.noContent);
  }

  DoxResponse notModified(DoxRequest req) {
    return response().statusCode(HttpStatus.notModified);
  }

  /// GET /core/e33/cookie: the Cookie header as the handler sees it
  Map<String, dynamic> cookie(DoxRequest req) {
    return <String, dynamic>{'cookie': req.header('cookie')};
  }

  /// GET /core/e33/big?kb=N: N KiB of `x`
  String big(DoxRequest req) {
    int kb = int.parse('${req.input('kb') ?? 1}');
    return 'x' * (kb * 1024);
  }

  /// GET /core/e33/slow?ms=N: answers after N ms
  Future<Map<String, dynamic>> slow(DoxRequest req) async {
    int ms = int.parse('${req.input('ms') ?? 100}');
    await Future<void>.delayed(Duration(milliseconds: ms));
    return <String, dynamic>{'slept': ms};
  }

  /// POST /core/e33/hold?ms=N: never reads its body (eg. an
  /// application/grpc body, that Dox does not read), answers after N ms
  Future<Map<String, dynamic>> hold(DoxRequest req) async {
    int ms = int.parse('${req.input('ms') ?? 100}');
    await Future<void>.delayed(Duration(milliseconds: ms));
    return <String, dynamic>{'held': ms};
  }

  /// GET /core/e33/trailers: a body and a trailer. HTTP/2 sends the
  /// trailer, HTTP/1.1 drops it.
  Future<void> trailers(DoxRequest req) async {
    req.takeOverResponse();
    NativeResponse res = req.httpRequest.response as NativeResponse;
    res.write('with trailers');
    res.trailers.set('x-e33-trailer', 'yes');
    await res.close();
  }

  /// GET /core/e33/takeover?throw=before|after: the handler sends the
  /// answer itself. `before`: it fails before any write (Dox sends 500).
  /// `after`: it fails after the head went out (Dox sends nothing more).
  Future<void> takeover(DoxRequest req) async {
    req.takeOverResponse();
    HttpResponse res = req.httpRequest.response;
    String? when = req.input('throw')?.toString();
    if (when == 'before') throw StateError('e33 before');
    res.headers.set('x-e33', 'mine');
    res.write('taken over');
    if (when == 'after') {
      await res.flush();
      throw StateError('e33 after');
    }
    await res.close();
  }

  /// POST /core/e33/rpc: always fails, rendered by [rpcError]
  Map<String, dynamic> rpc(DoxRequest req) {
    throw StateError('e33 rpc failed');
  }

  static DoxResponse? rpcError(Object error, DoxRequest req) {
    return response(<String, dynamic>{'rpc_error': '$error'})
        .statusCode(HttpStatus.badRequest);
  }

  static bool hasFallbackHeader(HttpRequest req) {
    return req.headers.value('x-e33-fallback') != null;
  }

  Map<String, dynamic> fallback(DoxRequest req) {
    return <String, dynamic>{'fallback': req.path(), 'method': req.method};
  }
}
