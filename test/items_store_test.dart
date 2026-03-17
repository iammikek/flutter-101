import 'package:flutter_test/flutter_test.dart';

import 'package:fastapi_flutter/app/api_service.dart';
import 'package:fastapi_flutter/items/items_repository.dart';
import 'package:fastapi_flutter/items/items_store.dart';
import 'package:fastapi_flutter/models/item.dart';

class FakeApiService implements ApiService {
  FakeApiService({required this.items});

  List<Map<String, dynamic>> items;

  @override
  String get baseUrl => 'http://fake';

  @override
  String? get apiKey => 'fake';

  @override
  Future<dynamic> getHealth() async => {'status': 'ok'};

  @override
  Future<dynamic> getRoot() async => {'message': 'hi'};

  @override
  Future<List<dynamic>> getItems({Map<String, dynamic>? query}) async => items;

  @override
  Future<Item> getItem(int id) async =>
      Item.fromJson(items.firstWhere((e) => e['id'] == id));

  @override
  Future<Item> createItem(Item item) async => item;

  @override
  Future<Item> updateItem(int id, Item item) async => item;

  @override
  Future<bool> deleteItem(int id) async => true;
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

