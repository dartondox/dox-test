// GENERATED CODE - DO NOT MODIFY BY HAND
// Made by dox_builder. Run `dart run build_runner build`.
// ignore_for_file: type=lint

import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/http/controllers/auth.controller.dart' as i1;
import 'package:dox_test/app/http/controllers/cache.controller.dart' as i2;
import 'package:dox_test/app/http/controllers/file.controller.dart' as i3;
import 'package:dox_test/app/http/controllers/inertia.controller.dart' as i4;
import 'package:dox_test/app/http/controllers/post.controller.dart' as i5;
import 'package:dox_test/app/http/controllers/storage.controller.dart' as i6;
import 'package:dox_test/app/http/controllers/system.controller.dart' as i7;
import 'package:dox_test/app/http/controllers/tag.controller.dart' as i8;
import 'package:dox_test/app/http/controllers/user.controller.dart' as i9;
import 'package:dox_test/app/http/controllers/view.controller.dart' as i10;
import 'package:dox_test/app/http/controllers/web_auth.controller.dart' as i11;
import 'package:dox_test/app/repositories/comment.repository.dart' as i12;
import 'package:dox_test/app/repositories/post.repository.dart' as i13;
import 'package:dox_test/app/repositories/tag.repository.dart' as i14;
import 'package:dox_test/app/repositories/user.repository.dart' as i15;
import 'package:dox_test/app/services/auth.service.dart' as i16;
import 'package:dox_test/app/services/cache.service.dart' as i17;
import 'package:dox_test/app/services/file.service.dart' as i18;
import 'package:dox_test/app/services/note.service.dart' as i19;
import 'package:dox_test/app/services/post.service.dart' as i20;
import 'package:dox_test/app/services/storage.service.dart' as i21;
import 'package:dox_test/app/services/system.service.dart' as i22;
import 'package:dox_test/app/services/tag.service.dart' as i23;
import 'package:dox_test/app/services/user.service.dart' as i24;
import 'package:dox_test/providers/auth_provider.dart' as i25;
import 'package:dox_test/providers/inertia_provider.dart' as i26;
import 'package:dox_test/providers/orm_provider.dart' as i27;
import 'package:dox_test/providers/queue_provider.dart' as i28;
import 'package:dox_test/providers/schedule_provider.dart' as i29;
import 'package:dox_test/providers/socketio_provider.dart' as i30;
import 'package:dox_test/providers/storage_provider.dart' as i31;
import 'package:dox_test/providers/view_provider.dart' as i32;
import 'package:dox_test/routes/api.dart' as i33;
import 'package:dox_test/routes/inertia.dart' as i34;
import 'package:dox_test/routes/views.dart' as i35;
import 'package:dox_test/routes/web.dart' as i36;
import 'package:dox_test/app/models/comment/comment.model.dart' as i37;
import 'package:dox_test/app/models/post/post.model.dart' as i38;
import 'package:dox_test/app/models/profile/profile.model.dart' as i39;
import 'package:dox_test/app/models/tag/tag.model.dart' as i40;
import 'package:dox_test/app/models/user/user.model.dart' as i41;

