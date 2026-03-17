import '../api/api_client.dart';
import '../api/mock_api_client.dart';
import '../models/item.dart';
import 'app_config.dart';

abstract class ApiService {
  String get baseUrl;
  String? get apiKey;

  Future<dynamic> getRoot();
  Future<dynamic> getHealth();

  Future<List<dynamic>> getItems({Map<String, dynamic>? query});
  Future<Item> getItem(int id);
  Future<Item> createItem(Item item);
  Future<Item> updateItem(int id, Item item);
  Future<bool> deleteItem(int id);
}

class ApiServiceFactory {
  static ApiService fromConfig(AppConfig config) {
    return config.useMock
        ? _MockApiService(config)
        : _RealApiService(config);
  }
}

class _RealApiService implements ApiService {
  _RealApiService(this._config)
      : _client = ApiClient(baseUrl: _config.baseUrl, apiKey: _config.apiKey);

  final AppConfig _config;
  final ApiClient _client;

  @override
  String get baseUrl => _config.baseUrl;

  @override
  String? get apiKey => _config.apiKey;

  @override
  Future<dynamic> getRoot() => _client.getRoot();

  @override
  Future<dynamic> getHealth() => _client.getHealth();

  @override
  Future<List<dynamic>> getItems({Map<String, dynamic>? query}) =>
      _client.getItems(query: query);

  @override
  Future<Item> getItem(int id) => _client.getItem(id);

  @override
  Future<Item> createItem(Item item) => _client.createItem(item);

  @override
  Future<Item> updateItem(int id, Item item) => _client.updateItem(id, item);

  @override
  Future<bool> deleteItem(int id) => _client.deleteItem(id);
}

class _MockApiService implements ApiService {
  _MockApiService(this._config) : _client = MockApiClient();

  final AppConfig _config;
  final MockApiClient _client;

  @override
  String get baseUrl => _config.baseUrl;

  @override
  String? get apiKey => _config.apiKey;

  @override
  Future<dynamic> getRoot() => _client.getRoot();

  @override
  Future<dynamic> getHealth() => _client.getHealth();

  @override
  Future<List<dynamic>> getItems({Map<String, dynamic>? query}) =>
      _client.getItems(query: query);

  @override
  Future<Item> getItem(int id) => _client.getItem(id);

  @override
  Future<Item> createItem(Item item) => _client.createItem(item);

  @override
  Future<Item> updateItem(int id, Item item) => _client.updateItem(id, item);

  @override
  Future<bool> deleteItem(int id) => _client.deleteItem(id);
}

