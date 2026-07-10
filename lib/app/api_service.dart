import '../models/category.dart';
import '../models/item.dart';
import '../models/item_stats.dart';
import '../models/paginated.dart';
import '../models/user.dart';
import '../app/app_config.dart';
import '../auth/auth_store.dart';
import '../api/api_client.dart';
import '../api/mock_api_client.dart';

abstract class ApiService {
  String get baseUrl;
  String? get accessToken;
  void setAccessToken(String? token);

  Future<dynamic> getRoot();
  Future<dynamic> getHealth();

  Future<User> register(String email, String password);
  Future<AuthToken> login(String email, String password);
  Future<User> getMe();

  Future<Paginated<Category>> listCategories({int skip = 0, int limit = 50});
  Future<Category> getCategory(int id);
  Future<Category> createCategory(Category category);
  Future<Category> updateCategory(int id, Category category);
  Future<void> deleteCategory(int id);

  Future<Paginated<Item>> listItems({
    int skip = 0,
    int limit = 20,
    int? categoryId,
    String? nameContains,
    double? minPrice,
    double? maxPrice,
  });
  Future<ItemStats> getItemStats();
  Future<Item> getItem(int id);
  Future<Item> createItem(Item item);
  Future<Item> updateItem(int id, Item item);
  Future<void> deleteItem(int id);
}

class ApiServiceFactory {
  static ApiService fromConfig(AppConfig config, AuthStore auth) {
    final service = config.useMock ? _MockApiService(config) : _RealApiService(config);
    service.setAccessToken(auth.accessToken);
    return service;
  }
}

class _RealApiService implements ApiService {
  _RealApiService(this._config) : _client = ApiClient(baseUrl: _config.baseUrl);

  final AppConfig _config;
  final ApiClient _client;

  @override
  String get baseUrl => _config.baseUrl;

  @override
  String? get accessToken => _client.accessToken;

  @override
  void setAccessToken(String? token) {
    _client.accessToken = token;
  }

  @override
  Future<dynamic> getRoot() => _client.getRoot();

  @override
  Future<dynamic> getHealth() => _client.getHealth();

  @override
  Future<User> register(String email, String password) => _client.register(email, password);

  @override
  Future<AuthToken> login(String email, String password) => _client.login(email, password);

  @override
  Future<User> getMe() => _client.getMe();

  @override
  Future<Paginated<Category>> listCategories({int skip = 0, int limit = 50}) =>
      _client.listCategories(skip: skip, limit: limit);

  @override
  Future<Category> getCategory(int id) => _client.getCategory(id);

  @override
  Future<Category> createCategory(Category category) => _client.createCategory(category);

  @override
  Future<Category> updateCategory(int id, Category category) => _client.updateCategory(id, category);

  @override
  Future<void> deleteCategory(int id) => _client.deleteCategory(id);

  @override
  Future<Paginated<Item>> listItems({
    int skip = 0,
    int limit = 20,
    int? categoryId,
    String? nameContains,
    double? minPrice,
    double? maxPrice,
  }) =>
      _client.listItems(
        skip: skip,
        limit: limit,
        categoryId: categoryId,
        nameContains: nameContains,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );

  @override
  Future<ItemStats> getItemStats() => _client.getItemStats();

  @override
  Future<Item> getItem(int id) => _client.getItem(id);

  @override
  Future<Item> createItem(Item item) => _client.createItem(item);

  @override
  Future<Item> updateItem(int id, Item item) => _client.updateItem(id, item);

  @override
  Future<void> deleteItem(int id) => _client.deleteItem(id);
}

class _MockApiService implements ApiService {
  _MockApiService(this._config) : _client = MockApiClient();

  final AppConfig _config;
  final MockApiClient _client;

  @override
  String get baseUrl => _config.baseUrl;

  @override
  String? get accessToken => _client.accessToken;

  @override
  void setAccessToken(String? token) {
    _client.accessToken = token;
  }

  @override
  Future<dynamic> getRoot() => _client.getRoot();

  @override
  Future<dynamic> getHealth() => _client.getHealth();

  @override
  Future<User> register(String email, String password) => _client.register(email, password);

  @override
  Future<AuthToken> login(String email, String password) => _client.login(email, password);

  @override
  Future<User> getMe() => _client.getMe();

  @override
  Future<Paginated<Category>> listCategories({int skip = 0, int limit = 50}) =>
      _client.listCategories(skip: skip, limit: limit);

  @override
  Future<Category> getCategory(int id) => _client.getCategory(id);

  @override
  Future<Category> createCategory(Category category) => _client.createCategory(category);

  @override
  Future<Category> updateCategory(int id, Category category) => _client.updateCategory(id, category);

  @override
  Future<void> deleteCategory(int id) => _client.deleteCategory(id);

  @override
  Future<Paginated<Item>> listItems({
    int skip = 0,
    int limit = 20,
    int? categoryId,
    String? nameContains,
    double? minPrice,
    double? maxPrice,
  }) =>
      _client.listItems(
        skip: skip,
        limit: limit,
        categoryId: categoryId,
        nameContains: nameContains,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );

  @override
  Future<ItemStats> getItemStats() => _client.getItemStats();

  @override
  Future<Item> getItem(int id) => _client.getItem(id);

  @override
  Future<Item> createItem(Item item) => _client.createItem(item);

  @override
  Future<Item> updateItem(int id, Item item) => _client.updateItem(id, item);

  @override
  Future<void> deleteItem(int id) => _client.deleteItem(id);
}
