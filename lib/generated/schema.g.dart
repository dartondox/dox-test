// GENERATED CODE - DO NOT MODIFY BY HAND
// Made by dox_graphql_builder. Run `dart run build_runner build`.
// ignore_for_file: type=lint

import 'package:dox_graphql/dox_graphql.dart';
import 'package:dox_graphql_orm/dox_graphql_orm.dart';
import 'package:dox_auth/dox_auth.dart' show Gate;
import 'package:dox_test/app/models/comment/comment.model.dart' as i1;
import 'package:dox_test/app/models/gql_secret/gql_secret.model.dart' as i2;
import 'package:dox_test/app/models/post/post.model.dart' as i3;
import 'package:dox_test/app/models/profile/profile.model.dart' as i4;
import 'package:dox_test/app/models/tag/tag.model.dart' as i5;
import 'package:dox_test/app/models/user/user.model.dart' as i6;
import 'package:dox_test/app/dtos/graphql/graphql.dto.dart' as i7;
import 'package:dox_test/app/graphql/e33.resolver.dart' as i8;

/// The GraphQL schema of the app, made from the
/// `@GraphQLType`, `@GraphQLQuery` and `@GraphQLMutation` annotations.
/// Use it in `GraphQLConfig(schema: graphqlSchema)`.
final GraphQLSchema<DoxGraphQLContext> graphqlSchema =
    GraphQLSchema<DoxGraphQLContext>(
      query: ObjectType<Object?, DoxGraphQLContext>(
        'Query',
        fields: () => <Field<Object?, DoxGraphQLContext>>[
          AutoField<Object?, DoxGraphQLContext>(
            'comments',
            _tComment.nonNull.list.nonNull,
            args: <Argument>[
              Argument('limit', graphqlInt, defaultValue: '20'),
              Argument('offset', graphqlInt, defaultValue: '0'),
            ],
            resolve: (Object? _, ResolveInfo<DoxGraphQLContext> info) =>
                GraphQLOrm.list<i1.Comment>(i1.Comment(), info),
          ),
          AutoField<Object?, DoxGraphQLContext>(
            'comment',
            _tComment,
            args: <Argument>[Argument('id', graphqlId.nonNull)],
            resolve: (Object? _, ResolveInfo<DoxGraphQLContext> info) =>
                GraphQLOrm.find<i1.Comment>(
                  i1.Comment(),
                  int.tryParse(info.args.get<String>('id')!),
                ),
          ),
          AutoField<Object?, DoxGraphQLContext>(
            'gqlSecrets',
            _tGqlSecret.nonNull.list.nonNull,
            auth: true,
            args: <Argument>[
              Argument('limit', graphqlInt, defaultValue: '20'),
              Argument('offset', graphqlInt, defaultValue: '0'),
            ],
            resolve: (Object? _, ResolveInfo<DoxGraphQLContext> info) =>
                _allowIf<i2.GqlSecret>(info, 'viewAny').then(
                  (_) => _viewList<i2.GqlSecret>(
                    info,
                    GraphQLOrm.list<i2.GqlSecret>(i2.GqlSecret(), info),
                  ),
                ),
          ),
          AutoField<Object?, DoxGraphQLContext>(
            'gqlSecret',
            _tGqlSecret,
            auth: true,
            args: <Argument>[Argument('id', graphqlId.nonNull)],
            resolve: (Object? _, ResolveInfo<DoxGraphQLContext> info) =>
                _findGqlSecret(info),
          ),
          AutoField<Object?, DoxGraphQLContext>(
            'posts',
            _tPost.nonNull.list.nonNull,
            auth: false,
            args: <Argument>[
              Argument('limit', graphqlInt, defaultValue: '20'),
              Argument('offset', graphqlInt, defaultValue: '0'),
            ],
            resolve: (Object? _, ResolveInfo<DoxGraphQLContext> info) =>
                _allowIf<i3.Post>(info, 'viewAny').then(
                  (_) => _viewList<i3.Post>(
                    info,
                    GraphQLOrm.list<i3.Post>(i3.Post(), info),
                  ),
                ),
          ),
          AutoField<Object?, DoxGraphQLContext>(
            'post',
            _tPost,
            auth: false,
            args: <Argument>[Argument('id', graphqlId.nonNull)],
            resolve: (Object? _, ResolveInfo<DoxGraphQLContext> info) =>
                _findPost(info),
          ),
          AutoField<Object?, DoxGraphQLContext>(
            'users',
            _tUser.nonNull.list.nonNull,
            auth: true,
            args: <Argument>[
              Argument('limit', graphqlInt, defaultValue: '20'),
              Argument('offset', graphqlInt, defaultValue: '0'),
            ],
            resolve: (Object? _, ResolveInfo<DoxGraphQLContext> info) =>
                GraphQLOrm.list<i6.User>(i6.User(), info),
          ),
          AutoField<Object?, DoxGraphQLContext>(
            'user',
            _tUser,
            auth: true,
            args: <Argument>[Argument('id', graphqlId.nonNull)],
            resolve: (Object? _, ResolveInfo<DoxGraphQLContext> info) =>
                GraphQLOrm.find<i6.User>(
                  i6.User(),
                  int.tryParse(info.args.get<String>('id')!),
                ),
          ),
          Field<Object?, DoxGraphQLContext>(
            'gqlHits',
            graphqlInt.nonNull,
            description: 'Counts its runs, so a test can see that a rejected query ran none.',
            auth: false,
            resolve: (Object? _, ResolveInfo<DoxGraphQLContext> info) =>
                i8.E33Resolver().gqlHits(),
          ),
          Field<Object?, DoxGraphQLContext>(
            'gqlBoom',
            graphqlString.nonNull,
            description:
                'Throws an error with a secret text: production must hide it.',
            auth: false,
            resolve: (Object? _, ResolveInfo<DoxGraphQLContext> info) =>
                i8.E33Resolver().gqlBoom(),
          ),
        ],
      ),
      mutation: ObjectType<Object?, DoxGraphQLContext>(
        'Mutation',
        fields: () => <Field<Object?, DoxGraphQLContext>>[
          AutoField<Object?, DoxGraphQLContext>(
            'createGqlSecret',
            _tGqlSecret.nonNull,
            auth: true,
            args: <Argument>[Argument('input', _iCreateGqlSecretInput.nonNull)],
            resolve: (Object? _, ResolveInfo<DoxGraphQLContext> info) =>
                _createGqlSecret(info),
          ),
          AutoField<Object?, DoxGraphQLContext>(
            'updateGqlSecret',
            _tGqlSecret,
            auth: true,
            args: <Argument>[
              Argument('id', graphqlId.nonNull),
              Argument('input', _iUpdateGqlSecretInput.nonNull),
            ],
            resolve: (Object? _, ResolveInfo<DoxGraphQLContext> info) =>
                _updateGqlSecret(info),
          ),
          AutoField<Object?, DoxGraphQLContext>(
            'deleteGqlSecret',
            graphqlBoolean.nonNull,
            auth: true,
            args: <Argument>[Argument('id', graphqlId.nonNull)],
            resolve: (Object? _, ResolveInfo<DoxGraphQLContext> info) =>
                _deleteGqlSecret(info),
          ),
          AutoField<Object?, DoxGraphQLContext>(
            'createPost',
            _tPost.nonNull,
            auth: true,
            args: <Argument>[Argument('input', _iCreatePostInput.nonNull)],
            resolve: (Object? _, ResolveInfo<DoxGraphQLContext> info) =>
                _createPost(info),
          ),
          AutoField<Object?, DoxGraphQLContext>(
            'updatePost',
            _tPost,
            auth: false,
            args: <Argument>[
              Argument('id', graphqlId.nonNull),
              Argument('input', _iUpdatePostInput.nonNull),
            ],
            resolve: (Object? _, ResolveInfo<DoxGraphQLContext> info) =>
                _updatePost(info),
          ),
          AutoField<Object?, DoxGraphQLContext>(
            'deletePost',
            graphqlBoolean.nonNull,
            auth: false,
            args: <Argument>[Argument('id', graphqlId.nonNull)],
            resolve: (Object? _, ResolveInfo<DoxGraphQLContext> info) =>
                _deletePost(info),
          ),
        ],
      ),
      types: <NamedType>[
        _tComment,
        _tGqlSecret,
        _tPost,
        _tProfile,
        _tTag,
        _tUser,
      ],
    );

