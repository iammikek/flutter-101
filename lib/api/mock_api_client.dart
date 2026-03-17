import '../models/item.dart';

class MockApiClient {
  String baseUrl = 'http://localhost:8000';
  String? apiKey = 'dev-key-123';

  Future<dynamic> getRoot() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return {'message': 'Hello from mock'};
  }

  Future<dynamic> getHealth() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return {'status': 'ok'};
  }

  Future<List<dynamic>> getItems({Map<String, dynamic>? query}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return [
      {'id': 1, 'name': 'Widget', 'price': 9.99},
      {'id': 2, 'name': 'Gadget', 'price': 19.5},
      {'id': 3, 'name': 'Thingamajig', 'price': 3.25},
    ];
  }

  Future<List<Item>> getItemsTyped({Map<String, dynamic>? query}) async {
    final list = await getItems(query: query);
    return list.map((e) => Item.fromJson(e is Map<String, dynamic> ? e : <String, dynamic>{})).toList();
  }

  Future<Item> getItem(int id) async {
    final items = await getItemsTyped();
    final found = items.where((e) => e.id == id).toList();
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return found.isNotEmpty ? found.first : Item(id: id, name: 'Unknown', price: 0.0);
  }

  Future<Item> createItem(Item item) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return Item(id: 999, name: item.name, price: item.price);
  }

  Future<Item> updateItem(int id, Item item) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return Item(id: id, name: item.name, price: item.price);
  }

  Future<bool> deleteItem(int id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return true;
  }
}
