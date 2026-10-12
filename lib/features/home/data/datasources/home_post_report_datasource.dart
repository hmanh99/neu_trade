import 'package:neu_trade/core/error/exceptions.dart';
import 'package:neu_trade/core/services/report_services.dart';
import 'package:neu_trade/features/home/data/models/home_post_report_model.dart';
import 'package:supabase/supabase.dart';

abstract class HomePostReportDatasource {
  Future<HomePostReportModel> sendReport({
    required int postId,
    required String reason,
    String? description,
  });
}

class HomePostReportDatasourceImpl implements HomePostReportDatasource {
  const HomePostReportDatasourceImpl(this._reportServices);

  final ReportServices _reportServices;

  @override
  Future<HomePostReportModel> sendReport({
    required int postId,
    required String reason,
    String? description,
  }) async {
    try {
      final result = await _reportServices.createPostReport(
        postId: postId,
        reason: reason,
        description: description,
      );
      return HomePostReportModel.fromJson(result);
    } on PostgrestException catch (error) {
      throw ServerException(message: error.message);
    }
  }
}
