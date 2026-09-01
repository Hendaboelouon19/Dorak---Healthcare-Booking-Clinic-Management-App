import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static final TextTheme textTheme = GoogleFonts.manropeTextTheme();

  static TextStyle get heading1 => (textTheme.headlineMedium ?? const TextStyle()).copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
      );

  static TextStyle get heading2 => (textTheme.titleLarge ?? const TextStyle()).copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      );

  static TextStyle get title => (textTheme.titleMedium ?? const TextStyle()).copyWith(
        fontWeight: FontWeight.w700,
      );

  static TextStyle get body => (textTheme.bodyMedium ?? const TextStyle()).copyWith(
        fontWeight: FontWeight.w500,
      );

  static TextStyle get caption => (textTheme.bodySmall ?? const TextStyle()).copyWith(
        color: const Color(0xFF667085),
        fontWeight: FontWeight.w500,
      );
}
