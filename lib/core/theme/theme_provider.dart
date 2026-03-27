import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';

const _kThemeKey = 'auralix_theme_variant';

final themeProvider = NotifierProvider<ThemeNotifier, AppThemeVariant>(ThemeNotifier.new);

class ThemeNotifier extends Notifier<AppThemeVariant> {
  @override
  AppThemeVariant build() => AppThemeVariant.auralixDefault;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kThemeKey);
    if (saved != null) {
      final variant = AppThemeVariant.values.firstWhere(
        (v) => v.name == saved,
        orElse: () => AppThemeVariant.auralixDefault,
      );
      state = variant;
    }
  }

  Future<void> setTheme(AppThemeVariant variant) async {
    state = variant;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeKey, variant.name);
  }
}
