import 'package:dox_core/dox_core.dart';
import 'package:dox_test/app/http/controllers/auth.controller.dart';
import 'package:dox_test/app/http/controllers/file.controller.dart';
import 'package:dox_test/app/http/controllers/post.controller.dart';
import 'package:dox_test/app/http/controllers/system.controller.dart';
import 'package:dox_test/app/http/controllers/tag.controller.dart';
import 'package:dox_test/app/http/controllers/user.controller.dart';
import 'package:dox_test/app/repositories/comment.repository.dart';
import 'package:dox_test/app/repositories/post.repository.dart';
import 'package:dox_test/app/repositories/tag.repository.dart';
import 'package:dox_test/app/repositories/user.repository.dart';
import 'package:dox_test/app/services/auth.service.dart';
import 'package:dox_test/app/services/file.service.dart';
import 'package:dox_test/app/services/post.service.dart';
import 'package:dox_test/app/services/system.service.dart';
import 'package:dox_test/app/services/tag.service.dart';
import 'package:dox_test/app/services/user.service.dart';
import 'package:dox_test/app/ws/chat.socket_controller.dart';

/// Puts every repository, service and controller in the dox IoC container.
/// Each class gets what it needs through its constructor.
/// Singletons are made in order, so dependencies come first.
class ContainerServiceProvider implements DoxService {
  @override
  void setup() {
    IocContainer ioc = Dox().ioc;

    ioc.registerSingleton<UserRepository>(userRepository);
    ioc.registerSingleton<PostRepository>(postRepository);
    ioc.registerSingleton<CommentRepository>(commentRepository);
    ioc.registerSingleton<TagRepository>(tagRepository);

    ioc.registerSingleton<AuthService>(authService);
    ioc.registerSingleton<UserService>(userService);
    ioc.registerSingleton<PostService>(postService);
    ioc.registerSingleton<TagService>(tagService);
    ioc.registerSingleton<FileService>(fileService);
    ioc.registerSingleton<SystemService>(systemService);

    ioc.registerSingleton<AuthController>(authController);
    ioc.registerSingleton<UserController>(userController);
    ioc.registerSingleton<PostController>(postController);
    ioc.registerSingleton<TagController>(tagController);
    ioc.registerSingleton<FileController>(fileController);
    ioc.registerSingleton<SystemController>(systemController);
    ioc.registerSingleton<ChatSocketController>(chatSocketController);
  }

  UserRepository userRepository(IocContainer i) {
    return UserRepository();
  }

  PostRepository postRepository(IocContainer i) {
    return PostRepository();
  }

  CommentRepository commentRepository(IocContainer i) {
    return CommentRepository();
  }

  TagRepository tagRepository(IocContainer i) {
    return TagRepository();
  }

  AuthService authService(IocContainer i) {
    return AuthService(i.get<UserRepository>());
  }

  UserService userService(IocContainer i) {
    return UserService(i.get<UserRepository>());
  }

  PostService postService(IocContainer i) {
    return PostService(
      i.get<PostRepository>(),
      i.get<TagRepository>(),
      i.get<CommentRepository>(),
    );
  }

  TagService tagService(IocContainer i) {
    return TagService(i.get<TagRepository>());
  }

  FileService fileService(IocContainer i) {
    return FileService();
  }

  SystemService systemService(IocContainer i) {
    return SystemService();
  }

  AuthController authController(IocContainer i) {
    return AuthController(i.get<AuthService>());
  }

  UserController userController(IocContainer i) {
    return UserController(i.get<UserService>());
  }

  PostController postController(IocContainer i) {
    return PostController(i.get<PostService>());
  }

  TagController tagController(IocContainer i) {
    return TagController(i.get<TagService>());
  }

  FileController fileController(IocContainer i) {
    return FileController(i.get<FileService>());
  }

  SystemController systemController(IocContainer i) {
    return SystemController(i.get<SystemService>());
  }

  ChatSocketController chatSocketController(IocContainer i) {
    return ChatSocketController();
  }
}
