/// Backend configuration. Never hardcode URLs in widgets or services.
///
/// Run with:
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4000/api --dart-define=USE_MOCK_DATA=false
class ApiConfig {
  ApiConfig._();

  static const String baseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:4000/api');

  /// While the Node.js backend and the database are still being built by the
  /// other teams, the app runs on the in-memory mock data source.
  static const bool useMockData =
      bool.fromEnvironment('USE_MOCK_DATA', defaultValue: true);

  static const Duration timeout = Duration(seconds: 20);
}
