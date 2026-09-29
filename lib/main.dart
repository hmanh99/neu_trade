import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neu_trade/core/config/app_config.dart';
import 'package:neu_trade/core/router/app_router.dart';
import 'package:neu_trade/core/services/auth_services.dart';
import 'package:neu_trade/core/services/profile_services.dart';
import 'package:neu_trade/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:neu_trade/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:neu_trade/features/auth/domain/usecases/forgot_password_use_case.dart';
import 'package:neu_trade/features/auth/domain/usecases/get_current_user_use_case.dart';
import 'package:neu_trade/features/auth/domain/usecases/login_use_case.dart';
import 'package:neu_trade/features/auth/domain/usecases/logout_use_case.dart';
import 'package:neu_trade/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:neu_trade/features/auth/domain/usecases/watch_auth_state_use_case.dart';
import 'package:neu_trade/features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'package:neu_trade/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:neu_trade/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:neu_trade/features/profile/domain/repositories/profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConfig.supabaseURL,
    publishableKey: AppConfig.publishableKey,
  );

  final datasource = AuthRemoteDataSourceImpl(AuthServices());
  final repository = AuthRepositoryImpl(remoteDatasource: datasource);
  final authBloc = AuthBloc(
    getCurrentUser: GetCurrentUserUseCase(repository),
    login: LoginUseCase(repository),
    signUp: SignUpUseCase(repository),
    forgotPassword: ForgotPasswordUseCase(repository),
    logout: LogoutUseCase(repository),
    watchAuthState: WatchAuthStateUseCase(repository),
  )..add(const AuthSessionRestoreRequested());

  final profileRepository = ProfileRepositoryImpl(
    remoteDatasource: ProfileRemoteDataSourceImpl(ProfileServices()),
  );

  runApp(MyApp(authBloc: authBloc, profileRepository: profileRepository));
}

class MyApp extends StatelessWidget {
  MyApp({
    super.key,
    required AuthBloc authBloc,
    required ProfileRepository profileRepository,
  }) : _authBloc = authBloc,
       _router = createAppRouter(
         authBloc,
         profileRepository: profileRepository,
       );

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
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        routerConfig: _router,
      ),
    );
  }
}
