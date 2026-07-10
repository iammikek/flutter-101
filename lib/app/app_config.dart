import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig extends ChangeNotifier {
  AppConfig({
    String baseUrl = 'http://localhost:8000',
    bool useMock = true,
  })  : _baseUrl = baseUrl,
        _useMock = useMock;

  factory AppConfig.fromEnv() {
    return AppConfig(
      baseUrl: _readEnv('BASE_URL', 'http://localhost:8000'),
      useMock: _readEnv('USE_MOCK', 'true').toLowerCase() == 'true',
    );
  }

  static String _readEnv(String key, String fallback) {
    try {
      return dotenv.get(key, fallback: fallback);
    } catch (_) {
      return fallback;
    }
  }

  late String _baseUrl;
  late bool _useMock;

  String get baseUrl => _baseUrl;
  bool get useMock => _useMock;

  void setBaseUrl(String value) {
    if (value == _baseUrl) return;
    _baseUrl = value;
    notifyListeners();
  }

  void setUseMock(bool value) {
    if (value == _useMock) return;
    _useMock = value;
    notifyListeners();
  }
}
