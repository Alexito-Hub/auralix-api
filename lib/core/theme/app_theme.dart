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
    const display = GoogleFonts.spaceMono;

    return base.copyWith(
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
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
        // Terminal-inspired typography.
        displayLarge: display(
            textStyle: TextStyle(
                color: c.text, fontSize: 50, fontWeight: FontWeight.w700)),
        displayMedium: display(
            textStyle: TextStyle(
                color: c.text, fontSize: 42, fontWeight: FontWeight.w700)),
        displaySmall: display(
            textStyle: TextStyle(
                color: c.text, fontSize: 34, fontWeight: FontWeight.w700)),
        headlineLarge: display(
            textStyle: TextStyle(
                color: c.text, fontSize: 30, fontWeight: FontWeight.w700)),
        headlineMedium: display(
            textStyle: TextStyle(
                color: c.text, fontSize: 26, fontWeight: FontWeight.w700)),
        headlineSmall: display(
            textStyle: TextStyle(
                color: c.text, fontSize: 22, fontWeight: FontWeight.w700)),
        titleLarge: display(
            textStyle: TextStyle(
                color: c.text, fontSize: 20, fontWeight: FontWeight.w600)),
        titleMedium: mono(
            textStyle: TextStyle(
                color: c.text, fontSize: 15, fontWeight: FontWeight.w600)),
        titleSmall: mono(
            textStyle: TextStyle(
                color: c.text, fontSize: 13, fontWeight: FontWeight.w600)),
        bodyLarge: mono(
            textStyle: TextStyle(color: c.text, fontSize: 15, height: 1.4)),
        bodyMedium: mono(
            textStyle: TextStyle(color: c.text, fontSize: 13, height: 1.4)),
        bodySmall: mono(
            textStyle:
                TextStyle(color: c.textMuted, fontSize: 11.5, height: 1.35)),
        labelLarge: mono(
            textStyle: TextStyle(
                color: c.text, fontSize: 13, fontWeight: FontWeight.w700)),
        labelMedium:
            mono(textStyle: TextStyle(color: c.textMuted, fontSize: 11.5)),
        labelSmall:
            mono(textStyle: TextStyle(color: c.textMuted, fontSize: 10.5)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        hintStyle: mono(textStyle: TextStyle(color: c.textMuted, fontSize: 14)),
        labelStyle:
            mono(textStyle: TextStyle(color: c.textMuted, fontSize: 14)),
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          textStyle: mono(
              textStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.primary,
          side: BorderSide(color: c.primary),
          textStyle: mono(
              textStyle:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        foregroundColor: c.text,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: mono(
            textStyle: TextStyle(
                color: c.text, fontSize: 15, fontWeight: FontWeight.w700)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surfaceVariant,
        selectedColor: c.primary.withValues(alpha: 0.2),
        side: BorderSide(color: c.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        labelStyle: mono(textStyle: TextStyle(color: c.text, fontSize: 12)),
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
