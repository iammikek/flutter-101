import 'package:flutter/foundation.dart';

import '../models/item.dart';
import 'items_repository.dart';

class ItemsStore extends ChangeNotifier {
  ItemsStore(this._repo);

  ItemsRepository _repo;

  void updateRepo(ItemsRepository repo) {
    if (identical(repo, _repo)) return;
    _repo = repo;
  }

  bool _loading = false;
  String? _error;
  List<Item> _items = const [];
  int _total = 0;
  int _skip = 0;
  final int _limit = 20;
  int? _categoryId;
  String _nameContains = '';

  bool get loading => _loading;
  String? get error => _error;
  List<Item> get items => _items;
  int get total => _total;
  int get skip => _skip;
  int get limit => _limit;
  int? get categoryId => _categoryId;
  String get nameContains => _nameContains;
  bool get hasMore => _skip + _items.length < _total;

  Future<void> refresh() async {
    _skip = 0;
    await _load(append: false);
  }

  Future<void> loadMore() async {
    if (!hasMore || _loading) return;
    _skip += _limit;
    await _load(append: true);
  }

  void setCategoryFilter(int? categoryId) {
    if (_categoryId == categoryId) return;
    _categoryId = categoryId;
    refresh();
  }

  void setNameFilter(String value) {
    _nameContains = value;
  }

  Future<void> applyNameFilter() => refresh();

  Future<Item?> getById(int id) async {
    try {
      return await _repo.get(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<Item?> create(Item item) async {
    return _mutate(() async {
      final created = await _repo.create(item);
      await refresh();
      return created;
    });
  }

  Future<Item?> update(int id, Item item) async {
    return _mutate(() async {
      final updated = await _repo.update(id, item);
      await refresh();
      return updated;
    });
  }

  Future<bool> delete(int id) async {
    final result = await _mutate(() async {
      await _repo.delete(id);
      await refresh();
      return true;
    });
    return result == true;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> _load({required bool append}) async {
    _setLoading(true);
    if (!append) _error = null;
    notifyListeners();
    try {
      final page = await _repo.list(
        skip: _skip,
        limit: _limit,
        categoryId: _categoryId,
        nameContains: _nameContains.isEmpty ? null : _nameContains,
      );
      _items = append ? [..._items, ...page.items] : page.items;
      _total = page.total;
    } catch (e) {
      _error = e.toString();
      if (!append) _items = const [];
    } finally {
      _setLoading(false);
    }
  }

  Future<T?> _mutate<T>(Future<T> Function() action) async {
    _setLoading(true);
    _error = null;
    notifyListeners();
    try {
      return await action();
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    if (_loading == value) return;
    _loading = value;
    notifyListeners();
  }
}
