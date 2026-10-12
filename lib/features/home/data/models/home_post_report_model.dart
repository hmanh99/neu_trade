import 'package:neu_trade/features/home/domain/entities/home_post_report_entity.dart';
import 'package:neu_trade/features/home/domain/entities/report_status.dart';

class HomePostReportModel extends HomePostReportEntity {
  const HomePostReportModel({
    required super.reportId,
    required super.postId,
    required super.reportUserId,
    required super.reason,
    super.description,
    required super.status,
  });

  factory HomePostReportModel.fromJson(Map<String, dynamic> json) =>
      HomePostReportModel(
        reportId: json['baocao_id'] as int,
        postId: json['tindang_id'] as int,
        reportUserId: json['nguoi_bao_cao'] as String,
        reason: json['ly_do'] as String,
        description: json['chi_tiet'] as String?,
        status: ReportStatus.fromString(json['trang_thai_xl'] as String),
      );

  HomePostReportEntity toEntity() {
    return HomePostReportEntity(
      reportId: reportId,
      postId: postId,
      reportUserId: reportUserId,
      description: description,
      reason: reason,
      status: status,
    );
  }
}
