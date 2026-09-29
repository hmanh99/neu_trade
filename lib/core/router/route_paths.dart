/// Canonical URL paths for deep linking & redirects.
/// Use [GoRouter] for `path`, `context.go`, and check `state.matchedLocation`.
///
abstract final class AppRoutePaths {
  AppRoutePaths._();

  static const auth = '/auth';
  static const login = '/auth/login';
  static const signUp = '/auth/sign-up';
  static const forgotPassword = '/auth/forgot-password';

  ///redirect to [appHome] if user direct correctly to `/app`.
  static const app = '/app';

  static const appHome = '/app/home';
  static const post = '/app/post';
  static const transaction = '/app/transaction';
  static const profile = '/app/profile';
  static const profileSetup = '/app/profile/setup';

  static bool isAuthPath(String location) {
    final path = Uri.parse(location).path;
    return _isPathWithin(path, auth);
  }

  static bool isAppShellPath(String location) {
    final path = Uri.parse(location).path;
    return _isPathWithin(path, app);
  }

  static bool _isPathWithin(String path, String root) =>
      path == root || path.startsWith('$root/');
}
