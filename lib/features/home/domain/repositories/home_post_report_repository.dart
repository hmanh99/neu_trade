import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/features/home/domain/entities/home_post_report_entity.dart';

import '../../../../core/error/failure.dart';

abstract interface class HomePostReportRepository {
  Future<Either<Failure, HomePostReportEntity>> sendReport({
    required int postId,
    required String reason,
    String? description,
  });
}
