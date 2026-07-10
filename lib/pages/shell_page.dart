import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_store.dart';
import 'categories/category_form_page.dart';
import 'items/item_form_page.dart';
import 'auth/login_page.dart';
import 'categories/categories_list_page.dart';
import 'items/items_list_page.dart';
import 'settings/settings_sheet.dart';
import 'stats/stats_page.dart';

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStore>();
    final pages = const [
      ItemsListPage(),
      CategoriesListPage(),
      StatsPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(switch (_index) {
          0 => 'Items',
          1 => 'Categories',
          _ => 'Stats',
        }),
        actions: [
          IconButton(
            tooltip: auth.isAuthenticated ? 'Account' : 'Sign in',
            onPressed: () {
              if (auth.isAuthenticated) {
                showDialog<void>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Signed in'),
                    content: Text(auth.user?.email ?? 'Authenticated'),
                    actions: [
                      TextButton(onPressed: auth.logout, child: const Text('Sign out')),
                      TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
                    ],
                  ),
                );
              } else {
                Navigator.of(context).push<void>(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              }
            },
            icon: Icon(auth.isAuthenticated ? Icons.person : Icons.login),
          ),
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
      body: IndexedStack(index: _index, children: pages),
      floatingActionButton: _index == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => ItemCreatePage()),
              ),
              child: const Icon(Icons.add),
            )
          : _index == 1
              ? FloatingActionButton(
                  onPressed: () => Navigator.of(context).push<bool>(
                    MaterialPageRoute(builder: (_) => CategoryCreatePage()),
                  ),
                  child: const Icon(Icons.add),
                )
              : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: 'Items'),
          NavigationDestination(icon: Icon(Icons.category_outlined), label: 'Categories'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), label: 'Stats'),
        ],
      ),
    );
  }
}
