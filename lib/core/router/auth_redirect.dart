import 'package:neu_trade/core/router/route_paths.dart';
import 'package:neu_trade/features/auth/presentation/bloc/auth_state.dart';

/// Guard / redirect base on [AuthState] and current [URL].

String resolveAuthReturnLocation(String? rawLocation, {bool isAdmin = false}) {
  if (rawLocation == null || rawLocation.isEmpty) {
    return AppRoutePaths.appHome;
  }

  final uri = Uri.tryParse(rawLocation);
  if (uri == null ||
      uri.hasScheme ||
      uri.hasAuthority ||
      !AppRoutePaths.isAppShellPath(uri.path)) {
    return AppRoutePaths.appHome;
  }

  if (AppRoutePaths.isAdminPath(uri.path) && !isAdmin) {
    return AppRoutePaths.appHome;
  }

  return uri.toString();
}

String? resolveAuthRedirect({
  required AuthState authState,
  required String location,
}) {
  final uri = Uri.parse(location);
  final path = uri.path;

  final isLoggingIn = AppRoutePaths.isAuthPath(path);

  final authenticated = authState is AuthAuthenticatedState;

  // Un_auth -> sign in
  if (!authenticated) {
    if (AppRoutePaths.isAppShellPath(path)) {
      /// -> auth/[location]
      return Uri(
        path: AppRoutePaths.login,
        queryParameters: {'from': location},
      ).toString();
    }
    return null;
  }

  // Preserve a protected deep link after authentication.
  if (authenticated && isLoggingIn) {
    if (authState is AuthLoginState && !authState.isProfileCompleted) {
      return AppRoutePaths.profileSetup;
    }
    final isAdmin = authState is AuthLoginState && authState.isAdmin;
    return resolveAuthReturnLocation(
      uri.queryParameters['from'],
      isAdmin: isAdmin,
    );
  }

  if (authState is AuthLoginState &&
      authState.isProfileCompleted &&
      path == AppRoutePaths.profileSetup) {
    return AppRoutePaths.appHome;
  }

  // Admin route protection:
  if (AppRoutePaths.isAdminPath(path)) {
    final isAdmin = authState is AuthLoginState && authState.isAdmin;
    if (!isAdmin) {
      return AppRoutePaths.appHome;
    }
  }

  // The user is already inside a protected route.
  return null;
}
