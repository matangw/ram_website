import 'package:flutter/material.dart';

/// Memorial color palette — black background, white text, gold accents.
/// Designer-recommended: #0A0A0A (softer than pure black), #FFFFFF primary text,
/// #A1A1AA secondary, #71717A muted. Gold accents for CTAs and dignity.
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

  /// Black/white theme — designer-recommended palette.
  /// Background: #0A0A0A (softer than pure black, reduces eye strain).
  /// Text: #FFFFFF primary, #A1A1AA secondary, #71717A muted.
  /// Gold accents for memorial dignity; WCAG AA compliant.
  static MemorialThemeExtension get light => MemorialThemeExtension(
        surface: const Color(0xFF0A0A0A),
        surfaceSecondary: const Color(0xFF141414),
        primaryGold: const Color(0xFFD4AF37),
        secondaryGold: const Color(0xFFE5C158),
        tertiaryGold: const Color(0xFFB8956B),
        goldHover: const Color(0xFFE8D48B),
        textPrimary: const Color(0xFFFFFFFF),
        textSecondary: const Color(0xFFA1A1AA),
        textMuted: const Color(0xFF71717A),
        shadowLight: Colors.black.withOpacity(0.25),
        shadowMedium: Colors.black.withOpacity(0.4),
        shadowDark: Colors.black.withOpacity(0.6),
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
