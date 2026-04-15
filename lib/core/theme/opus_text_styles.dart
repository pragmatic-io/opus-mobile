import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'opus_colors.dart';

class OpusTextStyles {
  OpusTextStyles._();

  static TextStyle get h1 => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: OpusColors.noirGoudron,
        height: 1.2,
      );

  static TextStyle get h2 => GoogleFonts.inter(
        fontSize: 19,
        fontWeight: FontWeight.w800,
        color: OpusColors.noirGoudron,
        height: 1.3,
      );

  static TextStyle get h3 => GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: OpusColors.noirGoudron,
        height: 1.4,
      );

  static TextStyle get body => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: OpusColors.noirGoudron,
        height: 1.5,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: OpusColors.betonBrut,
        letterSpacing: 0.8,
        height: 1.4,
      );

  static TextStyle get button => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: OpusColors.blancChaux,
        height: 1.2,
      );
}
