import 'package:flutter/material.dart';
import 'screens/landing_screen.dart';

void main() => runApp(const IcebreakerApp());

class IcebreakerApp extends StatelessWidget {
  const IcebreakerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Icebreaker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7C3AED)),
        useMaterial3: true,
      ),
      home: const LandingScreen(),
    );
  }
}