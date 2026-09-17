import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/mg_widgets.dart';
import '../../auth/state/auth_controller.dart';
import '../../medications/data/medication_repository.dart';
import '../../medications/state/medication_providers.dart';

/// Patient home: orientation card (day/date/time), quick actions and today's
/// doses, with an always visible SOS button (FR-12, FR-09, FR-17).
class PatientHomeScreen extends ConsumerWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final user = ref.watch(authControllerProvider).user;
    final now = DateTime.now();
    final greeting = now.hour < 12 ? s.t('greetingMorning') : s.t('greetingEvening');
    final meds = ref.watch(medicationListProvider);

    final orientation =
        '$greeting ${user?.fullName ?? ''}. '
        '${DateFormat('EEEE', 'ar').format(now)}، '
        '${DateFormat('d MMMM y', 'ar').format(now)}، '
        '${DateFormat('h:mm a', 'ar').format(now)}';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GradientHeader(
            title: '$greeting، ${user?.fullName ?? ''}',
            subtitle: s.t('howAreYouToday'),
            trailing: IconButton(
              tooltip: s.t('logout'),
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) context.go(AppRoutes.welcome);
              },
              icon: const Icon(Icons.logout_rounded, color: AppColors.onPrimary),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.t('todayInfo'),
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 14,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text(
                          '${DateFormat('EEEE', 'ar').format(now)} • '
                          '${DateFormat('d/M/y').format(now)}',
                          style: const TextStyle(
                              color: AppColors.onPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(DateFormat('h:mm a', 'ar').format(now),
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.9), fontSize: 16)),
                      ],
                    ),
                  ),
                  SpeakButton(text: orientation),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionTitle(s.t('quickActions')),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.05,
                  children: [
                    _QuickAction(
                      icon: Icons.psychology_rounded,
                      color: AppColors.purple,
                      background: AppColors.purpleSoft,
                      title: s.t('memoryExercises'),
                      subtitle: s.t('startTodayExercise'),
                      onTap: () => context.go(AppRoutes.patientExercises),
                    ),
                    _QuickAction(
                      icon: Icons.medication_rounded,
                      color: AppColors.info,
                      background: AppColors.infoSoft,
                      title: s.t('medications'),
                      subtitle: s.t('nextDose'),
                      onTap: () => context.go(AppRoutes.patientMedications),
                    ),
                    _QuickAction(
                      icon: Icons.people_alt_rounded,
                      color: AppColors.warning,
                      background: AppColors.warningSoft,
                      title: s.t('familiarFaces'),
                      subtitle: s.t('knowYourFamily'),
                      onTap: () => context.go(AppRoutes.patientFamily),
                    ),
                    _QuickAction(
                      icon: Icons.favorite_rounded,
                      color: AppColors.success,
                      background: AppColors.successSoft,
                      title: s.t('healthTitle'),
                      subtitle: s.t('healthSubtitle'),
                      onTap: () => context.go(AppRoutes.patientHealth),
                    ),
                  ],
                ),
                SectionTitle(s.t('todayMedications')),
                AsyncStateView<List<Medication>>(
                  value: meds,
                  onRetry: () => ref.read(medicationListProvider.notifier).load(),
                  isEmpty: (data) => data.isEmpty,
                  builder: (items) => Column(
                    children: [
                      for (final m in items.take(3))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: MgCard(
                            child: Row(
                              children: [
                                SoftIcon(
                                  icon: Icons.medication_liquid_rounded,
                                  color: m.status == DoseStatus.taken
                                      ? AppColors.success
                                      : AppColors.warning,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(m.name,
                                          style: const TextStyle(
                                              fontSize: 17, fontWeight: FontWeight.w700)),
                                      const SizedBox(height: 4),
                                      Text(m.time,
                                          style: const TextStyle(
                                              color: AppColors.textSecondary, fontSize: 15)),
                                    ],
                                  ),
                                ),
                                StatusChip(
                                  label: m.status == DoseStatus.taken
                                      ? s.t('done')
                                      : s.t('pending'),
                                  color: m.status == DoseStatus.taken
                                      ? AppColors.success
                                      : AppColors.warning,
                                  background: m.status == DoseStatus.taken
                                      ? AppColors.successSoft
                                      : AppColors.warningSoft,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _SosButton(label: s.t('sos'), sentMessage: s.t('sosSent')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.color,
    required this.background,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MgCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SoftIcon(icon: icon, color: color, background: background),
          const Spacer(),
          Text(title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}

/// FR-17: emergency alert. The actual dispatch is a backend call; the UI
/// contract is one big always reachable button.
class _SosButton extends StatelessWidget {
  const _SosButton({required this.label, required this.sentMessage});
  final String label;
  final String sentMessage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 68,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.danger,
          foregroundColor: Colors.white,
        ),
        onPressed: () => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(sentMessage))),
        icon: const Icon(Icons.sos_rounded, size: 30),
        label: Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      ),
    );
  }
}
