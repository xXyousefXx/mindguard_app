import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../data/auth_models.dart';

/// First screen in the Figma flow: brand, tagline, feature pills and the two
/// entry points (patient / caregiver).
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 108,
                    height: 108,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: const Icon(Icons.psychology_alt_rounded,
                        size: 60, color: AppColors.onPrimary),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  s.t('appName'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.onPrimary, fontSize: 30, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Text(
                  s.t('appTagline'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.9), fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 28),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _Pill(icon: Icons.location_on_rounded, label: s.t('gpsLocation')),
                    _Pill(icon: Icons.medication_rounded, label: s.t('memoryReminders')),
                    _Pill(icon: Icons.auto_awesome_rounded, label: s.t('aiFeature')),
                  ],
                ),
                const SizedBox(height: 36),
                _RoleButton(
                  icon: Icons.elderly_rounded,
                  label: s.t('patientApp'),
                  filled: true,
                  onTap: () => context.push(AppRoutes.login, extra: UserRole.patient),
                ),
                const SizedBox(height: 14),
                _RoleButton(
                  icon: Icons.shield_moon_rounded,
                  label: s.t('caregiverApp'),
                  filled: false,
                  onTap: () => context.push(AppRoutes.login, extra: UserRole.caregiver),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => context.push(AppRoutes.register, extra: UserRole.patient),
                  child: Text(
                    s.t('register'),
                    style: const TextStyle(
                        color: AppColors.onPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.onPrimary),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: AppColors.onPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  const _RoleButton({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = filled ? AppColors.primary : AppColors.onPrimary;
    return Material(
      color: filled ? AppColors.surface : Colors.white.withOpacity(0.14),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 66,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: filled ? null : Border.all(color: Colors.white70, width: 1.4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foreground, size: 26),
              const SizedBox(width: 10),
              Text(label,
                  style: TextStyle(
                      color: foreground, fontSize: 19, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }
}