final ObjectType<i1.Comment, DoxGraphQLContext> _tComment =
    ObjectType<i1.Comment, DoxGraphQLContext>(
      'Comment',
      description: 'One row in the `comments` table.',
      fields: () {
        i1.Comment model = i1.Comment();
        List<String> hidden = model.hidden;
        List<String> visible = model.visibleFields;
        bool show(String name) =>
            !hidden.contains(name) &&
            (visible.isEmpty || visible.contains(name));
        return <Field<i1.Comment, DoxGraphQLContext>>[
          if (show('id'))
            Field<i1.Comment, DoxGraphQLContext>(
              'id',
              graphqlId.nonNull,
              resolve: (i1.Comment s, ResolveInfo<DoxGraphQLContext> info) =>
                  s.id,
            ),
          if (show('post_id'))
            Field<i1.Comment, DoxGraphQLContext>(
              'postId',
              graphqlInt,
              resolve: (i1.Comment s, ResolveInfo<DoxGraphQLContext> info) =>
                  s.postId,
            ),
          if (show('user_id'))
            Field<i1.Comment, DoxGraphQLContext>(
              'userId',
              graphqlInt,
              resolve: (i1.Comment s, ResolveInfo<DoxGraphQLContext> info) =>
                  s.userId,
            ),
          if (show('body'))
            Field<i1.Comment, DoxGraphQLContext>(
              'body',
              graphqlString,
              resolve: (i1.Comment s, ResolveInfo<DoxGraphQLContext> info) =>
                  s.body,
            ),
          if (show('user'))
            Field<i1.Comment, DoxGraphQLContext>(
              'user',
              _tUser,
              resolve: (i1.Comment s, ResolveInfo<DoxGraphQLContext> info) =>
                  GraphQLOrm.relation<i1.Comment, i6.User?>(
                    s,
                    'user',
                    info.context,
                    (i1.Comment p) => p.user,
                  ),
            ),
        ];
      },
    );

