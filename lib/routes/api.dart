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

  IocContainer get ioc => Dox().ioc;

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
    AuthController auth = ioc.get<AuthController>();
    Route.post('/register', auth.register);
    Route.post('/login', auth.login);
    Route.get('/me', <dynamic>[AuthMiddleware(), auth.me]);
    Route.put('/me/profile', <dynamic>[
      AuthMiddleware(),
      ioc.get<UserController>().saveProfile,
    ]);
  }

  void registerUsers() {
    UserController users = ioc.get<UserController>();
    Route.get('/', users.index);
    Route.get('/{id}', users.show);
  }

  void registerPosts() {
    PostController posts = ioc.get<PostController>();
    // Fixed paths first, so `{id}` does not catch them.
    Route.get('/trashed', posts.trashed);
    Route.get('/stats', posts.stats);
    Route.get('/', posts.index);
    Route.get('/{id}', posts.show);
    Route.get('/{id}/summary', posts.summary);
    Route.get('/{postId}/comments/{commentId}', posts.showComment);
    Route.middleware(<dynamic>[AuthMiddleware()], registerPostWrites);
  }

  void registerPostWrites() {
    PostController posts = ioc.get<PostController>();
    Route.post('/', posts.store);
    Route.put('/{id}', posts.update);
    Route.delete('/{id}', posts.destroy);
    Route.post('/{id}/comments', posts.addComment);
  }

  void registerTags() {
    TagController tags = ioc.get<TagController>();
    Route.get('/', tags.index);
    Route.post('/', tags.store);
    Route.get('/{name}/posts', tags.posts);
  }

  void registerFiles() {
    FileController files = ioc.get<FileController>();
    Route.post('/', files.upload);
    Route.get('/{name}', files.download);
    Route.get('/{name}/raw', files.raw);
  }

  /// {store} is memory, file or redis.
  void registerCache() {
    CacheController cache = ioc.get<CacheController>();
    Route.put('/{store}/items/{key}', cache.put);
    Route.get('/{store}/items/{key}', cache.get);
    Route.delete('/{store}/items/{key}', cache.forget);
    Route.post('/{store}/remember/{key}', cache.remember);
    Route.post('/{store}/increment/{key}', cache.increment);
    Route.put('/{store}/tags/{tag}/{key}', cache.putTagged);
    Route.get('/{store}/tags/{tag}/{key}', cache.getTagged);
    Route.delete('/{store}/tags/{tag}', cache.flushTag);
    Route.post('/{store}/locks/{name}', cache.lock);
    Route.delete('/{store}/locks/{name}', cache.release);
  }

  /// {disk} is local, memory or s3. {key*} takes the rest of the path.
  void registerStorage() {
    StorageController storage = ioc.get<StorageController>();
    Route.post('/{disk}', storage.upload);
    Route.get('/{disk}/stream/{key*}', storage.stream);
    Route.get('/{disk}/download/{key*}', storage.download);
    Route.get('/{disk}/signed/{key*}', storage.signed);
    Route.delete('/{disk}/files/{key*}', storage.delete);
  }

  /// Every system route needs the API key header.
  void registerSystem() {
    Route.middleware(<dynamic>[ApiKeyMiddleware()], registerSystemRoutes);
  }

  void registerSystemRoutes() {
    SystemController system = ioc.get<SystemController>();
    Route.get('/query', system.query);
    Route.post('/echo', system.echo);
    Route.get('/env', system.env);
    Route.post('/hash', system.hash);
    Route.get('/cookie', system.setCookie);
    Route.get('/cookie/read', system.readCookie);
    Route.get('/teapot', system.teapot);
    Route.get('/crash', system.crash);
    Route.get('/container', system.container);
    Route.get('/ip', system.ip);
    Route.get('/twice/{n}', system.twice);
  }
}
