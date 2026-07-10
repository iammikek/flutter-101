import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_config.dart';
import '../../auth/auth_store.dart';
import '../../categories/categories_store.dart';
import '../../models/category.dart';
import 'category_form_page.dart';

class CategoriesListPage extends StatefulWidget {
  const CategoriesListPage({super.key});

  @override
  State<CategoriesListPage> createState() => _CategoriesListPageState();
}

class _CategoriesListPageState extends State<CategoriesListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<CategoriesStore>().refresh());
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<CategoriesStore>();
    final config = context.watch<AppConfig>();
    final auth = context.watch<AuthStore>();
    final canWrite = auth.isAuthenticated || config.useMock;

    return Column(
      children: [
        if (!canWrite)
          MaterialBanner(
            content: const Text('Sign in to create, edit, or delete categories.'),
            actions: const [SizedBox.shrink()],
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
            child: store.loading && store.categories.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: store.categories.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final category = store.categories[i];
                      return ListTile(
                        title: Text(category.name),
                        subtitle: Text(category.description ?? 'No description'),
                        onTap: () => Navigator.of(context).push<void>(
                          MaterialPageRoute(builder: (_) => CategoryDetailPage(categoryId: category.id)),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class CategoryDetailPage extends StatefulWidget {
  const CategoryDetailPage({super.key, required this.categoryId});

  final int categoryId;

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  Category? _category;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final category = await context.read<CategoriesStore>().getById(widget.categoryId);
    if (!mounted) return;
    setState(() {
      _category = category;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<CategoriesStore>();
    final config = context.watch<AppConfig>();
    final auth = context.watch<AuthStore>();
    final canWrite = auth.isAuthenticated || config.useMock;
    final category = _category;

    return Scaffold(
      appBar: AppBar(
        title: Text(category?.name ?? 'Category'),
        actions: [
          if (category != null && canWrite)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                final updated = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => CategoryEditPage(category: category)),
                );
                if (updated == true && mounted) await _load();
              },
            ),
          if (category != null && canWrite)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Theme.of(context).colorScheme.error,
              onPressed: store.loading
                  ? null
                  : () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete category?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                            FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
                          ],
                        ),
                      );
                      if (ok == true && context.mounted) {
                        final deleted = await store.delete(widget.categoryId);
                        if (context.mounted && deleted) Navigator.of(context).pop();
                      }
                    },
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : category == null
              ? const Center(child: Text('Category not found'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(category.name, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 12),
                    Text(category.description ?? 'No description'),
                  ],
                ),
    );
  }
}
