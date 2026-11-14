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
import 'package:dox_test/app/http/controllers/pdfme.controller.dart' as i8;
import 'package:dox_test/app/http/controllers/post.controller.dart' as i9;
import 'package:dox_test/app/http/controllers/storage.controller.dart' as i10;
import 'package:dox_test/app/http/controllers/system.controller.dart' as i11;
import 'package:dox_test/app/http/controllers/tag.controller.dart' as i12;
import 'package:dox_test/app/http/controllers/token.controller.dart' as i13;
import 'package:dox_test/app/http/controllers/user.controller.dart' as i14;
import 'package:dox_test/app/http/controllers/view.controller.dart' as i15;
import 'package:dox_test/app/http/controllers/web_auth.controller.dart' as i16;
import 'package:dox_test/app/repositories/badge.repository.dart' as i17;
import 'package:dox_test/app/repositories/comment.repository.dart' as i18;
import 'package:dox_test/app/repositories/post.repository.dart' as i19;
import 'package:dox_test/app/repositories/tag.repository.dart' as i20;
import 'package:dox_test/app/repositories/user.repository.dart' as i21;
import 'package:dox_test/app/services/auth.service.dart' as i22;
import 'package:dox_test/app/services/badge.service.dart' as i23;
import 'package:dox_test/app/services/cache.service.dart' as i24;
import 'package:dox_test/app/services/file.service.dart' as i25;
import 'package:dox_test/app/services/mail.service.dart' as i26;
import 'package:dox_test/app/services/note.service.dart' as i27;
import 'package:dox_test/app/services/pdfme.service.dart' as i28;
import 'package:dox_test/app/services/post.service.dart' as i29;
import 'package:dox_test/app/services/storage.service.dart' as i30;
import 'package:dox_test/app/services/system.service.dart' as i31;
import 'package:dox_test/app/services/tag.service.dart' as i32;
import 'package:dox_test/app/services/token.service.dart' as i33;
import 'package:dox_test/app/services/user.service.dart' as i34;
import 'package:dox_test/providers/auth_provider.dart' as i35;
import 'package:dox_test/providers/broadcast_provider.dart' as i36;
import 'package:dox_test/providers/cache_provider.dart' as i37;
import 'package:dox_test/providers/inertia_provider.dart' as i38;
import 'package:dox_test/providers/mail_provider.dart' as i39;
import 'package:dox_test/providers/orm_provider.dart' as i40;
import 'package:dox_test/providers/queue_provider.dart' as i41;
import 'package:dox_test/providers/schedule_provider.dart' as i42;
import 'package:dox_test/providers/socketio_provider.dart' as i43;
import 'package:dox_test/providers/storage_provider.dart' as i44;
import 'package:dox_test/providers/view_provider.dart' as i45;
import 'package:dox_test/routes/api.dart' as i46;
import 'package:dox_test/routes/broadcast.dart' as i47;
import 'package:dox_test/routes/core.dart' as i48;
import 'package:dox_test/routes/inertia.dart' as i49;
import 'package:dox_test/routes/views.dart' as i50;
import 'package:dox_test/routes/web.dart' as i51;
import 'package:dox_test/app/models/badge/badge.model.dart' as i52;
import 'package:dox_test/app/models/comment/comment.model.dart' as i53;
import 'package:dox_test/app/models/e2e310/e2e310.model.dart' as i54;
import 'package:dox_test/app/models/e2e310b/e2e310b.model.dart' as i55;
import 'package:dox_test/app/models/post/post.model.dart' as i56;
import 'package:dox_test/app/models/profile/profile.model.dart' as i57;
import 'package:dox_test/app/models/reaction/reaction.model.dart' as i58;
import 'package:dox_test/app/models/tag/tag.model.dart' as i59;
import 'package:dox_test/app/models/user/user.model.dart' as i60;

