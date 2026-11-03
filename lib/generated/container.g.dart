// GENERATED CODE - DO NOT MODIFY BY HAND
// Made by dox_builder. Run `dart run build_runner build`.
// ignore_for_file: type=lint

import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/http/controllers/auth.controller.dart' as i1;
import 'package:dox_test/app/http/controllers/cache.controller.dart' as i2;
import 'package:dox_test/app/http/controllers/file.controller.dart' as i3;
import 'package:dox_test/app/http/controllers/inertia.controller.dart' as i4;
import 'package:dox_test/app/http/controllers/mail.controller.dart' as i5;
import 'package:dox_test/app/http/controllers/post.controller.dart' as i6;
import 'package:dox_test/app/http/controllers/storage.controller.dart' as i7;
import 'package:dox_test/app/http/controllers/system.controller.dart' as i8;
import 'package:dox_test/app/http/controllers/tag.controller.dart' as i9;
import 'package:dox_test/app/http/controllers/user.controller.dart' as i10;
import 'package:dox_test/app/http/controllers/view.controller.dart' as i11;
import 'package:dox_test/app/http/controllers/web_auth.controller.dart' as i12;
import 'package:dox_test/app/repositories/comment.repository.dart' as i13;
import 'package:dox_test/app/repositories/post.repository.dart' as i14;
import 'package:dox_test/app/repositories/tag.repository.dart' as i15;
import 'package:dox_test/app/repositories/user.repository.dart' as i16;
import 'package:dox_test/app/services/auth.service.dart' as i17;
import 'package:dox_test/app/services/cache.service.dart' as i18;
import 'package:dox_test/app/services/file.service.dart' as i19;
import 'package:dox_test/app/services/mail.service.dart' as i20;
import 'package:dox_test/app/services/note.service.dart' as i21;
import 'package:dox_test/app/services/post.service.dart' as i22;
import 'package:dox_test/app/services/storage.service.dart' as i23;
import 'package:dox_test/app/services/system.service.dart' as i24;
import 'package:dox_test/app/services/tag.service.dart' as i25;
import 'package:dox_test/app/services/user.service.dart' as i26;
import 'package:dox_test/providers/auth_provider.dart' as i27;
import 'package:dox_test/providers/inertia_provider.dart' as i28;
import 'package:dox_test/providers/mail_provider.dart' as i29;
import 'package:dox_test/providers/orm_provider.dart' as i30;
import 'package:dox_test/providers/queue_provider.dart' as i31;
import 'package:dox_test/providers/schedule_provider.dart' as i32;
import 'package:dox_test/providers/socketio_provider.dart' as i33;
import 'package:dox_test/providers/storage_provider.dart' as i34;
import 'package:dox_test/providers/view_provider.dart' as i35;
import 'package:dox_test/routes/api.dart' as i36;
import 'package:dox_test/routes/inertia.dart' as i37;
import 'package:dox_test/routes/views.dart' as i38;
import 'package:dox_test/routes/web.dart' as i39;
import 'package:dox_test/app/models/comment/comment.model.dart' as i40;
import 'package:dox_test/app/models/post/post.model.dart' as i41;
import 'package:dox_test/app/models/profile/profile.model.dart' as i42;
import 'package:dox_test/app/models/tag/tag.model.dart' as i43;
import 'package:dox_test/app/models/user/user.model.dart' as i44;

