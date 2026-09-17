import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/mg_widgets.dart';
import '../../shared/state/app_providers.dart';
import '../data/health_repository.dart';

/// Patient health screen (FR-14). All values come from the smart watch team via
/// the backend; this screen only renders what the repository returns.
class HealthScreen extends ConsumerWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final snapshot = ref.watch(healthSnapshotProvider);

    return PatientDirectionality(
      child: Scaffold(
        body: Column(
          children: [
            GradientHeader(title: s.t('healthTitle'), subtitle: s.t('healthSubtitle')),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                child: AsyncStateView<HealthSnapshot>(
                  value: snapshot,
                  onRetry: () => ref.invalidate(healthSnapshotProvider),
                  builder: (data) => _HealthBody(data: data, s: s),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthBody extends StatelessWidget {
  const _HealthBody({required this.data, required this.s});

  final HealthSnapshot data;
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    if (!data.watchPaired) {
      return MgCard(
        child: Row(
          children: [
            const SoftIcon(icon: Icons.watch_off_rounded, color: AppColors.textSecondary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(s.t('watchNotPaired'), style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.favorite_rounded,
                color: AppColors.danger,
                background: AppColors.dangerSoft,
                label: s.t('heartRate'),
                value: '${data.heartRate}',
                unit: 'bpm',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                icon: Icons.bloodtype_rounded,
                color: AppColors.info,
                background: AppColors.infoSoft,
                label: s.t('oxygen'),
                value: '${data.oxygen}',
                unit: '%',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.directions_walk_rounded,
                color: AppColors.success,
                background: AppColors.successSoft,
                label: s.t('steps'),
                value: '${data.steps}',
                unit: '',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                icon: Icons.nightlight_round,
                color: AppColors.purple,
                background: AppColors.purpleSoft,
                label: s.t('sleep'),
                value: data.sleepHours.toStringAsFixed(1),
                unit: 'h',
              ),
            ),
          ],
        ),
        SectionTitle(s.t('heartRateToday')),
        MgCard(
          child: SizedBox(
            height: 180,
            child: MgLineChart(
              points: data.heartRateSeries,
              color: AppColors.danger,
            ),
          ),
        ),
        const SizedBox(height: 16),
        MgCard(
          color: AppColors.successSoft,
          child: Row(
            children: [
              const SoftIcon(
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
                background: AppColors.surface,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.t('healthGood'),
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.t('healthGoodSub'),
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              SpeakButton(text: '${s.t('healthGood')}. ${s.t('healthGoodSub')}'),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.color,
    required this.background,
    required this.label,
    required this.value,
    required this.unit,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return MgCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SoftIcon(icon: icon, color: color, background: background),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(unit, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

/// Shared line chart used by the health, dashboard and reports screens.
class MgLineChart extends StatelessWidget {
  const MgLineChart({super.key, required this.points, required this.color});

  final List<(String, double)> points;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 20),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final i = value.round();
                if (i < 0 || i >= points.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    points[i].$1,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].$2),
            ],
            isCurved: true,
            barWidth: 3,
            color: color,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: color.withOpacity(0.12)),
          ),
        ],
      ),
    );
  }
}
