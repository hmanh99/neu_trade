import 'package:neu_trade/features/admin/domain/entities/admin_report_entity.dart';
import 'package:neu_trade/features/admin/domain/entities/report_status.dart';
import 'package:neu_trade/features/admin/domain/entities/status.dart';

class AdminReportModel extends AdminReportEntity {
  const AdminReportModel({
    required super.reportId,
    required super.postId,
    required super.reporterId,
    required super.reporterName,
    required super.reason,
    super.description,
    required super.status,
    required super.createdAt,
    super.postTitle,
    super.postStatus,
    super.postImageUrls = const [],
    super.postAuthorId,
    super.postAuthorName,
  });

  factory AdminReportModel.fromJson(Map<String, dynamic> json) {
    return AdminReportModel(
      reportId: (json['baocao_id'] as num).toInt(),
      postId: (json['tindang_id'] as num).toInt(),
      reporterId: json['nguoi_bao_cao'] as String? ?? '',
      reporterName: json['ten_nguoi_bao_cao'] as String? ?? 'Sinh viên',
      reason: json['ly_do'] as String? ?? '',
      description: json['chi_tiet'] as String?,
      status: ReportStatus.fromString(json['trang_thai_xl'] as String? ?? 'ChoXuLy'),
      createdAt: json['ngay_tao'] != null
          ? DateTime.parse(json['ngay_tao'] as String)
          : DateTime.now(),
      postTitle: json['tieu_de_tin'] as String?,
      postStatus: json['trang_thai_tin'] != null
          ? Status.fromString(json['trang_thai_tin'] as String)
          : null,
      postImageUrls: _parseImages(json['hinh_anh_tin']),
      postAuthorId: json['nguoi_dang_id'] as String?,
      postAuthorName: json['ho_ten_nguoi_dang'] as String?,
    );
  }

  static List<String> _parseImages(Object? value) {
    if (value == null) return const [];
    if (value is String) return [value];
    if (value is List) return value.whereType<String>().toList(growable: false);
    return const [];
  }
}
