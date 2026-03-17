import '../app/api_service.dart';
import '../models/item.dart';

class ItemsRepository {
  ItemsRepository(this._api);

  ApiService _api;

  void updateApi(ApiService api) {
    _api = api;
  }

  Future<List<Item>> list({int skip = 0, int limit = 50}) async {
    final data = await _api.getItems(query: {'skip': skip, 'limit': limit});
    return data
        .map((e) => Item.fromJson(e is Map<String, dynamic> ? e : <String, dynamic>{}))
        .toList();
  }

  Future<Item> get(int id) => _api.getItem(id);

  Future<Item> create(Item item) => _api.createItem(item);

  Future<Item> update(int id, Item item) => _api.updateItem(id, item);

  Future<void> delete(int id) async {
    await _api.deleteItem(id);
  }
}

