import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/mg_widgets.dart';
import '../../shared/state/app_providers.dart';
import '../data/exercise_repository.dart';

/// Daily memory exercises. The questions and their difficulty come from the
/// AI engine (FR-35); this screen only presents them and reports results.
class ExercisesScreen extends ConsumerWidget {
  const ExercisesScreen({super.key});

  static const _visuals = {
    ExerciseCategory.family: (Icons.people_alt_rounded, AppColors.warning, AppColors.warningSoft),
    ExerciseCategory.colors: (Icons.palette_rounded, AppColors.purple, AppColors.purpleSoft),
    ExerciseCategory.fruits: (Icons.local_florist_rounded, AppColors.success, AppColors.successSoft),
    ExerciseCategory.dailyLife: (Icons.wb_sunny_rounded, AppColors.info, AppColors.infoSoft),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final topics = ref.watch(todayTopicsProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GradientHeader(
            title: s.t('memoryExercises'),
            subtitle: s.t('exercisesSubtitle'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionTitle(s.t('todayExercise')),
                MgCard(
                  child: Row(
                    children: [
                      const SoftIcon(
                          icon: Icons.auto_awesome_rounded,
                          color: AppColors.purple,
                          background: AppColors.purpleSoft),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.t('answerFourQuestions'),
                                style: const TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            Text(s.t('adaptiveDifficulty'),
                                style: const TextStyle(
                                    color: AppColors.textSecondary, fontSize: 14, height: 1.4)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AsyncStateView<List<ExerciseTopic>>(
                  value: topics,
                  onRetry: () => ref.invalidate(todayTopicsProvider),
                  isEmpty: (d) => d.isEmpty,
                  builder: (items) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < items.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: MgCard(
                            child: Row(
                              children: [
                                SoftIcon(
                                  icon: _visuals[items[i].category]!.$1,
                                  color: _visuals[items[i].category]!.$2,
                                  background: _visuals[items[i].category]!.$3,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(items[i].title,
                                      style: const TextStyle(
                                          fontSize: 17, fontWeight: FontWeight.w700)),
                                ),
                                Text('${i + 1}/${items.length}',
                                    style: const TextStyle(
                                        color: AppColors.textSecondary, fontSize: 15)),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(s.t('startExercise'))),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded, size: 28),
                        label: Text(s.t('startExercise')),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
