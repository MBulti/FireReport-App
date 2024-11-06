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
);

InputDecoration defaultInputDecoration(String labelText) {
  return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.grey),
      focusedBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none);
}
