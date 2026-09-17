import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_result.dart';

class FamilyMember {
  const FamilyMember({
    required this.id,
    required this.name,
    required this.relation,
    required this.photoUrl,
  });

  final String id;
  final String name;
  final String relation;
  final String photoUrl;

  /// Sentence read aloud by TTS when the photo is selected (FR-13).
  String get spokenIntroduction => '$name، $relation';


  factory FamilyMember.fromJson(Map<String, dynamic> json) => FamilyMember(
        id: json['id'].toString(),
        name: json['name'] as String,
        relation: json['relation'] as String? ?? '',
        photoUrl: json['photoUrl'] as String? ?? '',
      );
}

/// GET /api/family-members, POST/PUT/DELETE managed by the caregiver (FR-21)
abstract class FamilyRepository {
  Future<ApiResult<List<FamilyMember>>> list({String? patientId});
}

class ApiFamilyRepository implements FamilyRepository {
  ApiFamilyRepository(this._client);
  final ApiClient _client;

  @override
  Future<ApiResult<List<FamilyMember>>> list({String? patientId}) => _client.get(
        patientId == null ? '/family-members' : '/family-members?patientId=$patientId',
        (json) => (json as List)
            .map((e) => FamilyMember.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}

class MockFamilyRepository implements FamilyRepository {
  @override
  Future<ApiResult<List<FamilyMember>>> list({String? patientId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return const Success([
      FamilyMember(
        id: '1',
        name: 'عادل',
        relation: 'الأخ الكبير',
        photoUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800&q=80',
      ),
      FamilyMember(
        id: '2',
        name: 'سارة',
        relation: 'الابنة',
        photoUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800&q=80',
      ),
      FamilyMember(
        id: '3',
        name: 'محمد',
        relation: 'الابن',
        photoUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&q=80',
      ),
      FamilyMember(
        id: '4',
        name: 'يوسف',
        relation: 'الحفيد',
        photoUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800&q=80',
      ),
      FamilyMember(
        id: '5',
        name: 'كريم',
        relation: 'الجار',
        photoUrl: 'https://images.unsplash.com/photo-1531427186611-ecfd6d936c79?w=800&q=80',
      ),
    ]);
  }
}

final familyRepositoryProvider = Provider<FamilyRepository>((ref) => ApiConfig.useMockData
    ? MockFamilyRepository()
    : ApiFamilyRepository(ref.watch(apiClientProvider)));
