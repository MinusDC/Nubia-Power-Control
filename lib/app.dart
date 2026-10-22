import 'package:flutter/material.dart';
import 'package:power_control/screens/home_screen.dart';

class PowerControlApp extends StatelessWidget {
  const PowerControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF10131A);

    return MaterialApp(
      title: 'Power Control',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3988FF),
          brightness: Brightness.dark,
          surface: backgroundColor,
        ),
        useMaterial3: true,
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
