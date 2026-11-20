// This is a generated file - do not edit.
//
// Generated from echo.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'echo.pb.dart' as $0;

export 'echo.pb.dart';

@$pb.GrpcServiceName('dox.test.Echo')
class EchoClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  EchoClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.EchoReply> unary(
    $0.EchoRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$unary, request, options: options);
  }

  $grpc.ResponseStream<$0.EchoReply> serverStream(
    $0.EchoRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$serverStream, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseFuture<$0.EchoReply> clientStream(
    $async.Stream<$0.EchoRequest> request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(_$clientStream, request, options: options)
        .single;
  }

  $grpc.ResponseStream<$0.EchoReply> bidi(
    $async.Stream<$0.EchoRequest> request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(_$bidi, request, options: options);
  }

  // method descriptors

  static final _$unary = $grpc.ClientMethod<$0.EchoRequest, $0.EchoReply>(
      '/dox.test.Echo/Unary',
      ($0.EchoRequest value) => value.writeToBuffer(),
      $0.EchoReply.fromBuffer);
  static final _$serverStream =
      $grpc.ClientMethod<$0.EchoRequest, $0.EchoReply>(
          '/dox.test.Echo/ServerStream',
          ($0.EchoRequest value) => value.writeToBuffer(),
          $0.EchoReply.fromBuffer);
  static final _$clientStream =
      $grpc.ClientMethod<$0.EchoRequest, $0.EchoReply>(
          '/dox.test.Echo/ClientStream',
          ($0.EchoRequest value) => value.writeToBuffer(),
          $0.EchoReply.fromBuffer);
  static final _$bidi = $grpc.ClientMethod<$0.EchoRequest, $0.EchoReply>(
      '/dox.test.Echo/Bidi',
      ($0.EchoRequest value) => value.writeToBuffer(),
      $0.EchoReply.fromBuffer);
}

@$pb.GrpcServiceName('dox.test.Echo')
abstract class EchoServiceBase extends $grpc.Service {
  $core.String get $name => 'dox.test.Echo';

  EchoServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.EchoRequest, $0.EchoReply>(
        'Unary',
        unary_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.EchoRequest.fromBuffer(value),
        ($0.EchoReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.EchoRequest, $0.EchoReply>(
        'ServerStream',
        serverStream_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.EchoRequest.fromBuffer(value),
        ($0.EchoReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.EchoRequest, $0.EchoReply>(
        'ClientStream',
        clientStream,
        true,
        false,
        ($core.List<$core.int> value) => $0.EchoRequest.fromBuffer(value),
        ($0.EchoReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.EchoRequest, $0.EchoReply>(
        'Bidi',
        bidi,
        true,
        true,
        ($core.List<$core.int> value) => $0.EchoRequest.fromBuffer(value),
        ($0.EchoReply value) => value.writeToBuffer()));
  }

  $async.Future<$0.EchoReply> unary_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.EchoRequest> $request) async {
    return unary($call, await $request);
  }

  $async.Future<$0.EchoReply> unary(
      $grpc.ServiceCall call, $0.EchoRequest request);

  $async.Stream<$0.EchoReply> serverStream_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.EchoRequest> $request) async* {
    yield* serverStream($call, await $request);
  }

  $async.Stream<$0.EchoReply> serverStream(
      $grpc.ServiceCall call, $0.EchoRequest request);

  $async.Future<$0.EchoReply> clientStream(
      $grpc.ServiceCall call, $async.Stream<$0.EchoRequest> request);

  $async.Stream<$0.EchoReply> bidi(
      $grpc.ServiceCall call, $async.Stream<$0.EchoRequest> request);
}
