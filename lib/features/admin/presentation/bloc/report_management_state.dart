import 'package:equatable/equatable.dart';
import 'package:neu_trade/features/admin/domain/entities/admin_report_entity.dart';

abstract class ReportManagementState extends Equatable {
  const ReportManagementState();

  @override
  List<Object?> get props => [];
}

class ReportManagementInitialState extends ReportManagementState {
  const ReportManagementInitialState();
}

class ReportManagementLoadingState extends ReportManagementState {
  const ReportManagementLoadingState();
}

class ReportManagementLoadedState extends ReportManagementState {
  final List<AdminReportEntity> reports;
  final String? statusFilter;
  final int? resolvingReportId;
  final String? successMessage;

  const ReportManagementLoadedState({
    required this.reports,
    this.statusFilter,
    this.resolvingReportId,
    this.successMessage,
  });

  ReportManagementLoadedState copyWith({
    List<AdminReportEntity>? reports,
    String? Function()? statusFilter,
    int? Function()? resolvingReportId,
    String? Function()? successMessage,
  }) {
    return ReportManagementLoadedState(
      reports: reports ?? this.reports,
      statusFilter:
          statusFilter != null ? statusFilter() : this.statusFilter,
      resolvingReportId:
          resolvingReportId != null
              ? resolvingReportId()
              : this.resolvingReportId,
      successMessage:
          successMessage != null ? successMessage() : this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
    reports,
    statusFilter,
    resolvingReportId,
    successMessage,
  ];
}

class ReportManagementErrorState extends ReportManagementState {
  final String message;
  final List<AdminReportEntity> reports;
  final String? statusFilter;

  const ReportManagementErrorState({
    required this.message,
    this.reports = const [],
    this.statusFilter,
  });

  @override
  List<Object?> get props => [message, reports, statusFilter];
}
