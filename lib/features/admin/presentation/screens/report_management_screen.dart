import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neu_trade/core/constants/color_constants.dart';
import 'package:neu_trade/features/admin/domain/entities/admin_report_entity.dart';
import 'package:neu_trade/features/admin/presentation/bloc/report_management_bloc.dart';
import 'package:neu_trade/features/admin/presentation/bloc/report_management_event.dart';
import 'package:neu_trade/features/admin/presentation/bloc/report_management_state.dart';
import 'package:neu_trade/features/admin/presentation/widgets/report_card.dart';
import 'package:neu_trade/features/admin/presentation/widgets/resolve_report_sheet.dart';

class ReportManagementScreen extends StatefulWidget {
  const ReportManagementScreen({super.key});

  @override
  State<ReportManagementScreen> createState() => _ReportManagementScreenState();
}

class _ReportManagementScreenState extends State<ReportManagementScreen> {
  // Tabs: null (Tất cả), 'ChoXuLy', 'DaXuLy', 'BacBo'
  final List<({String label, String? status})> _tabs = const [
    (label: 'Tất cả', status: null),
    (label: 'Chờ xử lý', status: 'ChoXuLy'),
    (label: 'Đã xử lý', status: 'DaXuLy'),
    (label: 'Bác bỏ', status: 'BacBo'),
  ];

  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<ReportManagementBloc>().add(
          const ReportManagementLoadEvent(),
        );
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<ReportManagementBloc>();
    final filter = _tabs[_selectedTabIndex].status;
    final completed = bloc.stream.firstWhere(
      (state) =>
          state is ReportManagementLoadedState ||
          state is ReportManagementErrorState,
    );
    bloc.add(ReportManagementLoadEvent(statusFilter: filter));
    await completed;
  }

  void _onTabChanged(int index) {
    setState(() => _selectedTabIndex = index);
    final filter = _tabs[index].status;
    context.read<ReportManagementBloc>().add(
          ReportManagementFilterChangedEvent(filter),
        );
  }

  void _openResolveSheet(AdminReportEntity report) {
    ResolveReportSheet.show(
      context: context,
      report: report,
      onResolve: (newStatus) {
        context.read<ReportManagementBloc>().add(
              ReportManagementResolveEvent(
                reportId: report.reportId,
                status: newStatus,
              ),
            );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Xử lý báo cáo vi phạm',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ColorConstants.textPrimaryColor,
            letterSpacing: -0.4,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: ColorConstants.textPrimaryColor,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            icon: const Icon(
              Icons.refresh_rounded,
              color: ColorConstants.textPrimaryColor,
            ),
            onPressed: () {
              final filter = _tabs[_selectedTabIndex].status;
              context.read<ReportManagementBloc>().add(
                    ReportManagementLoadEvent(statusFilter: filter),
                  );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _tabs.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = index == _selectedTabIndex;
                return ChoiceChip(
                  label: Text(_tabs[index].label),
                  selected: isSelected,
                  onSelected: (_) => _onTabChanged(index),
                  selectedColor: ColorConstants.primaryColor,
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : ColorConstants.greyShade700,
                  ),
                  backgroundColor: ColorConstants.greyShade100,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: BlocConsumer<ReportManagementBloc, ReportManagementState>(
        listener: (context, state) {
          if (state is ReportManagementErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: ColorConstants.snackBarFailedColor,
              ),
            );
          } else if (state is ReportManagementLoadedState &&
              state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: ColorConstants.snackBarSuccessColor,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ReportManagementLoadingState) {
            return const Center(
              child: CircularProgressIndicator(
                color: ColorConstants.primaryColor,
              ),
            );
          }

          if (state is ReportManagementErrorState && state.reports.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    size: 48,
                    color: ColorConstants.greyShade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: ColorConstants.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      final filter = _tabs[_selectedTabIndex].status;
                      context.read<ReportManagementBloc>().add(
                            ReportManagementLoadEvent(statusFilter: filter),
                          );
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Thử lại'),
                    style: FilledButton.styleFrom(
                      backgroundColor: ColorConstants.primaryColor,
                    ),
                  ),
                ],
              ),
            );
          }

          final reports = switch (state) {
            ReportManagementLoadedState(:final reports) => reports,
            ReportManagementErrorState(:final reports) => reports,
            _ => const <AdminReportEntity>[],
          };

          final resolvingId = switch (state) {
            ReportManagementLoadedState(:final resolvingReportId) =>
              resolvingReportId,
            _ => null,
          };

          if (reports.isEmpty) {
            return RefreshIndicator(
              color: ColorConstants.primaryColor,
              onRefresh: _onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.55,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: ColorConstants.blueShade50,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.verified_user_rounded,
                              size: 48,
                              color: ColorConstants.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Không có báo cáo nào',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: ColorConstants.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _selectedTabIndex == 0
                                ? 'Hiện không có báo cáo vi phạm nào trong hệ thống.'
                                : 'Không có báo cáo nào ở mục "${_tabs[_selectedTabIndex].label}".',
                            style: const TextStyle(
                              fontSize: 13,
                              color: ColorConstants.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: ColorConstants.primaryColor,
            onRefresh: _onRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return ReportCard(
                  key: ValueKey(report.reportId),
                  report: report,
                  isResolving: resolvingId == report.reportId,
                  onResolveTap: () => _openResolveSheet(report),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
