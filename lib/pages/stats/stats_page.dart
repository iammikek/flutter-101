import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/api_service.dart';
import '../../models/item_stats.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  ItemStats? _stats;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final stats = await context.read<ApiService>().getItemStats();
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 12),
            FilledButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    final stats = _stats!;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _metricCard(context, 'Total items', '${stats.totalItems}'),
          _metricCard(context, 'Average price', '\$${stats.averagePrice.toStringAsFixed(2)}'),
          _metricCard(context, 'Min price', stats.minPrice == null ? '—' : '\$${stats.minPrice!.toStringAsFixed(2)}'),
          _metricCard(context, 'Max price', stats.maxPrice == null ? '—' : '\$${stats.maxPrice!.toStringAsFixed(2)}'),
          _metricCard(context, 'Uncategorized', '${stats.uncategorizedCount}'),
          const SizedBox(height: 16),
          Text('By category', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (stats.byCategory.isEmpty)
            const Text('No categorized items yet')
          else
            ...stats.byCategory.map(
              (row) => Card(
                child: ListTile(
                  title: Text(row.categoryName),
                  subtitle: Text('${row.itemCount} items'),
                  trailing: Text('\$${row.averagePrice.toStringAsFixed(2)} avg'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _metricCard(BuildContext context, String label, String value) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Text(value, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}
