import 'package:dox_auth/dox_auth.dart';
import 'package:dox_core/dox_core.dart';
import 'package:dox_socketio/dox_socketio.dart';
import 'package:dox_test/app/dtos/e32y/e32y.dto.dart';
import 'package:dox_test/app/models/e32y/e32y.model.dart';
import 'package:dox_test/app/models/user/user.model.dart';

/// Routes for test/e2e_32y_patch.dart (the 3.2.y patch checks).
/// CoreRouter adds them in the group `/e32y`, so they all start with
/// /core/e32y. Plain methods, so they need no container entry.
class E32yRoutes {
  void register() {
    /// a `:` in a path is a plain char, not a param
    Route.get('/books:search', <dynamic>[AuthMiddleware(), books]);
    Route.get('/items/{id}', item);
    Route.post('/valid/{kind}', valid);
    Route.post('/valid-dto', validDto);
    Route.post('/attempt', attempt);
    Route.get('/optional-api', <dynamic>[
      AuthMiddleware(guard: 'api').asOptional(),
      whoami,
    ]);
    Route.get('/optional-tokens', <dynamic>[
      AuthMiddleware(guard: 'tokens').asOptional(),
      whoami,
    ]);
    Route.post('/ping-others/{id}', pingOthers);
  }

  Map<String, dynamic> books(DoxRequest req) {
    return <String, dynamic>{'path': req.path(), 'q': req.input('q')};
  }

  /// GET /core/e32y/items/{id}: the model, as JSON
  Future<Map<String, dynamic>?> item(DoxRequest req) async {
    E32yItem? found = await E32yItem().find(req.param['id']);
    return found?.toJson();
  }

  /// the schemas of POST /core/e32y/valid/{kind}, all on the key `n`
  static final Map<String, Schema<Object?>> schemas = <String, Schema<Object?>>{
    'num': v.num(),
    'datetime': v.string().datetime(),
    'cdate': v.coerce.date(),
    'cint': v.coerce.int(),
    'tenth': v.num().multipleOf(0.1),
    'whole': v.num().multipleOf(1),
  };

  Future<Map<String, dynamic>> valid(DoxRequest req) async {
    Schema<Object?> schema = schemas[req.param['kind']]!;
    await req.validateSchema(v.object(<String, Schema<Object?>>{'n': schema}));
    return <String, dynamic>{'ok': true};
  }

  Map<String, dynamic> validDto(E32yForm form) {
    return <String, dynamic>{
      'at': form.at?.toIso8601String(),
      'count': form.count,
    };
  }

  /// POST /core/e32y/attempt: the body as it is goes to Auth().attempt
  Future<dynamic> attempt(DoxRequest req) async {
    String? token = await Auth().attempt(req.body);
    if (token == null) {
      return response(<String, dynamic>{'message': 'failed'}).statusCode(401);
    }
    return <String, dynamic>{'token': token};
  }

  Map<String, dynamic> whoami(DoxRequest req) {
    Auth? auth = req.auth as Auth?;
    return <String, dynamic>{
      'id': req.auth?.id(),
      'name': auth?.user<User>()?.name,
    };
  }

  /// POST /core/e32y/ping-others/{id}: broadcasts to `private-users.{id}`,
  /// skipping the socket of the X-Socket-ID header.
  Future<Map<String, dynamic>> pingOthers(DoxRequest req) async {
    await Broadcast.event(
      E32yPinged(int.parse('${req.param['id']}')),
      toOthers: Broadcast.socketId(req),
    );
    return <String, dynamic>{'skip': Broadcast.socketId(req)};
  }
}

/// the event of POST /core/e32y/ping-others/{id}
class E32yPinged with ShouldBroadcast {
  E32yPinged(this.userId);

  final int userId;

  @override
  List<Channel> broadcastOn() {
    return <Channel>[PrivateChannel('users.$userId')];
  }

  @override
  String broadcastAs() => 'e32y.pinged';

  @override
  Map<String, Object?> broadcastWith() {
    return <String, Object?>{'id': userId};
  }
}
