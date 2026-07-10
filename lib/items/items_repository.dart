import '../app/api_service.dart';
import '../models/category.dart';
import '../models/item.dart';
import '../models/item_stats.dart';
import '../models/paginated.dart';

class ItemsRepository {
  ItemsRepository(this._api);

  ApiService _api;

  void updateApi(ApiService api) => _api = api;

  Future<Paginated<Item>> list({
    int skip = 0,
    int limit = 20,
    int? categoryId,
    String? nameContains,
    double? minPrice,
    double? maxPrice,
  }) =>
      _api.listItems(
        skip: skip,
        limit: limit,
        categoryId: categoryId,
        nameContains: nameContains,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );

  Future<ItemStats> stats() => _api.getItemStats();

  Future<Item> get(int id) => _api.getItem(id);

  Future<Item> create(Item item) => _api.createItem(item);

  Future<Item> update(int id, Item item) => _api.updateItem(id, item);

  Future<void> delete(int id) => _api.deleteItem(id);
}

class CategoriesRepository {
  CategoriesRepository(this._api);

  ApiService _api;

  void updateApi(ApiService api) => _api = api;

  Future<Paginated<Category>> list({int skip = 0, int limit = 50}) =>
      _api.listCategories(skip: skip, limit: limit);

  Future<Category> get(int id) => _api.getCategory(id);

  Future<Category> create(Category category) => _api.createCategory(category);

  Future<Category> update(int id, Category category) => _api.updateCategory(id, category);

  Future<void> delete(int id) => _api.deleteCategory(id);
}
