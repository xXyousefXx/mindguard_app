import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_result.dart';
import '../../caregiver/data/caregiver_repository.dart';
import '../../exercises/data/exercise_repository.dart';
import '../../family/data/family_repository.dart';
import '../../health/data/health_repository.dart';

/// Read-only screens all share the same pattern: a FutureProvider that turns
/// an [ApiResult] into an AsyncValue the UI can render with AsyncStateView.
final todayTopicsProvider = FutureProvider<List<ExerciseTopic>>(
    (ref) async => (await ref.watch(exerciseRepositoryProvider).todayTopics()).orThrow());

final familyMembersProvider = FutureProvider<List<FamilyMember>>(
    (ref) async => (await ref.watch(familyRepositoryProvider).list()).orThrow());

final healthSnapshotProvider = FutureProvider<HealthSnapshot>(
    (ref) async => (await ref.watch(healthRepositoryProvider).latest()).orThrow());

final caregiverDashboardProvider = FutureProvider<CaregiverDashboard>(
    (ref) async => (await ref.watch(caregiverRepositoryProvider).dashboard()).orThrow());

final voiceNotesProvider = FutureProvider<List<VoiceNote>>(
    (ref) async => (await ref.watch(caregiverRepositoryProvider).voiceNotes()).orThrow());

/// Reports screen toggles between daily and weekly ranges.
final reportRangeWeeklyProvider = StateProvider<bool>((ref) => true);

final progressReportProvider = FutureProvider<ProgressReport>((ref) async =>
    (await ref
            .watch(caregiverRepositoryProvider)
            .report(weekly: ref.watch(reportRangeWeeklyProvider)))
        .orThrow());
