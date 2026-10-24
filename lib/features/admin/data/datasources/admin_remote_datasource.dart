import 'package:neu_trade/core/services/admin_services.dart';
import 'package:neu_trade/features/admin/data/models/admin_post_model.dart';
import 'package:neu_trade/features/admin/data/models/admin_report_model.dart';

abstract class AdminRemoteDatasource {
  Future<List<AdminPostModel>> getPendingPosts();

  Future<void> approvePost(int postId);

  Future<void> rejectPost(int postId);

  Future<List<AdminReportModel>> getReports({String? status});

  Future<void> resolveReport({required int reportId, required String status});
}

class AdminRemoteDataSourceImpl implements AdminRemoteDatasource {
  final AdminServices _adminServices;

  AdminRemoteDataSourceImpl(this._adminServices);

  @override
  Future<List<AdminPostModel>> getPendingPosts() async {
    final list = await _adminServices.getPendingPosts();
    return list.map((json) => AdminPostModel.fromJson(json)).toList();
  }

  @override
  Future<void> approvePost(int postId) async {
    await _adminServices.approvePost(postId);
  }

  @override
  Future<void> rejectPost(int postId) async {
    await _adminServices.rejectPost(postId);
  }

  @override
  Future<List<AdminReportModel>> getReports({String? status}) async {
    final list = await _adminServices.getReports(status: status);
    return list.map((json) => AdminReportModel.fromJson(json)).toList();
  }

  @override
  Future<void> resolveReport({
    required int reportId,
    required String status,
  }) async {
    await _adminServices.resolveReport(reportId: reportId, status: status);
  }
}
