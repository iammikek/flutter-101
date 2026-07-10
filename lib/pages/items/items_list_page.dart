import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_config.dart';
import '../../auth/auth_store.dart';
import '../../categories/categories_store.dart';
import '../../items/items_store.dart';
import '../../models/category.dart';
import '../auth/login_page.dart';
import 'item_detail_page.dart';
import 'item_form_page.dart';

class ItemsListPage extends StatefulWidget {
  const ItemsListPage({super.key});

  @override
  State<ItemsListPage> createState() => _ItemsListPageState();
}

class _ItemsListPageState extends State<ItemsListPage> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoriesStore>().refresh();
      context.read<ItemsStore>().refresh();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = context.watch<AppConfig>();
    final auth = context.watch<AuthStore>();
    final canWrite = auth.isAuthenticated || config.useMock;
    final categories = context.watch<CategoriesStore>();
    final store = context.watch<ItemsStore>();

    return Column(
      children: [
        Material(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: ListTile(
            dense: true,
            title: Text(config.useMock ? 'Mock mode' : 'Live API', style: Theme.of(context).textTheme.titleSmall),
            subtitle: Text(config.baseUrl, style: Theme.of(context).textTheme.bodySmall),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Search name',
                    isDense: true,
                  ),
                  onSubmitted: (value) {
                    store.setNameFilter(value.trim());
                    store.applyNameFilter();
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Search',
                onPressed: () {
                  store.setNameFilter(_searchCtrl.text.trim());
                  store.applyNameFilter();
                },
                icon: const Icon(Icons.search),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonFormField<int?>(
            value: store.categoryId,
            decoration: const InputDecoration(labelText: 'Category filter', isDense: true),
            items: [
              const DropdownMenuItem<int?>(value: null, child: Text('All categories')),
              ...categories.categories.map(
                (Category c) => DropdownMenuItem<int?>(value: c.id, child: Text(c.name)),
              ),
            ],
            onChanged: store.loading ? null : store.setCategoryFilter,
          ),
        ),
        if (!canWrite)
          MaterialBanner(
            content: const Text('Sign in to create, edit, or delete items.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).push<void>(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                ),
                child: const Text('Sign in'),
              ),
            ],
          ),
        if (store.error != null)
          MaterialBanner(
            content: Text(store.error!),
            actions: [
              TextButton(onPressed: store.clearError, child: const Text('Dismiss')),
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
                  itemCount: store.items.length + (store.hasMore ? 1 : 0),
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    if (i == store.items.length) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: OutlinedButton(
                            onPressed: store.loading ? null : store.loadMore,
                            child: Text(store.loading ? 'Loading…' : 'Load more (${store.items.length}/${store.total})'),
                          ),
                        ),
                      );
                    }
                    final item = store.items[i];
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text(item.categoryLabel),
                      trailing: Text('\$${item.price.toStringAsFixed(2)}'),
                      onTap: item.id == null
                          ? null
                          : () => Navigator.of(context).push<void>(
                                MaterialPageRoute(builder: (_) => ItemDetailPage(itemId: item.id!)),
                              ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
