import 'package:flutter/material.dart';
import 'opus_colors.dart';
import 'opus_text_styles.dart';
import 'opus_spacing.dart';

class OpusTheme {
  OpusTheme._();

  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: OpusColors.rougeEnseigne,
      onPrimary: OpusColors.blancChaux,
      primaryContainer: Color(0xFFFAD0D3),
      onPrimaryContainer: OpusColors.terreRouge,
      secondary: OpusColors.indigoBache,
      onSecondary: OpusColors.blancChaux,
      secondaryContainer: Color(0xFFD0DCF0),
      onSecondaryContainer: OpusColors.indigoBache,
      tertiary: OpusColors.bleuBache,
      onTertiary: OpusColors.blancChaux,
      tertiaryContainer: Color(0xFFD0E4F0),
      onTertiaryContainer: OpusColors.indigoBache,
      error: OpusColors.error,
      onError: OpusColors.blancChaux,
      errorContainer: Color(0xFFFDD0D0),
      onErrorContainer: Color(0xFF8B1A1A),
      surface: OpusColors.blancChaux,
      onSurface: OpusColors.noirGoudron,
      surfaceContainerHighest: Color(0xFFE9ECEF),
      onSurfaceVariant: OpusColors.grisAsphalte,
      outline: OpusColors.grisPoussiere,
      outlineVariant: Color(0xFFDEE2E6),
      shadow: Color(0x1A000000),
      scrim: Color(0x66000000),
      inverseSurface: OpusColors.noirGoudron,
      onInverseSurface: OpusColors.blancChaux,
      inversePrimary: Color(0xFFF4A0A6),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: OpusColors.blancChaux,
      textTheme: TextTheme(
        displayLarge: OpusTextStyles.h1,
        displayMedium: OpusTextStyles.h2,
        displaySmall: OpusTextStyles.h3,
        headlineLarge: OpusTextStyles.h1,
        headlineMedium: OpusTextStyles.h2,
        headlineSmall: OpusTextStyles.h3,
        titleLarge: OpusTextStyles.h2,
        titleMedium: OpusTextStyles.h3,
        titleSmall: OpusTextStyles.body,
        bodyLarge: OpusTextStyles.body,
        bodyMedium: OpusTextStyles.body,
        bodySmall: OpusTextStyles.caption,
        labelLarge: OpusTextStyles.button,
        labelMedium: OpusTextStyles.caption,
        labelSmall: OpusTextStyles.caption,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: OpusSpacing.md,
          vertical: OpusSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: OpusColors.grisPoussiere),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: OpusColors.grisPoussiere),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: OpusColors.rougeEnseigne, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: OpusColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: OpusColors.error, width: 2),
        ),
        labelStyle: OpusTextStyles.body.copyWith(color: OpusColors.betonBrut),
        hintStyle: OpusTextStyles.body.copyWith(color: OpusColors.grisPoussiere),
        errorStyle: OpusTextStyles.caption.copyWith(color: OpusColors.error),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: OpusColors.rougeEnseigne,
          foregroundColor: OpusColors.blancChaux,
          textStyle: OpusTextStyles.button,
          padding: const EdgeInsets.symmetric(
            horizontal: OpusSpacing.lg,
            vertical: OpusSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: OpusColors.indigoBache,
        foregroundColor: OpusColors.blancChaux,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: OpusTextStyles.h2.copyWith(color: OpusColors.blancChaux),
        iconTheme: const IconThemeData(color: OpusColors.blancChaux),
      ),
    );
  }
}
