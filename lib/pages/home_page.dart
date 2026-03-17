import 'package:flutter/material.dart';
import 'dart:convert';
import '../api/api_client.dart';
import '../api/mock_api_client.dart';
import '../models/item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _baseUrlCtrl = TextEditingController(text: 'http://localhost:8000');
  final _apiKeyCtrl = TextEditingController(text: 'dev-key-123');
  late dynamic _api;

  String _status = '';
  String _output = '';
  bool _loading = false;
  bool _useMock = true;

  @override
  void initState() {
    super.initState();
    _api = _useMock
        ? MockApiClient()
        : ApiClient(baseUrl: _baseUrlCtrl.text, apiKey: _apiKeyCtrl.text);
    _baseUrlCtrl.addListener(_syncConfig);
    _apiKeyCtrl.addListener(_syncConfig);
    _syncConfig();
  }

  @override
  void dispose() {
    _baseUrlCtrl.dispose();
    _apiKeyCtrl.dispose();
    super.dispose();
  }

  void _syncConfig() {
    _api.baseUrl = _baseUrlCtrl.text;
    _api.apiKey = _apiKeyCtrl.text;
  }

  Future<void> _call(Future<dynamic> Function() fn, String label) async {
    setState(() {
      _loading = true;
      _status = 'Calling $label...';
      _output = '';
    });
    try {
      final result = await fn();
      setState(() {
        _status = 'Success: $label';
        _output = _prettyJson(result);
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  String _prettyJson(dynamic data) {
    try {
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return '$data';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FastAPI-101 Client')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              value: _useMock,
              onChanged: (v) {
                setState(() {
                  _useMock = v;
                  _api = v
                      ? MockApiClient()
                      : ApiClient(baseUrl: _baseUrlCtrl.text, apiKey: _apiKeyCtrl.text);
                  _syncConfig();
                });
              },
              title: const Text('Use mock data'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _baseUrlCtrl,
                    decoration: const InputDecoration(labelText: 'Base URL', hintText: 'http://localhost:8000'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _apiKeyCtrl,
                    decoration: const InputDecoration(labelText: 'API Key (x-api-key)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _loading ? null : () => _call(_api.getRoot, 'GET /'),
                  child: const Text('Get Root'),
                ),
                ElevatedButton(
                  onPressed: _loading ? null : () => _call(_api.getHealth, 'GET /health'),
                  child: const Text('Check Health'),
                ),
                ElevatedButton(
                  onPressed: _loading ? null : () => _call(() => _api.getItems(), 'GET /items'),
                  child: const Text('List Items'),
                ),
                ElevatedButton(
                  onPressed: _loading
                      ? null
                      : () {
                          const name = 'New Item';
                          const price = 1.0;
                          _call(
                            () => _api.createItem(Item(name: name, price: price)),
                            'POST /items',
                          );
                        },
                  child: const Text('Create Item'),
                ),
                ElevatedButton(
                  onPressed: _loading
                      ? null
                      : () {
                          _call(() => _api.deleteItem(1), 'DELETE /items/1');
                        },
                  child: const Text('Delete Item 1'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(_status, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  child: Text(_output.isEmpty ? 'No output yet' : _output),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
