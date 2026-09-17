import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_result.dart';

enum DoseStatus { taken, pending }

class Medication {
  const Medication({
    required this.id,
    required this.name,
    required this.time,
    required this.status,
    this.voiceMessage,
  });

  final String id;
  final String name;

  /// Display time as agreed with the backend, e.g. "08:00 ص".
  final String time;
  final DoseStatus status;

  /// Text spoken by TTS when the reminder fires (FR-10).
  final String? voiceMessage;

  Medication copyWith({DoseStatus? status}) => Medication(
        id: id,
        name: name,
        time: time,
        status: status ?? this.status,
        voiceMessage: voiceMessage,
      );

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
        id: json['id'].toString(),
        name: json['name'] as String,
        time: json['time'] as String,
        status: (json['status'] as String? ?? 'pending') == 'taken'
            ? DoseStatus.taken
            : DoseStatus.pending,
        voiceMessage: json['voiceMessage'] as String?,
      );

  Map<String, dynamic> toJson() =>
      {'name': name, 'time': time, 'status': status.name, 'voiceMessage': voiceMessage};
}

/// GET/POST/PUT/DELETE /api/medications  (patient reads own, caregiver manages)
abstract class MedicationRepository {
  Future<ApiResult<List<Medication>>> list({String? patientId});
  Future<ApiResult<Medication>> markTaken(String id);
  Future<ApiResult<Medication>> create(Medication medication);
  Future<ApiResult<void>> delete(String id);
}

class ApiMedicationRepository implements MedicationRepository {
  ApiMedicationRepository(this._client);
  final ApiClient _client;

  List<Medication> _parseList(dynamic json) =>
      (json as List).map((e) => Medication.fromJson(Map<String, dynamic>.from(e as Map))).toList();

  @override
  Future<ApiResult<List<Medication>>> list({String? patientId}) => _client.get(
      patientId == null ? '/medications' : '/medications?patientId=$patientId', _parseList);

  @override
  Future<ApiResult<Medication>> markTaken(String id) => _client.put('/medications/$id',
      {'status': 'taken'}, (json) => Medication.fromJson(Map<String, dynamic>.from(json as Map)));

  @override
  Future<ApiResult<Medication>> create(Medication medication) => _client.post('/medications',
      medication.toJson(), (json) => Medication.fromJson(Map<String, dynamic>.from(json as Map)));

  @override
  Future<ApiResult<void>> delete(String id) => _client.delete('/medications/$id', (_) {});
}

class MockMedicationRepository implements MedicationRepository {
  final List<Medication> _items = [
    const Medication(
      id: '1',
      name: 'دواء الضغط',
      time: '08:00 ص',
      status: DoseStatus.taken,
      voiceMessage: 'حان الآن موعد دواء الضغط',
    ),
    const Medication(
      id: '2',
      name: 'فيتامين د',
      time: '01:00 م',
      status: DoseStatus.pending,
      voiceMessage: 'لا تنسَ فيتامين د بعد وجبة الغداء',
    ),
    const Medication(
      id: '3',
      name: 'دواء السكر',
      time: '06:00 م',
      status: DoseStatus.pending,
      voiceMessage: 'موعد دواء السكر في المساء',
    ),
  ];

  @override
  Future<ApiResult<List<Medication>>> list({String? patientId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return Success(List.unmodifiable(_items));
  }

  @override
  Future<ApiResult<Medication>> markTaken(String id) async {
    final index = _items.indexWhere((m) => m.id == id);
    if (index == -1) return const Failure(FailureKind.notFound, 'الدواء غير موجود');
    _items[index] = _items[index].copyWith(status: DoseStatus.taken);
    return Success(_items[index]);
  }

  @override
  Future<ApiResult<Medication>> create(Medication medication) async {
    final created = Medication(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: medication.name,
      time: medication.time,
      status: DoseStatus.pending,
      voiceMessage: medication.voiceMessage,
    );
    _items.add(created);
    return Success(created);
  }

  @override
  Future<ApiResult<void>> delete(String id) async {
    _items.removeWhere((m) => m.id == id);
    return const Success(null);
  }
}

final medicationRepositoryProvider = Provider<MedicationRepository>((ref) => ApiConfig.useMockData
    ? MockMedicationRepository()
    : ApiMedicationRepository(ref.watch(apiClientProvider)));
