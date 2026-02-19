import 'package:flutter/material.dart';
import 'opus_colors.dart';

/// Styles de texte OPUS - Police Inter
///
/// Hiérarchie typographique basée sur la charte graphique.
/// Police: Inter (Google Fonts)
///
/// Référence: design/OPUS_Charte_Graphique_Final_v3.md
class OpusTextStyles {
  OpusTextStyles._();

  // ============================================================================
  // TITRES
  // ============================================================================

  /// H1 - Titres de pages
  static const TextStyle h1 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 32,
    fontWeight: FontWeight.w800, // ExtraBold
    height: 1.2,
    letterSpacing: -0.5,
    color: OpusColors.noirGoudron,
  );

  /// H2 - Titres de sections
  static const TextStyle h2 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 19,
    fontWeight: FontWeight.w800,
    height: 1.26,
    letterSpacing: -0.3,
    color: OpusColors.noirGoudron,
  );

  /// H3 - Titres de cards
  static const TextStyle h3 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 17,
    fontWeight: FontWeight.w700, // Bold
    height: 1.3,
    color: OpusColors.noirGoudron,
  );

  // ============================================================================
  // BODY
  // ============================================================================

  /// Body Regular - Texte principal
  static const TextStyle bodyRegular = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w500, // Medium
    height: 1.5,
    color: OpusColors.grisMur,
  );

  /// Body Small - Texte secondaire
  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
    color: OpusColors.grisAsphalte,
  );

  /// Caption - Labels, timestamps
  static const TextStyle caption = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w600, // SemiBold
    height: 1.33,
    letterSpacing: 0.5,
    color: OpusColors.betonBrut,
  );

  /// Caption Uppercase - Metadata, badges
  static const TextStyle captionUppercase = TextStyle(
    fontFamily: 'Inter',
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 1.45,
    letterSpacing: 0.5,
    color: OpusColors.betonBrut,
  );

  // ============================================================================
  // BOUTONS
  // ============================================================================

  /// Button Text - Texte des boutons
  static const TextStyle button = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
    color: OpusColors.blancPur,
  );

  /// Button Small - Petits boutons
  static const TextStyle buttonSmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    color: OpusColors.blancPur,
  );
}
