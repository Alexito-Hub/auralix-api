import 'package:flutter/material.dart';

/// Predefined terminal-aesthetic color schemes for Auralix Hub.
enum AppThemeVariant { neutralDark, cyberGreen, oceanBlue, neoViolet }

/// Public color token class used across all screens.
class ThemeColors {
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color accent;
  final Color accentAlt;
  final Color warning;
  final Color error;
  final Color success;
  final Color text;
  final Color textMuted;
  final Color textSubtle;
  final Color border;
  final Color glow;
  final Color glowAlt;
  final Color cursor;
  final Color terminalGreen;
  final Color terminalCyan;
  final Color terminalYellow;

  const ThemeColors({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.accent,
    required this.accentAlt,
    required this.warning,
    required this.error,
    required this.success,
    required this.text,
    required this.textMuted,
    required this.textSubtle,
    required this.border,
    required this.glow,
    required this.glowAlt,
    required this.cursor,
    required this.terminalGreen,
    required this.terminalCyan,
    required this.terminalYellow,
  });
}

class AppColors {
  AppColors._();

  // â”€â”€ Neutral Dark â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static const neutralDark = ThemeColors(
    background: Color(0xFF111417),
    surface: Color(0xFF1A2026),
    surfaceVariant: Color(0xFF232C34),
    primary: Color(0xFF9CC3FF),
    onPrimary: Color(0xFF0E1218),
    secondary: Color(0xFF8FDBBF),
    accent: Color(0xFFE2C38F),
    accentAlt: Color(0xFF8AC5D6),
    warning: Color(0xFFF0B676),
    error: Color(0xFFF38A8A),
    success: Color(0xFF8FDBBF),
    text: Color(0xFFE8EEF4),
    textMuted: Color(0xFFA7B5C4),
    textSubtle: Color(0xFF596775),
    border: Color(0xFF36424E),
    glow: Color(0x309CC3FF),
    glowAlt: Color(0x308FDBBF),
    cursor: Color(0xFF9CC3FF),
    terminalGreen: Color(0xFF8FDBBF),
    terminalCyan: Color(0xFF8AC5D6),
    terminalYellow: Color(0xFFF0B676),
  );

  // â”€â”€ Cyber Green â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static const cyberGreen = ThemeColors(
    background: Color(0xFF081713),
    surface: Color(0xFF0E1F1A),
    surfaceVariant: Color(0xFF132B24),
    primary: Color(0xFF47F5B1),
    onPrimary: Color(0xFF04120D),
    secondary: Color(0xFF8CEB6C),
    accent: Color(0xFF6EF0FF),
    accentAlt: Color(0xFF49D7F2),
    warning: Color(0xFFFFC163),
    error: Color(0xFFFF7474),
    success: Color(0xFF47F5B1),
    text: Color(0xFFD7F7EB),
    textMuted: Color(0xFF7FB39E),
    textSubtle: Color(0xFF36584D),
    border: Color(0xFF24443A),
    glow: Color(0x4047F5B1),
    glowAlt: Color(0x406EF0FF),
    cursor: Color(0xFF47F5B1),
    terminalGreen: Color(0xFF47F5B1),
    terminalCyan: Color(0xFF49D7F2),
    terminalYellow: Color(0xFFFFC163),
  );

  // â”€â”€ Ocean Blue â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static const oceanBlue = ThemeColors(
    background: Color(0xFF0A1624),
    surface: Color(0xFF112033),
    surfaceVariant: Color(0xFF17314A),
    primary: Color(0xFF6BD7FF),
    onPrimary: Color(0xFF07111A),
    secondary: Color(0xFF87E6B7),
    accent: Color(0xFF79A7FF),
    accentAlt: Color(0xFF4EF0D1),
    warning: Color(0xFFFFC36D),
    error: Color(0xFFFF7A8B),
    success: Color(0xFF5CE7B5),
    text: Color(0xFFE1F0FF),
    textMuted: Color(0xFF8BA6C2),
    textSubtle: Color(0xFF3B5168),
    border: Color(0xFF2D465E),
    glow: Color(0x406BD7FF),
    glowAlt: Color(0x404EF0D1),
    cursor: Color(0xFF6BD7FF),
    terminalGreen: Color(0xFF5CE7B5),
    terminalCyan: Color(0xFF6BD7FF),
    terminalYellow: Color(0xFFFFC36D),
  );

  // â”€â”€ Neo Violet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static const neoViolet = ThemeColors(
    background: Color(0xFF131726),
    surface: Color(0xFF1A2133),
    surfaceVariant: Color(0xFF242D45),
    primary: Color(0xFFC7A6FF),
    onPrimary: Color(0xFF130F21),
    secondary: Color(0xFF8DF4D8),
    accent: Color(0xFF8AB8FF),
    accentAlt: Color(0xFFEE84FF),
    warning: Color(0xFFFFCB72),
    error: Color(0xFFFF7A9F),
    success: Color(0xFF7DEAB7),
    text: Color(0xFFE8E7FF),
    textMuted: Color(0xFFA5A0CC),
    textSubtle: Color(0xFF514F70),
    border: Color(0xFF3B3D5A),
    glow: Color(0x40C7A6FF),
    glowAlt: Color(0x40EE84FF),
    cursor: Color(0xFFC7A6FF),
    terminalGreen: Color(0xFF7DEAB7),
    terminalCyan: Color(0xFF8AB8FF),
    terminalYellow: Color(0xFFFFCB72),
  );

  static ThemeColors fromVariant(AppThemeVariant variant) {
    return switch (variant) {
      AppThemeVariant.neutralDark => neutralDark,
      AppThemeVariant.cyberGreen => cyberGreen,
      AppThemeVariant.oceanBlue => oceanBlue,
      AppThemeVariant.neoViolet => neoViolet,
    };
  }

  static String variantLabel(AppThemeVariant variant) {
    return switch (variant) {
      AppThemeVariant.neutralDark => 'Neutral Dark',
      AppThemeVariant.cyberGreen => 'Cyber Green',
      AppThemeVariant.oceanBlue => 'Ocean Blue',
      AppThemeVariant.neoViolet => 'Neo Violet',
    };
  }

  // HTTP Status Code colouring
  static Color statusColor(ThemeColors c, int code) {
    if (code == 429) return c.warning;
    if (code >= 500) return c.error;
    if (code >= 400) return c.warning;
    if (code >= 300) return c.accentAlt;
    if (code >= 200) return c.success;
    return c.textMuted;
  }
}
