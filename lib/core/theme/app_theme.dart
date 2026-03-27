import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'theme_extension.dart';

class AppTheme {
  AppTheme._();

  static ThemeData build(AppThemeVariant variant) {
    final c = AppColors.fromVariant(variant);

    final base = ThemeData.dark(useMaterial3: true);
    const mono = GoogleFonts.jetBrainsMono;
    const sans = GoogleFonts.inter;

    return base.copyWith(
      scaffoldBackgroundColor: c.background,
      colorScheme: ColorScheme.dark(
        brightness: Brightness.dark,
        surface: c.surface,
        onSurface: c.text,
        primary: c.primary,
        onPrimary: c.onPrimary,
        secondary: c.secondary,
        onSecondary: c.onPrimary,
        error: c.error,
        onError: c.onPrimary,
        tertiary: c.accent,
        surfaceContainerHighest: c.surfaceVariant,
        outline: c.border,
        outlineVariant: c.textSubtle,
      ),
      textTheme: TextTheme(
        // Display styles — sans-serif
        displayLarge: sans(textStyle: TextStyle(color: c.text, fontSize: 57, fontWeight: FontWeight.w300)),
        displayMedium: sans(textStyle: TextStyle(color: c.text, fontSize: 45, fontWeight: FontWeight.w300)),
        displaySmall: sans(textStyle: TextStyle(color: c.text, fontSize: 36, fontWeight: FontWeight.w400)),
        headlineLarge: sans(textStyle: TextStyle(color: c.text, fontSize: 32, fontWeight: FontWeight.w600)),
        headlineMedium: sans(textStyle: TextStyle(color: c.text, fontSize: 28, fontWeight: FontWeight.w600)),
        headlineSmall: sans(textStyle: TextStyle(color: c.text, fontSize: 24, fontWeight: FontWeight.w600)),
        titleLarge: sans(textStyle: TextStyle(color: c.text, fontSize: 22, fontWeight: FontWeight.w600)),
        titleMedium: sans(textStyle: TextStyle(color: c.text, fontSize: 16, fontWeight: FontWeight.w500)),
        titleSmall: sans(textStyle: TextStyle(color: c.text, fontSize: 14, fontWeight: FontWeight.w500)),
        // Body — monospace
        bodyLarge: mono(textStyle: TextStyle(color: c.text, fontSize: 16)),
        bodyMedium: mono(textStyle: TextStyle(color: c.text, fontSize: 14)),
        bodySmall: mono(textStyle: TextStyle(color: c.textMuted, fontSize: 12)),
        labelLarge: mono(textStyle: TextStyle(color: c.text, fontSize: 14, fontWeight: FontWeight.w600)),
        labelMedium: mono(textStyle: TextStyle(color: c.textMuted, fontSize: 12)),
        labelSmall: mono(textStyle: TextStyle(color: c.textMuted, fontSize: 11)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        hintStyle: mono(textStyle: TextStyle(color: c.textMuted, fontSize: 14)),
        labelStyle: mono(textStyle: TextStyle(color: c.textMuted, fontSize: 14)),
        prefixStyle: mono(textStyle: TextStyle(color: c.primary, fontSize: 14)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: c.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: c.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          textStyle: mono(textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.primary,
          side: BorderSide(color: c.primary),
          textStyle: mono(textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.primary,
          textStyle: mono(textStyle: const TextStyle(fontSize: 14)),
        ),
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: c.border),
        ),
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(color: c.border, thickness: 1),
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        textColor: c.text,
        iconColor: c.textMuted,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: c.surfaceVariant,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: c.border),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: c.surfaceVariant,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: c.border),
        ),
        textStyle: mono(textStyle: TextStyle(color: c.text, fontSize: 12)),
      ),
      extensions: [AuralixThemeExtension.from(c, variant)],
    );
  }
}
