// GENERATED CODE - DO NOT MODIFY BY HAND
// Made by dox_builder. Run `dart run build_runner build`.
// ignore_for_file: type=lint

import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/http/controllers/auth.controller.dart' as i1;
import 'package:dox_test/app/http/controllers/badge.controller.dart' as i2;
import 'package:dox_test/app/http/controllers/cache.controller.dart' as i3;
import 'package:dox_test/app/http/controllers/core.controller.dart' as i4;
import 'package:dox_test/app/http/controllers/file.controller.dart' as i5;
import 'package:dox_test/app/http/controllers/inertia.controller.dart' as i6;
import 'package:dox_test/app/http/controllers/mail.controller.dart' as i7;
import 'package:dox_test/app/http/controllers/post.controller.dart' as i8;
import 'package:dox_test/app/http/controllers/storage.controller.dart' as i9;
import 'package:dox_test/app/http/controllers/system.controller.dart' as i10;
import 'package:dox_test/app/http/controllers/tag.controller.dart' as i11;
import 'package:dox_test/app/http/controllers/token.controller.dart' as i12;
import 'package:dox_test/app/http/controllers/user.controller.dart' as i13;
import 'package:dox_test/app/http/controllers/view.controller.dart' as i14;
import 'package:dox_test/app/http/controllers/web_auth.controller.dart' as i15;
import 'package:dox_test/app/repositories/badge.repository.dart' as i16;
import 'package:dox_test/app/repositories/comment.repository.dart' as i17;
import 'package:dox_test/app/repositories/post.repository.dart' as i18;
import 'package:dox_test/app/repositories/tag.repository.dart' as i19;
import 'package:dox_test/app/repositories/user.repository.dart' as i20;
import 'package:dox_test/app/services/auth.service.dart' as i21;
import 'package:dox_test/app/services/badge.service.dart' as i22;
import 'package:dox_test/app/services/cache.service.dart' as i23;
import 'package:dox_test/app/services/file.service.dart' as i24;
import 'package:dox_test/app/services/mail.service.dart' as i25;
import 'package:dox_test/app/services/note.service.dart' as i26;
import 'package:dox_test/app/services/post.service.dart' as i27;
import 'package:dox_test/app/services/storage.service.dart' as i28;
import 'package:dox_test/app/services/system.service.dart' as i29;
import 'package:dox_test/app/services/tag.service.dart' as i30;
import 'package:dox_test/app/services/token.service.dart' as i31;
import 'package:dox_test/app/services/user.service.dart' as i32;
import 'package:dox_test/providers/auth_provider.dart' as i33;
import 'package:dox_test/providers/broadcast_provider.dart' as i34;
import 'package:dox_test/providers/cache_provider.dart' as i35;
import 'package:dox_test/providers/inertia_provider.dart' as i36;
import 'package:dox_test/providers/mail_provider.dart' as i37;
import 'package:dox_test/providers/orm_provider.dart' as i38;
import 'package:dox_test/providers/queue_provider.dart' as i39;
import 'package:dox_test/providers/schedule_provider.dart' as i40;
import 'package:dox_test/providers/socketio_provider.dart' as i41;
import 'package:dox_test/providers/storage_provider.dart' as i42;
import 'package:dox_test/providers/view_provider.dart' as i43;
import 'package:dox_test/routes/api.dart' as i44;
import 'package:dox_test/routes/broadcast.dart' as i45;
import 'package:dox_test/routes/core.dart' as i46;
import 'package:dox_test/routes/inertia.dart' as i47;
import 'package:dox_test/routes/views.dart' as i48;
import 'package:dox_test/routes/web.dart' as i49;
import 'package:dox_test/app/models/badge/badge.model.dart' as i50;
import 'package:dox_test/app/models/comment/comment.model.dart' as i51;
import 'package:dox_test/app/models/e2e310/e2e310.model.dart' as i52;
import 'package:dox_test/app/models/e2e310b/e2e310b.model.dart' as i53;
import 'package:dox_test/app/models/post/post.model.dart' as i54;
import 'package:dox_test/app/models/profile/profile.model.dart' as i55;
import 'package:dox_test/app/models/reaction/reaction.model.dart' as i56;
import 'package:dox_test/app/models/tag/tag.model.dart' as i57;
import 'package:dox_test/app/models/user/user.model.dart' as i58;

