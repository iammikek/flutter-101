import 'package:flutter_test/flutter_test.dart';

import 'package:fastapi_flutter/app/api_service.dart';
import 'package:fastapi_flutter/items/items_repository.dart';
import 'package:fastapi_flutter/items/items_store.dart';
import 'package:fastapi_flutter/models/category.dart';
import 'package:fastapi_flutter/models/item.dart';
import 'package:fastapi_flutter/models/item_stats.dart';
import 'package:fastapi_flutter/models/paginated.dart';
import 'package:fastapi_flutter/models/user.dart';

class FakeApiService implements ApiService {
  FakeApiService({required this.items});

  List<Map<String, dynamic>> items;
  String? _token;

  @override
  String get baseUrl => 'http://fake';

  @override
  String? get accessToken => _token;

  @override
  void setAccessToken(String? token) => _token = token;

  @override
  Future<dynamic> getHealth() async => {'status': 'ok'};

  @override
  Future<dynamic> getRoot() async => {'message': 'hi'};

  @override
  Future<User> register(String email, String password) async => User(id: 1, email: email);

  @override
  Future<AuthToken> login(String email, String password) async => const AuthToken(accessToken: 't');

  @override
  Future<User> getMe() async => const User(id: 1, email: 'a@b.com');

  @override
  Future<Paginated<Category>> listCategories({int skip = 0, int limit = 50}) async =>
      const Paginated(items: [], total: 0, skip: 0, limit: 50);

  @override
  Future<Category> getCategory(int id) async => Category(id: id, name: 'Cat');

  @override
  Future<Category> createCategory(Category category) async => category;

  @override
  Future<Category> updateCategory(int id, Category category) async => category;

  @override
  Future<void> deleteCategory(int id) async {}

  @override
  Future<Paginated<Item>> listItems({
    int skip = 0,
    int limit = 20,
    int? categoryId,
    String? nameContains,
    double? minPrice,
    double? maxPrice,
  }) async {
    final parsed = items.map(Item.fromJson).toList();
    return Paginated(items: parsed, total: parsed.length, skip: skip, limit: limit);
  }

  @override
  Future<ItemStats> getItemStats() async => const ItemStats(
        totalItems: 0,
        averagePrice: 0,
        minPrice: null,
        maxPrice: null,
        uncategorizedCount: 0,
        byCategory: [],
      );

  @override
  Future<Item> getItem(int id) async => Item.fromJson(items.firstWhere((e) => e['id'] == id));

  @override
  Future<Item> createItem(Item item) async => item;

  @override
  Future<Item> updateItem(int id, Item item) async => item;

  @override
  Future<void> deleteItem(int id) async {}
}

void main() {
  test('ItemsStore.refresh populates items and clears error', () async {
    final api = FakeApiService(items: [
      {'id': 1, 'name': 'A', 'price': 1.0},
      {'id': 2, 'name': 'B', 'price': 2.0},
    ]);
    final repo = ItemsRepository(api);
    final store = ItemsStore(repo);

    await store.refresh();

    expect(store.error, isNull);
    expect(store.items.length, 2);
    expect(store.items.first.name, 'A');
  });
}
