import 'package:first_project/screens/collections/collection_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyAppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Todo List',
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFF0A0F1F), 
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF3A7AFE),
          ),
          useMaterial3: true,
        ),

        home: CollectionsScreen(),
      ),
    );
  }
}