/// Puts every class of the app into the container: the
/// `@Inject()` classes, routers, providers and model binders.
/// Use it in `AppConfig(container: registerContainer)`.
void registerContainer(IocContainer c) {
  c.singleton<i1.AuthController>(
    (IocContainer c) => i1.AuthController(c.get<i17.AuthService>()),
  );
  c.singleton<i2.CacheController>(
    (IocContainer c) => i2.CacheController(c.get<i18.CacheService>()),
  );
  c.singleton<i3.FileController>(
    (IocContainer c) => i3.FileController(c.get<i19.FileService>()),
  );
  c.singleton<i4.InertiaController>(
    (IocContainer c) => i4.InertiaController(c.get<i21.NoteService>()),
  );
  c.singleton<i5.MailController>(
    (IocContainer c) => i5.MailController(c.get<i20.MailService>()),
  );
  c.singleton<i6.PostController>(
    (IocContainer c) => i6.PostController(c.get<i22.PostService>()),
  );
  c.singleton<i7.StorageController>(
    (IocContainer c) => i7.StorageController(c.get<i23.FileStorageService>()),
  );
  c.singleton<i8.SystemController>(
    (IocContainer c) => i8.SystemController(c.get<i24.SystemService>()),
  );
  c.singleton<i9.TagController>(
    (IocContainer c) => i9.TagController(c.get<i25.TagService>()),
  );
  c.singleton<i10.UserController>(
    (IocContainer c) => i10.UserController(c.get<i26.UserService>()),
  );
  c.singleton<i11.ViewController>(
    (IocContainer c) => i11.ViewController(c.get<i21.NoteService>()),
  );
  c.singleton<i12.WebAuthController>(
    (IocContainer c) => i12.WebAuthController(),
  );
  c.singleton<i13.CommentRepository>(
    (IocContainer c) => i13.CommentRepository(),
  );
  c.singleton<i14.PostRepository>((IocContainer c) => i14.PostRepository());
  c.singleton<i15.TagRepository>((IocContainer c) => i15.TagRepository());
  c.singleton<i16.UserRepository>((IocContainer c) => i16.UserRepository());
  c.singleton<i17.AuthService>(
    (IocContainer c) => i17.AuthService(c.get<i16.UserRepository>()),
  );
  c.singleton<i18.CacheService>((IocContainer c) => i18.CacheService());
  c.singleton<i19.FileService>((IocContainer c) => i19.FileService());
  c.singleton<i20.MailService>(
    (IocContainer c) => i20.MailService(c.get<i16.UserRepository>()),
  );
  c.singleton<i21.NoteService>((IocContainer c) => i21.NoteService());
  c.singleton<i22.PostService>(
    (IocContainer c) => i22.PostService(
      c.get<i14.PostRepository>(),
      c.get<i15.TagRepository>(),
      c.get<i13.CommentRepository>(),
    ),
  );
  c.singleton<i23.FileStorageService>(
    (IocContainer c) => i23.FileStorageService(),
  );
  c.singleton<i24.SystemService>((IocContainer c) => i24.SystemService());
  c.singleton<i25.TagService>(
    (IocContainer c) => i25.TagService(c.get<i15.TagRepository>()),
  );
  c.singleton<i26.UserService>(
    (IocContainer c) => i26.UserService(c.get<i16.UserRepository>()),
  );
  c.provider<i27.AppAuthProvider>((IocContainer c) => i27.AppAuthProvider());
  c.provider<i28.AppInertiaProvider>(
    (IocContainer c) => i28.AppInertiaProvider(),
  );
  c.provider<i29.AppMailProvider>((IocContainer c) => i29.AppMailProvider());
  c.provider<i30.ORMProvider>((IocContainer c) => i30.ORMProvider());
  c.provider<i31.AppQueueProvider>((IocContainer c) => i31.AppQueueProvider());
  c.provider<i32.ScheduleProvider>((IocContainer c) => i32.ScheduleProvider());
  c.provider<i33.AppSocketIoProvider>(
    (IocContainer c) => i33.AppSocketIoProvider(),
  );
  c.provider<i34.AppStorageProvider>(
    (IocContainer c) => i34.AppStorageProvider(),
  );
  c.provider<i35.AppViewProvider>((IocContainer c) => i35.AppViewProvider());
  c.router<i36.ApiRouter>((IocContainer c) => i36.ApiRouter());
  c.router<i37.InertiaRouter>((IocContainer c) => i37.InertiaRouter());
  c.router<i38.ViewsRouter>((IocContainer c) => i38.ViewsRouter());
  c.router<i39.WebRouter>((IocContainer c) => i39.WebRouter());
  c.bindModel<i40.Comment>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i40.Comment().find(key);
  });
  c.bindModel<i41.Post>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i41.Post().find(key);
  });
  c.bindModel<i42.Profile>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i42.Profile().find(key);
  });
  c.bindModel<i43.Tag>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i43.Tag().find(key);
  });
  c.bindModel<i44.User>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i44.User().find(key);
  });
}