final ObjectType<i2.GqlSecret, DoxGraphQLContext>
_tGqlSecret = ObjectType<i2.GqlSecret, DoxGraphQLContext>(
  'GqlSecret',
  description:
      'A private row of test/e2e_33_graphql.dart. Only its owner sees it.',
  auth: true,
  fields: () {
    i2.GqlSecret model = i2.GqlSecret();
    List<String> hidden = model.hidden;
    List<String> visible = model.visibleFields;
    bool show(String name) =>
        !hidden.contains(name) && (visible.isEmpty || visible.contains(name));
    return <Field<i2.GqlSecret, DoxGraphQLContext>>[
      if (show('id'))
        Field<i2.GqlSecret, DoxGraphQLContext>(
          'id',
          graphqlId.nonNull,
          resolve: (i2.GqlSecret s, ResolveInfo<DoxGraphQLContext> info) =>
              s.id,
        ),
      if (show('user_id'))
        Field<i2.GqlSecret, DoxGraphQLContext>(
          'userId',
          graphqlInt,
          resolve: (i2.GqlSecret s, ResolveInfo<DoxGraphQLContext> info) =>
              s.userId,
        ),
      if (show('post_id'))
        Field<i2.GqlSecret, DoxGraphQLContext>(
          'postId',
          graphqlInt,
          resolve: (i2.GqlSecret s, ResolveInfo<DoxGraphQLContext> info) =>
              s.postId,
        ),
      if (show('body'))
        Field<i2.GqlSecret, DoxGraphQLContext>(
          'body',
          graphqlString,
          resolve: (i2.GqlSecret s, ResolveInfo<DoxGraphQLContext> info) =>
              s.body,
        ),
      if (show('post'))
        Field<i2.GqlSecret, DoxGraphQLContext>(
          'post',
          _tPost,
          description:
              'a single relation to Post: `view` of PostPolicy makes it null',
          resolve: (i2.GqlSecret s, ResolveInfo<DoxGraphQLContext> info) =>
              _allowIf<i3.Post>(info, 'viewAny').then(
                (_) => _viewOne<i3.Post>(
                  info,
                  GraphQLOrm.relation<i2.GqlSecret, i3.Post?>(
                    s,
                    'post',
                    info.context,
                    (i2.GqlSecret p) => p.post,
                  ),
                ),
              ),
        ),
    ];
  },
);

