import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_client.dart';
import '../../../core/services/service_catalog.dart';
import '../../../core/theme/theme_extension.dart';
import '../../../core/ui/breakpoints.dart';
import '../../../shared/widgets/terminal_card.dart';
import '../../../shared/widgets/terminal_page_layout.dart';
import '../../../shared/widgets/terminal_widgets.dart';
import '../providers/landing_provider.dart';

part '../widgets/landing_screen_widgets.dart';

class LandingScreen extends ConsumerWidget {
  const LandingScreen({super.key});

  Stream<String> _simulateConsoleResponse(String response) async* {
    yield 'Resolving auralix-hub.local... OK\n';
    await Future.delayed(200.ms);
    yield 'Connecting to API Gateway... 200 OK\n';
    await Future.delayed(400.ms);
    yield 'Fetching service catalog...\n';
    await Future.delayed(300.ms);
    yield '$response\n';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ext = AuralixThemeExtension.of(context);
    final catalogState = ref.watch(landingServiceCatalogProvider);
    final catalog = catalogState.valueOrNull;
    final services = catalog?.services ?? const <ApiServiceMetadata>[];
    final isCompact = context.isMobile || context.isTablet;
    final hPadding = context.pageHorizontalPadding;
    final maxWidth = context.pageMaxWidth;

    final sample = services.isNotEmpty ? services.first : null;
    final sampleMethod = sample?.method ?? 'GET';
    final sampleEndpoint = sample?.endpoint ?? '/hub/search/food';
    final sampleResponse = sample?.responseExample.trim().isNotEmpty == true
        ? sample!.responseExample
        : '{\n  "status": true,\n  "data": {}\n}';
    final sampleCommand = sample?.requiresAuth == true
        ? '> curl -X $sampleMethod ${ApiClient.buildAbsoluteUrl(sampleEndpoint)} -H "Authorization: Bearer <token>"'
        : '> curl -X $sampleMethod ${ApiClient.buildAbsoluteUrl(sampleEndpoint)}';

    final featured = services.take(isCompact ? 4 : 8).toList();

    return Scaffold(
      backgroundColor: ext.bg,
      body: Stack(
        children: [
          // Cyberpunk Background Elements
          Positioned(
            top: -200,
            left: -150,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ext.primary.withValues(alpha: 0.08),
                    ext.bg.withValues(alpha: 0.0)
                  ],
                  stops: const [0.1, 1.0],
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fade(duration: 5.seconds, begin: 0.5, end: 1.0)
                .scale(
                    begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1)),
          ),
          Positioned(
            bottom: -150,
            right: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ext.accent.withValues(alpha: 0.05),
                    ext.bg.withValues(alpha: 0.0)
                  ],
                  stops: const [0.1, 1.0],
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fade(duration: 7.seconds, begin: 0.4, end: 1.0),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(hPadding, 20, hPadding, 24),
                  child: TerminalPageReveal(
                    animationKey: 'landing-main',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hub Header Identity
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: ext.bg,
                                border:
                                    Border.all(color: ext.primary, width: 2),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                      color: ext.primary.withValues(alpha: 0.3),
                                      blurRadius: 15)
                                ],
                              ),
                              child: Text('A',
                                  style: TextStyle(
                                      color: ext.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      fontFamily: 'JetBrainsMono')),
                            )
                                .animate(onPlay: (c) => c.repeat(reverse: true))
                                .shimmer(
                                    duration: 3.seconds,
                                    color: ext.primary.withValues(alpha: 0.5)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'AURALIX HUB',
                                    style: TextStyle(
                                        color: ext.text,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'JetBrainsMono',
                                        letterSpacing: 1.5),
                                  ),
                                  Text(
                                    'API Workspace Â· Docs Â· Sandbox Â· Monitoring',
                                    style: TextStyle(
                                        color: ext.textMuted,
                                        fontSize: 12,
                                        fontFamily: 'JetBrainsMono'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: -0.1),
                        const SizedBox(height: 24),

                        // Status Bar
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: ext.surfaceVariant.withValues(alpha: 0.7),
                            border: Border.all(color: ext.border),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  StatusBadge(
                                    code: catalogState.hasError
                                        ? 503
                                        : (catalogState.isLoading ? 102 : 200),
                                    message: catalogState.hasError
                                        ? 'CATALOG_OFFLINE'
                                        : (catalogState.isLoading
                                            ? 'LOADING_CATALOG'
                                            : 'SYSTEM_ONLINE'),
                                  ),
                                  if (services.isNotEmpty)
                                    StatusBadge(
                                        code: 200,
                                        message:
                                            '${services.length}_SERVICES_ACTIVE'),
                                ],
                              ),
                              Icon(Icons.wifi,
                                      color: catalogState.hasError
                                          ? ext.error
                                          : ext.success,
                                      size: 16)
                                  .animate(
                                      onPlay: (c) => c.repeat(reverse: true))
                                  .fade(duration: 1.seconds),
                            ],
                          ),
                        ).animate().fadeIn(delay: 200.ms),
                        const SizedBox(height: 32),

                        // Hero Section
                        if (isCompact)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _HoverLandingCard(
                                ext: ext,
                                child: _LandingHeroCopy(
                                    serviceCount: services.length,
                                    categoryCount:
                                        catalog?.categories.length ?? 0),
                              )
                                  .animate()
                                  .fadeIn(delay: 300.ms)
                                  .slideX(begin: -0.05),
                              const SizedBox(height: 16),
                              _HoverActionPanel(ext: ext)
                                  .animate()
                                  .fadeIn(delay: 400.ms),
                              const SizedBox(height: 16),
                              TerminalCard(
                                command: sampleCommand,
                                responseStream: () =>
                                    _simulateConsoleResponse(sampleResponse),
                                statusCode: 200,
                                height: 320,
                              )
                                  .animate()
                                  .fadeIn(delay: 500.ms)
                                  .slideY(begin: 0.1),
                            ],
                          )
                        else
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 6,
                                child: Column(
                                  children: [
                                    _HoverLandingCard(
                                      ext: ext,
                                      child: _LandingHeroCopy(
                                          serviceCount: services.length,
                                          categoryCount:
                                              catalog?.categories.length ?? 0),
                                    )
                                        .animate()
                                        .fadeIn(delay: 300.ms)
                                        .slideX(begin: -0.05),
                                    const SizedBox(height: 24),
                                    _HoverActionPanel(ext: ext)
                                        .animate()
                                        .fadeIn(delay: 400.ms)
                                        .slideX(begin: -0.05),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 5,
                                child: TerminalCard(
                                  command: sampleCommand,
                                  responseStream: () =>
                                      _simulateConsoleResponse(sampleResponse),
                                  statusCode: 200,
                                  height: 380,
                                )
                                    .animate()
                                    .fadeIn(delay: 500.ms)
                                    .slideY(begin: 0.1),
                              ),
                            ],
                          ),

                        const SizedBox(height: 48),

                        // Pipeline / Flow
                        _LandingSectionMatrix(
                          title: 'RECOMMENDED_PIPELINE',
                          ext: ext,
                          child: const Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _CyberStep(step: '01', label: 'AUTH_INIT'),
                              _CyberStep(step: '02', label: 'EXPLORE_DOCS'),
                              _CyberStep(step: '03', label: 'EXEC_SANDBOX'),
                              _CyberStep(step: '04', label: 'INTEGRATE'),
                            ],
                          ),
                        ).animate().fadeIn(delay: 600.ms),
                        const SizedBox(height: 24),

                        // Capabilities Array
                        _LandingSectionMatrix(
                          title: 'SYSTEM_CAPABILITIES',
                          ext: ext,
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _CyberFeature(
                                  icon: Icons.code,
                                  title: 'DYNAMIC_DOCS',
                                  text:
                                      'Real-time parameters, schemas & valid auth HTTP targets.',
                                  ext: ext),
                              _CyberFeature(
                                  icon: Icons.terminal,
                                  title: 'LIVE_SANDBOX',
                                  text:
                                      'Execute direct requests with full terminal I/O feedback.',
                                  ext: ext),
                              _CyberFeature(
                                  icon: Icons.analytics,
                                  title: 'AUDIT_LOGS',
                                  text:
                                      'Granular visibility on usage, success rates, and latency.',
                                  ext: ext),
                            ],
                          ),
                        ).animate().fadeIn(delay: 700.ms),
                        const SizedBox(height: 32),

                        // Available Services Grid
                        if (services.isNotEmpty)
                          _LandingSectionMatrix(
                            title: 'AVAILABLE_ENDPOINTS',
                            ext: ext,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: featured
                                  .map((s) =>
                                      _HoverEndpointChip(service: s, ext: ext))
                                  .toList(),
                            ),
                          ).animate().fadeIn(delay: 800.ms),

                        const SizedBox(height: 64),

                        // Cyber Footer
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 24, horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border(top: BorderSide(color: ext.border)),
                          ),
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            runSpacing: 16,
                            children: [
                              Text('Â© 2026 AURALIX_SYSTEMS',
                                  style: TextStyle(
                                      color: ext.textMuted,
                                      fontSize: 11,
                                      fontFamily: 'JetBrainsMono')),
                              Wrap(
                                spacing: 16,
                                runSpacing: 8,
                                children: [
                                  _CyberFooterLink(
                                      label: 'LOGIN',
                                      target: '/login',
                                      ext: ext),
                                  _CyberFooterLink(
                                      label: 'REGISTER',
                                      target: '/register',
                                      ext: ext),
                                  _CyberFooterLink(
                                      label: 'TERMS',
                                      target: '/terms',
                                      ext: ext),
                                  _CyberFooterLink(
                                      label: 'PRIVACY',
                                      target: '/privacy',
                                      ext: ext),
                                ],
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 900.ms),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
