import 'package:flutter/material.dart';
import 'opus_colors.dart';
import 'opus_text_styles.dart';

/// Theme OPUS Mobile complet
///
/// Applique la charte graphique "Béton & Latérite" à toute l'app.
class OpusTheme {
  OpusTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      // Couleurs
      colorScheme: ColorScheme.light(
        primary: OpusColors.rougeEnseigne,
        secondary: OpusColors.indigoBache,
        tertiary: OpusColors.jauneTaxi,
        error: OpusColors.error,
        surface: OpusColors.blancChaux,
        onPrimary: OpusColors.blancPur,
        onSecondary: OpusColors.blancPur,
        onSurface: OpusColors.noirGoudron,
      ),

      // Scaffold
      scaffoldBackgroundColor: OpusColors.blancChaux,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: OpusColors.indigoBache,
        foregroundColor: OpusColors.blancPur,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: OpusTextStyles.h2.copyWith(
          color: OpusColors.blancPur,
        ),
      ),

      // Textes
      textTheme: TextTheme(
        displayLarge: OpusTextStyles.h1,
        displayMedium: OpusTextStyles.h2,
        displaySmall: OpusTextStyles.h3,
        bodyLarge: OpusTextStyles.bodyRegular,
        bodyMedium: OpusTextStyles.bodySmall,
        labelSmall: OpusTextStyles.caption,
      ),

      // Boutons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: OpusColors.rougeEnseigne,
          foregroundColor: OpusColors.blancPur,
          textStyle: OpusTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 8,
          shadowColor: OpusColors.rougeEnseigne.withOpacity(0.3),
        ),
      ),

      // Cards
      cardTheme: CardTheme(
        color: OpusColors.blancPur,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: OpusColors.blancChaux, width: 2),
        ),
        margin: const EdgeInsets.all(0),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: OpusColors.blancChaux,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: OpusColors.blancChaux, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: OpusColors.blancChaux, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: OpusColors.rougeEnseigne, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: OpusColors.error, width: 2),
        ),
      ),
    );
  }
}
