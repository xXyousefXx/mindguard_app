import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_theme.dart';

/// Bottom navigation shell for the patient app. Text is scaled up so the
/// whole patient side stays readable (FR-15).
class PatientShell extends ConsumerWidget {
  const PatientShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  static const _tabs = [
    (AppRoutes.patientHome, Icons.home_rounded, 'navHome'),
    (AppRoutes.patientExercises, Icons.psychology_rounded, 'navExercises'),
    (AppRoutes.patientMedications, Icons.medication_rounded, 'navMedications'),
    (AppRoutes.patientFamily, Icons.people_alt_rounded, 'navFamily'),
    (AppRoutes.patientHealth, Icons.favorite_rounded, 'navHealth'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final index = _tabs.indexWhere((t) => t.$1 == location);

    return MediaQuery.withClampedTextScaling(
      minScaleFactor: AppTheme.patientTextScale,
      maxScaleFactor: AppTheme.patientTextScale * 1.3,
      child: Scaffold(
        body: child,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: index < 0 ? 0 : index,
          onTap: (i) => context.go(_tabs[i].$1),
          items: [
            for (final tab in _tabs)
              BottomNavigationBarItem(icon: Icon(tab.$2), label: s.t(tab.$3)),
          ],
        ),
      ),
    );
  }
}
