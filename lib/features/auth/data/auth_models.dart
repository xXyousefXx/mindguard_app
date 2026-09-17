enum UserRole { patient, caregiver }

UserRole roleFromApi(String value) =>
    value.toLowerCase() == 'caregiver' ? UserRole.caregiver : UserRole.patient;

String roleToApi(UserRole role) => role.name;

/// Permission level of a caregiver on a patient link (FR-06).
enum CaregiverPermission { primary, secondary }

class AppUser {
  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.permission,
  });

  final String id;
  final String fullName;
  final String email;
  final UserRole role;
  final CaregiverPermission? permission;

  bool get canEditSensitiveSettings =>
      role == UserRole.caregiver && permission == CaregiverPermission.primary;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'].toString(),
        fullName: json['fullName'] as String? ?? '',
        email: json['email'] as String? ?? '',
        role: roleFromApi(json['role'] as String? ?? 'patient'),
        permission: json['permission'] == null
            ? null
            : CaregiverPermission.values.firstWhere(
                (p) => p.name == json['permission'],
                orElse: () => CaregiverPermission.secondary,
              ),
      );
}

class AuthSession {
  const AuthSession({required this.token, required this.user});
  final String token;
  final AppUser user;

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        token: json['token'] as String,
        user: AppUser.fromJson(Map<String, dynamic>.from(json['user'] as Map)),
      );
}
