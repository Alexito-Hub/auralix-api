import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hub_aura/l10n/app_localizations.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/verify_email_screen.dart';
import '../../features/landing/screens/landing_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../shared/models/user_model.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/dashboard/screens/history_screen.dart';
import '../../features/docs/screens/docs_screen.dart';
import '../../features/sandbox/screens/sandbox_screen.dart';
import '../../features/snippets/screens/snippets_screen.dart';
import '../../features/snippets/screens/snippet_detail_screen.dart';
import '../../features/billing/screens/billing_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/legal/screens/legal_screen.dart';
import '../../shared/widgets/app_shell.dart';
import '../../core/theme/theme_extension.dart';

Page<dynamic> _animatedPage(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.015, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final authStateListenable =
      ValueNotifier<AsyncValue<HubUser?>>(ref.read(authProvider));

  ref.listen<AsyncValue<HubUser?>>(authProvider, (_, next) {
    authStateListenable.value = next;
  });

  final router = GoRouter(
    initialLocation: '/',
    refreshListenable: authStateListenable,
    redirect: (context, state) {
      final authState = authStateListenable.value;
      if (authState.isLoading) return null;

      final isAuth = authState.valueOrNull != null;
      final requestPath = state.uri.path.toLowerCase();

      final isPublicRoute = state.matchedLocation == '/' ||
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/terms' ||
          state.matchedLocation == '/privacy' ||
          state.matchedLocation == '/usage' ||
          state.matchedLocation.startsWith('/verify-email') ||
          requestPath.startsWith('/s/');

      if (!isAuth && !isPublicRoute) {
        return '/login';
      }

      if (isAuth && state.matchedLocation == '/') {
        return '/dashboard';
      }

      if (isAuth &&
          (state.matchedLocation == '/login' ||
              state.matchedLocation == '/register')) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      // --- Public auth routes ---
      GoRoute(
        path: '/',
        pageBuilder: (_, state) => _animatedPage(state, const LandingScreen()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (_, state) => _animatedPage(state, const LoginScreen()),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (_, state) => _animatedPage(state, const RegisterScreen()),
      ),
      GoRoute(
        path: '/verify-email',
        pageBuilder: (_, state) => _animatedPage(
          state,
          VerifyEmailScreen(token: state.uri.queryParameters['token']),
        ),
      ),

      // --- Public snippet viewer ---
      GoRoute(
        path: '/s/:id',
        pageBuilder: (_, state) => _animatedPage(
          state,
          SnippetDetailScreen(id: state.pathParameters['id']!),
        ),
      ),

      // --- Legal pages (public) ---
      GoRoute(
        path: '/terms',
        pageBuilder: (_, state) =>
            _animatedPage(state, const LegalScreen(page: LegalPage.terms)),
      ),
      GoRoute(
        path: '/privacy',
        pageBuilder: (_, state) =>
            _animatedPage(state, const LegalScreen(page: LegalPage.privacy)),
      ),
      GoRoute(
        path: '/usage',
        pageBuilder: (_, state) =>
            _animatedPage(state, const LegalScreen(page: LegalPage.usage)),
      ),

      // --- Authenticated shell with side nav ---
      ShellRoute(
        builder: (_, __, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (_, state) =>
                _animatedPage(state, const DashboardScreen()),
          ),
          GoRoute(
            path: '/history',
            pageBuilder: (_, state) =>
                _animatedPage(state, const HistoryScreen()),
          ),
          GoRoute(
            path: '/docs',
            pageBuilder: (_, state) => _animatedPage(state, const DocsScreen()),
          ),
          GoRoute(
            path: '/docs/:apiId',
            pageBuilder: (_, state) => _animatedPage(
              state,
              DocsScreen(apiId: state.pathParameters['apiId']),
            ),
          ),
          GoRoute(
            path: '/sandbox',
            pageBuilder: (_, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return _animatedPage(
                state,
                SandboxScreen(
                  prefilledServiceId: extra?['serviceId'] as String?,
                  prefilledPath: extra?['path'] as String?,
                  prefilledBody: extra?['body'] as String?,
                  prefilledMethod: extra?['method'] as String?,
                ),
              );
            },
          ),
          GoRoute(
            path: '/snippets',
            pageBuilder: (_, state) =>
                _animatedPage(state, const SnippetsScreen()),
          ),
          GoRoute(
            path: '/billing',
            pageBuilder: (_, state) =>
                _animatedPage(state, const BillingScreen()),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (_, state) =>
                _animatedPage(state, const SettingsScreen()),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) {
      final ext = AuralixThemeExtension.of(context);
      final l10n = AppLocalizations.of(context)!;
      return Scaffold(
        backgroundColor: ext.bg,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: DecoratedBox(
                decoration: ext.surfaceDecoration,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.route_outlined, size: 32, color: ext.warning),
                      const SizedBox(height: 10),
                      Text(
                        l10n.routerNotFoundTitle,
                        style: TextStyle(
                          color: ext.text,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.error?.toString() ?? l10n.routerUnknownError,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: ext.textMuted, fontSize: 13),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () => context.go('/'),
                            child: Text(l10n.routerGoHome),
                          ),
                          OutlinedButton(
                            onPressed: () => context.go('/dashboard'),
                            child: Text(l10n.routerOpenDashboard),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );

  ref.onDispose(() {
    authStateListenable.dispose();
    router.dispose();
  });

  return router;
});

// touch
