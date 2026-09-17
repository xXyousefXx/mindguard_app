import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/mg_widgets.dart';
import '../../health/presentation/health_screen.dart' show MgLineChart;
import '../../shared/state/app_providers.dart';
import '../data/caregiver_repository.dart';

/// Caregiver reports (FR-16): daily / weekly progress summary produced by the
/// backend from AI exercise results, medication logs and watch data.
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final weekly = ref.watch(reportRangeWeeklyProvider);
    final report = ref.watch(progressReportProvider);

    return Scaffold(
      body: Column(
        children: [
          GradientHeader(
            title: s.t('reportsTitle'),
            subtitle: s.t('reportsSubtitle'),
            child: SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: false, label: Text(s.t('daily'))),
                ButtonSegment(value: true, label: Text(s.t('weekly'))),
              ],
              selected: {weekly},
              showSelectedIcon: false,
              onSelectionChanged: (selection) =>
                  ref.read(reportRangeWeeklyProvider.notifier).state = selection.first,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              child: AsyncStateView<ProgressReport>(
                value: report,
                onRetry: () => ref.invalidate(progressReportProvider),
                builder: (data) => _ReportBody(data: data, s: s),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({required this.data, required this.s});

  final ProgressReport data;
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _ReportCard(
                icon: Icons.psychology_rounded,
                color: AppColors.purple,
                background: AppColors.purpleSoft,
                label: s.t('memoryScoreLabel'),
                value: '${data.memoryScore}%',
                caption: '+${data.memoryDelta}%',
                captionColor: AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ReportCard(
                icon: Icons.medication_rounded,
                color: AppColors.success,
                background: AppColors.successSoft,
                label: s.t('adherence'),
                value: '${data.adherencePercent}%',
                caption: data.adherenceLabel,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ReportCard(
                icon: Icons.location_off_rounded,
                color: AppColors.warning,
                background: AppColors.warningSoft,
                label: s.t('zoneExits'),
                value: '${data.zoneExits}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ReportCard(
                icon: Icons.directions_walk_rounded,
                color: AppColors.info,
                background: AppColors.infoSoft,
                label: s.t('avgSteps'),
                value: '${data.averageSteps}',
              ),
            ),
          ],
        ),
        SectionTitle(s.t('memoryTrend')),
        MgCard(
          child: SizedBox(
            height: 200,
            child: MgLineChart(points: data.memoryTrend, color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.icon,
    required this.color,
    required this.background,
    required this.label,
    required this.value,
    this.caption,
    this.captionColor,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final String label;
  final String value;
  final String? caption;
  final Color? captionColor;

  @override
  Widget build(BuildContext context) {
    return MgCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SoftIcon(icon: icon, color: color, background: background, size: 42),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          if (caption != null) ...[
            const SizedBox(height: 6),
            Text(
              caption!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: captionColor ?? AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
