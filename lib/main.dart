import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/router/app_router.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use path URL strategy to avoid hash (#) in web routes
  setPathUrlStrategy();

  // Load persisted theme before app starts
  final container = ProviderContainer();
  await container.read(themeProvider.notifier).load();

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
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Auralix Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(variant),
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es'), Locale('en')],
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}
