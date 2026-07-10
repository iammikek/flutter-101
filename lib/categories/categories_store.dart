import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../items/items_repository.dart';
import '../models/category.dart';

class CategoriesStore extends ChangeNotifier {
  CategoriesStore(this._repo);

  CategoriesRepository _repo;

  void updateRepo(CategoriesRepository repo) {
    if (identical(repo, _repo)) return;
    _repo = repo;
  }

  bool _loading = false;
  String? _error;
  List<Category> _categories = const [];

  bool get loading => _loading;
  String? get error => _error;
  List<Category> get categories => _categories;

  Future<void> refresh() async {
    _setLoading(true);
    _error = null;
    notifyListeners();
    try {
      final page = await _repo.list(limit: 100);
      _categories = page.items;
    } catch (e) {
      _error = e.toString();
      _categories = const [];
    } finally {
      _setLoading(false);
    }
  }

  Future<Category?> getById(int id) async {
    try {
      return await _repo.get(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<Category?> create(Category category) async {
    return _mutate(() async {
      final created = await _repo.create(category);
      await refresh();
      return created;
    });
  }

  Future<Category?> update(int id, Category category) async {
    return _mutate(() async {
      final updated = await _repo.update(id, category);
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
