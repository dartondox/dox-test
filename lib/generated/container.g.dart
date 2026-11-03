// GENERATED CODE - DO NOT MODIFY BY HAND
// Made by dox_builder. Run `dart run build_runner build`.
// ignore_for_file: type=lint

import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/http/controllers/auth.controller.dart' as i1;
import 'package:dox_test/app/http/controllers/badge.controller.dart' as i2;
import 'package:dox_test/app/http/controllers/cache.controller.dart' as i3;
import 'package:dox_test/app/http/controllers/file.controller.dart' as i4;
import 'package:dox_test/app/http/controllers/inertia.controller.dart' as i5;
import 'package:dox_test/app/http/controllers/mail.controller.dart' as i6;
import 'package:dox_test/app/http/controllers/post.controller.dart' as i7;
import 'package:dox_test/app/http/controllers/storage.controller.dart' as i8;
import 'package:dox_test/app/http/controllers/system.controller.dart' as i9;
import 'package:dox_test/app/http/controllers/tag.controller.dart' as i10;
import 'package:dox_test/app/http/controllers/user.controller.dart' as i11;
import 'package:dox_test/app/http/controllers/view.controller.dart' as i12;
import 'package:dox_test/app/http/controllers/web_auth.controller.dart' as i13;
import 'package:dox_test/app/repositories/badge.repository.dart' as i14;
import 'package:dox_test/app/repositories/comment.repository.dart' as i15;
import 'package:dox_test/app/repositories/post.repository.dart' as i16;
import 'package:dox_test/app/repositories/tag.repository.dart' as i17;
import 'package:dox_test/app/repositories/user.repository.dart' as i18;
import 'package:dox_test/app/services/auth.service.dart' as i19;
import 'package:dox_test/app/services/badge.service.dart' as i20;
import 'package:dox_test/app/services/cache.service.dart' as i21;
import 'package:dox_test/app/services/file.service.dart' as i22;
import 'package:dox_test/app/services/mail.service.dart' as i23;
import 'package:dox_test/app/services/note.service.dart' as i24;
import 'package:dox_test/app/services/post.service.dart' as i25;
import 'package:dox_test/app/services/storage.service.dart' as i26;
import 'package:dox_test/app/services/system.service.dart' as i27;
import 'package:dox_test/app/services/tag.service.dart' as i28;
import 'package:dox_test/app/services/user.service.dart' as i29;
import 'package:dox_test/providers/auth_provider.dart' as i30;
import 'package:dox_test/providers/inertia_provider.dart' as i31;
import 'package:dox_test/providers/mail_provider.dart' as i32;
import 'package:dox_test/providers/orm_provider.dart' as i33;
import 'package:dox_test/providers/queue_provider.dart' as i34;
import 'package:dox_test/providers/schedule_provider.dart' as i35;
import 'package:dox_test/providers/socketio_provider.dart' as i36;
import 'package:dox_test/providers/storage_provider.dart' as i37;
import 'package:dox_test/providers/view_provider.dart' as i38;
import 'package:dox_test/routes/api.dart' as i39;
import 'package:dox_test/routes/inertia.dart' as i40;
import 'package:dox_test/routes/views.dart' as i41;
import 'package:dox_test/routes/web.dart' as i42;
import 'package:dox_test/app/models/badge/badge.model.dart' as i43;
import 'package:dox_test/app/models/comment/comment.model.dart' as i44;
import 'package:dox_test/app/models/post/post.model.dart' as i45;
import 'package:dox_test/app/models/profile/profile.model.dart' as i46;
import 'package:dox_test/app/models/reaction/reaction.model.dart' as i47;
import 'package:dox_test/app/models/tag/tag.model.dart' as i48;
import 'package:dox_test/app/models/user/user.model.dart' as i49;

