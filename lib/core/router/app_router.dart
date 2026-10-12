import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neu_trade/core/router/route_names.dart';
import 'package:neu_trade/core/router/route_paths.dart';
import 'package:neu_trade/core/services/post_services.dart';
import 'package:neu_trade/core/services/report_services.dart';
import 'package:neu_trade/core/services/transaction_services.dart';
import 'package:neu_trade/features/home/presentation/bloc/post_detail_bloc.dart';
import 'package:neu_trade/features/profile/domain/repositories/profile_repository.dart';
import 'package:neu_trade/features/profile/domain/usecases/get_profile_use_case.dart';
import 'package:neu_trade/features/profile/domain/usecases/save_profile_use_case.dart';
import 'package:neu_trade/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:neu_trade/features/profile/presentation/screens/profile_setup_screen.dart';
import 'package:neu_trade/features/transaction/data/datasources/transaction_remote_datasource.dart';
import 'package:neu_trade/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:neu_trade/features/transaction/domain/usecases/complete_transaction_usecase.dart';
import 'package:neu_trade/features/transaction/domain/usecases/create_transaction_usecase.dart';
import 'package:neu_trade/features/transaction/domain/usecases/get_transactions_usecase.dart';
import 'package:neu_trade/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:neu_trade/features/upload/data/datasources/post_remote_datasources.dart';
import 'package:neu_trade/features/upload/data/repositories/upload_post_repository_impl.dart';
import 'package:neu_trade/features/upload/domain/usecases/create_post_use_case.dart';
import 'package:neu_trade/features/upload/presentation/bloc/upload_post_bloc.dart';
import 'package:neu_trade/features/upload/presentation/screens/upload_post_screen.dart';
import 'package:neu_trade/shared/wigdets/main_shell.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/home/data/datasources/home_post_remote_datasource.dart';
import '../../features/home/data/datasources/home_post_report_datasource.dart';
import '../../features/home/data/repositories/home_post_repository_impl.dart';
import '../../features/home/data/repositories/home_post_report_repository_impl.dart';
import '../../features/home/domain/usecases/get_home_post_usecase.dart';
import '../../features/home/domain/usecases/get_home_posts_usecase.dart';
import '../../features/home/domain/usecases/send_home_report_usecase.dart';
import '../../features/home/presentation/bloc/home_post_bloc.dart';
import '../../features/home/presentation/screens/home_post_screen.dart';
import '../../features/home/presentation/screens/post_detail_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/transaction/presentation/screens/transaction_screen.dart';
import 'auth_redirect.dart';
import 'go_router_refresh_stream.dart';