final ObjectType<i3.Post, DoxGraphQLContext> _tPost =
    ObjectType<i3.Post, DoxGraphQLContext>(
      'Post',
      description: 'One row in the `posts` table. Delete only sets `deleted_at`.\nGraphQL: public reads, PostPolicy checks, the owner is the caller.',
      auth: false,
      fields: () {
        i3.Post model = i3.Post();
        List<String> hidden = model.hidden;
        List<String> visible = model.visibleFields;
        bool show(String name) =>
            !hidden.contains(name) &&
            (visible.isEmpty || visible.contains(name));
        return <Field<i3.Post, DoxGraphQLContext>>[
          if (show('id'))
            Field<i3.Post, DoxGraphQLContext>(
              'id',
              graphqlId.nonNull,
              resolve: (i3.Post s, ResolveInfo<DoxGraphQLContext> info) => s.id,
            ),
          if (show('user_id'))
            Field<i3.Post, DoxGraphQLContext>(
              'userId',
              graphqlInt,
              resolve: (i3.Post s, ResolveInfo<DoxGraphQLContext> info) =>
                  s.userId,
            ),
          if (show('title'))
            Field<i3.Post, DoxGraphQLContext>(
              'title',
              graphqlString,
              resolve: (i3.Post s, ResolveInfo<DoxGraphQLContext> info) =>
                  s.title,
            ),
          if (show('body'))
            Field<i3.Post, DoxGraphQLContext>(
              'body',
              graphqlString,
              resolve: (i3.Post s, ResolveInfo<DoxGraphQLContext> info) =>
                  s.body,
            ),
          if (show('status'))
            Field<i3.Post, DoxGraphQLContext>(
              'status',
              graphqlString,
              resolve: (i3.Post s, ResolveInfo<DoxGraphQLContext> info) =>
                  s.status,
            ),
          if (show('views'))
            Field<i3.Post, DoxGraphQLContext>(
              'views',
              graphqlInt,
              description: 'how many times the post was viewed. `increment(\'views\')` adds 1.',
              resolve: (i3.Post s, ResolveInfo<DoxGraphQLContext> info) =>
                  s.views,
            ),
          if (show('deleted_at'))
            Field<i3.Post, DoxGraphQLContext>(
              'deletedAt',
              graphqlDateTime,
              resolve: (i3.Post s, ResolveInfo<DoxGraphQLContext> info) =>
                  s.deletedAt,
            ),
          if (show('author'))
            Field<i3.Post, DoxGraphQLContext>(
              'author',
              _tUser,
              resolve: (i3.Post s, ResolveInfo<DoxGraphQLContext> info) =>
                  GraphQLOrm.relation<i3.Post, i6.User?>(
                    s,
                    'author',
                    info.context,
                    (i3.Post p) => p.author,
                  ),
            ),
          if (show('comments'))
            Field<i3.Post, DoxGraphQLContext>(
              'comments',
              _tComment.nonNull.list.nonNull,
              resolve: (i3.Post s, ResolveInfo<DoxGraphQLContext> info) =>
                  GraphQLOrm.many<i3.Post, i1.Comment>(
                    s,
                    'comments',
                    info.context,
                    (i3.Post p) => p.comments,
                  ),
            ),
          if (show('tags'))
            Field<i3.Post, DoxGraphQLContext>(
              'tags',
              _tTag.nonNull.list.nonNull,
              resolve: (i3.Post s, ResolveInfo<DoxGraphQLContext> info) =>
                  GraphQLOrm.many<i3.Post, i5.Tag>(
                    s,
                    'tags',
                    info.context,
                    (i3.Post p) => p.tags,
                    pivot: true,
                  ),
            ),
        ];
      },
    );

final ObjectType<i4.Profile, DoxGraphQLContext>
_tProfile = ObjectType<i4.Profile, DoxGraphQLContext>(
  'Profile',
  description: 'One row in the `profiles` table. Each user has one profile.',
  fields: () {
    i4.Profile model = i4.Profile();
    List<String> hidden = model.hidden;
    List<String> visible = model.visibleFields;
    bool show(String name) =>
        !hidden.contains(name) && (visible.isEmpty || visible.contains(name));
    return <Field<i4.Profile, DoxGraphQLContext>>[
      if (show('id'))
        Field<i4.Profile, DoxGraphQLContext>(
          'id',
          graphqlId.nonNull,
          resolve: (i4.Profile s, ResolveInfo<DoxGraphQLContext> info) => s.id,
        ),
      if (show('user_id'))
        Field<i4.Profile, DoxGraphQLContext>(
          'userId',
          graphqlInt,
          resolve: (i4.Profile s, ResolveInfo<DoxGraphQLContext> info) =>
              s.userId,
        ),
      if (show('bio'))
        Field<i4.Profile, DoxGraphQLContext>(
          'bio',
          graphqlString,
          resolve: (i4.Profile s, ResolveInfo<DoxGraphQLContext> info) => s.bio,
        ),
      if (show('website'))
        Field<i4.Profile, DoxGraphQLContext>(
          'website',
          graphqlString,
          resolve: (i4.Profile s, ResolveInfo<DoxGraphQLContext> info) =>
              s.website,
        ),
      if (show('user'))
        Field<i4.Profile, DoxGraphQLContext>(
          'user',
          _tUser,
          resolve: (i4.Profile s, ResolveInfo<DoxGraphQLContext> info) =>
              GraphQLOrm.relation<i4.Profile, i6.User?>(
                s,
                'user',
                info.context,
                (i4.Profile p) => p.user,
              ),
        ),
    ];
  },
);

