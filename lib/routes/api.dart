import 'package:dox_auth/dox_auth.dart';
import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/http/controllers/auth.controller.dart';
import 'package:dox_test/app/http/controllers/cache.controller.dart';
import 'package:dox_test/app/http/controllers/file.controller.dart';
import 'package:dox_test/app/http/controllers/post.controller.dart';
import 'package:dox_test/app/http/controllers/storage.controller.dart';
import 'package:dox_test/app/http/controllers/system.controller.dart';
import 'package:dox_test/app/http/controllers/tag.controller.dart';
import 'package:dox_test/app/http/controllers/user.controller.dart';
import 'package:dox_test/app/http/middleware/api_key.middleware.dart';

/// All routes here start with /api
class ApiRouter extends Router {
  @override
  String get prefix => 'api';

  @override
  void register() {
    Route.group('/auth', registerAuth);
    Route.group('/users', registerUsers);
    Route.group('/posts', registerPosts);
    Route.group('/tags', registerTags);
    Route.group('/files', registerFiles);
    Route.group('/system', registerSystem);
    Route.group('/cache', registerCache);
    Route.group('/storage', registerStorage);
  }

  void registerAuth() {
    Route.post<AuthController>('/register', (AuthController c) => c.register);
    Route.post<AuthController>('/login', (AuthController c) => c.login);
    Route.get<AuthController>('/me', <dynamic>[
      AuthMiddleware(),
      (AuthController c) => c.me,
    ]);
    Route.put<UserController>('/me/profile', <dynamic>[
      AuthMiddleware(),
      (UserController c) => c.saveProfile,
    ]);
    Route.patch<UserController>('/me/profile', <dynamic>[
      AuthMiddleware(),
      (UserController c) => c.patchProfile,
    ]);
  }

  void registerUsers() {
    Route.get<UserController>('/', (UserController c) => c.index);
    Route.get<UserController>('/{id}', (UserController c) => c.show);
    Route.put<UserController>('/{id}', <dynamic>[
      AuthMiddleware(),
      (UserController c) => c.update,
    ]);
  }

  void registerPosts() {
    // Fixed paths first, so `{id}` does not catch them.
    Route.get<PostController>('/trashed', (PostController c) => c.trashed);
    Route.get<PostController>('/stats', (PostController c) => c.stats);
    Route.get<PostController>('/', (PostController c) => c.index);
    Route.get<PostController>('/{id}', (PostController c) => c.show);
    Route.get<PostController>('/{id}/summary', (PostController c) => c.summary);
    Route.get<PostController>(
      '/{postId}/comments/{commentId}',
      (PostController c) => c.showComment,
    );
    Route.middleware(<dynamic>[AuthMiddleware()], registerPostWrites);
  }

  void registerPostWrites() {
    Route.post<PostController>('/', (PostController c) => c.store);
    Route.put<PostController>('/{id}', (PostController c) => c.update);
    Route.delete<PostController>('/{id}', (PostController c) => c.destroy);
    Route.post<PostController>(
      '/{id}/comments',
      (PostController c) => c.addComment,
    );
  }

  void registerTags() {
    Route.get<TagController>('/', (TagController c) => c.index);
    Route.post<TagController>('/', (TagController c) => c.store);
    Route.get<TagController>('/{name}/posts', (TagController c) => c.posts);
  }

  void registerFiles() {
    Route.post<FileController>('/', (FileController c) => c.upload);
    Route.post<FileController>('/avatar', (FileController c) => c.avatar);
    Route.get<FileController>('/{name}', (FileController c) => c.download);
    Route.get<FileController>('/{name}/raw', (FileController c) => c.raw);
  }

  /// {store} is memory, file or redis.
  void registerCache() {
    Route.put<CacheController>(
      '/{store}/items/{key}',
      (CacheController c) => c.put,
    );
    Route.get<CacheController>(
      '/{store}/items/{key}',
      (CacheController c) => c.get,
    );
    Route.delete<CacheController>(
      '/{store}/items/{key}',
      (CacheController c) => c.forget,
    );
    Route.post<CacheController>(
      '/{store}/remember/{key}',
      (CacheController c) => c.remember,
    );
    Route.post<CacheController>(
      '/{store}/increment/{key}',
      (CacheController c) => c.increment,
    );
    Route.put<CacheController>(
      '/{store}/tags/{tag}/{key}',
      (CacheController c) => c.putTagged,
    );
    Route.get<CacheController>(
      '/{store}/tags/{tag}/{key}',
      (CacheController c) => c.getTagged,
    );
    Route.delete<CacheController>(
      '/{store}/tags/{tag}',
      (CacheController c) => c.flushTag,
    );
    Route.post<CacheController>(
      '/{store}/locks/{name}',
      (CacheController c) => c.lock,
    );
    Route.delete<CacheController>(
      '/{store}/locks/{name}',
      (CacheController c) => c.release,
    );
  }

  /// {disk} is local, memory or s3. {key*} takes the rest of the path.
  void registerStorage() {
    Route.post<StorageController>('/{disk}', (StorageController c) => c.upload);
    Route.get<StorageController>(
      '/{disk}/stream/{key*}',
      (StorageController c) => c.stream,
    );
    Route.get<StorageController>(
      '/{disk}/download/{key*}',
      (StorageController c) => c.download,
    );
    Route.get<StorageController>(
      '/{disk}/signed/{key*}',
      (StorageController c) => c.signed,
    );
    Route.delete<StorageController>(
      '/{disk}/files/{key*}',
      (StorageController c) => c.delete,
    );
  }

  /// Every system route needs the API key header.
  void registerSystem() {
    Route.middleware(<dynamic>[ApiKeyMiddleware()], registerSystemRoutes);
  }

  void registerSystemRoutes() {
    Route.get<SystemController>('/query', (SystemController c) => c.query);
    Route.post<SystemController>('/echo', (SystemController c) => c.echo);
    Route.get<SystemController>('/env', (SystemController c) => c.env);
    Route.post<SystemController>('/hash', (SystemController c) => c.hash);
    Route.post<SystemController>('/orders', (SystemController c) => c.order);
    Route.get<SystemController>('/cookie', (SystemController c) => c.setCookie);
    Route.get<SystemController>(
      '/cookie/read',
      (SystemController c) => c.readCookie,
    );
    Route.get<SystemController>('/teapot', (SystemController c) => c.teapot);
    Route.get<SystemController>('/crash', (SystemController c) => c.crash);
    Route.get<SystemController>(
      '/container',
      (SystemController c) => c.container,
    );
    Route.get<SystemController>('/ip', (SystemController c) => c.ip);
    Route.get<SystemController>('/twice/{n}', (SystemController c) => c.twice);
  }
}
