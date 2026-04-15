import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/ideas_provider.dart';
import 'screens/ideas_screen.dart';

void main() {
  runApp(const IdeasApp());
}

class IdeasApp extends StatelessWidget {
  const IdeasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => IdeasProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Ideas App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            centerTitle: true,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          useMaterial3: true,
        ),
        home: const IdeasScreen(),
      ),
    );
  }
}
