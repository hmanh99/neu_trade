import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neu_trade/core/di/dependency_injection.dart';
import 'package:neu_trade/core/router/route_names.dart';
import 'package:neu_trade/core/router/route_paths.dart';
import 'package:neu_trade/features/admin/presentation/bloc/post_approval_bloc.dart';
import 'package:neu_trade/features/admin/presentation/bloc/report_management_bloc.dart';
import 'package:neu_trade/features/admin/presentation/bloc/statistics_bloc.dart';
import 'package:neu_trade/features/admin/presentation/screens/circulation_stats_screen.dart';
import 'package:neu_trade/features/admin/presentation/screens/post_approval_screen.dart';
import 'package:neu_trade/features/admin/presentation/screens/report_management_screen.dart';
import 'package:neu_trade/features/home/domain/entities/home_post_entity.dart';
import 'package:neu_trade/features/home/presentation/bloc/post_detail_bloc.dart';
import 'package:neu_trade/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:neu_trade/features/profile/presentation/screens/post_history_screen.dart';
import 'package:neu_trade/features/profile/presentation/screens/profile_setup_screen.dart';
import 'package:neu_trade/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:neu_trade/features/upload/presentation/bloc/upload_post_bloc.dart';
import 'package:neu_trade/features/upload/presentation/screens/upload_post_screen.dart';
import 'package:neu_trade/shared/wigdets/main_shell.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/home/presentation/bloc/home_post_bloc.dart';
import '../../features/home/presentation/screens/home_post_screen.dart';
import '../../features/home/presentation/screens/post_detail_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/transaction/presentation/screens/transaction_screen.dart';
import 'auth_redirect.dart';
import 'go_router_refresh_stream.dart';

GoRouter createAppRouter(AuthBloc authBloc) {
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
              isAdmin: authBloc.state is AuthLoginState &&
                  (authBloc.state as AuthLoginState).isAdmin,
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
              isAdmin: authBloc.state is AuthLoginState &&
                  (authBloc.state as AuthLoginState).isAdmin,
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
                      _ => null,
                    };
                    if (user == null) return const SizedBox.shrink();
                    return BlocProvider(
                      key: ValueKey(user.id),
                      create: (_) => sl<HomeBloc>(),
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
                        _ => null,
                      };
                      final userId = user?.id ?? '';

                      return BlocProvider(
                        create: (_) => sl<PostDetailBloc>(),
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
                      _ => null,
                    };
                    if (user == null) return const SizedBox.shrink();
                    return BlocProvider(
                      key: ValueKey(user.id),
                      create: (_) => sl<PostBloc>(),
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
                builder: (context, state) => BlocBuilder<AuthBloc, AuthState>(
                  bloc: authBloc,
                  builder: (context, authState) {
                    final user = switch (authState) {
                      AuthLoginState(:final user) => user,
                      _ => null,
                    };
                    if (user == null) return const SizedBox.shrink();

                    return BlocProvider(
                      key: ValueKey(user.id),
                      create: (_) => sl<TransactionBloc>(),
                      child: TransactionScreen(currentUserId: user.id),
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
                      _ => null,
                    };
                    // The auth guard redirects guests. Never retain another account's UI.
                    if (user == null) return const SizedBox.shrink();
                    return BlocProvider(
                      key: ValueKey(user.id),
                      create: (_) => sl<ProfileBloc>(param1: user.id),
                      child: const ProfileScreen(),
                    );
                  },
                ),
                routes: [
                  GoRoute(
                    path: 'posts',
                    name: AppRouteNames.postHistory,
                    builder: (context, state) =>
                        BlocBuilder<AuthBloc, AuthState>(
                          bloc: authBloc,
                          builder: (context, authState) {
                            final user = switch (authState) {
                              AuthLoginState(:final user) => user,
                              _ => null,
                            };
                            if (user == null) return const SizedBox.shrink();
                            return PostHistoryScreen(
                              key: ValueKey(user.id),
                              userId: user.id,
                            );
                          },
                        ),
                    routes: [
                      GoRoute(
                        path: ':id',
                        name: AppRouteNames.profilePostDetail,
                        builder: (context, state) {
                          final postId =
                              int.tryParse(state.pathParameters['id'] ?? '') ??
                              0;
                          final authState = authBloc.state;
                          final user = switch (authState) {
                            AuthLoginState(:final user) => user,
                            _ => null,
                          };
                          final userId = user?.id ?? '';
                          final initialPost = state.extra is HomePostEntity
                              ? state.extra as HomePostEntity
                              : null;

                          return BlocProvider(
                            create: (_) =>
                                sl<PostDetailBloc>(param1: initialPost),
                            child: PostDetailScreen(
                              postId: postId,
                              currentUserId: userId,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'admin/statistics',
                    name: AppRouteNames.circulationStats,
                    builder: (context, state) =>
                        BlocBuilder<AuthBloc, AuthState>(
                          bloc: authBloc,
                          builder: (context, authState) {
                            final user = switch (authState) {
                              AuthLoginState(:final user) => user,
                              _ => null,
                            };
                            if (user == null) return const SizedBox.shrink();
                            return BlocProvider(
                              key: ValueKey(user.id),
                              create: (_) => sl<StatisticsBloc>(),
                              child: const CirculationStatsScreen(),
                            );
                          },
                        ),
                  ),
                  GoRoute(
                    path: 'admin/posts',
                    name: AppRouteNames.adminPosts,
                    builder: (context, state) =>
                        BlocBuilder<AuthBloc, AuthState>(
                          bloc: authBloc,
                          builder: (context, authState) {
                            final user = switch (authState) {
                              AuthLoginState(:final user) => user,
                              _ => null,
                            };
                            if (user == null) return const SizedBox.shrink();
                            return BlocProvider(
                              key: ValueKey(user.id),
                              create: (_) => sl<PostApprovalBloc>(),
                              child: const PostApprovalScreen(),
                            );
                          },
                        ),
                  ),
                  GoRoute(
                    path: 'admin/reports',
                    name: AppRouteNames.adminReports,
                    builder: (context, state) =>
                        BlocBuilder<AuthBloc, AuthState>(
                          bloc: authBloc,
                          builder: (context, authState) {
                            final user = switch (authState) {
                              AuthLoginState(:final user) => user,
                              _ => null,
                            };
                            if (user == null) return const SizedBox.shrink();
                            return BlocProvider(
                              key: ValueKey(user.id),
                              create: (_) => sl<ReportManagementBloc>(),
                              child: const ReportManagementScreen(),
                            );
                          },
                        ),
                  ),
                ],
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
            _ => throw StateError('Authenticated user is required.'),
          };

          return BlocProvider(
            key: ValueKey(user.id),
            create: (context) => sl<ProfileBloc>(param1: user.id),
            child: ProfileSetupScreen(
              userId: user.id,
              initialEmail: user.email,
              onProfileCompleted: () {
                authBloc.add(const AuthProfileCompletedEvent());
              },
            ),
          );
        },
      ),
    ],
  );
}
