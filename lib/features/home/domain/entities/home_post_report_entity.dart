import 'package:equatable/equatable.dart';
import 'package:neu_trade/features/home/domain/entities/report_status.dart';

class HomePostReportEntity extends Equatable {
  final int reportId;
  final int postId;
  final String reportUserId;
  final String reason;
  final String? description;
  final ReportStatus status;

  const HomePostReportEntity({
    required this.reportId,
    required this.postId,
    required this.reportUserId,
    required this.reason,
    this.description,
    required this.status,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [
    reportId,
    postId,
    reportUserId,
    reason,
    description,
    status,
  ];
}
