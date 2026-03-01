import 'package:first_project/screens/collections/collection_screen.dart';
import 'package:first_project/screens/collections/collection_controller.dart'; // Add this import
import 'package:first_project/providers/app_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // USE MULTIPROVIDER TO INJECT BOTH CONTROLLERS
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppController()),
        ChangeNotifierProvider(create: (_) => CollectionController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Todo List',
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFF0A0F1F),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0A0F1F),
            iconTheme: IconThemeData(color: Colors.white),
            actionsIconTheme: IconThemeData(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white), 
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF3A7AFE),
          ),
          useMaterial3: true,
        ),
        home: const CollectionsScreen(),
      ),
    );
  }
}