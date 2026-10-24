import 'package:equatable/equatable.dart';
import 'package:neu_trade/features/admin/domain/entities/report_status.dart';
import 'package:neu_trade/features/admin/domain/entities/status.dart';

class AdminReportEntity extends Equatable {
  final int reportId;
  final int postId;
  final String reporterId;
  final String reporterName;
  final String reason;
  final String? description;
  final ReportStatus status;
  final DateTime createdAt;
  final String? postTitle;
  final Status? postStatus;
  final List<String> postImageUrls;
  final String? postAuthorId;
  final String? postAuthorName;

  const AdminReportEntity({
    required this.reportId,
    required this.postId,
    required this.reporterId,
    required this.reporterName,
    required this.reason,
    this.description,
    required this.status,
    required this.createdAt,
    this.postTitle,
    this.postStatus,
    this.postImageUrls = const [],
    this.postAuthorId,
    this.postAuthorName,
  });

  @override
  List<Object?> get props => [
    reportId,
    postId,
    reporterId,
    reporterName,
    reason,
    description,
    status,
    createdAt,
    postTitle,
    postStatus,
    postImageUrls,
    postAuthorId,
    postAuthorName,
  ];
}
