// GENERATED CODE - DO NOT MODIFY BY HAND
// Made by dox_builder. Run `dart run build_runner build`.
// ignore_for_file: type=lint

import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/http/controllers/auth.controller.dart' as i1;
import 'package:dox_test/app/http/controllers/cache.controller.dart' as i2;
import 'package:dox_test/app/http/controllers/file.controller.dart' as i3;
import 'package:dox_test/app/http/controllers/post.controller.dart' as i4;
import 'package:dox_test/app/http/controllers/storage.controller.dart' as i5;
import 'package:dox_test/app/http/controllers/system.controller.dart' as i6;
import 'package:dox_test/app/http/controllers/tag.controller.dart' as i7;
import 'package:dox_test/app/http/controllers/user.controller.dart' as i8;
import 'package:dox_test/app/repositories/comment.repository.dart' as i9;
import 'package:dox_test/app/repositories/post.repository.dart' as i10;
import 'package:dox_test/app/repositories/tag.repository.dart' as i11;
import 'package:dox_test/app/repositories/user.repository.dart' as i12;
import 'package:dox_test/app/services/auth.service.dart' as i13;
import 'package:dox_test/app/services/cache.service.dart' as i14;
import 'package:dox_test/app/services/file.service.dart' as i15;
import 'package:dox_test/app/services/post.service.dart' as i16;
import 'package:dox_test/app/services/storage.service.dart' as i17;
import 'package:dox_test/app/services/system.service.dart' as i18;
import 'package:dox_test/app/services/tag.service.dart' as i19;
import 'package:dox_test/app/services/user.service.dart' as i20;
import 'package:dox_test/providers/auth_service_provider.dart' as i21;
import 'package:dox_test/providers/orm_service_provider.dart' as i22;
import 'package:dox_test/routes/api.dart' as i23;
import 'package:dox_test/routes/web.dart' as i24;
import 'package:dox_test/services/queue_service.dart' as i25;
import 'package:dox_test/services/schedule_service.dart' as i26;
import 'package:dox_test/app/models/comment/comment.model.dart' as i27;
import 'package:dox_test/app/models/post/post.model.dart' as i28;
import 'package:dox_test/app/models/profile/profile.model.dart' as i29;
import 'package:dox_test/app/models/tag/tag.model.dart' as i30;
import 'package:dox_test/app/models/user/user.model.dart' as i31;

/// Puts every class of the app into the container: the
/// `@Inject()` classes, routers, services and model binders.
/// Use it in `AppConfig(container: registerContainer)`.
void registerContainer(IocContainer c) {
  c.singleton<i1.AuthController>(
    (IocContainer c) => i1.AuthController(c.get<i13.AuthService>()),
  );
  c.singleton<i2.CacheController>(
    (IocContainer c) => i2.CacheController(c.get<i14.CacheService>()),
  );
  c.singleton<i3.FileController>(
    (IocContainer c) => i3.FileController(c.get<i15.FileService>()),
  );
  c.singleton<i4.PostController>(
    (IocContainer c) => i4.PostController(c.get<i16.PostService>()),
  );
  c.singleton<i5.StorageController>(
    (IocContainer c) => i5.StorageController(c.get<i17.StorageService>()),
  );
  c.singleton<i6.SystemController>(
    (IocContainer c) => i6.SystemController(c.get<i18.SystemService>()),
  );
  c.singleton<i7.TagController>(
    (IocContainer c) => i7.TagController(c.get<i19.TagService>()),
  );
  c.singleton<i8.UserController>(
    (IocContainer c) => i8.UserController(c.get<i20.UserService>()),
  );
  c.singleton<i9.CommentRepository>((IocContainer c) => i9.CommentRepository());
  c.singleton<i10.PostRepository>((IocContainer c) => i10.PostRepository());
  c.singleton<i11.TagRepository>((IocContainer c) => i11.TagRepository());
  c.singleton<i12.UserRepository>((IocContainer c) => i12.UserRepository());
  c.singleton<i13.AuthService>(
    (IocContainer c) => i13.AuthService(c.get<i12.UserRepository>()),
  );
  c.singleton<i14.CacheService>((IocContainer c) => i14.CacheService());
  c.singleton<i15.FileService>((IocContainer c) => i15.FileService());
  c.singleton<i16.PostService>(
    (IocContainer c) => i16.PostService(
      c.get<i10.PostRepository>(),
      c.get<i11.TagRepository>(),
      c.get<i9.CommentRepository>(),
    ),
  );
  c.singleton<i17.StorageService>((IocContainer c) => i17.StorageService());
  c.singleton<i18.SystemService>((IocContainer c) => i18.SystemService());
  c.singleton<i19.TagService>(
    (IocContainer c) => i19.TagService(c.get<i11.TagRepository>()),
  );
  c.singleton<i20.UserService>(
    (IocContainer c) => i20.UserService(c.get<i12.UserRepository>()),
  );
  c.service<i21.AuthServiceProvider>(
    (IocContainer c) => i21.AuthServiceProvider(),
  );
  c.service<i22.OrmServiceProvider>(
    (IocContainer c) => i22.OrmServiceProvider(),
  );
  c.router<i23.ApiRouter>((IocContainer c) => i23.ApiRouter());
  c.router<i24.WebRouter>((IocContainer c) => i24.WebRouter());
  c.service<i25.AppQueueService>((IocContainer c) => i25.AppQueueService());
  c.service<i26.ScheduleService>((IocContainer c) => i26.ScheduleService());
  c.bindModel<i27.Comment>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i27.Comment().find(key);
  });
  c.bindModel<i28.Post>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i28.Post().find(key);
  });
  c.bindModel<i29.Profile>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i29.Profile().find(key);
  });
  c.bindModel<i30.Tag>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i30.Tag().find(key);
  });
  c.bindModel<i31.User>((String id) {
    int? key = int.tryParse(id);
    if (key == null) return null;
    return i31.User().find(key);
  });
}
