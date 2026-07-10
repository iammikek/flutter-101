import '../models/category.dart';
import '../models/item.dart';
import '../models/item_stats.dart';
import '../models/paginated.dart';
import '../models/user.dart';
import 'api_client.dart' show ApiError;

class MockApiClient {
  String baseUrl = 'http://localhost:8000';
  String? accessToken;

  final List<Category> _categories = [
    const Category(id: 1, name: 'Tools', description: 'Hand and power tools'),
    const Category(id: 2, name: 'Books', description: 'Paperbacks and hardcovers'),
  ];

  final List<Item> _items = [
    const Item(id: 1, name: 'Widget', description: 'A useful widget', price: 9.99, categoryId: 1, category: Category(id: 1, name: 'Tools')),
    const Item(id: 2, name: 'Gadget', description: 'Handy gadget', price: 19.5, categoryId: 1, category: Category(id: 1, name: 'Tools')),
    const Item(id: 3, name: 'Novel', description: 'A good read', price: 3.25, categoryId: 2, category: Category(id: 2, name: 'Books')),
  ];

  User? _currentUser;
  int _nextItemId = 4;
  int _nextCategoryId = 3;
  int _nextUserId = 1;

  Future<dynamic> getRoot() async {
    await _delay();
    return {'message': 'Hello from mock'};
  }

  Future<dynamic> getHealth() async {
    await _delay();
    return {'status': 'ok'};
  }

  Future<User> register(String email, String password) async {
    await _delay();
    _currentUser = User(id: _nextUserId++, email: email);
    accessToken = 'mock-token';
    return _currentUser!;
  }

  Future<AuthToken> login(String email, String password) async {
    await _delay();
    _currentUser = User(id: _nextUserId, email: email);
    accessToken = 'mock-token';
    return const AuthToken(accessToken: 'mock-token');
  }

  Future<User> getMe() async {
    await _delay();
    if (_currentUser == null) throw ApiError(statusCode: 401, body: 'Not authenticated');
    return _currentUser!;
  }

  Future<Paginated<Category>> listCategories({int skip = 0, int limit = 50}) async {
    await _delay();
    final slice = _slice(_categories, skip, limit);
    return Paginated(items: slice, total: _categories.length, skip: skip, limit: limit);
  }

  Future<Category> getCategory(int id) async {
    await _delay();
    return _categories.firstWhere((c) => c.id == id);
  }

  Future<Category> createCategory(Category category) async {
    await _delay();
    final created = Category(id: _nextCategoryId++, name: category.name, description: category.description);
    _categories.add(created);
    return created;
  }

  Future<Category> updateCategory(int id, Category category) async {
    await _delay();
    final index = _categories.indexWhere((c) => c.id == id);
    final updated = Category(id: id, name: category.name, description: category.description);
    _categories[index] = updated;
    return updated;
  }

  Future<void> deleteCategory(int id) async {
    await _delay();
    _categories.removeWhere((c) => c.id == id);
    for (var i = 0; i < _items.length; i++) {
      if (_items[i].categoryId == id) {
        _items[i] = Item(
          id: _items[i].id,
          name: _items[i].name,
          description: _items[i].description,
          price: _items[i].price,
          categoryId: null,
        );
      }
    }
  }

  Future<Paginated<Item>> listItems({
    int skip = 0,
    int limit = 20,
    int? categoryId,
    String? nameContains,
    double? minPrice,
    double? maxPrice,
  }) async {
    await _delay();
    var filtered = List<Item>.from(_items);
    if (categoryId != null) filtered = filtered.where((i) => i.categoryId == categoryId).toList();
    if (nameContains != null && nameContains.isNotEmpty) {
      final needle = nameContains.toLowerCase();
      filtered = filtered.where((i) => i.name.toLowerCase().contains(needle)).toList();
    }
    if (minPrice != null) filtered = filtered.where((i) => i.price >= minPrice).toList();
    if (maxPrice != null) filtered = filtered.where((i) => i.price <= maxPrice).toList();
    final slice = _slice(filtered, skip, limit);
    return Paginated(items: slice, total: filtered.length, skip: skip, limit: limit);
  }

  Future<ItemStats> getItemStats() async {
    await _delay();
    final total = _items.length;
    if (total == 0) {
      return const ItemStats(
        totalItems: 0,
        averagePrice: 0,
        minPrice: null,
        maxPrice: null,
        uncategorizedCount: 0,
        byCategory: [],
      );
    }
    final prices = _items.map((i) => i.price).toList();
    final uncategorized = _items.where((i) => i.categoryId == null).length;
    final byCategory = <CategoryItemStats>[];
    for (final category in _categories) {
      final inCategory = _items.where((i) => i.categoryId == category.id).toList();
      if (inCategory.isEmpty) continue;
      final avg = inCategory.map((i) => i.price).reduce((a, b) => a + b) / inCategory.length;
      byCategory.add(CategoryItemStats(
        categoryId: category.id,
        categoryName: category.name,
        itemCount: inCategory.length,
        averagePrice: avg,
      ));
    }
    return ItemStats(
      totalItems: total,
      averagePrice: prices.reduce((a, b) => a + b) / total,
      minPrice: prices.reduce((a, b) => a < b ? a : b),
      maxPrice: prices.reduce((a, b) => a > b ? a : b),
      uncategorizedCount: uncategorized,
      byCategory: byCategory,
    );
  }

  Future<Item> getItem(int id) async {
    await _delay();
    return _items.firstWhere((i) => i.id == id);
  }

  Future<Item> createItem(Item item) async {
    await _delay();
    final category = _findCategory(item.categoryId);
    final created = Item(
      id: _nextItemId++,
      name: item.name,
      description: item.description,
      price: item.price,
      categoryId: item.categoryId,
      category: category,
    );
    _items.add(created);
    return created;
  }

  Future<Item> updateItem(int id, Item item) async {
    await _delay();
    final index = _items.indexWhere((i) => i.id == id);
    final category = _findCategory(item.categoryId);
    final updated = Item(
      id: id,
      name: item.name,
      description: item.description,
      price: item.price,
      categoryId: item.categoryId,
      category: category,
    );
    _items[index] = updated;
    return updated;
  }

  Future<void> deleteItem(int id) async {
    await _delay();
    _items.removeWhere((i) => i.id == id);
  }

  List<T> _slice<T>(List<T> list, int skip, int limit) {
    if (skip >= list.length) return [];
    final end = (skip + limit).clamp(0, list.length);
    return list.sublist(skip, end);
  }

  Category? _findCategory(int? id) {
    if (id == null) return null;
    for (final category in _categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  Future<void> _delay() => Future<void>.delayed(const Duration(milliseconds: 120));
}
