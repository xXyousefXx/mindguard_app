import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_result.dart';
import '../data/medication_repository.dart';

/// Today's doses for the signed-in patient (or the linked patient when the
/// caregiver is managing them).
class MedicationListNotifier extends StateNotifier<AsyncValue<List<Medication>>> {
  MedicationListNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  final MedicationRepository _repository;

  Future<void> load() async {
    state = const AsyncValue.loading();
    final result = await _repository.list();
    state = switch (result) {
      Success(:final data) => AsyncValue.data(data),
      Failure(:final kind, :final message) =>
        AsyncValue.error(ApiException(kind, message), StackTrace.current),
    };
  }

  Future<void> markTaken(String id) async {
    await _repository.markTaken(id);
    await load();
  }

  Future<void> add(Medication medication) async {
    await _repository.create(medication);
    await load();
  }

  Future<void> remove(String id) async {
    await _repository.delete(id);
    await load();
  }
}

final medicationListProvider =
    StateNotifierProvider<MedicationListNotifier, AsyncValue<List<Medication>>>(
        (ref) => MedicationListNotifier(ref.watch(medicationRepositoryProvider)));