final ObjectType<i5.Tag, DoxGraphQLContext> _tTag =
    ObjectType<i5.Tag, DoxGraphQLContext>(
      'Tag',
      description: 'One row in the `tags` table.',
      fields: () {
        i5.Tag model = i5.Tag();
        List<String> hidden = model.hidden;
        List<String> visible = model.visibleFields;
        bool show(String name) =>
            !hidden.contains(name) &&
            (visible.isEmpty || visible.contains(name));
        return <Field<i5.Tag, DoxGraphQLContext>>[
          if (show('id'))
            Field<i5.Tag, DoxGraphQLContext>(
              'id',
              graphqlId.nonNull,
              resolve: (i5.Tag s, ResolveInfo<DoxGraphQLContext> info) => s.id,
            ),
          if (show('name'))
            Field<i5.Tag, DoxGraphQLContext>(
              'name',
              graphqlString,
              resolve: (i5.Tag s, ResolveInfo<DoxGraphQLContext> info) =>
                  s.name,
            ),
          if (show('posts'))
            Field<i5.Tag, DoxGraphQLContext>(
              'posts',
              _tPost.nonNull.list.nonNull,
              resolve: (i5.Tag s, ResolveInfo<DoxGraphQLContext> info) =>
                  _allowIf<i3.Post>(info, 'viewAny').then(
                    (_) => _viewList<i3.Post>(
                      info,
                      GraphQLOrm.many<i5.Tag, i3.Post>(
                        s,
                        'posts',
                        info.context,
                        (i5.Tag p) => p.posts,
                        pivot: true,
                      ),
                    ),
                  ),
            ),
        ];
      },
    );

final ObjectType<i6.User, DoxGraphQLContext> _tUser =
    ObjectType<i6.User, DoxGraphQLContext>(
      'User',
      description: 'One row in the `users` table.\nNotifiable: `user.notify(AccountReady())` emails the user.\nGraphQL: every field that gives a User needs a login. `password` is\nin `hidden`, so it is not in the schema.',
      auth: true,
      fields: () {
        i6.User model = i6.User();
        List<String> hidden = model.hidden;
        List<String> visible = model.visibleFields;
        bool show(String name) =>
            !hidden.contains(name) &&
            (visible.isEmpty || visible.contains(name));
        return <Field<i6.User, DoxGraphQLContext>>[
          if (show('id'))
            Field<i6.User, DoxGraphQLContext>(
              'id',
              graphqlId.nonNull,
              resolve: (i6.User s, ResolveInfo<DoxGraphQLContext> info) => s.id,
            ),
          if (show('name'))
            Field<i6.User, DoxGraphQLContext>(
              'name',
              graphqlString,
              resolve: (i6.User s, ResolveInfo<DoxGraphQLContext> info) =>
                  s.name,
            ),
          if (show('email'))
            Field<i6.User, DoxGraphQLContext>(
              'email',
              graphqlString,
              resolve: (i6.User s, ResolveInfo<DoxGraphQLContext> info) =>
                  s.email,
            ),
          if (show('password'))
            Field<i6.User, DoxGraphQLContext>(
              'password',
              graphqlString,
              resolve: (i6.User s, ResolveInfo<DoxGraphQLContext> info) =>
                  s.password,
            ),
          if (show('first_name'))
            Field<i6.User, DoxGraphQLContext>(
              'firstName',
              graphqlString,
              resolve: (i6.User s, ResolveInfo<DoxGraphQLContext> info) =>
                  s.firstName,
            ),
          if (show('last_name'))
            Field<i6.User, DoxGraphQLContext>(
              'lastName',
              graphqlString,
              resolve: (i6.User s, ResolveInfo<DoxGraphQLContext> info) =>
                  s.lastName,
            ),
          if (show('profile'))
            Field<i6.User, DoxGraphQLContext>(
              'profile',
              _tProfile,
              resolve: (i6.User s, ResolveInfo<DoxGraphQLContext> info) =>
                  GraphQLOrm.relation<i6.User, i4.Profile?>(
                    s,
                    'profile',
                    info.context,
                    (i6.User p) => p.profile,
                  ),
            ),
          if (show('posts'))
            Field<i6.User, DoxGraphQLContext>(
              'posts',
              _tPost.nonNull.list.nonNull,
              resolve: (i6.User s, ResolveInfo<DoxGraphQLContext> info) =>
                  _allowIf<i3.Post>(info, 'viewAny').then(
                    (_) => _viewList<i3.Post>(
                      info,
                      GraphQLOrm.many<i6.User, i3.Post>(
                        s,
                        'posts',
                        info.context,
                        (i6.User p) => p.posts,
                      ),
                    ),
                  ),
            ),
        ];
      },
    );

