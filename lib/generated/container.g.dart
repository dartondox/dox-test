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
import 'package:dox_test/app/http/controllers/web_auth.controller.dart' as i10;
import 'package:dox_test/app/repositories/comment.repository.dart' as i11;
import 'package:dox_test/app/repositories/post.repository.dart' as i12;
import 'package:dox_test/app/repositories/tag.repository.dart' as i13;
import 'package:dox_test/app/repositories/user.repository.dart' as i14;
import 'package:dox_test/app/services/auth.service.dart' as i15;
import 'package:dox_test/app/services/cache.service.dart' as i16;
import 'package:dox_test/app/services/file.service.dart' as i17;
import 'package:dox_test/app/services/note.service.dart' as i18;
import 'package:dox_test/app/services/post.service.dart' as i19;
import 'package:dox_test/app/services/storage.service.dart' as i20;
import 'package:dox_test/app/services/system.service.dart' as i21;
import 'package:dox_test/app/services/tag.service.dart' as i22;
import 'package:dox_test/app/services/user.service.dart' as i23;
import 'package:dox_test/providers/auth_service_provider.dart' as i24;
import 'package:dox_test/providers/inertia_service_provider.dart' as i25;
import 'package:dox_test/providers/orm_service_provider.dart' as i26;
import 'package:dox_test/providers/queue_service_provider.dart' as i27;
import 'package:dox_test/providers/schedule_service_provider.dart' as i28;
import 'package:dox_test/routes/api.dart' as i29;
import 'package:dox_test/routes/inertia.dart' as i30;
import 'package:dox_test/routes/web.dart' as i31;
import 'package:dox_test/app/models/comment/comment.model.dart' as i32;
import 'package:dox_test/app/models/post/post.model.dart' as i33;
import 'package:dox_test/app/models/profile/profile.model.dart' as i34;
import 'package:dox_test/app/models/tag/tag.model.dart' as i35;
import 'package:dox_test/app/models/user/user.model.dart' as i36;

/// Puts every class of the app into the container: the
/// `@Inject()` classes, routers, services and model binders.
/// Use it in `AppConfig(container: registerContainer)`.
void registerContainer(IocContainer c) {
  c.singleton<i1.AuthController>(
    (IocContainer c) => i1.AuthController(c.get<i15.AuthService>()),
  );
  c.singleton<i2.CacheController>(
    (IocContainer c) => i2.CacheController(c.get<i16.CacheService>()),
  );
  c.singleton<i3.FileController>(
    (IocContainer c) => i3.FileController(c.get<i17.FileService>()),
  );
  c.singleton<i4.InertiaController>(
    (IocContainer c) => i4.InertiaController(c.get<i18.NoteService>()),
  );
  c.singleton<i5.PostController>(
    (IocContainer c) => i5.PostController(c.get<i19.PostService>()),
  );
  c.singleton<i6.StorageController>(
    (IocContainer c) => i6.StorageController(c.get<i20.StorageService>()),
  );
  c.singleton<i7.SystemController>(
    (IocContainer c) => i7.SystemController(c.get<i21.SystemService>()),
  );
  c.singleton<i8.TagController>(
    (IocContainer c) => i8.TagController(c.get<i22.TagService>()),
  );
  c.singleton<i9.UserController>(
    (IocContainer c) => i9.UserController(c.get<i23.UserService>()),
  );
  c.singleton<i10.WebAuthController>(
    (IocContainer c) => i10.WebAuthController(),
  );
  c.singleton<i11.CommentRepository>(
    (IocContainer c) => i11.CommentRepository(),
  );
  c.singleton<i12.PostRepository>((IocContainer c) => i12.PostRepository());
  c.singleton<i13.TagRepository>((IocContainer c) => i13.TagRepository());
  c.singleton<i14.UserRepository>((IocContainer c) => i14.UserRepository());
  c.singleton<i15.AuthService>(
    (IocContainer c) => i15.AuthService(c.get<i14.UserRepository>()),
  );
  c.singleton<i16.CacheService>((IocContainer c) => i16.CacheService());
  c.singleton<i17.FileService>((IocContainer c) => i17.FileService());
  c.singleton<i18.NoteService>((IocContainer c) => i18.NoteService());
  c.singleton<i19.PostService>(
    (IocContainer c) => i19.PostService(
      c.get<i12.PostRepository>(),
      c.get<i13.TagRepository>(),
      c.get<i11.CommentRepository>(),
    ),
  );
  c.singleton<i20.StorageService>((IocContainer c) => i20.StorageService());
  c.singleton<i21.SystemService>((IocContainer c) => i21.SystemService());
  c.singleton<i22.TagService>(
    (IocContainer c) => i22.TagService(c.get<i13.TagRepository>()),
  );
  c.singleton<i23.UserService>(
    (IocContainer c) => i23.UserService(c.get<i14.UserRepository>()),
  );
  c.service<i24.AuthServiceProvider>(
    (IocContainer c) => i24.AuthServiceProvider(),
  );
  c.service<i25.AppInertiaService>((IocContainer c) => i25.AppInertiaService());
  c.service<i26.OrmServiceProvider>(
    (IocContainer c) => i26.OrmServiceProvider(),
  );
  c.service<i27.AppQueueService>((IocContainer c) => i27.AppQueueService());
  c.service<i28.ScheduleService>((IocContainer c) => i28.ScheduleService());
  c.router<i29.ApiRouter>((IocContainer c) => i29.ApiRouter());
  c.router<i30.InertiaRouter>((IocContainer c) => i30.InertiaRouter());
  c.router<i31.WebRouter>((IocContainer c) => i31.WebRouter());
  c.bindModel<i32.Comment>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i32.Comment().find(key);
  });
  c.bindModel<i33.Post>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i33.Post().find(key);
  });
  c.bindModel<i34.Profile>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i34.Profile().find(key);
  });
  c.bindModel<i35.Tag>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i35.Tag().find(key);
  });
  c.bindModel<i36.User>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i36.User().find(key);
  });
}
