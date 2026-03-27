import 'package:flutter/material.dart';

/// Predefined terminal-aesthetic color schemes for Auralix Hub.
enum AppThemeVariant { tokyoNight, dracula, nord, monokaiPro, auralixDefault }

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

  // ── Tokyo Night ────────────────────────────────────────────────────────────
  static const tokyoNight = ThemeColors(
    background: Color(0xFF1a1b2e),
    surface: Color(0xFF16213e),
    surfaceVariant: Color(0xFF0f3460),
    primary: Color(0xFF7aa2f7),
    onPrimary: Color(0xFF1a1b2e),
    secondary: Color(0xFF9ece6a),
    accent: Color(0xFFbb9af7),
    accentAlt: Color(0xFF7dcfff),
    warning: Color(0xFFe0af68),
    error: Color(0xFFf7768e),
    success: Color(0xFF9ece6a),
    text: Color(0xFFc0caf5),
    textMuted: Color(0xFF565f89),
    textSubtle: Color(0xFF414868),
    border: Color(0xFF292e42),
    glow: Color(0x407aa2f7),
    glowAlt: Color(0x40bb9af7),
    cursor: Color(0xFF7aa2f7),
    terminalGreen: Color(0xFF9ece6a),
    terminalCyan: Color(0xFF7dcfff),
    terminalYellow: Color(0xFFe0af68),
  );

  // ── Dracula ────────────────────────────────────────────────────────────────
  static const dracula = ThemeColors(
    background: Color(0xFF1e1f29),
    surface: Color(0xFF282a36),
    surfaceVariant: Color(0xFF343746),
    primary: Color(0xFFbd93f9),
    onPrimary: Color(0xFF282a36),
    secondary: Color(0xFF50fa7b),
    accent: Color(0xFFff79c6),
    accentAlt: Color(0xFF8be9fd),
    warning: Color(0xFFf1fa8c),
    error: Color(0xFFff5555),
    success: Color(0xFF50fa7b),
    text: Color(0xFFf8f8f2),
    textMuted: Color(0xFF6272a4),
    textSubtle: Color(0xFF44475a),
    border: Color(0xFF44475a),
    glow: Color(0x40bd93f9),
    glowAlt: Color(0x40ff79c6),
    cursor: Color(0xFFf8f8f2),
    terminalGreen: Color(0xFF50fa7b),
    terminalCyan: Color(0xFF8be9fd),
    terminalYellow: Color(0xFFf1fa8c),
  );

  // ── Nord ───────────────────────────────────────────────────────────────────
  static const nord = ThemeColors(
    background: Color(0xFF1c2333),
    surface: Color(0xFF242c3b),
    surfaceVariant: Color(0xFF2e3a4e),
    primary: Color(0xFF88c0d0),
    onPrimary: Color(0xFF1c2333),
    secondary: Color(0xFFa3be8c),
    accent: Color(0xFF81a1c1),
    accentAlt: Color(0xFF5e81ac),
    warning: Color(0xFFebcb8b),
    error: Color(0xFFbf616a),
    success: Color(0xFFa3be8c),
    text: Color(0xFFeceff4),
    textMuted: Color(0xFF677691),
    textSubtle: Color(0xFF4c566a),
    border: Color(0xFF3b4252),
    glow: Color(0x4088c0d0),
    glowAlt: Color(0x4081a1c1),
    cursor: Color(0xFF88c0d0),
    terminalGreen: Color(0xFFa3be8c),
    terminalCyan: Color(0xFF88c0d0),
    terminalYellow: Color(0xFFebcb8b),
  );

  // ── Monokai Pro ────────────────────────────────────────────────────────────
  static const monokaiPro = ThemeColors(
    background: Color(0xFF19181a),
    surface: Color(0xFF221f22),
    surfaceVariant: Color(0xFF2d2a2e),
    primary: Color(0xFFab9df2),
    onPrimary: Color(0xFF19181a),
    secondary: Color(0xFFa9dc76),
    accent: Color(0xFFff6188),
    accentAlt: Color(0xFF78dce8),
    warning: Color(0xFFffd866),
    error: Color(0xFFff6188),
    success: Color(0xFFa9dc76),
    text: Color(0xFFfcfcfa),
    textMuted: Color(0xFF727072),
    textSubtle: Color(0xFF5b595c),
    border: Color(0xFF403e41),
    glow: Color(0x40ab9df2),
    glowAlt: Color(0x40ff6188),
    cursor: Color(0xFFfcfcfa),
    terminalGreen: Color(0xFFa9dc76),
    terminalCyan: Color(0xFF78dce8),
    terminalYellow: Color(0xFFffd866),
  );

  // ── Auralix Default ────────────────────────────────────────────────────────
  static const auralixDefault = ThemeColors(
    background: Color(0xFF0d1117),
    surface: Color(0xFF161b22),
    surfaceVariant: Color(0xFF21262d),
    primary: Color(0xFF58a6ff),
    onPrimary: Color(0xFF0d1117),
    secondary: Color(0xFF3fb950),
    accent: Color(0xFFd2a8ff),
    accentAlt: Color(0xFF79c0ff),
    warning: Color(0xFFd29922),
    error: Color(0xFFf85149),
    success: Color(0xFF3fb950),
    text: Color(0xFFe6edf3),
    textMuted: Color(0xFF7d8590),
    textSubtle: Color(0xFF30363d),
    border: Color(0xFF30363d),
    glow: Color(0x4058a6ff),
    glowAlt: Color(0x40d2a8ff),
    cursor: Color(0xFF58a6ff),
    terminalGreen: Color(0xFF3fb950),
    terminalCyan: Color(0xFF79c0ff),
    terminalYellow: Color(0xFFd29922),
  );

  static ThemeColors fromVariant(AppThemeVariant variant) {
    return switch (variant) {
      AppThemeVariant.tokyoNight => tokyoNight,
      AppThemeVariant.dracula => dracula,
      AppThemeVariant.nord => nord,
      AppThemeVariant.monokaiPro => monokaiPro,
      AppThemeVariant.auralixDefault => auralixDefault,
    };
  }

  // HTTP Status Code colouring
  static Color statusColor(ThemeColors c, int code) {
    if (code >= 500) return c.error;
    if (code >= 400) return c.warning;
    if (code >= 300) return c.accentAlt;
    if (code >= 200) return c.success;
    return c.textMuted;
  }
}
