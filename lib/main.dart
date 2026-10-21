import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neu_trade/core/config/app_config.dart';
import 'package:neu_trade/core/di/dependency_injection.dart';
import 'package:neu_trade/core/router/app_router.dart';
import 'package:neu_trade/core/theme/app_theme.dart';
import 'package:neu_trade/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:neu_trade/features/auth/presentation/bloc/auth_event.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConfig.supabaseURL,
    publishableKey: AppConfig.publishableKey,
  );

  await initDependencies();

  final authBloc = sl<AuthBloc>()..add(const AuthSessionRestoreRequested());

  runApp(MyApp(authBloc: authBloc));
}

class MyApp extends StatelessWidget {
  MyApp({
    super.key,
    required AuthBloc authBloc,
  }) : _authBloc = authBloc,
       _router = createAppRouter(authBloc);

  final AuthBloc _authBloc;
  final RouterConfig<Object> _router;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc,
      child: MaterialApp.router(
        title: 'NEU Trade',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}
