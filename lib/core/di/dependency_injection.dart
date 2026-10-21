import 'package:get_it/get_it.dart';
import 'package:neu_trade/core/services/auth_services.dart';
import 'package:neu_trade/core/services/post_services.dart';
import 'package:neu_trade/core/services/profile_services.dart';
import 'package:neu_trade/core/services/report_services.dart';
import 'package:neu_trade/core/services/review_services.dart';
import 'package:neu_trade/core/services/statistics_services.dart';
import 'package:neu_trade/core/services/transaction_services.dart';
import 'package:neu_trade/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:neu_trade/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:neu_trade/features/auth/domain/repositories/auth_repository.dart';
import 'package:neu_trade/features/auth/domain/usecases/forgot_password_use_case.dart';
import 'package:neu_trade/features/auth/domain/usecases/get_current_user_use_case.dart';
import 'package:neu_trade/features/auth/domain/usecases/login_use_case.dart';
import 'package:neu_trade/features/auth/domain/usecases/logout_use_case.dart';
import 'package:neu_trade/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:neu_trade/features/auth/domain/usecases/watch_auth_state_use_case.dart';
import 'package:neu_trade/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:neu_trade/features/auth/presentation/bloc/auth_state.dart';
import 'package:neu_trade/features/home/data/datasources/home_post_remote_datasource.dart';
import 'package:neu_trade/features/home/data/datasources/home_post_report_datasource.dart';
import 'package:neu_trade/features/home/data/repositories/home_post_report_repository_impl.dart';
import 'package:neu_trade/features/home/data/repositories/home_post_repository_impl.dart';
import 'package:neu_trade/features/home/domain/entities/home_post_entity.dart';
import 'package:neu_trade/features/home/domain/repositories/home_post_report_repository.dart';
import 'package:neu_trade/features/home/domain/repositories/home_post_repository.dart';
import 'package:neu_trade/features/home/domain/usecases/get_home_post_usecase.dart';
import 'package:neu_trade/features/home/domain/usecases/get_home_posts_usecase.dart';
import 'package:neu_trade/features/home/domain/usecases/send_home_report_usecase.dart';
import 'package:neu_trade/features/home/presentation/bloc/home_post_bloc.dart';
import 'package:neu_trade/features/home/presentation/bloc/post_detail_bloc.dart';
import 'package:neu_trade/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:neu_trade/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:neu_trade/features/profile/domain/repositories/profile_repository.dart';
import 'package:neu_trade/features/profile/domain/usecases/get_profile_use_case.dart';
import 'package:neu_trade/features/profile/domain/usecases/save_profile_use_case.dart';
import 'package:neu_trade/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:neu_trade/features/review/data/datasources/review_remote_datasource.dart';
import 'package:neu_trade/features/review/data/repositories/review_repository_impl.dart';
import 'package:neu_trade/features/review/domain/repositories/review_repository.dart';
import 'package:neu_trade/features/review/domain/usecases/get_rating_summary_usecase.dart';
import 'package:neu_trade/features/review/domain/usecases/submit_review_usecase.dart';
import 'package:neu_trade/features/statistics/data/datasources/statistics_remote_datasource.dart';
import 'package:neu_trade/features/statistics/data/repositories/statistics_repository_impl.dart';
import 'package:neu_trade/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:neu_trade/features/statistics/domain/usecases/get_circulation_stats_usecase.dart';
import 'package:neu_trade/features/statistics/presentation/bloc/statistics_bloc.dart';
import 'package:neu_trade/features/transaction/data/datasources/transaction_remote_datasource.dart';
import 'package:neu_trade/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:neu_trade/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:neu_trade/features/transaction/domain/usecases/cancel_transaction_usecase.dart';
import 'package:neu_trade/features/transaction/domain/usecases/complete_transaction_usecase.dart';
import 'package:neu_trade/features/transaction/domain/usecases/create_transaction_usecase.dart';
import 'package:neu_trade/features/transaction/domain/usecases/get_transaction_usecase.dart';
import 'package:neu_trade/features/transaction/domain/usecases/get_transactions_usecase.dart';
import 'package:neu_trade/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:neu_trade/features/upload/data/datasources/post_remote_datasources.dart';
import 'package:neu_trade/features/upload/data/repositories/upload_post_repository_impl.dart';
import 'package:neu_trade/features/upload/domain/repositories/upload_post_repository.dart';
import 'package:neu_trade/features/upload/domain/usecases/create_post_use_case.dart';
import 'package:neu_trade/features/upload/presentation/bloc/upload_post_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

