import 'package:flutter/foundation.dart';

import '../app/api_service.dart';
import '../models/user.dart';

class AuthStore extends ChangeNotifier {
  AuthStore();

  ApiService? _api;
  User? _user;
  String? _accessToken;
  bool _loading = false;
  String? _error;

  User? get user => _user;
  String? get accessToken => _accessToken;
  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;
  bool get loading => _loading;
  String? get error => _error;

  void updateApi(ApiService api) {
    _api = api;
    api.setAccessToken(_accessToken);
  }

  Future<bool> login(String email, String password) async {
    final api = _api;
    if (api == null) return false;
    return _runAuth(() async {
      final token = await api.login(email, password);
      _accessToken = token.accessToken;
      api.setAccessToken(_accessToken);
      _user = await api.getMe();
    });
  }

  Future<bool> register(String email, String password) async {
    final api = _api;
    if (api == null) return false;
    return _runAuth(() async {
      _user = await api.register(email, password);
      final token = await api.login(email, password);
      _accessToken = token.accessToken;
      api.setAccessToken(_accessToken);
    });
  }

  void logout() {
    _user = null;
    _accessToken = null;
    _api?.setAccessToken(null);
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> _runAuth(Future<void> Function() action) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
