import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../items/items_store.dart';
import '../../models/item.dart';

class ItemDetailPage extends StatefulWidget {
  const ItemDetailPage({super.key, required this.itemId});

  final int itemId;

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  Item? _item;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final item = await context.read<ItemsStore>().getById(widget.itemId);
    if (!mounted) return;
    setState(() {
      _item = item;
      _loading = false;
      _error = item == null ? 'Failed to load item' : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ItemsStore>();
    final item = _item;

    return Scaffold(
      appBar: AppBar(
        title: Text(item?.name ?? 'Item ${widget.itemId}'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : item == null
              ? Center(child: Text(_error ?? store.error ?? 'Unknown error'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(item.name, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text('\$${item.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    _kv(context, 'Category', item.category?.isNotEmpty == true ? item.category! : '—'),
                    const SizedBox(height: 8),
                    _kv(context, 'Description', item.description?.isNotEmpty == true ? item.description! : '—'),
                    const SizedBox(height: 24),
                    FilledButton.tonalIcon(
                      onPressed: store.loading
                          ? null
                          : () async {
                              await context.read<ItemsStore>().delete(widget.itemId);
                              if (context.mounted) Navigator.of(context).pop();
                            },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete (requires API key)'),
                    ),
                    if (store.error != null) ...[
                      const SizedBox(height: 12),
                      Text(store.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ],
                  ],
                ),
    );
  }

  Widget _kv(BuildContext context, String k, String v) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96,
          child: Text(k, style: Theme.of(context).textTheme.labelLarge),
        ),
        Expanded(child: Text(v)),
      ],
    );
  }
}

