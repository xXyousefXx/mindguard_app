import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_result.dart';
import '../../../core/storage/token_storage.dart';
import '../data/auth_models.dart';
import '../data/auth_repository.dart';

class AuthState {
  const AuthState({this.user, this.loading = false, this.error});

  final AppUser? user;
  final bool loading;
  final String? error;

  bool get isAuthenticated => user != null;

  AuthState copyWith({AppUser? user, bool? loading, String? error, bool clearError = false}) =>
      AuthState(
        user: user ?? this.user,
        loading: loading ?? this.loading,
        error: clearError ? null : (error ?? this.error),
      );
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository, this._tokenStorage) : super(const AuthState());

  final AuthRepository _repository;
  final TokenStorage _tokenStorage;

  Future<bool> login(String email, String password) =>
      _run(() => _repository.login(email: email, password: password));

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  }) =>
      _run(() => _repository.register(
          fullName: fullName, email: email, password: password, role: role));

  Future<bool> _run(Future<ApiResult<AuthSession>> Function() action) async {
    state = state.copyWith(loading: true, clearError: true);
    final result = await action();
    switch (result) {
      case Success(:final data):
        await _tokenStorage.save(token: data.token, role: roleToApi(data.user.role));
        state = AuthState(user: data.user);
        return true;
      case Failure(:final message):
        state = AuthState(error: message);
        return false;
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clear();
    state = const AuthState();
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ref.watch(authRepositoryProvider), ref.watch(tokenStorageProvider)),
);
