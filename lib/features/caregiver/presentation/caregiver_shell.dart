import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/localization/app_strings.dart';

/// Bottom navigation shell for the caregiver app.
class CaregiverShell extends ConsumerWidget {
  const CaregiverShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  static const _tabs = [
    (AppRoutes.caregiverDashboard, Icons.dashboard_rounded, 'navDashboard'),
    (AppRoutes.caregiverMedications, Icons.medication_rounded, 'navMedications'),
    (AppRoutes.caregiverReports, Icons.insights_rounded, 'navReports'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final index = _tabs.indexWhere((t) => t.$1 == location);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index < 0 ? 0 : index,
        onTap: (i) => context.go(_tabs[i].$1),
        items: [
          for (final tab in _tabs)
            BottomNavigationBarItem(icon: Icon(tab.$2), label: s.t(tab.$3)),
        ],
      ),
    );
  }
}
