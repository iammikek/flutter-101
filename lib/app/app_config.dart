import 'package:flutter/foundation.dart';

class AppConfig extends ChangeNotifier {
  AppConfig({
    String baseUrl = 'http://localhost:8000',
    String apiKey = 'dev-key-123',
    bool useMock = true,
  })  : _baseUrl = baseUrl,
        _apiKey = apiKey,
        _useMock = useMock;

  String _baseUrl;
  String _apiKey;
  bool _useMock;

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

