import 'package:flutter/material.dart';

/// Memorial color palette — darker smooth gold accents.
/// Warm cream backgrounds, dignified gold accents, warm brown text.
///
/// All colors are defined here. Components access them via
/// `Theme.of(context).extension<MemorialThemeExtension>()`.
class MemorialThemeExtension extends ThemeExtension<MemorialThemeExtension> {
  MemorialThemeExtension({
    required this.surface,
    required this.surfaceSecondary,
    required this.primaryGold,
    required this.secondaryGold,
    required this.tertiaryGold,
    required this.goldHover,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.shadowLight,
    required this.shadowMedium,
    required this.shadowDark,
  });

  final Color surface;
  final Color surfaceSecondary;
  final Color primaryGold;
  final Color secondaryGold;
  final Color tertiaryGold;
  final Color goldHover;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color shadowLight;
  final Color shadowMedium;
  final Color shadowDark;

  /// Single source of truth for the light theme palette.
  static MemorialThemeExtension get light => MemorialThemeExtension(
        surface: const Color(0xFFFAF7F2),
        surfaceSecondary: const Color(0xFFF5F0E8),
        primaryGold: const Color(0xFF8B6914),
        secondaryGold: const Color(0xFF9A7B0A),
        tertiaryGold: const Color(0xFFB8956B),
        goldHover: const Color(0xFFC9A227),
        textPrimary: const Color(0xFF2C2416),
        textSecondary: const Color(0xFF5C5348),
        textMuted: const Color(0xFF7A7065),
        shadowLight: Colors.black.withOpacity(0.15),
        shadowMedium: Colors.black.withOpacity(0.3),
        shadowDark: Colors.black.withOpacity(0.5),
      );

  @override
  MemorialThemeExtension copyWith({
    Color? surface,
    Color? surfaceSecondary,
    Color? primaryGold,
    Color? secondaryGold,
    Color? tertiaryGold,
    Color? goldHover,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? shadowLight,
    Color? shadowMedium,
    Color? shadowDark,
  }) {
    return MemorialThemeExtension(
      surface: surface ?? this.surface,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      primaryGold: primaryGold ?? this.primaryGold,
      secondaryGold: secondaryGold ?? this.secondaryGold,
      tertiaryGold: tertiaryGold ?? this.tertiaryGold,
      goldHover: goldHover ?? this.goldHover,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      shadowLight: shadowLight ?? this.shadowLight,
      shadowMedium: shadowMedium ?? this.shadowMedium,
      shadowDark: shadowDark ?? this.shadowDark,
    );
  }

  @override
  MemorialThemeExtension lerp(
    ThemeExtension<MemorialThemeExtension>? other,
    double t,
  ) {
    if (other is! MemorialThemeExtension) return this;
    return MemorialThemeExtension(
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSecondary: Color.lerp(surfaceSecondary, other.surfaceSecondary, t)!,
      primaryGold: Color.lerp(primaryGold, other.primaryGold, t)!,
      secondaryGold: Color.lerp(secondaryGold, other.secondaryGold, t)!,
      tertiaryGold: Color.lerp(tertiaryGold, other.tertiaryGold, t)!,
      goldHover: Color.lerp(goldHover, other.goldHover, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      shadowLight: Color.lerp(shadowLight, other.shadowLight, t)!,
      shadowMedium: Color.lerp(shadowMedium, other.shadowMedium, t)!,
      shadowDark: Color.lerp(shadowDark, other.shadowDark, t)!,
    );
  }
}
