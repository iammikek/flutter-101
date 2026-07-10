import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/category.dart';
import '../models/item.dart';
import '../models/item_stats.dart';
import '../models/paginated.dart';
import '../models/user.dart';

class ApiClient {
  ApiClient({
    required this.baseUrl,
    this.accessToken,
    http.Client? client,
  }) : _client = client ?? http.Client();

  String baseUrl;
  String? accessToken;
  final http.Client _client;

  Map<String, String> _headers({bool jsonBody = true, bool auth = false}) {
    final headers = <String, String>{
      'Accept': 'application/json',
      if (jsonBody) 'Content-Type': 'application/json',
    };
    if (auth && accessToken != null && accessToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    return headers;
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final normalizedBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$normalizedBase$normalizedPath');
    if (query == null || query.isEmpty) return uri;
    return uri.replace(
      queryParameters: query.map((k, v) => MapEntry(k, v == null ? '' : '$v')),
    );
  }

  Future<dynamic> getRoot() async {
    final res = await _client.get(_uri('/'), headers: _headers(jsonBody: false));
    _ensureOk(res);
    return jsonDecode(res.body);
  }

  Future<dynamic> getHealth() async {
    final res = await _client.get(_uri('/health'), headers: _headers(jsonBody: false));
    _ensureOk(res);
    return jsonDecode(res.body);
  }

  Future<User> register(String email, String password) async {
    final res = await _client.post(
      _uri('/auth/register'),
      headers: _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    _ensureOk(res);
    return User.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<AuthToken> login(String email, String password) async {
    final res = await _client.post(
      _uri('/auth/login'),
      headers: {'Accept': 'application/json', 'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': email, 'password': password},
    );
    _ensureOk(res);
    return AuthToken.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<User> getMe() async {
    final res = await _client.get(_uri('/auth/me'), headers: _headers(auth: true));
    _ensureOk(res);
    return User.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<Paginated<Category>> listCategories({int skip = 0, int limit = 50}) async {
    final res = await _client.get(
      _uri('/categories', {'skip': skip, 'limit': limit}),
      headers: _headers(jsonBody: false),
    );
    _ensureOk(res);
    return _parsePaginated(res.body, Category.fromJson);
  }

  Future<Category> getCategory(int id) async {
    final res = await _client.get(_uri('/categories/$id'), headers: _headers(jsonBody: false));
    _ensureOk(res);
    return Category.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<Category> createCategory(Category category) async {
    final res = await _client.post(
      _uri('/categories'),
      headers: _headers(auth: true),
      body: jsonEncode(category.toJson()),
    );
    _ensureOk(res);
    return Category.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<Category> updateCategory(int id, Category category) async {
    final res = await _client.patch(
      _uri('/categories/$id'),
      headers: _headers(auth: true),
      body: jsonEncode(category.toUpdateJson()),
    );
    _ensureOk(res);
    return Category.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> deleteCategory(int id) async {
    final res = await _client.delete(_uri('/categories/$id'), headers: _headers(auth: true));
    _ensureOk(res, allowEmpty: true);
  }

  Future<Paginated<Item>> listItems({
    int skip = 0,
    int limit = 20,
    int? categoryId,
    String? nameContains,
    double? minPrice,
    double? maxPrice,
  }) async {
    final query = <String, dynamic>{
      'skip': skip,
      'limit': limit,
      if (categoryId != null) 'category_id': categoryId,
      if (nameContains != null && nameContains.isNotEmpty) 'name_contains': nameContains,
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
    };
    final res = await _client.get(_uri('/items', query), headers: _headers(jsonBody: false));
    _ensureOk(res);
    return _parsePaginated(res.body, Item.fromJson);
  }

  Future<ItemStats> getItemStats() async {
    final res = await _client.get(_uri('/items/stats/summary'), headers: _headers(jsonBody: false));
    _ensureOk(res);
    return ItemStats.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<Item> getItem(int id) async {
    final res = await _client.get(_uri('/items/$id'), headers: _headers(jsonBody: false));
    _ensureOk(res);
    return Item.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<Item> createItem(Item item) async {
    final res = await _client.post(
      _uri('/items'),
      headers: _headers(auth: true),
      body: jsonEncode(item.toCreateJson()),
    );
    _ensureOk(res);
    return Item.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<Item> updateItem(int id, Item item) async {
    final res = await _client.patch(
      _uri('/items/$id'),
      headers: _headers(auth: true),
      body: jsonEncode(item.toUpdateJson()),
    );
    _ensureOk(res);
    return Item.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> deleteItem(int id) async {
    final res = await _client.delete(_uri('/items/$id'), headers: _headers(auth: true));
    _ensureOk(res, allowEmpty: true);
  }

  Paginated<T> _parsePaginated<T>(String body, T Function(Map<String, dynamic>) fromJson) {
    final decoded = jsonDecode(body);
    if (decoded is List) {
      final items = decoded.map((e) => fromJson(e as Map<String, dynamic>)).toList();
      return Paginated(items: items, total: items.length, skip: 0, limit: items.length);
    }
    final map = decoded as Map<String, dynamic>;
    final rawItems = map['items'];
    final items = rawItems is List
        ? rawItems.map((e) => fromJson(e as Map<String, dynamic>)).toList()
        : <T>[];
    return Paginated(
      items: items,
      total: map['total'] is num ? (map['total'] as num).toInt() : items.length,
      skip: map['skip'] is num ? (map['skip'] as num).toInt() : 0,
      limit: map['limit'] is num ? (map['limit'] as num).toInt() : items.length,
    );
  }

  void _ensureOk(http.Response res, {bool allowEmpty = false}) {
    if (res.statusCode == 204) return;
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    if (allowEmpty && res.statusCode == 204) return;
    throw ApiError(statusCode: res.statusCode, body: res.body);
  }
}

class ApiError implements Exception {
  ApiError({required this.statusCode, required this.body});
  final int statusCode;
  final String body;
  @override
  String toString() => 'ApiError(statusCode: $statusCode, body: $body)';
}
