import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';

const _kThemeKey = 'auralix_theme_variant';

final themeProvider =
    NotifierProvider<ThemeNotifier, AppThemeVariant>(ThemeNotifier.new);

class ThemeNotifier extends Notifier<AppThemeVariant> {
  @override
  AppThemeVariant build() => AppThemeVariant.neutralDark;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kThemeKey);
    if (saved != null) {
      final variant = _resolveVariant(saved);
      state = variant;
    }
  }

  Future<void> setTheme(AppThemeVariant variant) async {
    state = variant;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeKey, variant.name);
  }

  AppThemeVariant _resolveVariant(String raw) {
    for (final variant in AppThemeVariant.values) {
      if (variant.name == raw) return variant;
    }

    // Backward compatibility with legacy persisted variant names.
    return switch (raw) {
      'tokyoNight' => AppThemeVariant.oceanBlue,
      'nord' => AppThemeVariant.oceanBlue,
      'dracula' => AppThemeVariant.neoViolet,
      'monokaiPro' => AppThemeVariant.cyberGreen,
      'auralixDefault' => AppThemeVariant.oceanBlue,
      _ => AppThemeVariant.neutralDark,
    };
  }
}
