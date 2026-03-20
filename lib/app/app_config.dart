import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig extends ChangeNotifier {
  AppConfig() {
    _baseUrl = dotenv.get('BASE_URL', fallback: 'http://localhost:8000');
    _apiKey = dotenv.get('API_KEY', fallback: 'dev-key-123');
    _useMock = dotenv.get('USE_MOCK', fallback: 'true').toLowerCase() == 'true';
  }

  late String _baseUrl;
  late String _apiKey;
  late bool _useMock;

  String get baseUrl => _baseUrl;
  String get apiKey => _apiKey;
  bool get useMock => _useMock;

  void setBaseUrl(String value) {
    if (value == _baseUrl) return;
    _baseUrl = value;
    notifyListeners();
  }

  void setApiKey(String value) {
    if (value == _apiKey) return;
    _apiKey = value;
    notifyListeners();
  }

  void setUseMock(bool value) {
    if (value == _useMock) return;
    _useMock = value;
    notifyListeners();
  }
}