/// Puts every class of the app into the container: the
/// `@Inject()` classes, routers, providers and model binders.
/// Use it in `AppConfig(container: registerContainer)`.
void registerContainer(IocContainer c) {
  c.singleton<i1.AuthController>(
    (IocContainer c) => i1.AuthController(c.get<i16.AuthService>()),
  );
  c.singleton<i2.CacheController>(
    (IocContainer c) => i2.CacheController(c.get<i17.CacheService>()),
  );
  c.singleton<i3.FileController>(
    (IocContainer c) => i3.FileController(c.get<i18.FileService>()),
  );
  c.singleton<i4.InertiaController>(
    (IocContainer c) => i4.InertiaController(c.get<i19.NoteService>()),
  );
  c.singleton<i5.PostController>(
    (IocContainer c) => i5.PostController(c.get<i20.PostService>()),
  );
  c.singleton<i6.StorageController>(
    (IocContainer c) => i6.StorageController(c.get<i21.FileStorageService>()),
  );
  c.singleton<i7.SystemController>(
    (IocContainer c) => i7.SystemController(c.get<i22.SystemService>()),
  );
  c.singleton<i8.TagController>(
    (IocContainer c) => i8.TagController(c.get<i23.TagService>()),
  );
  c.singleton<i9.UserController>(
    (IocContainer c) => i9.UserController(c.get<i24.UserService>()),
  );
  c.singleton<i10.ViewController>(
    (IocContainer c) => i10.ViewController(c.get<i19.NoteService>()),
  );
  c.singleton<i11.WebAuthController>(
    (IocContainer c) => i11.WebAuthController(),
  );
  c.singleton<i12.CommentRepository>(
    (IocContainer c) => i12.CommentRepository(),
  );
  c.singleton<i13.PostRepository>((IocContainer c) => i13.PostRepository());
  c.singleton<i14.TagRepository>((IocContainer c) => i14.TagRepository());
  c.singleton<i15.UserRepository>((IocContainer c) => i15.UserRepository());
  c.singleton<i16.AuthService>(
    (IocContainer c) => i16.AuthService(c.get<i15.UserRepository>()),
  );
  c.singleton<i17.CacheService>((IocContainer c) => i17.CacheService());
  c.singleton<i18.FileService>((IocContainer c) => i18.FileService());
  c.singleton<i19.NoteService>((IocContainer c) => i19.NoteService());
  c.singleton<i20.PostService>(
    (IocContainer c) => i20.PostService(
      c.get<i13.PostRepository>(),
      c.get<i14.TagRepository>(),
      c.get<i12.CommentRepository>(),
    ),
  );
  c.singleton<i21.FileStorageService>(
    (IocContainer c) => i21.FileStorageService(),
  );
  c.singleton<i22.SystemService>((IocContainer c) => i22.SystemService());
  c.singleton<i23.TagService>(
    (IocContainer c) => i23.TagService(c.get<i14.TagRepository>()),
  );
  c.singleton<i24.UserService>(
    (IocContainer c) => i24.UserService(c.get<i15.UserRepository>()),
  );
  c.provider<i25.AppAuthProvider>((IocContainer c) => i25.AppAuthProvider());
  c.provider<i26.AppInertiaProvider>(
    (IocContainer c) => i26.AppInertiaProvider(),
  );
  c.provider<i27.ORMProvider>((IocContainer c) => i27.ORMProvider());
  c.provider<i28.AppQueueProvider>((IocContainer c) => i28.AppQueueProvider());
  c.provider<i29.ScheduleProvider>((IocContainer c) => i29.ScheduleProvider());
  c.provider<i30.AppSocketIoProvider>(
    (IocContainer c) => i30.AppSocketIoProvider(),
  );
  c.provider<i31.AppStorageProvider>(
    (IocContainer c) => i31.AppStorageProvider(),
  );
  c.provider<i32.AppViewProvider>((IocContainer c) => i32.AppViewProvider());
  c.router<i33.ApiRouter>((IocContainer c) => i33.ApiRouter());
  c.router<i34.InertiaRouter>((IocContainer c) => i34.InertiaRouter());
  c.router<i35.ViewsRouter>((IocContainer c) => i35.ViewsRouter());
  c.router<i36.WebRouter>((IocContainer c) => i36.WebRouter());
  c.bindModel<i37.Comment>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i37.Comment().find(key);
  });
  c.bindModel<i38.Post>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i38.Post().find(key);
  });
  c.bindModel<i39.Profile>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i39.Profile().find(key);
  });
  c.bindModel<i40.Tag>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i40.Tag().find(key);
  });
  c.bindModel<i41.User>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i41.User().find(key);
  });
}