final InputObjectType _iCreateGqlSecretInput = InputObjectType(
  'CreateGqlSecretInput',
  description: 'The input of `createGqlSecret`. `policy:` needs a DTO.',
  fields: () => <InputField>[
    InputField('body', graphqlString),
    InputField('postId', graphqlInt),
  ],
);

Map<String, Object?> _mCreateGqlSecretInput(InputValues v) {
  return <String, Object?>{
    if (v.has('body')) 'body': v.get<Object?>('body'),
    if (v.has('postId')) 'post_id': v.get<Object?>('postId'),
  };
}

Future<i7.GqlSecretInput> _vCreateGqlSecretInput(
  InputValues v,
  DoxGraphQLContext context,
) {
  return GraphQLDto.validate<i7.GqlSecretInput>(
    i7.$GqlSecretInputDto,
    _mCreateGqlSecretInput(v),
    context,
    names: const <String, String>{'post_id': 'postId'},
  );
}

final InputObjectType _iUpdateGqlSecretInput = InputObjectType(
  'UpdateGqlSecretInput',
  description: 'The input of `createGqlSecret`. `policy:` needs a DTO.',
  fields: () => <InputField>[
    InputField('body', graphqlString),
    InputField('postId', graphqlInt),
  ],
);

Map<String, Object?> _mUpdateGqlSecretInput(InputValues v) {
  return <String, Object?>{
    if (v.has('body')) 'body': v.get<Object?>('body'),
    if (v.has('postId')) 'post_id': v.get<Object?>('postId'),
  };
}

final InputObjectType _iCreatePostInput = InputObjectType(
  'CreatePostInput',
  description: 'The input of `createPost` and `updatePost` (GraphQL). No `userId`:\nthe owner is the logged-in user.',
  fields: () => <InputField>[
    InputField('title', graphqlString),
    InputField('body', graphqlString),
    InputField('status', graphqlString),
  ],
);

Map<String, Object?> _mCreatePostInput(InputValues v) {
  return <String, Object?>{
    if (v.has('title')) 'title': v.get<Object?>('title'),
    if (v.has('body')) 'body': v.get<Object?>('body'),
    if (v.has('status')) 'status': v.get<Object?>('status'),
  };
}

Future<i7.GqlPostInput> _vCreatePostInput(
  InputValues v,
  DoxGraphQLContext context,
) {
  return GraphQLDto.validate<i7.GqlPostInput>(
    i7.$GqlPostInputDto,
    _mCreatePostInput(v),
    context,
    names: const <String, String>{},
  );
}

final InputObjectType _iUpdatePostInput = InputObjectType(
  'UpdatePostInput',
  description: 'The input of `createPost` and `updatePost` (GraphQL). No `userId`:\nthe owner is the logged-in user.',
  fields: () => <InputField>[
    InputField('title', graphqlString),
    InputField('body', graphqlString),
    InputField('status', graphqlString),
  ],
);

Map<String, Object?> _mUpdatePostInput(InputValues v) {
  return <String, Object?>{
    if (v.has('title')) 'title': v.get<Object?>('title'),
    if (v.has('body')) 'body': v.get<Object?>('body'),
    if (v.has('status')) 'status': v.get<Object?>('status'),
  };
}

/// The GqlSecret with the id, after the `view` check of the policy when it has
/// one. A missing id is checked as a blank GqlSecret, so a user the policy
/// denies gets the same error for an id that exists and one that does not.
Future<i2.GqlSecret?> _findGqlSecret(
  ResolveInfo<DoxGraphQLContext> info,
) async {
  bool view = Gate.hasAbility<i2.GqlSecret>('view');
  if (view) await _login(info);
  i2.GqlSecret? model = await GraphQLOrm.find<i2.GqlSecret>(
    i2.GqlSecret(),
    int.tryParse(info.args.get<String>('id')!),
  );
  if (view) {
    await (model == null
        ? _allowMissing(info, 'view', i2.GqlSecret())
        : _allow(info, 'view', model));
  }
  return model;
}

