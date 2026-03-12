import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const FastApiFlutterApp());
}

class FastApiFlutterApp extends StatelessWidget {
  const FastApiFlutterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FastAPI-101 Client',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
