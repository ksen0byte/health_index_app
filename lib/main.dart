import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/input_screen.dart';
import 'package:flutter/foundation.dart';

void main() {
  if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    // Initialize FFI for Windows/Linux/macOS
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const HealthIndexApp());
}

class HealthIndexApp extends StatelessWidget {
  const HealthIndexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Індекс фізичного здоров\'я',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        scaffoldBackgroundColor: Colors.grey[200],
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: ColorScheme.fromSeed(seedColor: Colors.green).surfaceBright,
          border: const OutlineInputBorder(),
        ),
      ),
      home: const InputScreen(),
    );
  }
}
