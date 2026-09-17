import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindguard_app/features/auth/data/auth_models.dart';
import 'package:mindguard_app/features/auth/data/auth_repository.dart';
import 'package:mindguard_app/core/network/api_result.dart';

void main() {
  test('mock login returns a caregiver session for care* emails', () async {
    final repo = MockAuthRepository();
    final result = await repo.login(email: 'care@mindguard.app', password: '1234');
    expect(result, isA<Success<AuthSession>>());
    expect((result as Success<AuthSession>).data.user.role, UserRole.caregiver);
  });

  test('mock login rejects short passwords', () async {
    final repo = MockAuthRepository();
    final result = await repo.login(email: 'p@mindguard.app', password: '1');
    expect(result, isA<Failure<AuthSession>>());
  });

  test('provider container builds the auth repository', () {
    final container = ProviderContainer();
    expect(container.read(authRepositoryProvider), isA<AuthRepository>());
    container.dispose();
  });
}
