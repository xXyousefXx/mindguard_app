import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/mg_widgets.dart';
import '../../medications/data/medication_repository.dart';
import '../../medications/state/medication_providers.dart';
import '../../shared/state/app_providers.dart';
import '../data/caregiver_repository.dart';

/// Caregiver medication manager (FR-09): add, remove and review the patient's
/// doses, plus the family voice notes that play with each reminder.
class MedicationManagerScreen extends ConsumerWidget {
  const MedicationManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final medications = ref.watch(medicationListProvider);
    final notes = ref.watch(voiceNotesProvider);

    return Scaffold(
      body: Column(
        children: [
          GradientHeader(
            title: s.t('medicationManager'),
            subtitle: s.t('medicationManagerSub'),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AsyncStateView<List<Medication>>(
                    value: medications,
                    onRetry: () => ref.read(medicationListProvider.notifier).load(),
                    isEmpty: (data) => data.isEmpty,
                    builder: (data) => Column(
                      children: [
                        for (final medication in data) ...[
                          _ManagedMedicationTile(
                            medication: medication,
                            s: s,
                            onDelete: () =>
                                ref.read(medicationListProvider.notifier).remove(medication.id),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _openAddSheet(context, ref, s),
                    icon: const Icon(Icons.add_rounded),
                    label: Text(s.t('addMedication')),
                  ),
                  SectionTitle(s.t('voiceNotes')),
                  AsyncStateView<List<VoiceNote>>(
                    value: notes,
                    onRetry: () => ref.invalidate(voiceNotesProvider),
                    isEmpty: (data) => data.isEmpty,
                    builder: (data) => Column(
                      children: [
                        for (final note in data) ...[
                          MgCard(
                            child: Row(
                              children: [
                                const SoftIcon(
                                  icon: Icons.graphic_eq_rounded,
                                  color: AppColors.purple,
                                  background: AppColors.purpleSoft,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${note.author} · ${note.time}',
                                        style: const TextStyle(
                                            fontSize: 14, fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        note.text,
                                        style: const TextStyle(
                                            fontSize: 14, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                SpeakButton(text: note.text),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(s.t('recordVoiceNote'))),
                    ),
                    icon: const Icon(Icons.mic_rounded),
                    label: Text(s.t('recordVoiceNote')),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAddSheet(BuildContext context, WidgetRef ref, AppStrings s) async {
    final nameController = TextEditingController();
    final timeController = TextEditingController();
    final messageController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                s.t('addMedication'),
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: s.t('medications')),
                validator: (v) => (v == null || v.trim().isEmpty) ? s.t('empty') : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: timeController,
                decoration: InputDecoration(labelText: s.t('time'), hintText: '08:00 ص'),
                validator: (v) => (v == null || v.trim().isEmpty) ? s.t('empty') : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: messageController,
                decoration: InputDecoration(labelText: s.t('voiceNotes')),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  ref.read(medicationListProvider.notifier).add(
                        Medication(
                          id: '',
                          name: nameController.text.trim(),
                          time: timeController.text.trim(),
                          status: DoseStatus.pending,
                          voiceMessage: messageController.text.trim().isEmpty
                              ? null
                              : messageController.text.trim(),
                        ),
                      );
                  Navigator.of(sheetContext).pop();
                },
                child: Text(s.t('addMedication')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManagedMedicationTile extends StatelessWidget {
  const _ManagedMedicationTile({
    required this.medication,
    required this.s,
    required this.onDelete,
  });

  final Medication medication;
  final AppStrings s;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final taken = medication.status == DoseStatus.taken;
    return MgCard(
      child: Row(
        children: [
          SoftIcon(
            icon: Icons.medication_rounded,
            color: taken ? AppColors.success : AppColors.warning,
            background: taken ? AppColors.successSoft : AppColors.warningSoft,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(medication.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  medication.time,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          StatusChip(
            label: taken ? s.t('done') : s.t('pending'),
            color: taken ? AppColors.success : AppColors.warning,
            background: taken ? AppColors.successSoft : AppColors.warningSoft,
          ),
          IconButton(
            tooltip: 'delete',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
          ),
        ],
      ),
    );
  }
}
