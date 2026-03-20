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
          if (item != null)
            IconButton(
              tooltip: 'Delete',
              onPressed: store.loading ? null : () => _confirmDelete(context),
              icon: const Icon(Icons.delete_outline),
              color: Theme.of(context).colorScheme.error,
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
                    if (store.error != null) ...[
                      const SizedBox(height: 12),
                      Text(store.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ],
                  ],
                ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete item?'),
        content: const Text('Are you sure? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('confirm_delete'),
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!context.mounted || confirmed != true) return;
    await context.read<ItemsStore>().delete(widget.itemId);
    if (context.mounted) Navigator.of(context).pop();
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
