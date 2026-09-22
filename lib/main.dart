import 'package:flutter/material.dart';
import 'views/main_nav.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hành Hương Số',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFA56A12),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MainNavigation(),
    );
  }
}