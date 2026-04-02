import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleKey = 'auralix_locale';

final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() => null;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kLocaleKey);
    final parsed = _parseStoredLocale(raw);
    state = parsed;

    // Clean up legacy/invalid values so we can safely follow system locale.
    if (raw != null && raw.isNotEmpty && parsed == null) {
      await prefs.remove(_kLocaleKey);
    }
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_kLocaleKey);
      return;
    }
    final countryCode = locale.countryCode;
    final serialized = (countryCode == null || countryCode.isEmpty)
        ? locale.languageCode
      : '${locale.languageCode}_$countryCode';
    await prefs.setString(_kLocaleKey, serialized);
  }

  Locale? _parseStoredLocale(String? raw) {
    if (raw == null) return null;

    final value = raw.trim();
    if (value.isEmpty || value.toLowerCase() == 'system') return null;

    final normalized = value.replaceAll('-', '_');
    final parts = normalized.split('_');
    if (parts.isEmpty || parts.first.isEmpty) return null;

    final languageCode = parts.first.toLowerCase();
    if (parts.length == 1 || parts[1].isEmpty) {
      return Locale(languageCode);
    }

    return Locale(languageCode, parts[1].toUpperCase());
  }
}
