// GENERATED CODE - DO NOT MODIFY BY HAND
// Made by dox_builder. Run `dart run build_runner build`.
// ignore_for_file: type=lint

import 'package:dox_core/dox_core.dart';

/// OpenAPI docs found in the code.
/// Use it in `OpenApiConfig(registry: openApiRegistry)`.
const OpenApiRegistry openApiRegistry = OpenApiRegistry(
  operations: <OpenApiOperation>[
    OpenApiOperation(
      controller: 'AuthController',
      method: 'register',
      argumentTypes: <String>['RegisterRequest'],
      summary: 'Register a user',
      description: 'The email is saved in lower case (UserObserver).',
      tags: <String>['Auth'],
      formRequest: 'RegisterRequest',
      responses: <int, ResponseDoc>{
        200: ResponseDoc(description: 'Successful response'),
      },
    ),
    OpenApiOperation(
      controller: 'AuthController',
      method: 'login',
      argumentTypes: <String>['DoxRequest'],
      summary: 'Log in',
      description: 'Gives a JWT. Send it as `Authorization: Bearer <token>`.',
      tags: <String>['Auth'],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: '{token, user}',
          schema: <String, dynamic>{'type': 'object'},
        ),
        401: ResponseDoc(description: 'Wrong email or password'),
      },
    ),
    OpenApiOperation(
      controller: 'AuthController',
      method: 'me',
      argumentTypes: <String>['DoxRequest'],
      summary: 'The logged in user',
      tags: <String>['Auth'],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{
            'type': 'object',
            'properties': <String, dynamic>{
              'id': <String, dynamic>{
                'type': <dynamic>['integer', 'null'],
              },
              'name': <String, dynamic>{
                'type': <dynamic>['string', 'null'],
              },
              'email': <String, dynamic>{
                'type': <dynamic>['string', 'null'],
              },
              'full_name': <String, dynamic>{
                'type': <dynamic>['string', 'null'],
              },
            },
          },
        ),
      },
    ),
    OpenApiOperation(
      controller: 'UserController',
      method: 'index',
      argumentTypes: <String>['DoxRequest'],
      summary: 'GET /api/users?search=&page=&limit=',
      tags: <String>['User'],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{'\$ref': '#/components/schemas/Pagination'},
        ),
      },
    ),
    OpenApiOperation(
      controller: 'UserController',
      method: 'show',
      argumentTypes: <String>['DoxRequest', 'String'],
      summary: 'GET /api/users/{id}',
      tags: <String>['User'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'string'},
      ],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{'\$ref': '#/components/schemas/User'},
        ),
      },
    ),
    OpenApiOperation(
      controller: 'UserController',
      method: 'saveProfile',
      argumentTypes: <String>['DoxRequest'],
      summary: 'PUT /api/me/profile (needs token)',
      tags: <String>['User'],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{'\$ref': '#/components/schemas/Profile'},
        ),
      },
    ),
    OpenApiOperation(
      controller: 'PostController',
      method: 'index',
      argumentTypes: <String>['DoxRequest'],
      summary: 'GET /api/posts?page=&limit=&status=',
      tags: <String>['Post'],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{'\$ref': '#/components/schemas/Pagination'},
        ),
      },
    ),
    OpenApiOperation(
      controller: 'PostController',
      method: 'show',
      argumentTypes: <String>['DoxRequest', 'String'],
      summary: 'GET /api/posts/{id}',
      tags: <String>['Post'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'string'},
      ],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{'\$ref': '#/components/schemas/Post'},
        ),
      },
    ),
    OpenApiOperation(
      controller: 'PostController',
      method: 'summary',
      argumentTypes: <String>['DoxRequest', 'String'],
      summary: 'GET /api/posts/{id}/summary (uses the serializer)',
      tags: <String>['Post'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'string'},
      ],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{
            'type': 'object',
            'properties': <String, dynamic>{
              'id': <String, dynamic>{
                'type': <dynamic>['integer', 'null'],
              },
              'title': <String, dynamic>{
                'type': <dynamic>['string', 'null'],
              },
              'status': <String, dynamic>{
                'type': <dynamic>['string', 'null'],
              },
              'author': <String, dynamic>{
                'type': <dynamic>['string', 'null'],
              },
              'tags': <String, dynamic>{
                'type': 'array',
                'items': <String, dynamic>{
                  'type': <dynamic>['string', 'null'],
                },
              },
            },
          },
        ),
      },
    ),
    OpenApiOperation(
      controller: 'PostController',
      method: 'store',
      argumentTypes: <String>['PostRequest'],
      summary: 'POST /api/posts (needs token)',
      tags: <String>['Post'],
      formRequest: 'PostRequest',
      responses: <int, ResponseDoc>{
        200: ResponseDoc(description: 'Successful response'),
      },
    ),
    OpenApiOperation(
      controller: 'PostController',
      method: 'update',
      argumentTypes: <String>['PostRequest', 'String'],
      summary: 'PUT /api/posts/{id} (needs token)',
      tags: <String>['Post'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'string'},
      ],
      formRequest: 'PostRequest',
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{'\$ref': '#/components/schemas/Post'},
        ),
      },
    ),
    OpenApiOperation(
      controller: 'PostController',
      method: 'destroy',
      argumentTypes: <String>['DoxRequest', 'String'],
      summary: 'DELETE /api/posts/{id} (needs token)',
      tags: <String>['Post'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'string'},
      ],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{
            'type': 'object',
            'additionalProperties': <String, dynamic>{'type': 'string'},
          },
        ),
      },
    ),
    OpenApiOperation(
      controller: 'PostController',
      method: 'trashed',
      argumentTypes: <String>['DoxRequest'],
      summary: 'GET /api/posts/trashed',
      tags: <String>['Post'],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{
            'type': 'array',
            'items': <String, dynamic>{'\$ref': '#/components/schemas/Post'},
          },
        ),
      },
    ),
    OpenApiOperation(
      controller: 'PostController',
      method: 'stats',
      argumentTypes: <String>['DoxRequest'],
      summary: 'GET /api/posts/stats',
      tags: <String>['Post'],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{'type': 'object'},
        ),
      },
    ),
    OpenApiOperation(
      controller: 'PostController',
      method: 'addComment',
      argumentTypes: <String>['DoxRequest', 'String'],
      summary: 'POST /api/posts/{id}/comments (needs token)',
      tags: <String>['Post'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'string'},
      ],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(description: 'Successful response'),
      },
    ),
    OpenApiOperation(
      controller: 'PostController',
      method: 'showComment',
      argumentTypes: <String>['DoxRequest', 'String', 'String'],
      summary: 'GET /api/posts/{postId}/comments/{commentId}',
      tags: <String>['Post'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'string'},
        <String, dynamic>{'type': 'string'},
      ],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{'\$ref': '#/components/schemas/Comment'},
        ),
      },
    ),
    OpenApiOperation(
      controller: 'TagController',
      method: 'index',
      argumentTypes: <String>['DoxRequest'],
      summary: 'List tags (lower case annotation)',
      description: '`except=a,b` leaves those names out (whereNotIn).',
      tags: <String>['Tag'],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{
            'type': 'array',
            'items': <String, dynamic>{'\$ref': '#/components/schemas/Tag'},
          },
        ),
      },
    ),
    OpenApiOperation(
      controller: 'TagController',
      method: 'store',
      argumentTypes: <String>['DoxRequest'],
      summary: 'Create tags in a transaction',
      description:
          'With `fail: true` the transaction rolls back and nothing is saved.',
      tags: <String>['Tag', 'ORM'],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{'type': 'object'},
        ),
      },
    ),
    OpenApiOperation(
      controller: 'TagController',
      method: 'posts',
      argumentTypes: <String>['DoxRequest', 'String'],
      summary: 'GET /api/tags/{name}/posts',
      tags: <String>['Tag'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'string'},
      ],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{'\$ref': '#/components/schemas/Tag'},
        ),
      },
    ),
    OpenApiOperation(
      controller: 'FileController',
      method: 'upload',
      argumentTypes: <String>['DoxRequest'],
      summary: 'POST /api/files (multipart form-data: file + note)',
      tags: <String>['File'],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(description: 'Successful response'),
      },
    ),
    OpenApiOperation(
      controller: 'FileController',
      method: 'download',
      argumentTypes: <String>['DoxRequest', 'String'],
      summary: 'GET /api/files/{name}',
      tags: <String>['File'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'string'},
      ],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(description: 'Successful response'),
      },
    ),
    OpenApiOperation(
      controller: 'FileController',
      method: 'raw',
      argumentTypes: <String>['DoxRequest', 'String'],
      summary:
          'GET /api/files/{name}/raw (a File: Range gives 206 Partial Content)',
      tags: <String>['File'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'string'},
      ],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(description: 'Successful response'),
      },
    ),
    OpenApiOperation(
      controller: 'CacheController',
      method: 'put',
      argumentTypes: <String>['DoxRequest', 'String', 'String'],
      summary: 'Put a value',
      description: 'Body: `{"value": any JSON, "ttl": seconds (optional)}`.',
      tags: <String>['Cache'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'string'},
        <String, dynamic>{'type': 'string'},
      ],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{'type': 'object'},
        ),
      },
    ),
    OpenApiOperation(
      controller: 'CacheController',
      method: 'get',
      argumentTypes: <String>['DoxRequest', 'String', 'String'],
      summary: 'Get a value',
      tags: <String>['Cache'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'string'},
        <String, dynamic>{'type': 'string'},
      ],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{'type': 'object'},
        ),
      },
    ),
    OpenApiOperation(
      controller: 'CacheController',
      method: 'forget',
      argumentTypes: <String>['DoxRequest', 'String', 'String'],
      summary: 'Forget a value',
      tags: <String>['Cache'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'string'},
        <String, dynamic>{'type': 'string'},
      ],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{'type': 'object'},
        ),
      },
    ),
    OpenApiOperation(
      controller: 'CacheController',
      method: 'remember',
      argumentTypes: <String>['DoxRequest', 'String', 'String'],
      summary: 'Remember: compute once, then read from the cache',
      tags: <String>['Cache'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'string'},
        <String, dynamic>{'type': 'string'},
      ],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{'type': 'object'},
        ),
      },
    ),
    OpenApiOperation(
      controller: 'CacheController',
      method: 'increment',
      argumentTypes: <String>['DoxRequest', 'String', 'String'],
      summary: 'Increment a number (body `{"by": 1}`)',
      tags: <String>['Cache'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'string'},
        <String, dynamic>{'type': 'string'},
      ],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{'type': 'object'},
        ),
      },
    ),
    OpenApiOperation(
      controller: 'CacheController',
      method: 'putTagged',
      argumentTypes: <String>['DoxRequest', 'String', 'String', 'String'],
      summary: 'Put a tagged value',
      tags: <String>['Cache'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'string'},
        <String, dynamic>{'type': 'string'},
        <String, dynamic>{'type': 'string'},
      ],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{'type': 'object'},
        ),
      },
    ),
    OpenApiOperation(
      controller: 'CacheController',
      method: 'getTagged',
      argumentTypes: <String>['DoxRequest', 'String', 'String', 'String'],
      summary: 'Get a tagged value',
      tags: <String>['Cache'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'string'},
        <String, dynamic>{'type': 'string'},
        <String, dynamic>{'type': 'string'},
      ],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{'type': 'object'},
        ),
      },
    ),
    OpenApiOperation(
      controller: 'CacheController',
      method: 'flushTag',
      argumentTypes: <String>['DoxRequest', 'String', 'String'],
      summary: 'Flush one tag',
      tags: <String>['Cache'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'string'},
        <String, dynamic>{'type': 'string'},
      ],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{'type': 'object'},
        ),
      },
    ),
    OpenApiOperation(
      controller: 'CacheController',
      method: 'lock',
      argumentTypes: <String>['DoxRequest', 'String', 'String'],
      summary: 'Take a lock (memory and redis only)',
      tags: <String>['Cache'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'string'},
        <String, dynamic>{'type': 'string'},
      ],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: '{got, owner}',
          schema: <String, dynamic>{'type': 'object'},
        ),
        422: ResponseDoc(description: 'This store has no locks'),
      },
    ),
    OpenApiOperation(
      controller: 'CacheController',
      method: 'release',
      argumentTypes: <String>['DoxRequest', 'String', 'String'],
      summary: 'Release a lock (`?owner=` from the lock call)',
      tags: <String>['Cache'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'string'},
        <String, dynamic>{'type': 'string'},
      ],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{'type': 'object'},
        ),
      },
    ),
    OpenApiOperation(
      controller: 'StorageController',
      method: 'upload',
      argumentTypes: <String>['DoxRequest', 'String'],
      summary: 'Upload a file (form-data field `file`)',
      tags: <String>['Storage'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'string'},
      ],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(description: 'Successful response'),
      },
    ),
    OpenApiOperation(
      controller: 'StorageController',
      method: 'stream',
      argumentTypes: <String>['DoxRequest', 'String', 'String'],
      summary: 'Show a file (streamed)',
      tags: <String>['Storage'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'string'},
        <String, dynamic>{'type': 'string'},
      ],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(description: 'Successful response'),
      },
    ),
    OpenApiOperation(
      controller: 'StorageController',
      method: 'download',
      argumentTypes: <String>['DoxRequest', 'String', 'String'],
      summary: 'Download a file (streamed, as an attachment)',
      tags: <String>['Storage'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'string'},
        <String, dynamic>{'type': 'string'},
      ],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(description: 'Successful response'),
      },
    ),
    OpenApiOperation(
      controller: 'StorageController',
      method: 'signed',
      argumentTypes: <String>['DoxRequest', 'String', 'String'],
      summary: 'Make a signed URL that works for 10 minutes',
      tags: <String>['Storage'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'string'},
        <String, dynamic>{'type': 'string'},
      ],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{'type': 'object'},
        ),
      },
    ),
    OpenApiOperation(
      controller: 'StorageController',
      method: 'delete',
      argumentTypes: <String>['DoxRequest', 'String', 'String'],
      summary: 'Delete a file',
      tags: <String>['Storage'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'string'},
        <String, dynamic>{'type': 'string'},
      ],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{'type': 'object'},
        ),
      },
    ),
    OpenApiOperation(
      controller: 'SystemController',
      method: 'ping',
      argumentTypes: <String>['DoxRequest'],
      summary: 'GET /ping',
      tags: <String>['System'],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{'type': 'string'},
        ),
      },
    ),
    OpenApiOperation(
      controller: 'SystemController',
      method: 'query',
      argumentTypes: <String>['DoxRequest'],
      summary: 'GET /api/system/query?a=1',
      tags: <String>['System'],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{'type': 'object'},
        ),
      },
    ),
    OpenApiOperation(
      controller: 'SystemController',
      method: 'echo',
      argumentTypes: <String>['DoxRequest'],
      summary: 'POST /api/system/echo (JSON body)',
      tags: <String>['System'],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{'type': 'object'},
        ),
      },
    ),
    OpenApiOperation(
      controller: 'SystemController',
      method: 'env',
      argumentTypes: <String>['DoxRequest'],
      summary: 'GET /api/system/env',
      tags: <String>['System'],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{'type': 'object'},
        ),
      },
    ),
    OpenApiOperation(
      controller: 'SystemController',
      method: 'hash',
      argumentTypes: <String>['DoxRequest'],
      summary: 'POST /api/system/hash',
      tags: <String>['System'],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{'type': 'object'},
        ),
      },
    ),
    OpenApiOperation(
      controller: 'SystemController',
      method: 'setCookie',
      argumentTypes: <String>['DoxRequest'],
      summary: 'GET /api/system/cookie (sets an encrypted cookie)',
      tags: <String>['System'],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(description: 'Successful response'),
      },
    ),
    OpenApiOperation(
      controller: 'SystemController',
      method: 'readCookie',
      argumentTypes: <String>['DoxRequest'],
      summary: 'GET /api/system/cookie/read (reads it back)',
      tags: <String>['System'],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{'type': 'object'},
        ),
      },
    ),
    OpenApiOperation(
      controller: 'SystemController',
      method: 'teapot',
      argumentTypes: <String>['DoxRequest'],
      summary: 'GET /api/system/teapot (custom status and header)',
      tags: <String>['System'],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(description: 'Successful response'),
      },
    ),
    OpenApiOperation(
      controller: 'SystemController',
      method: 'crash',
      argumentTypes: <String>['DoxRequest'],
      summary: 'GET /api/system/crash (unhandled error, so 500)',
      tags: <String>['System'],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{'type': 'string'},
        ),
      },
    ),
    OpenApiOperation(
      controller: 'SystemController',
      method: 'container',
      argumentTypes: <String>['DoxRequest'],
      summary: 'GET /api/system/container',
      tags: <String>['System'],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{
            'type': 'object',
            'additionalProperties': <String, dynamic>{'type': 'integer'},
          },
        ),
      },
    ),
    OpenApiOperation(
      controller: 'SystemController',
      method: 'ip',
      argumentTypes: <String>['DoxRequest'],
      summary: 'GET /api/system/ip (X-Forwarded-* is read only from trusted proxies)',
      tags: <String>['System'],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{'type': 'object'},
        ),
      },
    ),
    OpenApiOperation(
      controller: 'SystemController',
      method: 'twice',
      argumentTypes: <String>['DoxRequest', 'String'],
      summary: 'GET /api/system/twice/{n}',
      tags: <String>['System'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'string'},
      ],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{
            'type': 'object',
            'additionalProperties': <String, dynamic>{'type': 'integer'},
          },
        ),
      },
    ),
    OpenApiOperation(
      controller: 'SystemController',
      method: 'playground',
      argumentTypes: <String>['DoxRequest'],
      ignore: true,
    ),
    OpenApiOperation(
      controller: 'SystemController',
      method: 'noCors',
      argumentTypes: <String>['DoxRequest'],
      summary: 'GET /no-cors',
      tags: <String>['System'],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{'type': 'string'},
        ),
      },
    ),
  ],
  routes: <OpenApiRouteBinding>[
    OpenApiRouteBinding('POST', '/register', 'AuthController.register'),
    OpenApiRouteBinding('POST', '/login', 'AuthController.login'),
    OpenApiRouteBinding('GET', '/me', 'AuthController.me'),
    OpenApiRouteBinding('PUT', '/me/profile', 'UserController.saveProfile'),
    OpenApiRouteBinding('GET', '/', 'UserController.index'),
    OpenApiRouteBinding('GET', '/{id}', 'UserController.show'),
    OpenApiRouteBinding('GET', '/trashed', 'PostController.trashed'),
    OpenApiRouteBinding('GET', '/stats', 'PostController.stats'),
    OpenApiRouteBinding('GET', '/', 'PostController.index'),
    OpenApiRouteBinding('GET', '/{id}', 'PostController.show'),
    OpenApiRouteBinding('GET', '/{id}/summary', 'PostController.summary'),
    OpenApiRouteBinding(
      'GET',
      '/{postId}/comments/{commentId}',
      'PostController.showComment',
    ),
    OpenApiRouteBinding('POST', '/', 'PostController.store'),
    OpenApiRouteBinding('PUT', '/{id}', 'PostController.update'),
    OpenApiRouteBinding('DELETE', '/{id}', 'PostController.destroy'),
    OpenApiRouteBinding('POST', '/{id}/comments', 'PostController.addComment'),
    OpenApiRouteBinding('GET', '/', 'TagController.index'),
    OpenApiRouteBinding('POST', '/', 'TagController.store'),
    OpenApiRouteBinding('GET', '/{name}/posts', 'TagController.posts'),
    OpenApiRouteBinding('POST', '/', 'FileController.upload'),
    OpenApiRouteBinding('GET', '/{name}', 'FileController.download'),
    OpenApiRouteBinding('GET', '/{name}/raw', 'FileController.raw'),
    OpenApiRouteBinding('PUT', '/{store}/items/{key}', 'CacheController.put'),
    OpenApiRouteBinding('GET', '/{store}/items/{key}', 'CacheController.get'),
    OpenApiRouteBinding(
      'DELETE',
      '/{store}/items/{key}',
      'CacheController.forget',
    ),
    OpenApiRouteBinding(
      'POST',
      '/{store}/remember/{key}',
      'CacheController.remember',
    ),
    OpenApiRouteBinding(
      'POST',
      '/{store}/increment/{key}',
      'CacheController.increment',
    ),
    OpenApiRouteBinding(
      'PUT',
      '/{store}/tags/{tag}/{key}',
      'CacheController.putTagged',
    ),
    OpenApiRouteBinding(
      'GET',
      '/{store}/tags/{tag}/{key}',
      'CacheController.getTagged',
    ),
    OpenApiRouteBinding(
      'DELETE',
      '/{store}/tags/{tag}',
      'CacheController.flushTag',
    ),
    OpenApiRouteBinding(
      'POST',
      '/{store}/locks/{name}',
      'CacheController.lock',
    ),
    OpenApiRouteBinding(
      'DELETE',
      '/{store}/locks/{name}',
      'CacheController.release',
    ),
    OpenApiRouteBinding('POST', '/{disk}', 'StorageController.upload'),
    OpenApiRouteBinding(
      'GET',
      '/{disk}/stream/{key*}',
      'StorageController.stream',
    ),
    OpenApiRouteBinding(
      'GET',
      '/{disk}/download/{key*}',
      'StorageController.download',
    ),
    OpenApiRouteBinding(
      'GET',
      '/{disk}/signed/{key*}',
      'StorageController.signed',
    ),
    OpenApiRouteBinding(
      'DELETE',
      '/{disk}/files/{key*}',
      'StorageController.delete',
    ),
    OpenApiRouteBinding('GET', '/query', 'SystemController.query'),
    OpenApiRouteBinding('POST', '/echo', 'SystemController.echo'),
    OpenApiRouteBinding('GET', '/env', 'SystemController.env'),
    OpenApiRouteBinding('POST', '/hash', 'SystemController.hash'),
    OpenApiRouteBinding('GET', '/cookie', 'SystemController.setCookie'),
    OpenApiRouteBinding('GET', '/cookie/read', 'SystemController.readCookie'),
    OpenApiRouteBinding('GET', '/teapot', 'SystemController.teapot'),
    OpenApiRouteBinding('GET', '/crash', 'SystemController.crash'),
    OpenApiRouteBinding('GET', '/container', 'SystemController.container'),
    OpenApiRouteBinding('GET', '/ip', 'SystemController.ip'),
    OpenApiRouteBinding('GET', '/twice/{n}', 'SystemController.twice'),
    OpenApiRouteBinding('GET', '/ping', 'SystemController.ping'),
    OpenApiRouteBinding('GET', '/playground', 'SystemController.playground'),
    OpenApiRouteBinding('GET', '/no-cors', 'SystemController.noCors'),
  ],
  schemas: <String, Map<String, dynamic>>{
    'Pagination': <String, dynamic>{
      'type': 'object',
      'properties': <String, dynamic>{
        'total': <String, dynamic>{'type': 'integer'},
        'per_page': <String, dynamic>{'type': 'integer'},
        'last_page': <String, dynamic>{'type': 'integer'},
        'current_page': <String, dynamic>{'type': 'integer'},
        'data': <String, dynamic>{
          'type': 'array',
          'items': <String, dynamic>{},
        },
      },
    },
    'User': <String, dynamic>{
      'type': 'object',
      'description': 'One row in the `users` table.',
      'properties': <String, dynamic>{
        'id': <String, dynamic>{'type': 'integer'},
        'name': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
        },
        'email': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
        },
        'first_name': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
        },
        'last_name': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
        },
        'profile': <String, dynamic>{
          'anyOf': <dynamic>[
            <String, dynamic>{'\$ref': '#/components/schemas/Profile'},
            <String, dynamic>{'type': 'null'},
          ],
        },
        'posts': <String, dynamic>{
          'type': 'array',
          'items': <String, dynamic>{'\$ref': '#/components/schemas/Post'},
        },
        'created_at': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
          'format': 'date-time',
        },
        'updated_at': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
          'format': 'date-time',
        },
        'full_name': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
        },
      },
    },
    'Profile': <String, dynamic>{
      'type': 'object',
      'description':
          'One row in the `profiles` table. Each user has one profile.',
      'properties': <String, dynamic>{
        'id': <String, dynamic>{'type': 'integer'},
        'user_id': <String, dynamic>{
          'type': <dynamic>['integer', 'null'],
        },
        'bio': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
        },
        'website': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
        },
        'user': <String, dynamic>{
          'anyOf': <dynamic>[
            <String, dynamic>{'\$ref': '#/components/schemas/User'},
            <String, dynamic>{'type': 'null'},
          ],
        },
        'created_at': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
          'format': 'date-time',
        },
        'updated_at': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
          'format': 'date-time',
        },
      },
    },
    'Post': <String, dynamic>{
      'type': 'object',
      'description':
          'One row in the `posts` table. Delete only sets `deleted_at`.',
      'properties': <String, dynamic>{
        'id': <String, dynamic>{'type': 'integer'},
        'user_id': <String, dynamic>{
          'type': <dynamic>['integer', 'null'],
        },
        'title': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
        },
        'body': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
        },
        'status': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
        },
        'deleted_at': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
          'format': 'date-time',
        },
        'author': <String, dynamic>{
          'anyOf': <dynamic>[
            <String, dynamic>{'\$ref': '#/components/schemas/User'},
            <String, dynamic>{'type': 'null'},
          ],
        },
        'comments': <String, dynamic>{
          'type': 'array',
          'items': <String, dynamic>{'\$ref': '#/components/schemas/Comment'},
        },
        'tags': <String, dynamic>{
          'type': 'array',
          'items': <String, dynamic>{'\$ref': '#/components/schemas/Tag'},
        },
        'created_at': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
          'format': 'date-time',
        },
        'updated_at': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
          'format': 'date-time',
        },
      },
    },
    'Comment': <String, dynamic>{
      'type': 'object',
      'description': 'One row in the `comments` table.',
      'properties': <String, dynamic>{
        'id': <String, dynamic>{'type': 'integer'},
        'post_id': <String, dynamic>{
          'type': <dynamic>['integer', 'null'],
        },
        'user_id': <String, dynamic>{
          'type': <dynamic>['integer', 'null'],
        },
        'body': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
        },
        'user': <String, dynamic>{
          'anyOf': <dynamic>[
            <String, dynamic>{'\$ref': '#/components/schemas/User'},
            <String, dynamic>{'type': 'null'},
          ],
        },
        'created_at': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
          'format': 'date-time',
        },
        'updated_at': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
          'format': 'date-time',
        },
      },
    },
    'Tag': <String, dynamic>{
      'type': 'object',
      'description': 'One row in the `tags` table.',
      'properties': <String, dynamic>{
        'id': <String, dynamic>{'type': 'integer'},
        'name': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
        },
        'posts': <String, dynamic>{
          'type': 'array',
          'items': <String, dynamic>{'\$ref': '#/components/schemas/Post'},
        },
        'created_at': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
          'format': 'date-time',
        },
        'updated_at': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
          'format': 'date-time',
        },
      },
    },
  },
);
