import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../storage/token_storage.dart';
import 'api_config.dart';
import 'api_result.dart';

/// Centralised HTTP client. UI never talks to http directly.
///
/// Expects the agreed envelope from the Node.js API:
///   { "success": true, "message": "...", "data": { ... } }
///   { "success": false, "message": "...", "errors": [ ... ] }
class ApiClient {
  ApiClient(this._tokenStorage, {http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  final TokenStorage _tokenStorage;
  final http.Client _http;

  Future<ApiResult<T>> get<T>(String path, T Function(dynamic json) parse) =>
      _send('GET', path, null, parse);

  Future<ApiResult<T>> post<T>(String path, Map<String, dynamic> body, T Function(dynamic) parse) =>
      _send('POST', path, body, parse);

  Future<ApiResult<T>> put<T>(String path, Map<String, dynamic> body, T Function(dynamic) parse) =>
      _send('PUT', path, body, parse);

  Future<ApiResult<T>> delete<T>(String path, T Function(dynamic) parse) =>
      _send('DELETE', path, null, parse);

  Future<ApiResult<T>> _send<T>(
    String method,
    String path,
    Map<String, dynamic>? body,
    T Function(dynamic json) parse,
  ) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final token = await _tokenStorage.readToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final request = http.Request(method, uri)..headers.addAll(headers);
      if (body != null) request.body = jsonEncode(body);
      final streamed = await _http.send(request).timeout(ApiConfig.timeout);
      final response = await http.Response.fromStream(streamed);
      final decoded = response.body.isEmpty ? const {} : jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Success(parse(decoded is Map ? decoded['data'] : decoded));
      }
      return Failure<T>(
        _kindFor(response.statusCode),
        decoded is Map ? (decoded['message'] as String? ?? 'Request failed') : 'Request failed',
        errors: decoded is Map && decoded['errors'] is List
            ? List<String>.from(decoded['errors'].map((e) => e.toString()))
            : const [],
      );
    } on TimeoutException {
      return const Failure(FailureKind.network, 'Connection timed out');
    } catch (_) {
      return const Failure(FailureKind.network, 'No internet connection');
    }
  }

  FailureKind _kindFor(int status) => switch (status) {
        401 || 403 => FailureKind.unauthorized,
        404 => FailureKind.notFound,
        422 || 400 => FailureKind.validation,
        >= 500 => FailureKind.server,
        _ => FailureKind.unknown,
      };
}

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref.watch(tokenStorageProvider)),
);
