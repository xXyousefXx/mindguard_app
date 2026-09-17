import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/mg_widgets.dart';
import '../data/medication_repository.dart';
import '../state/medication_providers.dart';

/// Patient view of today's doses. Each row can be read aloud (FR-10) and
/// confirmed as taken (FR-11).
class MedicationsScreen extends ConsumerWidget {
  const MedicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final meds = ref.watch(medicationListProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GradientHeader(
            title: s.t('medicationsTitle'),
            subtitle: s.t('medicationsSubtitle'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: AsyncStateView<List<Medication>>(
              value: meds,
              onRetry: () => ref.read(medicationListProvider.notifier).load(),
              isEmpty: (d) => d.isEmpty,
              builder: (items) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final m in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: MgCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SoftIcon(
                                  icon: Icons.medication_rounded,
                                  color: m.status == DoseStatus.taken
                                      ? AppColors.success
                                      : AppColors.warning,
                                  size: 54,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(m.name,
                                          style: const TextStyle(
                                              fontSize: 19, fontWeight: FontWeight.w800)),
                                      const SizedBox(height: 4),
                                      Text(m.time,
                                          style: const TextStyle(
                                              color: AppColors.textSecondary, fontSize: 16)),
                                    ],
                                  ),
                                ),
                                SpeakButton(text: m.voiceMessage ?? '${m.name} ${m.time}'),
                              ],
                            ),
                            const SizedBox(height: 14),
                            if (m.status == DoseStatus.taken)
                              StatusChip(
                                label: s.t('taken'),
                                color: AppColors.success,
                                background: AppColors.successSoft,
                              )
                            else
                              SizedBox(
                                height: 54,
                                child: ElevatedButton.icon(
                                  onPressed: () => ref
                                      .read(medicationListProvider.notifier)
                                      .markTaken(m.id),
                                  icon: const Icon(Icons.check_circle_rounded, size: 26),
                                  label: Text(s.t('taken')),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
