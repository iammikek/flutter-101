import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/api_service.dart';
import 'app/app_config.dart';
import 'items/items_repository.dart';
import 'items/items_store.dart';
import 'pages/items/items_list_page.dart';

void main() {
  runApp(const FastApiFlutterApp());
}

class FastApiFlutterApp extends StatelessWidget {
  const FastApiFlutterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppConfig()),
        ProxyProvider<AppConfig, ApiService>(
          update: (_, config, __) => ApiServiceFactory.fromConfig(config),
        ),
        ProxyProvider<ApiService, ItemsRepository>(
          update: (_, api, prev) => (prev ?? ItemsRepository(api))..updateApi(api),
        ),
        ChangeNotifierProxyProvider<ItemsRepository, ItemsStore>(
          create: (context) => ItemsStore(context.read<ItemsRepository>()),
          update: (_, repo, store) {
            if (store == null) return ItemsStore(repo);
            store.updateRepo(repo);
            return store;
          },
        ),
      ],
      child: MaterialApp(
        title: 'FastAPI-101 Client',
        theme: ThemeData(
          colorSchemeSeed: Colors.blue,
          useMaterial3: true,
        ),
        home: const ItemsListPage(),
      ),
    );
  }
}
