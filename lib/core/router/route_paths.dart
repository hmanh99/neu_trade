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
  static const postDetail = '/app/home/post/:id';
  static const upload = '/app/upload';
  static const transaction = '/app/transaction';
  static const profile = '/app/profile';
  static const profileSetup = '/app/profile/setup';
  static const postHistory = '/app/profile/posts';
  static const circulationStats = '/app/profile/admin/statistics';
  static const adminPosts = '/app/profile/admin/posts';
  static const adminReports = '/app/profile/admin/reports';

  static bool isAuthPath(String location) {
    final path = Uri.parse(location).path;
    return _isPathWithin(path, auth);
  }

  static bool isAppShellPath(String location) {
    final path = Uri.parse(location).path;
    return _isPathWithin(path, app);
  }

  static bool isAdminPath(String location) {
    final path = Uri.parse(location).path;
    return _isPathWithin(path, '/app/profile/admin');
  }

  static bool _isPathWithin(String path, String root) =>
      path == root || path.startsWith('$root/');
}
