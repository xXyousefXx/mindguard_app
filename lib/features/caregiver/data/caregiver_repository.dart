import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_result.dart';

enum AlertSeverity { warning, success, danger }

class PatientAlert {
  const PatientAlert({
    required this.id,
    required this.title,
    required this.timeAgo,
    required this.severity,
  });

  final String id;
  final String title;
  final String timeAgo;
  final AlertSeverity severity;

  factory PatientAlert.fromJson(Map<String, dynamic> json) => PatientAlert(
        id: json['id'].toString(),
        title: json['title'] as String,
        timeAgo: json['timeAgo'] as String? ?? '',
        severity: AlertSeverity.values.firstWhere(
          (s) => s.name == json['severity'],
          orElse: () => AlertSeverity.warning,
        ),
      );
}

class CaregiverDashboard {
  const CaregiverDashboard({
    required this.patientName,
    required this.patientPhotoUrl,
    required this.locationLabel,
    required this.lastUpdate,
    required this.dosesTaken,
    required this.dosesTotal,
    required this.memoryScore,
    required this.steps,
    required this.weeklyMemory,
    required this.alerts,
  });

  final String patientName;
  final String patientPhotoUrl;
  final String locationLabel;
  final String lastUpdate;
  final int dosesTaken;
  final int dosesTotal;
  final int memoryScore;
  final int steps;

  /// (day label, score) pairs.
  final List<(String, double)> weeklyMemory;
  final List<PatientAlert> alerts;

  factory CaregiverDashboard.fromJson(Map<String, dynamic> json) => CaregiverDashboard(
        patientName: json['patientName'] as String? ?? '',
        patientPhotoUrl: json['patientPhotoUrl'] as String? ?? '',
        locationLabel: json['locationLabel'] as String? ?? '',
        lastUpdate: json['lastUpdate'] as String? ?? '',
        dosesTaken: json['dosesTaken'] as int? ?? 0,
        dosesTotal: json['dosesTotal'] as int? ?? 0,
        memoryScore: json['memoryScore'] as int? ?? 0,
        steps: json['steps'] as int? ?? 0,
        weeklyMemory: ((json['weeklyMemory'] as List? ?? []))
            .map((e) => (e['label'] as String, (e['value'] as num).toDouble()))
            .toList(),
        alerts: ((json['alerts'] as List? ?? []))
            .map((e) => PatientAlert.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}

class VoiceNote {
  const VoiceNote({required this.id, required this.author, required this.time, required this.text});
  final String id;
  final String author;
  final String time;
  final String text;

  factory VoiceNote.fromJson(Map<String, dynamic> json) => VoiceNote(
        id: json['id'].toString(),
        author: json['author'] as String,
        time: json['time'] as String? ?? '',
        text: json['text'] as String? ?? '',
      );
}

class ProgressReport {
  const ProgressReport({
    required this.memoryScore,
    required this.memoryDelta,
    required this.adherencePercent,
    required this.adherenceLabel,
    required this.zoneExits,
    required this.averageSteps,
    required this.memoryTrend,
  });

  final int memoryScore;
  final int memoryDelta;
  final int adherencePercent;
  final String adherenceLabel;
  final int zoneExits;
  final int averageSteps;
  final List<(String, double)> memoryTrend;

  factory ProgressReport.fromJson(Map<String, dynamic> json) => ProgressReport(
        memoryScore: json['memoryScore'] as int? ?? 0,
        memoryDelta: json['memoryDelta'] as int? ?? 0,
        adherencePercent: json['adherencePercent'] as int? ?? 0,
        adherenceLabel: json['adherenceLabel'] as String? ?? '',
        zoneExits: json['zoneExits'] as int? ?? 0,
        averageSteps: json['averageSteps'] as int? ?? 0,
        memoryTrend: ((json['memoryTrend'] as List? ?? []))
            .map((e) => (e['label'] as String, (e['value'] as num).toDouble()))
            .toList(),
      );
}

/// GET /api/caregiver/dashboard, /api/reports?range=daily|weekly, /api/voice-notes
abstract class CaregiverRepository {
  Future<ApiResult<CaregiverDashboard>> dashboard();
  Future<ApiResult<ProgressReport>> report({required bool weekly});
  Future<ApiResult<List<VoiceNote>>> voiceNotes();
}

class ApiCaregiverRepository implements CaregiverRepository {
  ApiCaregiverRepository(this._client);
  final ApiClient _client;

  @override
  Future<ApiResult<CaregiverDashboard>> dashboard() => _client.get('/caregiver/dashboard',
      (json) => CaregiverDashboard.fromJson(Map<String, dynamic>.from(json as Map)));

  @override
  Future<ApiResult<ProgressReport>> report({required bool weekly}) => _client.get(
      '/reports?range=${weekly ? 'weekly' : 'daily'}',
      (json) => ProgressReport.fromJson(Map<String, dynamic>.from(json as Map)));

  @override
  Future<ApiResult<List<VoiceNote>>> voiceNotes() => _client.get(
        '/voice-notes',
        (json) => (json as List)
            .map((e) => VoiceNote.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}

class MockCaregiverRepository implements CaregiverRepository {
  @override
  Future<ApiResult<CaregiverDashboard>> dashboard() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return const Success(CaregiverDashboard(
      patientName: 'عادل إمام',
      patientPhotoUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&q=80',
      locationLabel: 'في المنزل',
      lastUpdate: 'منذ دقيقتين',
      dosesTaken: 1,
      dosesTotal: 3,
      memoryScore: 85,
      steps: 3200,
      weeklyMemory: [
        ('الأحد', 70),
        ('الاثنين', 73),
        ('الثلاثاء', 72),
        ('الأربعاء', 78),
        ('الخميس', 81),
        ('الجمعة', 85),
      ],
      alerts: [
        PatientAlert(
          id: '1',
          title: 'لم يتناول دواء فيتامين د في موعده',
          timeAgo: 'منذ ساعتين',
          severity: AlertSeverity.warning,
        ),
        PatientAlert(
          id: '2',
          title: 'أتمّ تمرين الذاكرة اليومي بنجاح',
          timeAgo: 'منذ 3 ساعات',
          severity: AlertSeverity.success,
        ),
        PatientAlert(
          id: '3',
          title: 'خرج من النطاق الآمن لمدة 5 دقائق',
          timeAgo: 'أمس',
          severity: AlertSeverity.danger,
        ),
      ],
    ));
  }

  @override
  Future<ApiResult<ProgressReport>> report({required bool weekly}) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return Success(ProgressReport(
      memoryScore: weekly ? 82 : 85,
      memoryDelta: 7,
      adherencePercent: 85,
      adherenceLabel: '17/20 جرعة',
      zoneExits: 0,
      averageSteps: 3800,
      memoryTrend: const [
        ('السبت', 62),
        ('الأحد', 68),
        ('الاثنين', 65),
        ('الثلاثاء', 72),
        ('الأربعاء', 79),
        ('الخميس', 78),
        ('الجمعة', 84),
      ],
    ));
  }

  @override
  Future<ApiResult<List<VoiceNote>>> voiceNotes() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return const Success([
      VoiceNote(id: '1', author: 'سارة', time: '7:00 ص', text: 'صباح الخير يا بابا، لا تنسى دواءك'),
      VoiceNote(id: '2', author: 'محمد', time: '1:00 م', text: 'اتغدّيت؟ خلي بالك من نفسك'),
    ]);
  }
}

final caregiverRepositoryProvider = Provider<CaregiverRepository>((ref) => ApiConfig.useMockData
    ? MockCaregiverRepository()
    : ApiCaregiverRepository(ref.watch(apiClientProvider)));
