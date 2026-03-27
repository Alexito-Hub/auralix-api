import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/verify_email_screen.dart';
import '../../features/landing/screens/landing_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
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

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuth = authState.valueOrNull != null;

      final isPublicRoute = state.matchedLocation == '/' ||
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/terms' ||
          state.matchedLocation == '/privacy' ||
          state.matchedLocation == '/usage' ||
          state.matchedLocation.startsWith('/verify-email') ||
          state.uri.path.startsWith('/s/');

      if (!isAuth && !isPublicRoute) {
        return '/login';
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
      GoRoute(path: '/', builder: (_, __) => const LandingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: '/verify-email',
        builder: (_, state) =>
            VerifyEmailScreen(token: state.uri.queryParameters['token']),
      ),

      // --- Public snippet viewer ---
      GoRoute(
        path: '/s/:id',
        builder: (_, state) =>
            SnippetDetailScreen(id: state.pathParameters['id']!),
      ),

      // --- Legal pages (public) ---
      GoRoute(
        path: '/terms',
        builder: (_, __) => const LegalScreen(page: LegalPage.terms),
      ),
      GoRoute(
        path: '/privacy',
        builder: (_, __) => const LegalScreen(page: LegalPage.privacy),
      ),
      GoRoute(
        path: '/usage',
        builder: (_, __) => const LegalScreen(page: LegalPage.usage),
      ),

      // --- Authenticated shell with side nav ---
      ShellRoute(
        builder: (_, __, child) => AppShell(child: child),
        routes: [
          GoRoute(
              path: '/dashboard', builder: (_, __) => const DashboardScreen()),
          GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
          GoRoute(path: '/docs', builder: (_, __) => const DocsScreen()),
          GoRoute(
              path: '/docs/:apiId',
              builder: (_, state) =>
                  DocsScreen(apiId: state.pathParameters['apiId'])),
          GoRoute(
            path: '/sandbox',
            builder: (_, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return SandboxScreen(
                prefilledPath: extra?['path'] as String?,
                prefilledBody: extra?['body'] as String?,
                prefilledMethod: extra?['method'] as String?,
              );
            },
          ),
          GoRoute(
              path: '/snippets', builder: (_, __) => const SnippetsScreen()),
          GoRoute(path: '/billing', builder: (_, __) => const BillingScreen()),
          GoRoute(
              path: '/settings', builder: (_, __) => const SettingsScreen()),
        ],
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(
        child: Text('404 — ${state.error}',
            style: const TextStyle(color: Colors.white)),
      ),
    ),
  );
});