/// Makes a GqlSecret from the input of `createGqlSecret`.
Future<i2.GqlSecret> _createGqlSecret(
  ResolveInfo<DoxGraphQLContext> info,
) async {
  await _allowIf<i2.GqlSecret>(info, 'create');
  i7.GqlSecretInput dto = await _vCreateGqlSecretInput(
    info.args.input('input')!,
    info.context,
  );
  i2.GqlSecret model = i2.GqlSecret()
    ..body = dto.body
    ..postId = dto.postId;
  model.userId = await GraphQLAuth.ownerId<int>(
    info.context,
    'GqlSecret.userId',
  );
  await model.save();
  return model;
}

/// Sets the fields the client sent on a GqlSecret. Null when there is no
/// GqlSecret with that id and the policy allows the update of a blank one.
Future<i2.GqlSecret?> _updateGqlSecret(
  ResolveInfo<DoxGraphQLContext> info,
) async {
  await _login(info);
  i2.GqlSecret? model = await GraphQLOrm.find<i2.GqlSecret>(
    i2.GqlSecret(),
    int.tryParse(info.args.get<String>('id')!),
  );
  if (model == null) {
    await _allowMissing(info, 'update', i2.GqlSecret());
    return null;
  }
  await _allow(info, 'update', model);
  InputValues input = info.args.input('input')!;
  Map<String, Object?> given = _mUpdateGqlSecretInput(input);
  // the other fields keep their stored values, and are not checked
  i7.GqlSecretInput dto = await GraphQLDto.validateSent<i7.GqlSecretInput>(
    i7.$GqlSecretInputDto,
    <String, Object?>{'body': model.body, 'post_id': model.postId, ...given},
    info.context,
    sent: given.keys.toSet(),
    placeholders: const <String, Object?>{'body': '-', 'post_id': 0},
    names: const <String, String>{'post_id': 'postId'},
    params: <String, String>{'id': '${model.id}'},
  );
  if (input.has('body')) model.body = dto.body;
  if (input.has('postId')) model.postId = dto.postId;
  await model.save();
  return model;
}

/// Deletes a GqlSecret. False when there is no GqlSecret with that id and the
/// policy allows the delete of a blank one.
Future<bool> _deleteGqlSecret(ResolveInfo<DoxGraphQLContext> info) async {
  await _login(info);
  i2.GqlSecret? model = await GraphQLOrm.find<i2.GqlSecret>(
    i2.GqlSecret(),
    int.tryParse(info.args.get<String>('id')!),
  );
  if (model == null) {
    await _allowMissing(info, 'delete', i2.GqlSecret());
    return false;
  }
  await _allow(info, 'delete', model);
  await model.delete();
  return true;
}

/// The Post with the id, after the `view` check of the policy when it has
/// one. A missing id is checked as a blank Post, so a user the policy
/// denies gets the same error for an id that exists and one that does not.
Future<i3.Post?> _findPost(ResolveInfo<DoxGraphQLContext> info) async {
  bool view = Gate.hasAbility<i3.Post>('view');
  i3.Post? model = await GraphQLOrm.find<i3.Post>(
    i3.Post(),
    int.tryParse(info.args.get<String>('id')!),
  );
  if (view) {
    await (model == null
        ? _allowMissing(info, 'view', i3.Post())
        : _allow(info, 'view', model));
  }
  return model;
}

/// Makes a Post from the input of `createPost`.
Future<i3.Post> _createPost(ResolveInfo<DoxGraphQLContext> info) async {
  await _allowIf<i3.Post>(info, 'create');
  i7.GqlPostInput dto = await _vCreatePostInput(
    info.args.input('input')!,
    info.context,
  );
  i3.Post model = i3.Post()
    ..title = dto.title
    ..body = dto.body
    ..status = dto.status;
  model.userId = await GraphQLAuth.ownerId<int>(info.context, 'Post.userId');
  await model.save();
  return model;
}

