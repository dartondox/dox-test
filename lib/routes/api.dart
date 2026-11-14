import 'package:dox_auth/dox_auth.dart';
import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/http/controllers/auth.controller.dart';
import 'package:dox_test/app/http/controllers/badge.controller.dart';
import 'package:dox_test/app/http/controllers/cache.controller.dart';
import 'package:dox_test/app/http/controllers/core.controller.dart';
import 'package:dox_test/app/http/controllers/file.controller.dart';
import 'package:dox_test/app/http/controllers/mail.controller.dart';
import 'package:dox_test/app/http/controllers/pdfme.controller.dart';
import 'package:dox_test/app/http/controllers/post.controller.dart';
import 'package:dox_test/app/http/controllers/storage.controller.dart';
import 'package:dox_test/app/http/controllers/system.controller.dart';
import 'package:dox_test/app/http/controllers/tag.controller.dart';
import 'package:dox_test/app/http/controllers/token.controller.dart';
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
    Route.group('/badges', registerBadges);
    Route.group('/files', registerFiles);
    Route.group('/system', registerSystem);
    Route.group('/cache', registerCache);
    Route.group('/storage', registerStorage);
    Route.group('/mail', registerMail);
    Route.group('/tokens', registerTokens);

    /// The pdfme playground page (/inertia/pdfme) posts here. It is under
    /// /api because it needs no session or CSRF token: it reads no cookie.
    Route.post('/pdfme/generate', (PdfmeController c) => c.generate);

    /// `{name?}` is optional: the docs show /api/greet and /api/greet/{name}.
    Route.get('/greet/{name?}', (CoreController c) => c.greet);
  }

  /// Access tokens (the `tokens` guard).
  void registerTokens() {
    Route.post('/login', (TokenController c) => c.tokenLogin);
    Route.middleware(<dynamic>[
      AuthMiddleware(guard: 'tokens'),
    ], registerTokenRoutes);
  }

  void registerTokenRoutes() {
    Route.post('/', (TokenController c) => c.store);
    Route.get('/', (TokenController c) => c.index);
    Route.get('/can/{ability}', (TokenController c) => c.can);
    Route.delete('/current', (TokenController c) => c.destroyCurrent);
    Route.delete('/{id}', (TokenController c) => c.destroy);
  }

  void registerAuth() {
    Route.post('/register', (AuthController c) => c.register);
    Route.post('/login', (AuthController c) => c.login);
    Route.get('/me', <dynamic>[AuthMiddleware(), (AuthController c) => c.me]);
    Route.post('/logout', <dynamic>[
      AuthMiddleware(),
      (AuthController c) => c.logout,
    ]);
    Route.put('/me/profile', <dynamic>[
      AuthMiddleware(),
      (UserController c) => c.saveProfile,
    ]);
    Route.patch('/me/profile', <dynamic>[
      AuthMiddleware(),
      (UserController c) => c.patchProfile,
    ]);
  }

  void registerUsers() {
    Route.get('/', (UserController c) => c.index);
    Route.get('/{id}', (UserController c) => c.show);
    Route.put('/{id}', <dynamic>[
      AuthMiddleware(),
      (UserController c) => c.update,
    ]);
  }

  void registerPosts() {
    // Fixed paths first, so `{id}` does not catch them.
    Route.get('/trashed', (PostController c) => c.trashed);
    Route.get('/stats', (PostController c) => c.stats);
    Route.get('/', (PostController c) => c.index);
    Route.get('/{id}', (PostController c) => c.show);
    Route.get('/{id}/summary', (PostController c) => c.summary);
    Route.post('/{id}/views', (PostController c) => c.addView);
    Route.get(
      '/{postId}/comments/{commentId}',
      (PostController c) => c.showComment,
    );
    Route.middleware(<dynamic>[AuthMiddleware()], registerPostWrites);
  }

  void registerPostWrites() {
    Route.post('/', (PostController c) => c.store);
    Route.put('/{id}', (PostController c) => c.update);
    Route.delete('/{id}', (PostController c) => c.destroy);
    Route.post('/{id}/comments', (PostController c) => c.addComment);
  }

  void registerTags() {
    Route.get('/', (TagController c) => c.index);
    Route.post('/', (TagController c) => c.store);
    Route.get('/{name}/posts', (TagController c) => c.posts);
  }

  void registerBadges() {
    // Fixed paths first, so `{id}` does not catch them.
    Route.get('/simple', (BadgeController c) => c.simple);
    Route.get('/trashed', (BadgeController c) => c.trashed);
    Route.get('/reactions', (BadgeController c) => c.reactions);
    Route.get('/', (BadgeController c) => c.index);
    Route.post('/', (BadgeController c) => c.store);
    Route.get('/{id}', (BadgeController c) => c.show);
    Route.delete('/{id}', (BadgeController c) => c.destroy);
    Route.post('/{id}/restore', (BadgeController c) => c.restore);
    Route.put('/{id}/posts', (BadgeController c) => c.syncPosts);
    Route.post('/{id}/reactions', (BadgeController c) => c.react);
  }

  void registerFiles() {
    Route.post('/', (FileController c) => c.upload);
    Route.post('/avatar', (FileController c) => c.avatar);
    Route.post('/photo', (FileController c) => c.photo);
    Route.get('/{name}', (FileController c) => c.download);
    Route.get('/{name}/raw', (FileController c) => c.raw);
  }

  /// {store} is memory, file or redis.
  void registerCache() {
    Route.put('/{store}/items/{key}', (CacheController c) => c.put);
    Route.get('/{store}/items/{key}', (CacheController c) => c.get);
    Route.delete('/{store}/items/{key}', (CacheController c) => c.forget);
    Route.post('/{store}/remember/{key}', (CacheController c) => c.remember);
    Route.post('/{store}/increment/{key}', (CacheController c) => c.increment);
    Route.put('/{store}/tags/{tag}/{key}', (CacheController c) => c.putTagged);
    Route.get('/{store}/tags/{tag}/{key}', (CacheController c) => c.getTagged);
    Route.delete('/{store}/tags/{tag}', (CacheController c) => c.flushTag);
    Route.post('/{store}/locks/{name}', (CacheController c) => c.lock);
    Route.delete('/{store}/locks/{name}', (CacheController c) => c.release);
  }

  /// {disk} is local, memory or s3. {key*} takes the rest of the path.
  void registerStorage() {
    Route.post('/{disk}', (StorageController c) => c.upload);
    Route.get('/{disk}/stream/{key*}', (StorageController c) => c.stream);
    Route.get('/{disk}/download/{key*}', (StorageController c) => c.download);
    Route.get('/{disk}/signed/{key*}', (StorageController c) => c.signed);
    Route.delete('/{disk}/files/{key*}', (StorageController c) => c.delete);
    Route.post('/{disk}/text/{key*}', (StorageController c) => c.addText);
    Route.get('/{disk}/info/{key*}', (StorageController c) => c.info);
    Route.post('/{disk}/dirs/{key*}', (StorageController c) => c.makeDirectory);
  }

  /// Sends real email, so it needs the API key header.
  void registerMail() {
    Route.middleware(<dynamic>[ApiKeyMiddleware()], registerMailRoutes);
  }

  void registerMailRoutes() {
    Route.post('/welcome/{id}', (MailController c) => c.welcome);
    Route.post('/account-ready/{id}', (MailController c) => c.accountReady);
  }

  /// Every system route needs the API key header.
  void registerSystem() {
    Route.middleware(<dynamic>[ApiKeyMiddleware()], registerSystemRoutes);
  }

  void registerSystemRoutes() {
    Route.get('/query', (SystemController c) => c.query);
    Route.post('/echo', (SystemController c) => c.echo);
    Route.get('/env', (SystemController c) => c.env);
    Route.post('/hash', (SystemController c) => c.hash);
    Route.post('/orders', (SystemController c) => c.order);
    Route.get('/cookie', (SystemController c) => c.setCookie);
    Route.get('/cookie/read', (SystemController c) => c.readCookie);
    Route.get('/teapot', (SystemController c) => c.teapot);
    Route.get('/crash', (SystemController c) => c.crash);
    Route.get('/container', (SystemController c) => c.container);
    Route.get('/ip', (SystemController c) => c.ip);
    Route.get('/twice/{n}', (SystemController c) => c.twice);
    Route.post('/rules', (SystemController c) => c.rules);
    Route.post('/rules/fluent', (SystemController c) => c.fluentRules);
  }
}
