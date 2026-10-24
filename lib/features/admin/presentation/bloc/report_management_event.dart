import 'package:equatable/equatable.dart';

abstract class ReportManagementEvent extends Equatable {
  const ReportManagementEvent();

  @override
  List<Object?> get props => [];
}

class ReportManagementLoadEvent extends ReportManagementEvent {
  final String? statusFilter;

  const ReportManagementLoadEvent({this.statusFilter});

  @override
  List<Object?> get props => [statusFilter];
}

class ReportManagementFilterChangedEvent extends ReportManagementEvent {
  final String? statusFilter;

  const ReportManagementFilterChangedEvent(this.statusFilter);

  @override
  List<Object?> get props => [statusFilter];
}

class ReportManagementResolveEvent extends ReportManagementEvent {
  final int reportId;
  final String status;

  const ReportManagementResolveEvent({
    required this.reportId,
    required this.status,
  });

  @override
  List<Object?> get props => [reportId, status];
}