/// Puts every class of the app into the container: the
/// `@Inject()` classes, routers, providers and model binders.
/// Use it in `AppConfig(container: registerContainer)`.
void registerContainer(IocContainer c) {
  c.singleton<i1.AuthController>(
    (IocContainer c) => i1.AuthController(c.get<i21.AuthService>()),
  );
  c.singleton<i2.BadgeController>(
    (IocContainer c) => i2.BadgeController(c.get<i22.BadgeService>()),
  );
  c.singleton<i3.CacheController>(
    (IocContainer c) => i3.CacheController(c.get<i23.CacheService>()),
  );
  c.singleton<i4.CoreController>((IocContainer c) => i4.CoreController());
  c.singleton<i5.FileController>(
    (IocContainer c) => i5.FileController(c.get<i24.FileService>()),
  );
  c.singleton<i6.InertiaController>(
    (IocContainer c) => i6.InertiaController(c.get<i26.NoteService>()),
  );
  c.singleton<i7.MailController>(
    (IocContainer c) => i7.MailController(c.get<i25.MailService>()),
  );
  c.singleton<i8.PostController>(
    (IocContainer c) => i8.PostController(c.get<i27.PostService>()),
  );
  c.singleton<i9.StorageController>(
    (IocContainer c) => i9.StorageController(c.get<i28.FileStorageService>()),
  );
  c.singleton<i10.SystemController>(
    (IocContainer c) => i10.SystemController(c.get<i29.SystemService>()),
  );
  c.singleton<i11.TagController>(
    (IocContainer c) => i11.TagController(c.get<i30.TagService>()),
  );
  c.singleton<i12.TokenController>(
    (IocContainer c) => i12.TokenController(c.get<i31.TokenService>()),
  );
  c.singleton<i13.UserController>(
    (IocContainer c) => i13.UserController(c.get<i32.UserService>()),
  );
  c.singleton<i14.ViewController>(
    (IocContainer c) => i14.ViewController(c.get<i26.NoteService>()),
  );
  c.singleton<i15.WebAuthController>(
    (IocContainer c) => i15.WebAuthController(),
  );
  c.singleton<i16.BadgeRepository>((IocContainer c) => i16.BadgeRepository());
  c.singleton<i17.CommentRepository>(
    (IocContainer c) => i17.CommentRepository(),
  );
  c.singleton<i18.PostRepository>((IocContainer c) => i18.PostRepository());
  c.singleton<i19.TagRepository>((IocContainer c) => i19.TagRepository());
  c.singleton<i20.UserRepository>((IocContainer c) => i20.UserRepository());
  c.singleton<i21.AuthService>(
    (IocContainer c) => i21.AuthService(c.get<i20.UserRepository>()),
  );
  c.singleton<i22.BadgeService>(
    (IocContainer c) => i22.BadgeService(c.get<i16.BadgeRepository>()),
  );
  c.singleton<i23.CacheService>((IocContainer c) => i23.CacheService());
  c.singleton<i24.FileService>((IocContainer c) => i24.FileService());
  c.singleton<i25.MailService>(
    (IocContainer c) => i25.MailService(c.get<i20.UserRepository>()),
  );
  c.singleton<i26.NoteService>((IocContainer c) => i26.NoteService());
  c.singleton<i27.PostService>(
    (IocContainer c) => i27.PostService(
      c.get<i18.PostRepository>(),
      c.get<i19.TagRepository>(),
      c.get<i17.CommentRepository>(),
    ),
  );
  c.singleton<i28.FileStorageService>(
    (IocContainer c) => i28.FileStorageService(),
  );
  c.singleton<i29.SystemService>((IocContainer c) => i29.SystemService());
  c.singleton<i30.TagService>(
    (IocContainer c) => i30.TagService(c.get<i19.TagRepository>()),
  );
  c.singleton<i31.TokenService>((IocContainer c) => i31.TokenService());
  c.singleton<i32.UserService>(
    (IocContainer c) => i32.UserService(c.get<i20.UserRepository>()),
  );
  c.provider<i33.AppAuthProvider>((IocContainer c) => i33.AppAuthProvider());
  c.provider<i34.BroadcastProvider>(
    (IocContainer c) => i34.BroadcastProvider(),
  );
  c.provider<i35.AppCacheProvider>((IocContainer c) => i35.AppCacheProvider());
  c.provider<i36.AppInertiaProvider>(
    (IocContainer c) => i36.AppInertiaProvider(),
  );
  c.provider<i37.AppMailProvider>((IocContainer c) => i37.AppMailProvider());
  c.provider<i38.ORMProvider>((IocContainer c) => i38.ORMProvider());
  c.provider<i39.AppQueueProvider>((IocContainer c) => i39.AppQueueProvider());
  c.provider<i40.ScheduleProvider>((IocContainer c) => i40.ScheduleProvider());
  c.provider<i41.AppSocketIoProvider>(
    (IocContainer c) => i41.AppSocketIoProvider(),
  );
  c.provider<i42.AppStorageProvider>(
    (IocContainer c) => i42.AppStorageProvider(),
  );
  c.provider<i43.AppViewProvider>((IocContainer c) => i43.AppViewProvider());
  c.router<i44.ApiRouter>((IocContainer c) => i44.ApiRouter());
  c.router<i45.BroadcastRouter>((IocContainer c) => i45.BroadcastRouter());
  c.router<i46.CoreRouter>((IocContainer c) => i46.CoreRouter());
  c.router<i47.InertiaRouter>((IocContainer c) => i47.InertiaRouter());
  c.router<i48.ViewsRouter>((IocContainer c) => i48.ViewsRouter());
  c.router<i49.WebRouter>((IocContainer c) => i49.WebRouter());
  c.bindModel<i50.Badge>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i50.Badge().find(key);
  });
  c.bindModel<i51.Comment>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i51.Comment().find(key);
  });
  c.bindModel<i52.Oauth2Client>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i52.Oauth2Client().find(key);
  });
  c.bindModel<i52.E2eMember>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i52.E2eMember().find(key);
  });
  c.bindModel<i52.E2eShelf>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i52.E2eShelf().find(key);
  });
  c.bindModel<i52.E2eBook>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i52.E2eBook().find(key);
  });
  c.bindModel<i53.E310bItem>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i53.E310bItem().find(key);
  });
  c.bindModel<i53.E310bTag>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i53.E310bTag().find(key);
  });
  c.bindModel<i53.E310bNote>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i53.E310bNote().find(key);
  });
  c.bindModel<i54.Post>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i54.Post().find(key);
  });
  c.bindModel<i55.Profile>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i55.Profile().find(key);
  });
  c.bindModel<i56.Reaction>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i56.Reaction().find(key);
  });
  c.bindModel<i57.Tag>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i57.Tag().find(key);
  });
  c.bindModel<i58.User>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i58.User().find(key);
  });
}