GoRouter createAppRouter(
  AuthBloc authBloc, {
  required ProfileRepository profileRepository,
}) {
  return GoRouter(
    initialLocation: AppRoutePaths.login,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      return resolveAuthRedirect(
        authState: authBloc.state,
        location: state.uri.toString(),
      );
    },
    routes: [
      /// auth
      GoRoute(
        path: AppRoutePaths.login,
        name: AppRouteNames.login,
        builder: (context, state) {
          return LoginScreen(
            returnTo: resolveAuthReturnLocation(
              state.uri.queryParameters['from'],
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutePaths.signUp,
        name: AppRouteNames.signUp,
        builder: (context, state) {
          return SignUpScreen(
            returnTo: resolveAuthReturnLocation(
              state.uri.queryParameters['from'],
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutePaths.forgotPassword,
        name: AppRouteNames.forgotPassword,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'];
          return ForgotPasswordScreen(initialEmail: email);
        },
      ),

      GoRoute(
        path: AppRoutePaths.app,
        redirect: (context, state) => AppRoutePaths.appHome,
      ),

      /// Main app tabs.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.appHome,
                name: AppRouteNames.appHome,
                builder: (context, state) => BlocBuilder<AuthBloc, AuthState>(
                  bloc: authBloc,
                  builder: (context, authState) {
                    final user = switch (authState) {
                      AuthLoginState(:final user) => user,
                      AuthSignUpState(:final user) => user,
                      _ => null,
                    };
                    if (user == null) return const SizedBox.shrink();
                    final datasource = HomePostRemoteDatasourceImpl(
                      PostServices(userId: user.id),
                    );
                    final repository = HomePostRepositoryImpl(
                      homePostRemoteDatasource: datasource,
                    );
                    return BlocProvider(
                      key: ValueKey(user.id),
                      create: (_) => HomeBloc(
                        getHomePosts: GetHomePostsUsecase(repository),
                      ),
                      child: const HomeScreen(),
                    );
                  },
                ),
                routes: [
                  GoRoute(
                    path: 'post/:id',
                    name: AppRouteNames.postDetail,
                    builder: (context, state) {
                      final postId =
                          int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                      final authState = authBloc.state;
                      final user = switch (authState) {
                        AuthLoginState(:final user) => user,
                        AuthSignUpState(:final user) => user,
                        _ => null,
                      };
                      final userId = user?.id ?? '';

                      // Home post dependencies
                      final postDatasource = HomePostRemoteDatasourceImpl(
                        PostServices(userId: userId),
                      );
                      final postRepository = HomePostRepositoryImpl(
                        homePostRemoteDatasource: postDatasource,
                      );
                      final reportRepository = HomePostReportRepositoryImpl(
                        homePostReportDatasource: HomePostReportDatasourceImpl(
                          ReportServices(userId: userId),
                        ),
                      );

                      // Transaction dependencies for reservation
                      final transactionDatasource =
                          TransactionRemoteDatasourceImpl(
                        TransactionServices(userId: userId),
                      );
                      final transactionRepository = TransactionRepositoryImpl(
                        remoteDatasource: transactionDatasource,
                      );

                      return BlocProvider(
                        create: (_) => PostDetailBloc(
                          getHomePost: GetHomePostUsecase(postRepository),
                          createTransaction:
                              CreateTransactionUsecase(transactionRepository),
                          sendReport: SendHomeReportUsecase(reportRepository),
                        ),
                        child: PostDetailScreen(
                          postId: postId,
                          currentUserId: userId,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.upload,
                name: AppRouteNames.upload,
                builder: (context, state) => BlocBuilder<AuthBloc, AuthState>(
                  bloc: authBloc,
                  builder: (context, authState) {
                    final user = switch (authState) {
                      AuthLoginState(:final user) => user,
                      AuthSignUpState(:final user) => user,
                      _ => null,
                    };
                    if (user == null) return const SizedBox.shrink();
                    final repository = PostRepositoryImpl(
                      remoteDatasource: PostRemoteDataSourceImpl(
                        PostServices(userId: user.id),
                      ),
                    );
                    return BlocProvider(
                      key: ValueKey(user.id),
                      create: (_) =>
                          PostBloc(createPost: CreatePostUseCase(repository)),
                      child: const PostScreen(),
                    );
                  },
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.transaction,
                name: AppRouteNames.transaction,
                builder: (context, state) =>
                    BlocBuilder<AuthBloc, AuthState>(
                  bloc: authBloc,
                  builder: (context, authState) {
                    final user = switch (authState) {
                      AuthLoginState(:final user) => user,
                      AuthSignUpState(:final user) => user,
                      _ => null,
                    };
                    if (user == null) return const SizedBox.shrink();

                    final datasource = TransactionRemoteDatasourceImpl(
                      TransactionServices(userId: user.id),
                    );
                    final repository = TransactionRepositoryImpl(
                      remoteDatasource: datasource,
                    );

                    return BlocProvider(
                      key: ValueKey(user.id),
                      create: (_) => TransactionBloc(
                        getTransactions:
                            GetTransactionsUsecase(repository: repository),
                        completeTransaction:
                            CompleteTransactionUsecase(repository),
                      ),
                      child: TransactionScreen(currentUserId: user.id,),
                    );
                  },
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.profile,
                name: AppRouteNames.profile,
                builder: (context, state) => BlocBuilder<AuthBloc, AuthState>(
                  bloc: authBloc,
                  builder: (context, authState) {
                    final user = switch (authState) {
                      AuthLoginState(:final user) => user,
                      AuthSignUpState(:final user) => user,
                      _ => null,
                    };
                    // The auth guard redirects guests. Never retain another account's UI.
                    if (user == null) return const SizedBox.shrink();
                    return BlocProvider(
                      key: ValueKey(user.id),
                      create: (_) => ProfileBloc(
                        userId: user.id,
                        getProfile: GetProfileUseCase(profileRepository),
                        saveProfile: SaveProfileUseCase(profileRepository),
                      ),
                      child: const ProfileScreen(),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: AppRoutePaths.profileSetup,
        name: AppRouteNames.profileSetup,
        builder: (context, state) {
          final authState = authBloc.state;
          final user = switch (authState) {
            AuthLoginState(:final user) => user,
            AuthSignUpState(:final user) => user,
            _ => throw StateError('Authenticated user is required.'),
          };

          return BlocProvider(
            key: ValueKey(user.id),
            create: (context) => ProfileBloc(
              userId: user.id,
              getProfile: GetProfileUseCase(profileRepository),
              saveProfile: SaveProfileUseCase(profileRepository),
            ),
            child: ProfileSetupScreen(
              userId: user.id,
              initialEmail: user.email,
            ),
          );
        },
      ),
    ],
  );
}
