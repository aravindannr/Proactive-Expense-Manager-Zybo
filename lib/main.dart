import 'package:flutter/material.dart';
import 'package:proactive_expense_manager/presentation/screens/initial_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proactive Expense Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF312ECB)),
        primaryColor: const Color(0xFF312ECB),
      ),
      home: const InitialScreen(),
    );
  }
}
