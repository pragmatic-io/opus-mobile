import 'package:flutter/material.dart';

/// Couleurs OPUS Mobile - "Béton & Latérite"
///
/// Cette classe centralise TOUTES les couleurs de l'app.
/// Ne pas créer de couleurs custom ailleurs.
///
/// Référence: design/OPUS_Charte_Graphique_Final_v3.md
class OpusColors {
  OpusColors._(); // Private constructor - classe utilitaire

  // ============================================================================
  // COULEURS PRIMAIRES
  // ============================================================================

  /// 🪧 Rouge Enseigne - Couleur signature OPUS
  /// Usage: CTAs principaux, actions urgentes, badges importants
  /// Inspiration: Enseignes peintes à la main des boutiques informelles
  static const Color rougeEnseigne = Color(0xFFE63946);

  /// 🛖 Indigo Bâche - Structure
  /// Usage: Headers, navigation, éléments structurels
  /// Inspiration: Bâches bleues délavées des marchés
  static const Color indigoBache = Color(0xFF1D3557);

  /// 🚕 Jaune Taxi - Opportunité
  /// Usage: Badges "Nouveau", highlights, pricing
  /// Inspiration: Taxis wôrô-wôrô jaune-orange
  static const Color jauneTaxi = Color(0xFFF4A261);

  /// 🏜️ Ocre Latérite - Chaleur
  /// Usage: Accents secondaires, illustrations, éléments chaleureux
  /// Inspiration: Terre rouge des rues non-pavées
  static const Color ocreLaterite = Color(0xFFE76F51);

  // ============================================================================
  // COULEURS SECONDAIRES
  // ============================================================================

  static const Color betonBrut = Color(0xFF6C757D);
  static const Color grisAsphalte = Color(0xFF495057);
  static const Color bleuBache = Color(0xFF457B9D);
  static const Color terreRouge = Color(0xFFA8402F);

  // ============================================================================
  // COULEURS NEUTRES
  // ============================================================================

  static const Color noirGoudron = Color(0xFF212529);
  static const Color grisMur = Color(0xFF343A40);
  static const Color grisPoussiere = Color(0xFFADB5BD);
  static const Color blancChaux = Color(0xFFF8F9FA);
  static const Color blancPur = Color(0xFFFFFFFF);

  // ============================================================================
  // COULEURS SÉMANTIQUES
  // ============================================================================

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF4A261); // Utilise Jaune Taxi
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF457B9D); // Utilise Bleu Bâche

  // ============================================================================
  // DÉGRADÉS
  // ============================================================================

  /// Gradient Rouge Enseigne (pour CTAs principaux)
  static const LinearGradient enseigneGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [rougeEnseigne, terreRouge],
  );

  /// Gradient Indigo (pour headers, navigation)
  static const LinearGradient nuitGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [indigoBache, bleuBache],
  );

  /// Gradient Jaune-Ocre (pour badges premium)
  static const LinearGradient soleilGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [jauneTaxi, ocreLaterite],
  );

  /// Gradient Béton (pour backgrounds sombres)
  static const LinearGradient betonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [grisAsphalte, noirGoudron],
  );
}
