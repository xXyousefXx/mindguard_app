import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/mg_widgets.dart';
import '../../auth/state/auth_controller.dart';
import '../../health/presentation/health_screen.dart' show MgLineChart;
import '../../shared/state/app_providers.dart';
import '../data/caregiver_repository.dart';

/// Caregiver dashboard (FR-05, FR-07, FR-15): patient status card, headline
/// metrics, weekly memory trend and today's alerts.
class CaregiverDashboardScreen extends ConsumerWidget {
  const CaregiverDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final dashboard = ref.watch(caregiverDashboardProvider);
    final language = ref.watch(languageProvider);

    return Scaffold(
      body: Column(
        children: [
          GradientHeader(
            title: s.t('dashboard'),
            subtitle: ref.watch(authControllerProvider).user?.fullName,
            trailing: Row(
              children: [
                TextButton(
                  onPressed: () => ref.read(languageProvider.notifier).state =
                      language == AppLanguage.ar ? AppLanguage.en : AppLanguage.ar,
                  style: TextButton.styleFrom(foregroundColor: AppColors.onPrimary),
                  child: Text(language == AppLanguage.ar ? 'EN' : 'ع'),
                ),
                IconButton(
                  tooltip: s.t('logout'),
                  color: AppColors.onPrimary,
                  onPressed: () async {
                    await ref.read(authControllerProvider.notifier).logout();
                    if (context.mounted) context.go(AppRoutes.welcome);
                  },
                  icon: const Icon(Icons.logout_rounded),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              child: AsyncStateView<CaregiverDashboard>(
                value: dashboard,
                onRetry: () => ref.invalidate(caregiverDashboardProvider),
                builder: (data) => _DashboardBody(data: data, s: s),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.data, required this.s});

  final CaregiverDashboard data;
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MgCard(
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.surfaceMuted,
                foregroundImage: data.patientPhotoUrl.isEmpty
                    ? null
                    : NetworkImage(data.patientPhotoUrl),
                child: const Icon(Icons.person_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.patientName,
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.place_rounded, size: 16, color: AppColors.success),
                        const SizedBox(width: 4),
                        Text(
                          data.locationLabel,
                          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${s.t('lastUpdate')}: ${data.lastUpdate}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton.filled(
                tooltip: s.t('callPatient'),
                onPressed: () => _notImplemented(context, s.t('callPatient')),
                icon: const Icon(Icons.call_rounded),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.medication_rounded,
                color: AppColors.warning,
                background: AppColors.warningSoft,
                label: s.t('medications'),
                value: '${data.dosesTaken}/${data.dosesTotal}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.psychology_rounded,
                color: AppColors.purple,
                background: AppColors.purpleSoft,
                label: s.t('memoryScore'),
                value: '${data.memoryScore}%',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.directions_walk_rounded,
                color: AppColors.success,
                background: AppColors.successSoft,
                label: s.t('steps'),
                value: '${data.steps}',
              ),
            ),
          ],
        ),
        SectionTitle(s.t('weeklyMemoryScore')),
        MgCard(
          child: SizedBox(
            height: 180,
            child: MgLineChart(points: data.weeklyMemory, color: AppColors.primary),
          ),
        ),
        SectionTitle(s.t('todayAlerts')),
        for (final alert in data.alerts) ...[
          _AlertTile(alert: alert),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  void _notImplemented(BuildContext context, String label) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(label)));
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.color,
    required this.background,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return MgCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        children: [
          SoftIcon(icon: icon, color: color, background: background, size: 40),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert});
  final PatientAlert alert;

  @override
  Widget build(BuildContext context) {
    final (icon, color, background) = switch (alert.severity) {
      AlertSeverity.success => (Icons.check_circle_rounded, AppColors.success, AppColors.successSoft),
      AlertSeverity.danger => (Icons.error_rounded, AppColors.danger, AppColors.dangerSoft),
      AlertSeverity.warning => (Icons.warning_rounded, AppColors.warning, AppColors.warningSoft),
    };

    return MgCard(
      child: Row(
        children: [
          SoftIcon(icon: icon, color: color, background: background, size: 42),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  alert.timeAgo,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
