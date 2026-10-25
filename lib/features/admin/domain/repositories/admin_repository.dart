import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/features/admin/domain/entities/admin_report_entity.dart';
import 'package:neu_trade/features/admin/domain/entities/admin_post_entity.dart';
import 'package:neu_trade/features/admin/domain/entities/circulation_stat_entity.dart';

abstract class AdminRepository {
  Future<Either<Failure, List<AdminPostEntity>>> getPendingPosts();
  Future<Either<Failure, void>> approvePost(int postId);
  Future<Either<Failure, void>> rejectPost(int postId);
  Future<Either<Failure, List<AdminReportEntity>>> getReports({String? status});
  Future<Either<Failure, void>> resolveReport({
    required int reportId,
    required String status,
  });
  Future<Either<Failure, List<CirculationStatEntity>>> getCirculationStats();
}
