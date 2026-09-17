import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/services/speech_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/mg_widgets.dart';
import '../../shared/state/app_providers.dart';
import '../data/family_repository.dart';

/// Familiar faces gallery (FR-13). Tapping a face reads the name and the
/// relation aloud.
class FamilyScreen extends ConsumerWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final members = ref.watch(familyMembersProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GradientHeader(title: s.t('familyTitle'), subtitle: s.t('familySubtitle')),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: AsyncStateView<List<FamilyMember>>(
              value: members,
              onRetry: () => ref.invalidate(familyMembersProvider),
              isEmpty: (d) => d.isEmpty,
              builder: (items) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.78,
                    ),
                    itemBuilder: (context, i) => _FaceCard(member: items[i]),
                  ),
                  const SizedBox(height: 18),
                  MgCard(
                    color: AppColors.surfaceMuted,
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(s.t('familyHint'),
                              style: const TextStyle(fontSize: 14, height: 1.5)),
                        ),
                      ],
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

class _FaceCard extends ConsumerWidget {
  const _FaceCard({required this.member});
  final FamilyMember member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MgCard(
      padding: const EdgeInsets.all(12),
      onTap: () => ref.read(speechServiceProvider).speak(member.spokenIntroduction),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                member.photoUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.surfaceMuted,
                  child: const Icon(Icons.person_rounded,
                      size: 48, color: AppColors.textSecondary),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(member.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          Text(member.relation,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 6),
          SpeakButton(text: member.spokenIntroduction, size: 40),
        ],
      ),
    );
  }
}