/// Puts every class of the app into the container: the
/// `@Inject()` classes, routers, providers and model binders.
/// Use it in `AppConfig(container: registerContainer)`.
void registerContainer(IocContainer c) {
  c.singleton<i1.AuthController>(
    (IocContainer c) => i1.AuthController(c.get<i22.AuthService>()),
  );
  c.singleton<i2.BadgeController>(
    (IocContainer c) => i2.BadgeController(c.get<i23.BadgeService>()),
  );
  c.singleton<i3.CacheController>(
    (IocContainer c) => i3.CacheController(c.get<i24.CacheService>()),
  );
  c.singleton<i4.CoreController>((IocContainer c) => i4.CoreController());
  c.singleton<i5.FileController>(
    (IocContainer c) => i5.FileController(c.get<i25.FileService>()),
  );
  c.singleton<i6.InertiaController>(
    (IocContainer c) => i6.InertiaController(c.get<i27.NoteService>()),
  );
  c.singleton<i7.MailController>(
    (IocContainer c) => i7.MailController(c.get<i26.MailService>()),
  );
  c.singleton<i8.PdfmeController>(
    (IocContainer c) => i8.PdfmeController(c.get<i28.PdfmeService>()),
  );
  c.singleton<i9.PostController>(
    (IocContainer c) => i9.PostController(c.get<i29.PostService>()),
  );
  c.singleton<i10.StorageController>(
    (IocContainer c) => i10.StorageController(c.get<i30.FileStorageService>()),
  );
  c.singleton<i11.SystemController>(
    (IocContainer c) => i11.SystemController(c.get<i31.SystemService>()),
  );
  c.singleton<i12.TagController>(
    (IocContainer c) => i12.TagController(c.get<i32.TagService>()),
  );
  c.singleton<i13.TokenController>(
    (IocContainer c) => i13.TokenController(c.get<i33.TokenService>()),
  );
  c.singleton<i14.UserController>(
    (IocContainer c) => i14.UserController(c.get<i34.UserService>()),
  );
  c.singleton<i15.ViewController>(
    (IocContainer c) => i15.ViewController(c.get<i27.NoteService>()),
  );
  c.singleton<i16.WebAuthController>(
    (IocContainer c) => i16.WebAuthController(),
  );
  c.singleton<i17.BadgeRepository>((IocContainer c) => i17.BadgeRepository());
  c.singleton<i18.CommentRepository>(
    (IocContainer c) => i18.CommentRepository(),
  );
  c.singleton<i19.PostRepository>((IocContainer c) => i19.PostRepository());
  c.singleton<i20.TagRepository>((IocContainer c) => i20.TagRepository());
  c.singleton<i21.UserRepository>((IocContainer c) => i21.UserRepository());
  c.singleton<i22.AuthService>(
    (IocContainer c) => i22.AuthService(c.get<i21.UserRepository>()),
  );
  c.singleton<i23.BadgeService>(
    (IocContainer c) => i23.BadgeService(c.get<i17.BadgeRepository>()),
  );
  c.singleton<i24.CacheService>((IocContainer c) => i24.CacheService());
  c.singleton<i25.FileService>((IocContainer c) => i25.FileService());
  c.singleton<i26.MailService>(
    (IocContainer c) => i26.MailService(c.get<i21.UserRepository>()),
  );
  c.singleton<i27.NoteService>((IocContainer c) => i27.NoteService());
  c.singleton<i28.PdfmeService>((IocContainer c) => i28.PdfmeService());
  c.singleton<i29.PostService>(
    (IocContainer c) => i29.PostService(
      c.get<i19.PostRepository>(),
      c.get<i20.TagRepository>(),
      c.get<i18.CommentRepository>(),
    ),
  );
  c.singleton<i30.FileStorageService>(
    (IocContainer c) => i30.FileStorageService(),
  );
  c.singleton<i31.SystemService>((IocContainer c) => i31.SystemService());
  c.singleton<i32.TagService>(
    (IocContainer c) => i32.TagService(c.get<i20.TagRepository>()),
  );
  c.singleton<i33.TokenService>((IocContainer c) => i33.TokenService());
  c.singleton<i34.UserService>(
    (IocContainer c) => i34.UserService(c.get<i21.UserRepository>()),
  );
  c.provider<i35.AppAuthProvider>((IocContainer c) => i35.AppAuthProvider());
  c.provider<i36.BroadcastProvider>(
    (IocContainer c) => i36.BroadcastProvider(),
  );
  c.provider<i37.AppCacheProvider>((IocContainer c) => i37.AppCacheProvider());
  c.provider<i38.AppInertiaProvider>(
    (IocContainer c) => i38.AppInertiaProvider(),
  );
  c.provider<i39.AppMailProvider>((IocContainer c) => i39.AppMailProvider());
  c.provider<i40.ORMProvider>((IocContainer c) => i40.ORMProvider());
  c.provider<i41.AppQueueProvider>((IocContainer c) => i41.AppQueueProvider());
  c.provider<i42.ScheduleProvider>((IocContainer c) => i42.ScheduleProvider());
  c.provider<i43.AppSocketIoProvider>(
    (IocContainer c) => i43.AppSocketIoProvider(),
  );
  c.provider<i44.AppStorageProvider>(
    (IocContainer c) => i44.AppStorageProvider(),
  );
  c.provider<i45.AppViewProvider>((IocContainer c) => i45.AppViewProvider());
  c.router<i46.ApiRouter>((IocContainer c) => i46.ApiRouter());
  c.router<i47.BroadcastRouter>((IocContainer c) => i47.BroadcastRouter());
  c.router<i48.CoreRouter>((IocContainer c) => i48.CoreRouter());
  c.router<i49.InertiaRouter>((IocContainer c) => i49.InertiaRouter());
  c.router<i50.ViewsRouter>((IocContainer c) => i50.ViewsRouter());
  c.router<i51.WebRouter>((IocContainer c) => i51.WebRouter());
  c.bindModel<i52.Badge>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i52.Badge().find(key);
  });
  c.bindModel<i53.Comment>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i53.Comment().find(key);
  });
  c.bindModel<i54.Oauth2Client>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i54.Oauth2Client().find(key);
  });
  c.bindModel<i54.E2eMember>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i54.E2eMember().find(key);
  });
  c.bindModel<i54.E2eShelf>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i54.E2eShelf().find(key);
  });
  c.bindModel<i54.E2eBook>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i54.E2eBook().find(key);
  });
  c.bindModel<i55.E310bItem>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i55.E310bItem().find(key);
  });
  c.bindModel<i55.E310bTag>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i55.E310bTag().find(key);
  });
  c.bindModel<i55.E310bNote>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i55.E310bNote().find(key);
  });
  c.bindModel<i56.Post>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i56.Post().find(key);
  });
  c.bindModel<i57.Profile>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i57.Profile().find(key);
  });
  c.bindModel<i58.Reaction>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i58.Reaction().find(key);
  });
  c.bindModel<i59.Tag>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i59.Tag().find(key);
  });
  c.bindModel<i60.User>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i60.User().find(key);
  });
}
