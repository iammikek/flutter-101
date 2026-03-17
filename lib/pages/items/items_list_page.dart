import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_config.dart';
import '../../items/items_store.dart';
import 'item_create_page.dart';
import 'item_detail_page.dart';
import '../settings/settings_sheet.dart';

class ItemsListPage extends StatefulWidget {
  const ItemsListPage({super.key});

  @override
  State<ItemsListPage> createState() => _ItemsListPageState();
}

class _ItemsListPageState extends State<ItemsListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemsStore>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = context.watch<AppConfig>();
    final store = context.watch<ItemsStore>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Items'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => const SettingsSheet(),
            ),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const ItemCreatePage()),
          );
          if (created == true && context.mounted) {
            await context.read<ItemsStore>().refresh();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: ListTile(
              dense: true,
              title: Text(
                config.useMock ? 'Mock mode' : 'Live API',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              subtitle: Text(
                config.baseUrl,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => const SettingsSheet(),
              ),
            ),
          ),
          if (store.error != null)
            MaterialBanner(
              content: Text(store.error!),
              actions: [
                TextButton(
                  onPressed: store.clearError,
                  child: const Text('Dismiss'),
                ),
              ],
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: store.refresh,
              child: Builder(
                builder: (context) {
                  if (store.loading && store.items.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!store.loading && store.items.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 96),
                        Center(child: Text('No items yet')),
                      ],
                    );
                  }

                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: store.items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final item = store.items[i];
                      final price = item.price.toStringAsFixed(2);
                      final avatarText = item.name.trim().isEmpty ? '?' : item.name.trim().substring(0, 1).toUpperCase();
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text(item.category?.isNotEmpty == true ? item.category! : 'Uncategorized'),
                        leading: CircleAvatar(child: Text(avatarText)),
                        trailing: Text('\$$price'),
                        onTap: item.id == null
                            ? null
                            : () => Navigator.of(context).push<void>(
                                  MaterialPageRoute(
                                    builder: (_) => ItemDetailPage(itemId: item.id!),
                                  ),
                                ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