final sl = GetIt.instance;

String _resolveUserId([String? userId]) {
  if (userId != null && userId.isNotEmpty) return userId;
  if (sl.isRegistered<AuthBloc>()) {
    final authState = sl<AuthBloc>().state;
    if (authState is AuthLoginState) {
      return authState.user.id;
    }
  }
  return sl<SupabaseClient>().auth.currentUser?.id ?? '';
}

Future<void> initDependencies() async {
  // External / Core
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  sl.registerLazySingleton<Uuid>(() => const Uuid());

  // Services
  sl.registerLazySingleton<AuthServices>(() => AuthServices());
  sl.registerLazySingleton<ProfileServices>(
    () => ProfileServices(client: sl()),
  );
  sl.registerFactoryParam<PostServices, String?, void>(
    (userId, _) => PostServices(userId: _resolveUserId(userId), client: sl()),
  );
  sl.registerFactoryParam<ReportServices, String?, void>(
    (userId, _) => ReportServices(userId: _resolveUserId(userId), client: sl()),
  );
  sl.registerFactoryParam<ReviewServices, String?, void>(
    (userId, _) => ReviewServices(userId: _resolveUserId(userId), client: sl()),
  );
  sl.registerFactoryParam<StatisticsServices, String?, void>(
    (userId, _) =>
        StatisticsServices(userId: _resolveUserId(userId), client: sl()),
  );
  sl.registerFactoryParam<TransactionServices, String?, void>(
    (userId, _) =>
        TransactionServices(userId: _resolveUserId(userId), client: sl()),
  );

  // Feature: Auth
  // Datasources
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDatasource: sl()),
  );

  // UseCases
  sl.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(sl()),
  );
  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl()));
  sl.registerLazySingleton<SignUpUseCase>(() => SignUpUseCase(sl()));
  sl.registerLazySingleton<ForgotPasswordUseCase>(
    () => ForgotPasswordUseCase(sl()),
  );
  sl.registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(sl()));
  sl.registerLazySingleton<WatchAuthStateUseCase>(
    () => WatchAuthStateUseCase(sl()),
  );

  // Bloc
  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      getCurrentUser: sl(),
      login: sl(),
      signUp: sl(),
      forgotPassword: sl(),
      logout: sl(),
      watchAuthState: sl(),
      getProfile: sl(),
    ),
  );

  // Feature: Profile
  // Datasources
  sl.registerLazySingleton<ProfileRemoteDatasource>(
    () => ProfileRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDatasource: sl()),
  );

  // UseCases
  sl.registerLazySingleton<GetProfileUseCase>(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton<SaveProfileUseCase>(() => SaveProfileUseCase(sl()));

  // Bloc
  sl.registerFactoryParam<ProfileBloc, String?, void>(
    (userId, _) => ProfileBloc(
      userId: _resolveUserId(userId),
      getProfile: sl(),
      saveProfile: sl(),
    ),
  );

  // Feature: Home
  // Datasources
  sl.registerFactory<HomePostRemoteDatasource>(
    () => HomePostRemoteDatasourceImpl(sl()),
  );
  sl.registerFactory<HomePostReportDatasource>(
    () => HomePostReportDatasourceImpl(sl()),
  );

  // Repositories
  sl.registerFactory<HomePostRepository>(
    () => HomePostRepositoryImpl(homePostRemoteDatasource: sl()),
  );
  sl.registerFactory<HomePostReportRepository>(
    () => HomePostReportRepositoryImpl(homePostReportDatasource: sl()),
  );

  // UseCases
  sl.registerFactory<GetHomePostsUsecase>(() => GetHomePostsUsecase(sl()));
  sl.registerFactory<GetHomePostUsecase>(() => GetHomePostUsecase(sl()));
  sl.registerFactory<SendHomeReportUsecase>(() => SendHomeReportUsecase(sl()));

  // Blocs
  sl.registerFactory<HomeBloc>(() => HomeBloc(getHomePosts: sl()));
  sl.registerFactoryParam<PostDetailBloc, HomePostEntity?, void>(
    (initialPost, _) => PostDetailBloc(
      getHomePost: sl(),
      createTransaction: sl(),
      sendReport: sl(),
      initialPost: initialPost,
    ),
  );

  // Feature: Upload
  // Datasources
  sl.registerFactory<PostRemoteDatasource>(
    () => PostRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerFactory<PostRepository>(
    () => PostRepositoryImpl(remoteDatasource: sl()),
  );

  // UseCases
  sl.registerFactory<CreatePostUseCase>(() => CreatePostUseCase(sl()));

  // Bloc
  sl.registerFactory<PostBloc>(
    () => PostBloc(createPost: sl(), uuid: sl()),
  );

  // Feature: Transaction
  // Datasources
  sl.registerFactory<TransactionRemoteDatasource>(
    () => TransactionRemoteDatasourceImpl(sl()),
  );

  // Repositories
  sl.registerFactory<TransactionRepository>(
    () => TransactionRepositoryImpl(remoteDatasource: sl()),
  );

  // UseCases
  sl.registerFactory<CreateTransactionUsecase>(
    () => CreateTransactionUsecase(sl()),
  );
  sl.registerFactory<GetTransactionsUsecase>(
    () => GetTransactionsUsecase(repository: sl()),
  );
  sl.registerFactory<GetTransactionUsecase>(
    () => GetTransactionUsecase(repository: sl()),
  );
  sl.registerFactory<CompleteTransactionUsecase>(
    () => CompleteTransactionUsecase(sl()),
  );
  sl.registerFactory<CancelTransactionUsecase>(
    () => CancelTransactionUsecase(sl()),
  );

  // Bloc
  sl.registerFactory<TransactionBloc>(
    () => TransactionBloc(
      getTransactions: sl(),
      completeTransaction: sl(),
      cancelTransaction: sl(),
      submitReview: sl(),
    ),
  );

  // Feature: Review
  // Datasources
  sl.registerFactory<ReviewRemoteDatasource>(
    () => ReviewRemoteDatasourceImpl(sl()),
  );

  // Repositories
  sl.registerFactory<ReviewRepository>(
    () => ReviewRepositoryImpl(remoteDatasource: sl()),
  );

  // UseCases
  sl.registerFactory<SubmitReviewUsecase>(() => SubmitReviewUsecase(sl()));
  sl.registerFactory<GetRatingSummaryUsecase>(
    () => GetRatingSummaryUsecase(sl()),
  );

  // Feature: Statistics
  // Datasources
  sl.registerFactory<StatisticsRemoteDatasource>(
    () => StatisticsRemoteDatasourceImpl(sl()),
  );

  // Repositories
  sl.registerFactory<StatisticsRepository>(
    () => StatisticsRepositoryImpl(remoteDatasource: sl()),
  );

  // UseCases
  sl.registerFactory<GetCirculationStatsUsecase>(
    () => GetCirculationStatsUsecase(sl()),
  );

  // Bloc
  sl.registerFactory<StatisticsBloc>(
    () => StatisticsBloc(getCirculationStats: sl()),
  );
}
