import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blueAccent,
    brightness: Brightness.light,
    dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
  ),
);

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blueAccent,
    brightness: Brightness.dark,
    dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
  ),
);

FeedbackThemeData feedbackLightTheme = FeedbackThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blueAccent,
    brightness: Brightness.light,
    dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
  ),
);

FeedbackThemeData feedbackDarkTheme = FeedbackThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blueAccent,
    dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
  ),
);
