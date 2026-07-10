import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'app/api_service.dart';
import 'app/app_config.dart';
import 'auth/auth_store.dart';
import 'categories/categories_store.dart';
import 'items/items_repository.dart';
import 'items/items_store.dart';
import 'pages/shell_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const FastApiFlutterApp());
}

class FastApiFlutterApp extends StatelessWidget {
  const FastApiFlutterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppConfig.fromEnv()),
        ChangeNotifierProvider(create: (_) => AuthStore()),
        ProxyProvider2<AppConfig, AuthStore, ApiService>(
          update: (_, config, auth, __) {
            final api = ApiServiceFactory.fromConfig(config, auth);
            auth.updateApi(api);
            return api;
          },
        ),
        ProxyProvider<ApiService, ItemsRepository>(
          update: (_, api, prev) => (prev ?? ItemsRepository(api))..updateApi(api),
        ),
        ProxyProvider<ApiService, CategoriesRepository>(
          update: (_, api, prev) => (prev ?? CategoriesRepository(api))..updateApi(api),
        ),
        ChangeNotifierProxyProvider<ItemsRepository, ItemsStore>(
          create: (context) => ItemsStore(context.read<ItemsRepository>()),
          update: (_, repo, store) {
            if (store == null) return ItemsStore(repo);
            store.updateRepo(repo);
            return store;
          },
        ),
        ChangeNotifierProxyProvider<CategoriesRepository, CategoriesStore>(
          create: (context) => CategoriesStore(context.read<CategoriesRepository>()),
          update: (_, repo, store) {
            if (store == null) return CategoriesStore(repo);
            store.updateRepo(repo);
            return store;
          },
        ),
      ],
      child: MaterialApp(
        title: '*-101 Flutter Client',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF007AFF)),
        ),
        home: const ShellPage(),
      ),
    );
  }
}
