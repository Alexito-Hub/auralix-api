import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/i18n/locale_provider.dart';
import 'core/router/app_router.dart';
import 'features/auth/providers/auth_provider.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:hub_aura/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use path URL strategy to avoid hash (#) in web routes
  setPathUrlStrategy();

  // Load persisted theme before app starts
  final container = ProviderContainer();
  await Future.wait([
    container.read(themeProvider.notifier).load(),
    container.read(localeProvider.notifier).load(),
    container.read(authProvider.future).catchError((_) => null),
  ]);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const HubAuraApp(),
    ),
  );
}

class HubAuraApp extends ConsumerWidget {
  const HubAuraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final variant = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Auralix Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(variant),
      locale: locale,
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        if (deviceLocale == null) return supportedLocales.first;

        for (final supported in supportedLocales) {
          if (supported.languageCode.toLowerCase() ==
              deviceLocale.languageCode.toLowerCase()) {
            return supported;
          }
        }

        return supportedLocales.first;
      },
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}
