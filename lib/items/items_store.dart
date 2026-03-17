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

  bool get loading => _loading;
  String? get error => _error;
  List<Item> get items => _items;

  Future<void> refresh() async {
    _setLoading(true);
    _error = null;
    notifyListeners();
    try {
      _items = await _repo.list();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

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
    _setLoading(true);
    _error = null;
    notifyListeners();
    try {
      final created = await _repo.create(item);
      await refresh();
      return created;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> delete(int id) async {
    _setLoading(true);
    _error = null;
    notifyListeners();
    try {
      await _repo.delete(id);
      await refresh();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_loading == value) return;
    _loading = value;
    notifyListeners();
  }
}

