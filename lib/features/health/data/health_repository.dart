import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_result.dart';

/// Smart watch data. The watch integration itself is owned by another team;
/// this app only reads what the backend exposes:
///   GET /api/health/latest
///   GET /api/health/series?metric=heartRate&range=today
class HealthSnapshot {
  const HealthSnapshot({
    required this.heartRate,
    required this.oxygen,
    required this.steps,
    required this.sleepHours,
    required this.heartRateSeries,
    required this.watchPaired,
  });

  final int heartRate;
  final int oxygen;
  final int steps;
  final double sleepHours;

  /// (hour label, bpm) pairs for the chart.
  final List<(String, double)> heartRateSeries;
  final bool watchPaired;

  factory HealthSnapshot.fromJson(Map<String, dynamic> json) => HealthSnapshot(
        heartRate: json['heartRate'] as int? ?? 0,
        oxygen: json['oxygen'] as int? ?? 0,
        steps: json['steps'] as int? ?? 0,
        sleepHours: (json['sleepHours'] as num? ?? 0).toDouble(),
        watchPaired: json['watchPaired'] as bool? ?? false,
        heartRateSeries: ((json['heartRateSeries'] as List? ?? []))
            .map((e) => (e['label'] as String, (e['value'] as num).toDouble()))
            .toList(),
      );
}

abstract class HealthRepository {
  Future<ApiResult<HealthSnapshot>> latest({String? patientId});
}

class ApiHealthRepository implements HealthRepository {
  ApiHealthRepository(this._client);
  final ApiClient _client;

  @override
  Future<ApiResult<HealthSnapshot>> latest({String? patientId}) => _client.get(
        patientId == null ? '/health/latest' : '/health/latest?patientId=$patientId',
        (json) => HealthSnapshot.fromJson(Map<String, dynamic>.from(json as Map)),
      );
}

class MockHealthRepository implements HealthRepository {
  @override
  Future<ApiResult<HealthSnapshot>> latest({String? patientId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return const Success(HealthSnapshot(
      heartRate: 72,
      oxygen: 98,
      steps: 3241,
      sleepHours: 7.5,
      watchPaired: true,
      heartRateSeries: [
        ('9ص', 68),
        ('12م', 74),
        ('3م', 78),
        ('6م', 75),
        ('9م', 71),
        ('الآن', 72),
      ],
    ));
  }
}

final healthRepositoryProvider = Provider<HealthRepository>((ref) => ApiConfig.useMockData
    ? MockHealthRepository()
    : ApiHealthRepository(ref.watch(apiClientProvider)));
