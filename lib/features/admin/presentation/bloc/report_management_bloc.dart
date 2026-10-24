import 'package:bloc/bloc.dart';
import 'package:neu_trade/features/admin/domain/entities/admin_report_entity.dart';
import 'package:neu_trade/features/admin/domain/usecases/get_reports_usecase.dart';
import 'package:neu_trade/features/admin/domain/usecases/resolve_report_usecase.dart';
import 'package:neu_trade/features/admin/presentation/bloc/report_management_event.dart';
import 'package:neu_trade/features/admin/presentation/bloc/report_management_state.dart';
import 'package:neu_trade/features/admin/domain/entities/report_status.dart';

class ReportManagementBloc
    extends Bloc<ReportManagementEvent, ReportManagementState> {
  final GetReportsUsecase _getReports;
  final ResolveReportUsecase _resolveReport;

  ReportManagementBloc({
    required GetReportsUsecase getReports,
    required ResolveReportUsecase resolveReport,
  }) : _getReports = getReports,
       _resolveReport = resolveReport,
       super(const ReportManagementInitialState()) {
    on<ReportManagementLoadEvent>((event, emit) async {
      emit(const ReportManagementLoadingState());
      final result = await _getReports(
        GetReportsParams(status: event.statusFilter),
      );
      result.fold(
        (failure) => emit(
          ReportManagementErrorState(
            message: failure.message,
            statusFilter: event.statusFilter,
          ),
        ),
        (reports) => emit(
          ReportManagementLoadedState(
            reports: reports,
            statusFilter: event.statusFilter,
          ),
        ),
      );
    });

    on<ReportManagementFilterChangedEvent>((event, emit) async {
      final currentFilter = state is ReportManagementLoadedState
          ? (state as ReportManagementLoadedState).statusFilter
          : null;
      if (currentFilter == event.statusFilter &&
          state is ReportManagementLoadedState) {
        return;
      }
      add(ReportManagementLoadEvent(statusFilter: event.statusFilter));
    });

    on<ReportManagementResolveEvent>((event, emit) async {
      final currentLoaded = state is ReportManagementLoadedState
          ? (state as ReportManagementLoadedState)
          : null;

      if (currentLoaded != null && currentLoaded.resolvingReportId != null) {
        return;
      }

      if (currentLoaded != null) {
        emit(currentLoaded.copyWith(resolvingReportId: () => event.reportId));
      }

      final result = await _resolveReport(
        ResolveReportParams(
          reportId: event.reportId,
          status: event.status,
        ),
      );

      result.fold(
        (failure) {
          if (currentLoaded != null) {
            emit(
              ReportManagementErrorState(
                message: failure.message,
                reports: currentLoaded.reports,
                statusFilter: currentLoaded.statusFilter,
              ),
            );
          } else {
            emit(ReportManagementErrorState(message: failure.message));
          }
        },
        (_) {
          if (currentLoaded != null) {
            final newStatus = ReportStatus.fromString(event.status);
            final updatedReports = currentLoaded.reports.map((r) {
              if (r.reportId == event.reportId) {
                return AdminReportEntity(
                  reportId: r.reportId,
                  postId: r.postId,
                  reporterId: r.reporterId,
                  reporterName: r.reporterName,
                  reason: r.reason,
                  description: r.description,
                  status: newStatus,
                  createdAt: r.createdAt,
                  postTitle: r.postTitle,
                  postStatus: r.postStatus,
                  postImageUrls: r.postImageUrls,
                  postAuthorId: r.postAuthorId,
                  postAuthorName: r.postAuthorName,
                );
              }
              return r;
            }).where((r) {
              // If filtering by specific status, remove report if its new status doesn't match
              if (currentLoaded.statusFilter != null &&
                  currentLoaded.statusFilter!.isNotEmpty) {
                return r.status.toDbString() == currentLoaded.statusFilter;
              }
              return true;
            }).toList();

            final statusText = event.status == 'DaXuLy' ? 'Đã xử lý' : 'Bác bỏ';
            emit(
              ReportManagementLoadedState(
                reports: updatedReports,
                statusFilter: currentLoaded.statusFilter,
                successMessage: 'Đã chuyển trạng thái báo cáo sang $statusText.',
              ),
            );
          } else {
            add(const ReportManagementLoadEvent());
          }
        },
      );
    });
  }
}
