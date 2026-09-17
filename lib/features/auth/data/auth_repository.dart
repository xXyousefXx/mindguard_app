import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_result.dart';
import 'auth_models.dart';

/// Contract the Node.js backend must satisfy.
///   POST /api/auth/login            { email, password }        -> { token, user }
///   POST /api/auth/register         { fullName, email, password, role }
///   POST /api/auth/forgot-password  { email }
abstract class AuthRepository {
  Future<ApiResult<AuthSession>> login({required String email, required String password});
  Future<ApiResult<AuthSession>> register({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  });
  Future<ApiResult<void>> forgotPassword(String email);
}

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._client);
  final ApiClient _client;

  @override
  Future<ApiResult<AuthSession>> login({required String email, required String password}) =>
      _client.post('/auth/login', {'email': email, 'password': password},
          (json) => AuthSession.fromJson(Map<String, dynamic>.from(json as Map)));

  @override
  Future<ApiResult<AuthSession>> register({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  }) =>
      _client.post(
        '/auth/register',
        {'fullName': fullName, 'email': email, 'password': password, 'role': roleToApi(role)},
        (json) => AuthSession.fromJson(Map<String, dynamic>.from(json as Map)),
      );

  @override
  Future<ApiResult<void>> forgotPassword(String email) =>
      _client.post('/auth/forgot-password', {'email': email}, (_) {});
}

/// Temporary stand-in until the backend is ready. Replace by flipping
/// USE_MOCK_DATA to false - no UI change required.
class MockAuthRepository implements AuthRepository {
  @override
  Future<ApiResult<AuthSession>> login({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (password.length < 4) {
      return const Failure(FailureKind.unauthorized, 'بيانات الدخول غير صحيحة');
    }
    final isCaregiver = email.toLowerCase().startsWith('care');
    return Success(AuthSession(
      token: 'mock-token',
      user: AppUser(
        id: isCaregiver ? 'c1' : 'p1',
        fullName: isCaregiver ? 'سارة إمام' : 'عادل إمام',
        email: email,
        role: isCaregiver ? UserRole.caregiver : UserRole.patient,
        permission: isCaregiver ? CaregiverPermission.primary : null,
      ),
    ));
  }

  @override
  Future<ApiResult<AuthSession>> register({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return Success(AuthSession(
      token: 'mock-token',
      user: AppUser(
        id: 'new',
        fullName: fullName,
        email: email,
        role: role,
        permission: role == UserRole.caregiver ? CaregiverPermission.primary : null,
      ),
    ));
  }

  @override
  Future<ApiResult<void>> forgotPassword(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return const Success(null);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) =>
    ApiConfig.useMockData ? MockAuthRepository() : ApiAuthRepository(ref.watch(apiClientProvider)));
