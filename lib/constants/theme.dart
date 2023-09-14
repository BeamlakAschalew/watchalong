import 'package:flutter/material.dart';

class Style {
  static ThemeData themeData() {
    return ThemeData(
        appBarTheme: const AppBarTheme(color: Color(0xFFeb4034)),
        elevatedButtonTheme: const ElevatedButtonThemeData(
            style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Color(0xFFeb4034)))),
        inputDecorationTheme: const InputDecorationTheme(
          fillColor: Color(0xFFeb4034),
          filled: true,
        ),
        primaryColor: Color(0xFFeb4034));
  }
}
