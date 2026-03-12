import 'dart:convert';

import 'package:http/http.dart' as http;
import '../models/item.dart';

class ApiClient {
  ApiClient({
    required this.baseUrl,
    this.apiKey,
    http.Client? client,
  }) : _client = client ?? http.Client();

  String baseUrl;
  String? apiKey;
  final http.Client _client;

  Map<String, String> _headers({bool includeApiKey = false}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (includeApiKey && apiKey != null && apiKey!.isNotEmpty) {
      headers['x-api-key'] = apiKey!;
    }
    return headers;
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final normalizedBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath').replace(queryParameters: query?.map((k, v) => MapEntry(k, '$v')));
  }

  Future<dynamic> getRoot() async {
    final res = await _client.get(_uri('/'), headers: _headers());
    _ensureOk(res);
    return jsonDecode(res.body);
  }

  Future<dynamic> getHealth() async {
    final res = await _client.get(_uri('/health'), headers: _headers());
    _ensureOk(res);
    return jsonDecode(res.body);
  }

  Future<List<dynamic>> getItems({Map<String, dynamic>? query}) async {
    final res = await _client.get(_uri('/items', query), headers: _headers(includeApiKey: true));
    _ensureOk(res);
    final body = jsonDecode(res.body);
    if (body is List) {
      return body;
    }
    // if API returns an object with a list field, try common keys
    final candidates = ['items', 'data', 'results'];
    for (final key in candidates) {
      final value = (body is Map) ? body[key] : null;
      if (value is List) return value;
    }
    return [body];
  }

  Future<List<Item>> getItemsTyped({Map<String, dynamic>? query}) async {
    final list = await getItems(query: query);
    return list.map((e) => Item.fromJson(e is Map<String, dynamic> ? e : <String, dynamic>{})).toList();
  }

  Future<Item> getItem(int id) async {
    final res = await _client.get(_uri('/items/$id'), headers: _headers(includeApiKey: true));
    _ensureOk(res);
    final body = jsonDecode(res.body);
    return Item.fromJson(body is Map<String, dynamic> ? body : <String, dynamic>{});
  }

  Future<Item> createItem(Item item) async {
    final res = await _client.post(
      _uri('/items'),
      headers: _headers(includeApiKey: true),
      body: jsonEncode(item.toJson()..removeWhere((k, v) => k == 'id')),
    );
    _ensureOk(res);
    final body = jsonDecode(res.body);
    return Item.fromJson(body is Map<String, dynamic> ? body : <String, dynamic>{});
  }

  Future<Item> updateItem(int id, Item item) async {
    final res = await _client.put(
      _uri('/items/$id'),
      headers: _headers(includeApiKey: true),
      body: jsonEncode(item.toJson()),
    );
    _ensureOk(res);
    final body = jsonDecode(res.body);
    return Item.fromJson(body is Map<String, dynamic> ? body : <String, dynamic>{});
  }

  Future<bool> deleteItem(int id) async {
    final res = await _client.delete(_uri('/items/$id'), headers: _headers(includeApiKey: true));
    _ensureOk(res);
    return true;
  }

  void _ensureOk(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiError(statusCode: res.statusCode, body: res.body);
    }
  }
}

class ApiError implements Exception {
  ApiError({required this.statusCode, required this.body});
  final int statusCode;
  final String body;
  @override
  String toString() => 'ApiError(statusCode: $statusCode, body: $body)';
}
