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
      argumentTypes: <String>['RegisterUser'],
      summary: 'Register a user',
      description: 'The email is saved in lower case.',
      tags: <String>['Auth'],
      schema: <String, dynamic>{'\$ref': '#/components/schemas/RegisterUser'},
      responses: <int, ResponseDoc>{
        200: ResponseDoc(description: 'Successful response'),
      },
    ),
    OpenApiOperation(
      controller: 'AuthController',
      method: 'login',
      argumentTypes: <String>['LoginUser'],
      summary: 'Log in',
      description: 'Gives a JWT. Send it as `Authorization: Bearer <token>`.',
      tags: <String>['Auth'],
      schema: <String, dynamic>{'\$ref': '#/components/schemas/LoginUser'},
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
      argumentTypes: <String>['ListUsers'],
      summary: 'List users',
      description: 'Search by name or email, one page at a time.',
      tags: <String>['User'],
      schema: <String, dynamic>{'\$ref': '#/components/schemas/ListUsers'},
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
      argumentTypes: <String>['int'],
      summary: 'Get one user',
      tags: <String>['User'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'integer'},
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
      method: 'update',
      argumentTypes: <String>['DoxRequest', 'int', 'UpdateUser'],
      summary: 'Update a user (needs token, only yourself)',
      tags: <String>['User'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'integer'},
      ],
      schema: <String, dynamic>{'\$ref': '#/components/schemas/UpdateUser'},
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
      argumentTypes: <String>['DoxRequest', 'SaveProfile'],
      summary: 'Save the profile (needs token)',
      tags: <String>['User'],
      schema: <String, dynamic>{'\$ref': '#/components/schemas/SaveProfile'},
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{'\$ref': '#/components/schemas/Profile'},
        ),
      },
    ),
    OpenApiOperation(
      controller: 'UserController',
      method: 'patchProfile',
      argumentTypes: <String>['DoxRequest', 'PatchProfile'],
      summary: 'Change part of the profile (needs token)',
      description: 'A missing key keeps the old value. `null` clears it.',
      tags: <String>['User'],
      schema: <String, dynamic>{'\$ref': '#/components/schemas/PatchProfile'},
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
      argumentTypes: <String>['ListPosts'],
      summary: 'List posts',
      description: 'Newest first. Filter by status and author.',
      tags: <String>['Post'],
      schema: <String, dynamic>{'\$ref': '#/components/schemas/ListPosts'},
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
      argumentTypes: <String>['int'],
      summary: 'Get one post',
      tags: <String>['Post'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'integer'},
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
      argumentTypes: <String>['int'],
      summary: 'Get one post, short form (serializer)',
      tags: <String>['Post'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'integer'},
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
      argumentTypes: <String>['DoxRequest', 'SavePost'],
      summary: 'Create a post (needs token)',
      tags: <String>['Post'],
      schema: <String, dynamic>{'\$ref': '#/components/schemas/SavePost'},
      responses: <int, ResponseDoc>{
        200: ResponseDoc(description: 'Successful response'),
      },
    ),
    OpenApiOperation(
      controller: 'PostController',
      method: 'update',
      argumentTypes: <String>['DoxRequest', 'int', 'SavePost'],
      summary: 'Update a post (needs token, only the owner)',
      tags: <String>['Post'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'integer'},
      ],
      schema: <String, dynamic>{'\$ref': '#/components/schemas/SavePost'},
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
      argumentTypes: <String>['DoxRequest', 'int'],
      summary: 'Delete a post (needs token, only the owner)',
      tags: <String>['Post'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'integer'},
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
      method: 'addView',
      argumentTypes: <String>['int'],
      summary: 'Count a view of a post',
      description: 'Adds 1 to `views` with `post.increment(\'views\')`.',
      tags: <String>['Post'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'integer'},
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
      method: 'trashed',
      argumentTypes: <String>[],
      summary: 'Deleted posts',
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
      argumentTypes: <String>[],
      summary: 'Post stats (cached)',
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
      argumentTypes: <String>['DoxRequest', 'int', 'AddComment'],
      summary: 'Add a comment (needs token)',
      tags: <String>['Post'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'integer'},
      ],
      schema: <String, dynamic>{'\$ref': '#/components/schemas/AddComment'},
      responses: <int, ResponseDoc>{
        200: ResponseDoc(description: 'Successful response'),
      },
    ),
    OpenApiOperation(
      controller: 'PostController',
      method: 'showComment',
      argumentTypes: <String>['int', 'int'],
      summary: 'Get one comment of a post',
      tags: <String>['Post'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'integer'},
        <String, dynamic>{'type': 'integer'},
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
      argumentTypes: <String>['ListTags'],
      summary: 'List tags (lower case annotation)',
      description: '`except=a,b` leaves those names out (whereNotIn).',
      tags: <String>['Tag'],
      schema: <String, dynamic>{'\$ref': '#/components/schemas/ListTags'},
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
      argumentTypes: <String>['CreateTags'],
      summary: 'Create tags in a transaction',
      description:
          'With `fail: true` the transaction rolls back and nothing is saved.',
      tags: <String>['Tag', 'ORM'],
      schema: <String, dynamic>{'\$ref': '#/components/schemas/CreateTags'},
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
      argumentTypes: <String>['String'],
      summary: 'Get a tag with its posts',
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
      argumentTypes: <String>['DoxRequest', 'UploadFile'],
      summary: 'Upload a file with a note (form data)',
      tags: <String>['File'],
      schema: <String, dynamic>{'\$ref': '#/components/schemas/UploadFile'},
      responses: <int, ResponseDoc>{
        200: ResponseDoc(description: 'Successful response'),
      },
    ),
    OpenApiOperation(
      controller: 'FileController',
      method: 'avatar',
      argumentTypes: <String>['UploadAvatar'],
      summary: 'Upload an avatar image (form data, 64 KB at most)',
      tags: <String>['File'],
      schema: <String, dynamic>{'\$ref': '#/components/schemas/UploadAvatar'},
      responses: <int, ResponseDoc>{
        200: ResponseDoc(description: 'Successful response'),
      },
    ),
    OpenApiOperation(
      controller: 'FileController',
      method: 'download',
      argumentTypes: <String>['String'],
      summary: 'Download an upload (streamed)',
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
      argumentTypes: <String>['String'],
      summary: 'An upload as a File (Range gives 206 Partial Content)',
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
      argumentTypes: <String>['String', 'String', 'PutCacheItem'],
      summary: 'Put a value',
      description: 'Body: `{"value": any JSON, "ttl": seconds (optional)}`.',
      tags: <String>['Cache'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'string'},
        <String, dynamic>{'type': 'string'},
      ],
      schema: <String, dynamic>{'\$ref': '#/components/schemas/PutCacheItem'},
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
      argumentTypes: <String>['String', 'String'],
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
      argumentTypes: <String>['String', 'String'],
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
      argumentTypes: <String>['String', 'String'],
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
      argumentTypes: <String>['String', 'String', 'IncrementCache'],
      summary: 'Increment a number (body `{"by": 1}`)',
      tags: <String>['Cache'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'string'},
        <String, dynamic>{'type': 'string'},
      ],
      schema: <String, dynamic>{'\$ref': '#/components/schemas/IncrementCache'},
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
      argumentTypes: <String>['String', 'String', 'String', 'PutCacheItem'],
      summary: 'Put a tagged value',
      tags: <String>['Cache'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'string'},
        <String, dynamic>{'type': 'string'},
        <String, dynamic>{'type': 'string'},
      ],
      schema: <String, dynamic>{'\$ref': '#/components/schemas/PutCacheItem'},
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
      argumentTypes: <String>['String', 'String', 'String'],
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
      argumentTypes: <String>['String', 'String'],
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
      argumentTypes: <String>['String', 'String', 'TakeLock'],
      summary: 'Take a lock (memory and redis only)',
      tags: <String>['Cache'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'string'},
        <String, dynamic>{'type': 'string'},
      ],
      schema: <String, dynamic>{'\$ref': '#/components/schemas/TakeLock'},
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
      argumentTypes: <String>['String', 'String', 'ReleaseLock'],
      summary: 'Release a lock (`?owner=` from the lock call)',
      tags: <String>['Cache'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'string'},
        <String, dynamic>{'type': 'string'},
      ],
      schema: <String, dynamic>{'\$ref': '#/components/schemas/ReleaseLock'},
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
      argumentTypes: <String>['String', 'StoreFile'],
      summary: 'Upload a file (form-data field `file`)',
      tags: <String>['Storage'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'string'},
      ],
      schema: <String, dynamic>{'\$ref': '#/components/schemas/StoreFile'},
      responses: <int, ResponseDoc>{
        200: ResponseDoc(description: 'Successful response'),
      },
    ),
    OpenApiOperation(
      controller: 'StorageController',
      method: 'stream',
      argumentTypes: <String>['String', 'String'],
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
      argumentTypes: <String>['String', 'String'],
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
      argumentTypes: <String>['String', 'String'],
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
      argumentTypes: <String>['String', 'String'],
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
      ignore: true,
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
      argumentTypes: <String>['HashPassword'],
      summary: 'POST /api/system/hash',
      tags: <String>['System'],
      schema: <String, dynamic>{'\$ref': '#/components/schemas/HashPassword'},
      responses: <int, ResponseDoc>{
        200: ResponseDoc(
          description: 'Successful response',
          schema: <String, dynamic>{'type': 'object'},
        ),
      },
    ),
    OpenApiOperation(
      controller: 'SystemController',
      method: 'order',
      argumentTypes: <String>['CreateOrder'],
      summary: 'POST /api/system/orders (nested DTO and a list of DTOs)',
      tags: <String>['System'],
      schema: <String, dynamic>{'\$ref': '#/components/schemas/CreateOrder'},
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
      argumentTypes: <String>['int'],
      summary: 'GET /api/system/twice/{n} (`abc` is not an int, so 404)',
      tags: <String>['System'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'integer'},
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
      ignore: true,
    ),
    OpenApiOperation(
      controller: 'InertiaController',
      method: 'home',
      argumentTypes: <String>['DoxRequest'],
      ignore: true,
    ),
    OpenApiOperation(
      controller: 'InertiaController',
      method: 'index',
      argumentTypes: <String>['DoxRequest'],
      ignore: true,
    ),
    OpenApiOperation(
      controller: 'InertiaController',
      method: 'store',
      argumentTypes: <String>['DoxRequest'],
      ignore: true,
    ),
    OpenApiOperation(
      controller: 'InertiaController',
      method: 'destroy',
      argumentTypes: <String>['DoxRequest', 'int'],
      ignore: true,
    ),
    OpenApiOperation(
      controller: 'WebAuthController',
      method: 'sessionLogin',
      argumentTypes: <String>['DoxRequest', 'LoginUser'],
      ignore: true,
    ),
    OpenApiOperation(
      controller: 'WebAuthController',
      method: 'sessionUser',
      argumentTypes: <String>['DoxRequest'],
      ignore: true,
    ),
    OpenApiOperation(
      controller: 'WebAuthController',
      method: 'sessionLogout',
      argumentTypes: <String>['DoxRequest'],
      ignore: true,
    ),
    OpenApiOperation(
      controller: 'WebAuthController',
      method: 'loginPage',
      argumentTypes: <String>['DoxRequest'],
      ignore: true,
    ),
    OpenApiOperation(
      controller: 'WebAuthController',
      method: 'loginForm',
      argumentTypes: <String>['DoxRequest', 'LoginUser'],
      ignore: true,
    ),
    OpenApiOperation(
      controller: 'WebAuthController',
      method: 'dashboard',
      argumentTypes: <String>['DoxRequest'],
      ignore: true,
    ),
    OpenApiOperation(
      controller: 'WebAuthController',
      method: 'logoutForm',
      argumentTypes: <String>['DoxRequest'],
      ignore: true,
    ),
    OpenApiOperation(
      controller: 'ViewController',
      method: 'index',
      argumentTypes: <String>['DoxRequest'],
      ignore: true,
    ),
    OpenApiOperation(
      controller: 'ViewController',
      method: 'store',
      argumentTypes: <String>['DoxRequest'],
      ignore: true,
    ),
    OpenApiOperation(
      controller: 'WebRouter',
      method: 'register',
      argumentTypes: <String>[],
      tags: <String>['WebRouter'],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(description: 'Successful response'),
      },
    ),
    OpenApiOperation(
      controller: 'WebRouter',
      method: 'buildFile',
      argumentTypes: <String>['String'],
      summary: 'The file names have a hash, so the browser can keep them for a year.',
      tags: <String>['WebRouter'],
      params: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'string'},
      ],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(description: 'Successful response'),
      },
    ),
    OpenApiOperation(
      controller: 'WebRouter',
      method: 'registerWebAuth',
      argumentTypes: <String>[],
      tags: <String>['WebRouter'],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(description: 'Successful response'),
      },
    ),
    OpenApiOperation(
      controller: 'WebRouter',
      method: 'registerNoCors',
      argumentTypes: <String>[],
      tags: <String>['WebRouter'],
      responses: <int, ResponseDoc>{
        200: ResponseDoc(description: 'Successful response'),
      },
    ),
  ],
  routes: <OpenApiRouteBinding>[
    OpenApiRouteBinding('POST', 'api/auth/register', 'AuthController.register'),
    OpenApiRouteBinding('POST', 'api/auth/login', 'AuthController.login'),
    OpenApiRouteBinding('GET', 'api/auth/me', 'AuthController.me'),
    OpenApiRouteBinding(
      'PUT',
      'api/auth/me/profile',
      'UserController.saveProfile',
    ),
    OpenApiRouteBinding(
      'PATCH',
      'api/auth/me/profile',
      'UserController.patchProfile',
    ),
    OpenApiRouteBinding('GET', 'api/users/', 'UserController.index'),
    OpenApiRouteBinding('GET', 'api/users/{id}', 'UserController.show'),
    OpenApiRouteBinding('PUT', 'api/users/{id}', 'UserController.update'),
    OpenApiRouteBinding('GET', 'api/posts/trashed', 'PostController.trashed'),
    OpenApiRouteBinding('GET', 'api/posts/stats', 'PostController.stats'),
    OpenApiRouteBinding('GET', 'api/posts/', 'PostController.index'),
    OpenApiRouteBinding('GET', 'api/posts/{id}', 'PostController.show'),
    OpenApiRouteBinding(
      'GET',
      'api/posts/{id}/summary',
      'PostController.summary',
    ),
    OpenApiRouteBinding(
      'POST',
      'api/posts/{id}/views',
      'PostController.addView',
    ),
    OpenApiRouteBinding(
      'GET',
      'api/posts/{postId}/comments/{commentId}',
      'PostController.showComment',
    ),
    OpenApiRouteBinding('GET', 'api/tags/', 'TagController.index'),
    OpenApiRouteBinding('POST', 'api/tags/', 'TagController.store'),
    OpenApiRouteBinding('GET', 'api/tags/{name}/posts', 'TagController.posts'),
    OpenApiRouteBinding('POST', 'api/files/', 'FileController.upload'),
    OpenApiRouteBinding('POST', 'api/files/avatar', 'FileController.avatar'),
    OpenApiRouteBinding('GET', 'api/files/{name}', 'FileController.download'),
    OpenApiRouteBinding('GET', 'api/files/{name}/raw', 'FileController.raw'),
    OpenApiRouteBinding(
      'PUT',
      'api/cache/{store}/items/{key}',
      'CacheController.put',
    ),
    OpenApiRouteBinding(
      'GET',
      'api/cache/{store}/items/{key}',
      'CacheController.get',
    ),
    OpenApiRouteBinding(
      'DELETE',
      'api/cache/{store}/items/{key}',
      'CacheController.forget',
    ),
    OpenApiRouteBinding(
      'POST',
      'api/cache/{store}/remember/{key}',
      'CacheController.remember',
    ),
    OpenApiRouteBinding(
      'POST',
      'api/cache/{store}/increment/{key}',
      'CacheController.increment',
    ),
    OpenApiRouteBinding(
      'PUT',
      'api/cache/{store}/tags/{tag}/{key}',
      'CacheController.putTagged',
    ),
    OpenApiRouteBinding(
      'GET',
      'api/cache/{store}/tags/{tag}/{key}',
      'CacheController.getTagged',
    ),
    OpenApiRouteBinding(
      'DELETE',
      'api/cache/{store}/tags/{tag}',
      'CacheController.flushTag',
    ),
    OpenApiRouteBinding(
      'POST',
      'api/cache/{store}/locks/{name}',
      'CacheController.lock',
    ),
    OpenApiRouteBinding(
      'DELETE',
      'api/cache/{store}/locks/{name}',
      'CacheController.release',
    ),
    OpenApiRouteBinding(
      'POST',
      'api/storage/{disk}',
      'StorageController.upload',
    ),
    OpenApiRouteBinding(
      'GET',
      'api/storage/{disk}/stream/{key*}',
      'StorageController.stream',
    ),
    OpenApiRouteBinding(
      'GET',
      'api/storage/{disk}/download/{key*}',
      'StorageController.download',
    ),
    OpenApiRouteBinding(
      'GET',
      'api/storage/{disk}/signed/{key*}',
      'StorageController.signed',
    ),
    OpenApiRouteBinding(
      'DELETE',
      'api/storage/{disk}/files/{key*}',
      'StorageController.delete',
    ),
    OpenApiRouteBinding('POST', 'api/', 'PostController.store'),
    OpenApiRouteBinding('PUT', 'api/{id}', 'PostController.update'),
    OpenApiRouteBinding('DELETE', 'api/{id}', 'PostController.destroy'),
    OpenApiRouteBinding(
      'POST',
      'api/{id}/comments',
      'PostController.addComment',
    ),
    OpenApiRouteBinding('GET', 'api/query', 'SystemController.query'),
    OpenApiRouteBinding('POST', 'api/echo', 'SystemController.echo'),
    OpenApiRouteBinding('GET', 'api/env', 'SystemController.env'),
    OpenApiRouteBinding('POST', 'api/hash', 'SystemController.hash'),
    OpenApiRouteBinding('POST', 'api/orders', 'SystemController.order'),
    OpenApiRouteBinding('GET', 'api/cookie', 'SystemController.setCookie'),
    OpenApiRouteBinding(
      'GET',
      'api/cookie/read',
      'SystemController.readCookie',
    ),
    OpenApiRouteBinding('GET', 'api/teapot', 'SystemController.teapot'),
    OpenApiRouteBinding('GET', 'api/crash', 'SystemController.crash'),
    OpenApiRouteBinding('GET', 'api/container', 'SystemController.container'),
    OpenApiRouteBinding('GET', 'api/ip', 'SystemController.ip'),
    OpenApiRouteBinding('GET', 'api/twice/{n}', 'SystemController.twice'),
    OpenApiRouteBinding('GET', 'inertia/', 'InertiaController.home'),
    OpenApiRouteBinding('GET', 'inertia/notes', 'InertiaController.index'),
    OpenApiRouteBinding('POST', 'inertia/notes', 'InertiaController.store'),
    OpenApiRouteBinding(
      'DELETE',
      'inertia/notes/{id}',
      'InertiaController.destroy',
    ),
    OpenApiRouteBinding('GET', 'inertia/login', 'WebAuthController.loginPage'),
    OpenApiRouteBinding('POST', 'inertia/login', 'WebAuthController.loginForm'),
    OpenApiRouteBinding(
      'GET',
      'inertia/dashboard',
      'WebAuthController.dashboard',
    ),
    OpenApiRouteBinding(
      'POST',
      'inertia/logout',
      'WebAuthController.logoutForm',
    ),
    OpenApiRouteBinding('GET', 'views/', 'ViewController.index'),
    OpenApiRouteBinding('POST', 'views/notes', 'ViewController.store'),
    OpenApiRouteBinding('GET', '/ping', 'SystemController.ping'),
    OpenApiRouteBinding('GET', '/playground', 'SystemController.playground'),
    OpenApiRouteBinding(
      'POST',
      '/web-auth/login',
      'WebAuthController.sessionLogin',
    ),
    OpenApiRouteBinding('GET', '/web-auth/me', 'WebAuthController.sessionUser'),
    OpenApiRouteBinding(
      'POST',
      '/web-auth/logout',
      'WebAuthController.sessionLogout',
    ),
    OpenApiRouteBinding('GET', '/build/{path*}', 'WebRouter.buildFile'),
    OpenApiRouteBinding('GET', '/no-cors', 'SystemController.noCors'),
  ],
  schemas: <String, Map<String, dynamic>>{
    'RegisterUser': <String, dynamic>{
      'type': 'object',
      'title': 'RegisterUser',
      'properties': <String, dynamic>{
        'name': <String, dynamic>{
          'type': 'string',
          'minLength': 2,
          'maxLength': 100,
        },
        'email': <String, dynamic>{'type': 'string', 'format': 'email'},
        'password': <String, dynamic>{'type': 'string', 'minLength': 6},
        'password_confirmation': <String, dynamic>{
          'type': 'string',
          'description': 'Must be the same as `password`.',
        },
        'first_name': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
          'maxLength': 100,
        },
        'last_name': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
          'maxLength': 100,
        },
      },
      'required': <dynamic>[
        'name',
        'email',
        'password',
        'password_confirmation',
      ],
    },
    'LoginUser': <String, dynamic>{
      'type': 'object',
      'title': 'LoginUser',
      'properties': <String, dynamic>{
        'email': <String, dynamic>{'type': 'string', 'format': 'email'},
        'password': <String, dynamic>{'type': 'string'},
      },
      'required': <dynamic>['email', 'password'],
    },
    'ListUsers': <String, dynamic>{
      'type': 'object',
      'title': 'ListUsers',
      'properties': <String, dynamic>{
        'page': <String, dynamic>{
          'type': 'integer',
          'minimum': 1,
          'default': 1,
        },
        'per_page': <String, dynamic>{
          'type': 'integer',
          'minimum': 1,
          'maximum': 100,
          'default': 10,
        },
        'search': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
          'description': 'Part of the name or the email.',
        },
      },
    },
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
        'views': <String, dynamic>{
          'type': <dynamic>['integer', 'null'],
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
    'UpdateUser': <String, dynamic>{
      'type': 'object',
      'title': 'UpdateUser',
      'properties': <String, dynamic>{
        'name': <String, dynamic>{
          'type': 'string',
          'minLength': 2,
          'maxLength': 100,
        },
        'email': <String, dynamic>{
          'type': 'string',
          'format': 'email',
          'description': 'Must be free, but the user may keep its own email.',
        },
      },
      'required': <dynamic>['name', 'email'],
    },
    'SaveProfile': <String, dynamic>{
      'type': 'object',
      'title': 'SaveProfile',
      'properties': <String, dynamic>{
        'bio': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
          'maxLength': 500,
        },
        'website': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
          'format': 'uri',
        },
      },
    },
    'PatchProfile': <String, dynamic>{
      'type': 'object',
      'title': 'PatchProfile',
      'properties': <String, dynamic>{
        'bio': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
          'maxLength': 500,
        },
        'website': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
          'format': 'uri',
        },
      },
    },
    'ListPosts': <String, dynamic>{
      'type': 'object',
      'title': 'ListPosts',
      'properties': <String, dynamic>{
        'page': <String, dynamic>{
          'type': 'integer',
          'minimum': 1,
          'default': 1,
        },
        'per_page': <String, dynamic>{
          'type': 'integer',
          'minimum': 1,
          'maximum': 100,
          'default': 10,
        },
        'status': <String, dynamic>{
          'type': 'array',
          'items': <String, dynamic>{
            'type': 'string',
            'enum': <dynamic>['draft', 'published'],
          },
          'uniqueItems': true,
          'description': '`status=draft&status=published`. Empty means all.',
          'default': <dynamic>[],
        },
        'author_id': <String, dynamic>{
          'type': <dynamic>['integer', 'null'],
          'description': 'Only posts of this user. The user must exist.',
        },
      },
    },
    'SavePost': <String, dynamic>{
      'type': 'object',
      'title': 'SavePost',
      'properties': <String, dynamic>{
        'title': <String, dynamic>{'type': 'string', 'maxLength': 255},
        'body': <String, dynamic>{'type': 'string'},
        'status': <String, dynamic>{
          'type': 'string',
          'enum': <dynamic>['draft', 'published'],
          'default': 'draft',
        },
        'tags': <String, dynamic>{
          'type': 'array',
          'items': <String, dynamic>{'type': 'string'},
          'maxItems': 5,
          'description': 'Tag names. Each one must be a slug.',
          'default': <dynamic>[],
        },
      },
      'required': <dynamic>['title', 'body'],
    },
    'AddComment': <String, dynamic>{
      'type': 'object',
      'title': 'AddComment',
      'properties': <String, dynamic>{
        'body': <String, dynamic>{'type': 'string', 'maxLength': 1000},
      },
      'required': <dynamic>['body'],
    },
    'ListTags': <String, dynamic>{
      'type': 'object',
      'title': 'ListTags',
      'properties': <String, dynamic>{
        'limit': <String, dynamic>{
          'type': 'integer',
          'minimum': 1,
          'maximum': 100,
          'default': 10,
        },
        'except': <String, dynamic>{
          'type': <dynamic>['string', 'null'],
          'description': '`alpha,beta` leaves those names out.',
        },
      },
    },
    'CreateTags': <String, dynamic>{
      'type': 'object',
      'title': 'CreateTags',
      'properties': <String, dynamic>{
        'names': <String, dynamic>{
          'type': 'array',
          'items': <String, dynamic>{
            'type': 'string',
            'minLength': 2,
            'maxLength': 100,
          },
          'minItems': 1,
          'maxItems': 10,
        },
        'fail': <String, dynamic>{
          'type': 'boolean',
          'description':
              '`true` throws inside the transaction, so nothing is saved.',
          'default': false,
        },
      },
      'required': <dynamic>['names'],
    },
    'UploadFile': <String, dynamic>{
      'type': 'object',
      'title': 'UploadFile',
      'properties': <String, dynamic>{
        'file': <String, dynamic>{
          'type': 'string',
          'format': 'binary',
          'maxLength': 1048576,
        },
        'note': <String, dynamic>{'type': 'string'},
      },
      'required': <dynamic>['file', 'note'],
    },
    'UploadAvatar': <String, dynamic>{
      'type': 'object',
      'title': 'UploadAvatar',
      'properties': <String, dynamic>{
        'avatar': <String, dynamic>{
          'type': 'string',
          'format': 'binary',
          'contentMediaType': 'image/*',
          'maxLength': 65536,
        },
      },
      'required': <dynamic>['avatar'],
    },
    'PutCacheItem': <String, dynamic>{
      'type': 'object',
      'title': 'PutCacheItem',
      'properties': <String, dynamic>{
        'value': <String, dynamic>{
          'anyOf': <dynamic>[
            <String, dynamic>{'description': 'Any JSON value. Not checked.'},
            <String, dynamic>{'type': 'null'},
          ],
        },
        'ttl': <String, dynamic>{
          'type': <dynamic>['integer', 'null'],
          'exclusiveMinimum': 0,
          'description': 'Seconds. Empty means forever.',
        },
      },
    },
    'IncrementCache': <String, dynamic>{
      'type': 'object',
      'title': 'IncrementCache',
      'properties': <String, dynamic>{
        'by': <String, dynamic>{'type': 'integer', 'default': 1},
      },
    },
    'TakeLock': <String, dynamic>{
      'type': 'object',
      'title': 'TakeLock',
      'properties': <String, dynamic>{
        'ttl': <String, dynamic>{
          'type': 'integer',
          'exclusiveMinimum': 0,
          'description': 'Seconds.',
          'default': 30,
        },
      },
    },
    'ReleaseLock': <String, dynamic>{
      'type': 'object',
      'title': 'ReleaseLock',
      'properties': <String, dynamic>{
        'owner': <String, dynamic>{
          'type': 'string',
          'description': 'The `owner` from the lock call.',
        },
      },
      'required': <dynamic>['owner'],
    },
    'StoreFile': <String, dynamic>{
      'type': 'object',
      'title': 'StoreFile',
      'properties': <String, dynamic>{
        'file': <String, dynamic>{'type': 'string', 'format': 'binary'},
      },
      'required': <dynamic>['file'],
    },
    'HashPassword': <String, dynamic>{
      'type': 'object',
      'title': 'HashPassword',
      'properties': <String, dynamic>{
        'password': <String, dynamic>{'type': 'string'},
      },
      'required': <dynamic>['password'],
    },
    'CreateOrder': <String, dynamic>{
      'type': 'object',
      'title': 'CreateOrder',
      'properties': <String, dynamic>{
        'address': <String, dynamic>{'\$ref': '#/components/schemas/Address'},
        'items': <String, dynamic>{
          'type': 'array',
          'items': <String, dynamic>{'\$ref': '#/components/schemas/OrderItem'},
          'minItems': 1,
          'maxItems': 10,
        },
      },
      'required': <dynamic>['address', 'items'],
      'additionalProperties': false,
    },
    'Address': <String, dynamic>{
      'type': 'object',
      'title': 'Address',
      'properties': <String, dynamic>{
        'city': <String, dynamic>{'type': 'string'},
        'post_code': <String, dynamic>{
          'type': 'string',
          'pattern': '^(?:\\d{5})\$',
          'description': 'Five digits.',
        },
      },
      'required': <dynamic>['city', 'post_code'],
    },
    'OrderItem': <String, dynamic>{
      'type': 'object',
      'title': 'OrderItem',
      'properties': <String, dynamic>{
        'name': <String, dynamic>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 50,
        },
        'quantity': <String, dynamic>{
          'type': 'integer',
          'minimum': 1,
          'maximum': 99,
        },
      },
      'required': <dynamic>['name', 'quantity'],
    },
  },
);
