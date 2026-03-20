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
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF007AFF), // iOS Blue
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF2F2F7), // iOS System Background
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            backgroundColor: Color(0xFFF2F2F7),
            elevation: 0,
            scrolledUnderElevation: 0,
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.41,
            ),
            iconTheme: IconThemeData(color: Color(0xFF007AFF)),
          ),
          listTileTheme: const ListTileThemeData(
            tileColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 17,
              letterSpacing: -0.41,
            ),
            subtitleTextStyle: TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 15,
              letterSpacing: -0.24,
            ),
          ),
          dividerTheme: const DividerThemeData(
            thickness: 0.5,
            indent: 16,
            color: Color(0xFFC6C6C8),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFC6C6C8), width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFC6C6C8), width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF007AFF), width: 1.0),
            ),
            hintStyle: const TextStyle(color: Color(0xFF8E8E93)),
            labelStyle: const TextStyle(color: Color(0xFF8E8E93)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007AFF),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.41,
              ),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF007AFF),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.41,
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF007AFF),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              textStyle: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.41,
              ),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF007AFF),
            foregroundColor: Colors.white,
            elevation: 2,
            shape: CircleBorder(), // FABs are often circles in modern iOS/Material hybrids
          ),
          cardTheme: const CardThemeData(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        home: const ItemsListPage(),
      ),
    );
  }
}
