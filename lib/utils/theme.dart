import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFFCF1C34),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFF191919),
    error: Color(0xFFCF1C34),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFF3F3F3),
    onSurface: Color(0xFF191919),
    inversePrimary: Color(0xFFFFFFFF),
    inverseSurface: Color(0xFF191919),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size.fromHeight(46),
      backgroundColor: const Color(0xFFCF1C34),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(
          color: Color(0xFFFFFFFF),
        ),
      ),
    ),
  ),
);

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFB5192E),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF3E3E40),
    onSecondary: Color(0xFFFFFFFF),
    error: Color(0xFFCF1C34),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFF222222),
    onSurface: Color(0xFFFFFFFF),
    inversePrimary: Color(0xFFF3F3F3),
    inverseSurface: Color(0xFF3E3E40),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size.fromHeight(46),
      backgroundColor: const Color(0xFFB5192E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(
          color: Color(0xFFFFFFFF),
        ),
      ),
    ),
  ),
);
