import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/data/auth_models.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/auth/presentation/welcome_screen.dart';
import '../features/auth/state/auth_controller.dart';
import '../features/caregiver/presentation/caregiver_dashboard_screen.dart';
import '../features/caregiver/presentation/caregiver_shell.dart';
import '../features/caregiver/presentation/medication_manager_screen.dart';
import '../features/caregiver/presentation/reports_screen.dart';
import '../features/exercises/presentation/exercises_screen.dart';
import '../features/family/presentation/family_screen.dart';
import '../features/health/presentation/health_screen.dart';
import '../features/medications/presentation/medications_screen.dart';
import '../features/patient/presentation/patient_home_screen.dart';
import '../features/patient/presentation/patient_shell.dart';

/// All navigation lives here. Screens never build routes by hand - they use
/// the named paths below, so adding a screen is a one line change.
class AppRoutes {
  AppRoutes._();

  static const welcome = '/';
  static const login = '/login';
  static const register = '/register';

  static const patientHome = '/patient/home';
  static const patientExercises = '/patient/exercises';
  static const patientMedications = '/patient/medications';
  static const patientFamily = '/patient/family';
  static const patientHealth = '/patient/health';

  static const caregiverDashboard = '/caregiver/dashboard';
  static const caregiverReports = '/caregiver/reports';
  static const caregiverMedications = '/caregiver/medications';
}

final routerProvider = Provider<GoRouter>((ref) {
  final patientShellKey = GlobalKey<NavigatorState>(debugLabel: 'patient');
  final caregiverShellKey = GlobalKey<NavigatorState>(debugLabel: 'caregiver');

  return GoRouter(
    initialLocation: AppRoutes.welcome,
    routes: [
      GoRoute(path: AppRoutes.welcome, builder: (_, __) => const WelcomeScreen()),
      GoRoute(path: AppRoutes.login, builder: (_, state) {
        final role = state.extra is UserRole ? state.extra! as UserRole : UserRole.patient;
        return LoginScreen(role: role);
      }),
      GoRoute(path: AppRoutes.register, builder: (_, state) {
        final role = state.extra is UserRole ? state.extra! as UserRole : UserRole.patient;
        return RegisterScreen(role: role);
      }),
      ShellRoute(
        navigatorKey: patientShellKey,
        builder: (_, state, child) =>
            PatientShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(path: AppRoutes.patientHome, builder: (_, __) => const PatientHomeScreen()),
          GoRoute(path: AppRoutes.patientExercises, builder: (_, __) => const ExercisesScreen()),
          GoRoute(
              path: AppRoutes.patientMedications,
              builder: (_, __) => const MedicationsScreen()),
          GoRoute(path: AppRoutes.patientFamily, builder: (_, __) => const FamilyScreen()),
          GoRoute(path: AppRoutes.patientHealth, builder: (_, __) => const HealthScreen()),
        ],
      ),
      ShellRoute(
        navigatorKey: caregiverShellKey,
        builder: (_, state, child) =>
            CaregiverShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
              path: AppRoutes.caregiverDashboard,
              builder: (_, __) => const CaregiverDashboardScreen()),
          GoRoute(path: AppRoutes.caregiverReports, builder: (_, __) => const ReportsScreen()),
          GoRoute(
              path: AppRoutes.caregiverMedications,
              builder: (_, __) => const MedicationManagerScreen()),
        ],
      ),
    ],
    redirect: (context, state) {
      final authed = ref.read(authControllerProvider).isAuthenticated;
      final path = state.uri.path;
      final isPublic = path == AppRoutes.welcome ||
          path == AppRoutes.login ||
          path == AppRoutes.register;
      if (!authed && !isPublic) return AppRoutes.welcome;
      return null;
    },
  );
});

/// Landing route after a successful login, based on the account role.
String homeForRole(UserRole role) =>
    role == UserRole.caregiver ? AppRoutes.caregiverDashboard : AppRoutes.patientHome;
