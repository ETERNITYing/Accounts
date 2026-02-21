import 'package:flutter/material.dart';

ThemeData buildTheme(ColorScheme? dynamicScheme, bool isDarkMode) {
  ColorScheme colorScheme = dynamicScheme ??
      (isDarkMode ? ColorScheme.dark() :  ColorScheme.light());
  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true
  );
}