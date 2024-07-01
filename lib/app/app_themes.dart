import 'package:flutter/material.dart';

class AppThemes {
  static ColorScheme getColorScheme({required bool appTheme}) {
    switch (appTheme) {
      case false:
        return ColorScheme.fromSeed(
          seedColor: const Color(0xFF000000),
          primary: const Color(0xFF000000),
          inversePrimary: const Color(0xFFFFFFFF),
          surface: const Color(0xFFFFFFFF),
          //menu and others
          primaryContainer: const Color(0xFFD4D4D4),
          //bot messages
          secondaryContainer: const Color(0xFFD8E8D1),
          //user messages
          tertiaryContainer: const Color(0xFFEBEBEB),
          //additional elements of interface
          onPrimaryContainer: const Color(0xFF9788A4),
          outline: const Color(0xFF949694),
        );

      case true:
        return ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFFFFF),
          primary: const Color(0xFFFFFFFF),
          inversePrimary: const Color(0xFF000000),
          surface: const Color(0xFF282529),
          //menu and others
          primaryContainer: const Color(0xFF413F42),
          //bot messages
          secondaryContainer: const Color(0xFF4E434F),
          //user messages
          tertiaryContainer: const Color(0xFF383638),
          //additional elements of interface
          onPrimaryContainer: const Color(0xFF5D506E),
          outline: const Color(0xFF757275),
        );

      default:
        return ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFFFFF),
          primary: const Color(0xFF000000),
          surface: const Color(0xFF616375),
          primaryContainer: const Color(0xFF4E5160),
          secondaryContainer: const Color(0xFF787B8C),
        );
    }
  }
}