/// Sets the fields the client sent on a Post. Null when there is no
/// Post with that id and the policy allows the update of a blank one.
Future<i3.Post?> _updatePost(ResolveInfo<DoxGraphQLContext> info) async {
  i3.Post? model = await GraphQLOrm.find<i3.Post>(
    i3.Post(),
    int.tryParse(info.args.get<String>('id')!),
  );
  if (model == null) {
    await _allowMissing(info, 'update', i3.Post());
    return null;
  }
  await _allow(info, 'update', model);
  InputValues input = info.args.input('input')!;
  Map<String, Object?> given = _mUpdatePostInput(input);
  // the other fields keep their stored values, and are not checked
  i7.GqlPostInput dto = await GraphQLDto.validateSent<i7.GqlPostInput>(
    i7.$GqlPostInputDto,
    <String, Object?>{
      'title': model.title,
      'body': model.body,
      'status': model.status,
      ...given,
    },
    info.context,
    sent: given.keys.toSet(),
    placeholders: const <String, Object?>{
      'title': '-',
      'body': '-',
      'status': '-',
    },
    names: const <String, String>{},
    params: <String, String>{'id': '${model.id}'},
  );
  if (input.has('title')) model.title = dto.title;
  if (input.has('body')) model.body = dto.body;
  if (input.has('status')) model.status = dto.status;
  await model.save();
  return model;
}

/// Deletes a Post. False when there is no Post with that id and the
/// policy allows the delete of a blank one.
Future<bool> _deletePost(ResolveInfo<DoxGraphQLContext> info) async {
  i3.Post? model = await GraphQLOrm.find<i3.Post>(
    i3.Post(),
    int.tryParse(info.args.get<String>('id')!),
  );
  if (model == null) {
    await _allowMissing(info, 'delete', i3.Post());
    return false;
  }
  await _allow(info, 'delete', model);
  await model.delete();
  return true;
}

/// Asks the policy (registered with `Gate.policy`) if the user may do
/// [ability] on [subject]: a row, or the model type. Throws when not:
/// "Unauthenticated" for a guest, else "Forbidden".
Future<void> _allow(
  ResolveInfo<DoxGraphQLContext> info,
  String ability,
  Object subject,
) async {
  Object? user = await info.context.user<Object>();
  if (!await Gate.allows(user, ability, subject)) throw _denied(user);
}

/// [_allow] for an id with no row: [blank] is a new, empty row. A user
/// the policy denies gets the same error as for a row that exists, so the
/// answer does not show which ids exist. A policy that fails to read the
/// empty row (a null check, a missing value) denies. Other errors, like a
/// database error, are thrown.
Future<void> _allowMissing(
  ResolveInfo<DoxGraphQLContext> info,
  String ability,
  Object blank,
) async {
  Object? user = await info.context.user<Object>();
  bool allowed;
  try {
    allowed = await Gate.allows(user, ability, blank);
  } on TypeError {
    allowed = false;
  } on StateError {
    allowed = false;
  } on NoSuchMethodError {
    allowed = false;
  }
  if (!allowed) throw _denied(user);
}

/// [_allow] on the model type [T], when the policy of [T] lists
/// [ability] (`viewAny`, `create`). Else nothing is checked.
Future<void> _allowIf<T>(
  ResolveInfo<DoxGraphQLContext> info,
  String ability,
) async {
  if (Gate.hasAbility<T>(ability)) await _allow(info, ability, T);
}

/// The rows of [rows] that the `view` ability of the policy allows, when
/// the policy of [T] lists `view`. The others are left out, with no error.
Future<List<T>?> _viewList<T extends Object>(
  ResolveInfo<DoxGraphQLContext> info,
  Future<List<T>?> rows,
) async {
  List<T>? list = await rows;
  if (list == null || list.isEmpty || !Gate.hasAbility<T>('view')) {
    return list;
  }
  Object? user = await info.context.user<Object>();
  return <T>[
    for (T row in list)
      if (await Gate.allows(user, 'view', row)) row,
  ];
}

/// [row] when the `view` ability of the policy allows it (or the policy
/// of [T] does not list `view`), else null.
Future<T?> _viewOne<T extends Object>(
  ResolveInfo<DoxGraphQLContext> info,
  Future<T?> row,
) async {
  T? value = await row;
  if (value == null || !Gate.hasAbility<T>('view')) return value;
  Object? user = await info.context.user<Object>();
  return await Gate.allows(user, 'view', value) ? value : null;
}

/// "Unauthenticated" before the row lookup, when the policy denies every
/// guest.
Future<void> _login(ResolveInfo<DoxGraphQLContext> info) async {
  if (await info.context.auth() == null)
    throw GraphQLAuth.unauthenticatedError();
}

GraphQLError _denied(Object? user) =>
    user == null ? GraphQLAuth.unauthenticatedError() : GraphQLAuth.forbidden();
