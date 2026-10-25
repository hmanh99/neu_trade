import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/exceptions.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:neu_trade/features/admin/domain/entities/admin_post_entity.dart';
import 'package:neu_trade/features/admin/domain/entities/admin_report_entity.dart';
import 'package:neu_trade/features/admin/domain/entities/circulation_stat_entity.dart';
import 'package:neu_trade/features/admin/domain/repositories/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDatasource remoteDatasource;

  AdminRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Either<Failure, List<AdminPostEntity>>> getPendingPosts() async {
    try {
      final posts = await remoteDatasource.getPendingPosts();
      return Right(posts.map((post) => post.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> approvePost(int postId) async {
    try {
      await remoteDatasource.approvePost(postId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> rejectPost(int postId) async {
    try {
      await remoteDatasource.rejectPost(postId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AdminReportEntity>>> getReports({String? status}) async {
    try {
      final reports = await remoteDatasource.getReports(status: status);
      return Right(reports);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resolveReport({
    required int reportId,
    required String status,
  }) async {
    try {
      await remoteDatasource.resolveReport(reportId: reportId, status: status);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CirculationStatEntity>>>
  getCirculationStats() async {
    try {
      final models = await remoteDatasource.getCirculationStats();
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
