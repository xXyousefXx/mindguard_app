import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the auth token and the cached role so the app can restore the
/// session offline. Swap for flutter_secure_storage before production.
class TokenStorage {
  static const _tokenKey = 'mg_auth_token';
  static const _roleKey = 'mg_auth_role';

  Future<String?> readToken() async =>
      (await SharedPreferences.getInstance()).getString(_tokenKey);

  Future<String?> readRole() async =>
      (await SharedPreferences.getInstance()).getString(_roleKey);

  Future<void> save({required String token, required String role}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_roleKey, role);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_roleKey);
  }
}

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());