/// Puts every class of the app into the container: the
/// `@Inject()` classes, routers, providers and model binders.
/// Use it in `AppConfig(container: registerContainer)`.
void registerContainer(IocContainer c) {
  c.singleton<i1.AuthController>(
    (IocContainer c) => i1.AuthController(c.get<i19.AuthService>()),
  );
  c.singleton<i2.BadgeController>(
    (IocContainer c) => i2.BadgeController(c.get<i20.BadgeService>()),
  );
  c.singleton<i3.CacheController>(
    (IocContainer c) => i3.CacheController(c.get<i21.CacheService>()),
  );
  c.singleton<i4.FileController>(
    (IocContainer c) => i4.FileController(c.get<i22.FileService>()),
  );
  c.singleton<i5.InertiaController>(
    (IocContainer c) => i5.InertiaController(c.get<i24.NoteService>()),
  );
  c.singleton<i6.MailController>(
    (IocContainer c) => i6.MailController(c.get<i23.MailService>()),
  );
  c.singleton<i7.PostController>(
    (IocContainer c) => i7.PostController(c.get<i25.PostService>()),
  );
  c.singleton<i8.StorageController>(
    (IocContainer c) => i8.StorageController(c.get<i26.FileStorageService>()),
  );
  c.singleton<i9.SystemController>(
    (IocContainer c) => i9.SystemController(c.get<i27.SystemService>()),
  );
  c.singleton<i10.TagController>(
    (IocContainer c) => i10.TagController(c.get<i28.TagService>()),
  );
  c.singleton<i11.UserController>(
    (IocContainer c) => i11.UserController(c.get<i29.UserService>()),
  );
  c.singleton<i12.ViewController>(
    (IocContainer c) => i12.ViewController(c.get<i24.NoteService>()),
  );
  c.singleton<i13.WebAuthController>(
    (IocContainer c) => i13.WebAuthController(),
  );
  c.singleton<i14.BadgeRepository>((IocContainer c) => i14.BadgeRepository());
  c.singleton<i15.CommentRepository>(
    (IocContainer c) => i15.CommentRepository(),
  );
  c.singleton<i16.PostRepository>((IocContainer c) => i16.PostRepository());
  c.singleton<i17.TagRepository>((IocContainer c) => i17.TagRepository());
  c.singleton<i18.UserRepository>((IocContainer c) => i18.UserRepository());
  c.singleton<i19.AuthService>(
    (IocContainer c) => i19.AuthService(c.get<i18.UserRepository>()),
  );
  c.singleton<i20.BadgeService>(
    (IocContainer c) => i20.BadgeService(c.get<i14.BadgeRepository>()),
  );
  c.singleton<i21.CacheService>((IocContainer c) => i21.CacheService());
  c.singleton<i22.FileService>((IocContainer c) => i22.FileService());
  c.singleton<i23.MailService>(
    (IocContainer c) => i23.MailService(c.get<i18.UserRepository>()),
  );
  c.singleton<i24.NoteService>((IocContainer c) => i24.NoteService());
  c.singleton<i25.PostService>(
    (IocContainer c) => i25.PostService(
      c.get<i16.PostRepository>(),
      c.get<i17.TagRepository>(),
      c.get<i15.CommentRepository>(),
    ),
  );
  c.singleton<i26.FileStorageService>(
    (IocContainer c) => i26.FileStorageService(),
  );
  c.singleton<i27.SystemService>((IocContainer c) => i27.SystemService());
  c.singleton<i28.TagService>(
    (IocContainer c) => i28.TagService(c.get<i17.TagRepository>()),
  );
  c.singleton<i29.UserService>(
    (IocContainer c) => i29.UserService(c.get<i18.UserRepository>()),
  );
  c.provider<i30.AppAuthProvider>((IocContainer c) => i30.AppAuthProvider());
  c.provider<i31.AppInertiaProvider>(
    (IocContainer c) => i31.AppInertiaProvider(),
  );
  c.provider<i32.AppMailProvider>((IocContainer c) => i32.AppMailProvider());
  c.provider<i33.ORMProvider>((IocContainer c) => i33.ORMProvider());
  c.provider<i34.AppQueueProvider>((IocContainer c) => i34.AppQueueProvider());
  c.provider<i35.ScheduleProvider>((IocContainer c) => i35.ScheduleProvider());
  c.provider<i36.AppSocketIoProvider>(
    (IocContainer c) => i36.AppSocketIoProvider(),
  );
  c.provider<i37.AppStorageProvider>(
    (IocContainer c) => i37.AppStorageProvider(),
  );
  c.provider<i38.AppViewProvider>((IocContainer c) => i38.AppViewProvider());
  c.router<i39.ApiRouter>((IocContainer c) => i39.ApiRouter());
  c.router<i40.InertiaRouter>((IocContainer c) => i40.InertiaRouter());
  c.router<i41.ViewsRouter>((IocContainer c) => i41.ViewsRouter());
  c.router<i42.WebRouter>((IocContainer c) => i42.WebRouter());
  c.bindModel<i43.Badge>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i43.Badge().find(key);
  });
  c.bindModel<i44.Comment>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i44.Comment().find(key);
  });
  c.bindModel<i45.Post>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i45.Post().find(key);
  });
  c.bindModel<i46.Profile>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i46.Profile().find(key);
  });
  c.bindModel<i47.Reaction>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i47.Reaction().find(key);
  });
  c.bindModel<i48.Tag>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i48.Tag().find(key);
  });
  c.bindModel<i49.User>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i49.User().find(key);
  });
}
