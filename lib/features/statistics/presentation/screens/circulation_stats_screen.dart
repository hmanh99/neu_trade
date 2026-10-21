import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neu_trade/core/constants/color_constants.dart';
import 'package:neu_trade/features/profile/presentation/widgets/profile_message.dart';
import 'package:neu_trade/features/statistics/domain/entities/circulation_stat_entity.dart';
import 'package:neu_trade/features/statistics/presentation/bloc/statistics_bloc.dart';
import 'package:neu_trade/features/statistics/presentation/bloc/statistics_event.dart';
import 'package:neu_trade/features/statistics/presentation/bloc/statistics_state.dart';

class CirculationStatsScreen extends StatefulWidget {
  const CirculationStatsScreen({super.key});

  @override
  State<CirculationStatsScreen> createState() => _CirculationStatsScreenState();
}

class _CirculationStatsScreenState extends State<CirculationStatsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StatisticsBloc>().add(const StatisticsLoadEvent());
  }

  Future<void> _reload() async {
    final bloc = context.read<StatisticsBloc>();
    if (bloc.state is StatisticsLoadingState) return;
    final completed = bloc.stream.firstWhere(
      (state) =>
          state is StatisticsLoadedState || state is StatisticsErrorState,
      orElse: () => const StatisticsInitialState(),
    );
    bloc.add(const StatisticsLoadEvent());
    await completed;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatisticsBloc, StatisticsState>(
      builder: (context, state) {
        final loading =
            state is StatisticsInitialState || state is StatisticsLoadingState;
        return Scaffold(
          backgroundColor: ColorConstants.backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Thống kê luân chuyển',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: ColorConstants.textPrimaryColor,
                letterSpacing: -0.4,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Tải lại số liệu',
                onPressed: loading ? null : _reload,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: SafeArea(child: _buildBody(state)),
        );
      },
    );
  }

  Widget _buildBody(StatisticsState state) {
    if (state is StatisticsErrorState) {
      return ProfileMessage(
        icon: Icons.cloud_off_outlined,
        title: 'Không thể tải thống kê',
        message: state.message.isNotEmpty
            ? state.message
            : 'Vui lòng kiểm tra kết nối và thử lại.',
        onRetry: _reload,
      );
    }

    if (state is StatisticsLoadedState) {
      final stats = state.stats;
      if (stats.isEmpty) {
        return ProfileMessage(
          icon: Icons.insights_outlined,
          title: 'Chưa có số liệu thống kê',
          message: 'Dữ liệu luân chuyển tài liệu theo kỳ sẽ hiển thị tại đây.',
          onRetry: _reload,
        );
      }

      final currentTerm = stats.first;
      final previousTerms = stats.length > 1
          ? stats.sublist(1)
          : const <CirculationStatEntity>[];

      return RefreshIndicator(
        color: ColorConstants.primaryColor,
        onRefresh: _reload,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            _CurrentTermHeroCard(stat: currentTerm),
            const SizedBox(height: 16),
            const _UpdateScheduleBanner(),
            if (previousTerms.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Các học kỳ trước',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: ColorConstants.textPrimaryColor,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),
              for (final term in previousTerms) ...[
                _TermStatCard(stat: term),
                const SizedBox(height: 12),
              ],
            ],
          ],
        ),
      );
    }

    return const Center(
      child: CircularProgressIndicator(color: ColorConstants.primaryColor),
    );
  }
}

class _CurrentTermHeroCard extends StatelessWidget {
  final CirculationStatEntity stat;

  const _CurrentTermHeroCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    final donatedPercent = (stat.donatedRatio * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: ColorConstants.primaryGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: ColorConstants.elevatedShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: ColorConstants.white24,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'KỲ HIỆN TẠI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                stat.termCode,
                style: const TextStyle(
                  color: ColorConstants.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            stat.termLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          if (stat.termRange.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              stat.termRange,
              style: const TextStyle(
                color: ColorConstants.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _HeroMetricBox(
                  icon: Icons.menu_book_rounded,
                  label: 'Tổng bàn giao',
                  value: '${stat.totalHandedOver}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroMetricBox(
                  icon: Icons.volunteer_activism_outlined,
                  label: 'Sách trao tặng',
                  value: '${stat.totalDonated}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroMetricBox(
                  icon: Icons.sell_outlined,
                  label: 'Có phí',
                  value: '${stat.totalPaid}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tỉ lệ trao tặng miễn phí',
                style: TextStyle(
                  color: ColorConstants.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$donatedPercent%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: stat.donatedRatio,
              minHeight: 7,
              backgroundColor: ColorConstants.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(
                ColorConstants.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetricBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _HeroMetricBox({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: ColorConstants.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _UpdateScheduleBanner extends StatelessWidget {
  const _UpdateScheduleBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: ColorConstants.blueShade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorConstants.blueShade100),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.schedule_rounded,
            size: 18,
            color: ColorConstants.primaryColor,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Số liệu được tổng hợp tự động mỗi ngày lúc 00:00 theo học kỳ Thu, Xuân và Hè.',
              style: TextStyle(
                fontSize: 12.5,
                color: ColorConstants.greyShade700,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TermStatCard extends StatelessWidget {
  final CirculationStatEntity stat;

  const _TermStatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    final donatedPercent = (stat.donatedRatio * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ColorConstants.borderLightColor),
        boxShadow: ColorConstants.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stat.termLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: ColorConstants.textPrimaryColor,
                      ),
                    ),
                    if (stat.termRange.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        stat.termRange,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: ColorConstants.textSecondaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: ColorConstants.greyShade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  stat.termCode,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: ColorConstants.greyShade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: ColorConstants.dividerColor),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _TermMetricItem(
                  icon: Icons.menu_book_rounded,
                  iconColor: ColorConstants.primaryColor,
                  iconBg: ColorConstants.blueShade50,
                  label: 'Đã bàn giao',
                  value: '${stat.totalHandedOver} cuốn',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TermMetricItem(
                  icon: Icons.volunteer_activism_outlined,
                  iconColor: ColorConstants.greenShade600,
                  iconBg: ColorConstants.greenShade50,
                  label: 'Trao tặng (0đ)',
                  value: '${stat.totalDonated} cuốn',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Có phí: ${stat.totalPaid} cuốn',
                style: const TextStyle(
                  fontSize: 12,
                  color: ColorConstants.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Tặng miễn phí: $donatedPercent%',
                style: const TextStyle(
                  fontSize: 12,
                  color: ColorConstants.greenShade700,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: stat.donatedRatio,
              minHeight: 6,
              backgroundColor: ColorConstants.greyShade100,
              valueColor: const AlwaysStoppedAnimation<Color>(
                ColorConstants.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TermMetricItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;

  const _TermMetricItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: ColorConstants.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: ColorConstants.textPrimaryColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
