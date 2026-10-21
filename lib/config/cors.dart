import 'package:dox_core/dox_core.dart';

/// CORS is on for every route, except routes inside `Route.disabledCors`.
CORSConfig cors = CORSConfig(
  origin: '*',
  methods: <String>['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
  headers: '*',
  exposeHeaders: <String>['content-type', 'x-app-name'],
  credentials: true,
  maxAge: 90,
);
