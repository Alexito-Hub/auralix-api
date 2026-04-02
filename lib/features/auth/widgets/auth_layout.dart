import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hub_aura/l10n/app_localizations.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/theme_extension.dart';
import '../../../core/ui/breakpoints.dart';
import '../../../shared/widgets/terminal_page_layout.dart';
import '../../../shared/widgets/terminal_widgets.dart';

class AuthLayout extends StatelessWidget {
  final String title;
  final Widget child;

  const AuthLayout({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isWide = context.isDesktop;
    final cardPadding =
        context.isMobile ? 16.0 : (context.isTablet ? 24.0 : 32.0);

    return Scaffold(
      backgroundColor: ext.bg,
      body: Stack(
        children: [
          // Cyberpunk Background Glow
          Positioned(
            top: -150,
            right: isWide ? -100 : null,
            left: isWide ? null : -150,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ext.primary.withValues(alpha: 0.1),
                    ext.bg.withValues(alpha: 0.0)
                  ],
                  stops: const [0.1, 1.0],
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fade(duration: 8.seconds, begin: 0.6, end: 1.0)
                .scale(
                    begin: const Offset(0.95, 0.95),
                    end: const Offset(1.05, 1.05)),
          ),
          SafeArea(
            child: Row(
              children: [
                if (isWide)
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: ext.surface,
                        border: Border(right: BorderSide(color: ext.border)),
                      ),
                      child: _TerminalSplash(ext: ext, l10n: l10n),
                    ),
                  ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(cardPadding),
                        child: TerminalPageReveal(
                          animationKey: 'auth-layout',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _AuthHeader(title: title, ext: ext)
                                  .animate()
                                  .fadeIn(duration: 400.ms)
                                  .slideY(begin: -0.1),
                              const SizedBox(height: 24),
                              _HoverAuthCard(child: child)
                                  .animate()
                                  .fadeIn(duration: 500.ms, delay: 100.ms)
                                  .slideY(begin: 0.05),
                              const SizedBox(height: 24),
                              Center(
                                child: Text(l10n.authVersionLabel,
                                    style: TextStyle(
                                        color: ext.textMuted
                                            .withValues(alpha: 0.5),
                                        fontFamily: 'JetBrainsMono',
                                        fontSize: 10)),
                              ).animate().fadeIn(delay: 300.ms),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthHeader extends StatelessWidget {
  final String title;
  final AuralixThemeExtension ext;

  const _AuthHeader({required this.title, required this.ext});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ext.surfaceVariant.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ext.border),
        boxShadow: [
          BoxShadow(color: ext.primary.withValues(alpha: 0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: ext.bg,
                  border: Border.all(color: ext.primary, width: 2),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: ext.primary.withValues(alpha: 0.3),
                        blurRadius: 15)
                  ],
                ),
                child: Center(
                  child: Text('A',
                      style: TextStyle(
                          color: ext.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                          fontFamily: 'JetBrainsMono')),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(
                  duration: 3.seconds,
                  color: ext.primary.withValues(alpha: 0.5)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.appTitle,
                      style: TextStyle(
                          color: ext.text,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'JetBrainsMono')),
                  const SizedBox(height: 2),
                  Text(title,
                      style: TextStyle(
                          color: ext.textMuted,
                          fontSize: 12,
                          fontFamily: 'JetBrainsMono')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: ext.border.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              StatusBadge(code: 200, message: l10n.authSecureAccessStatus),
              StatusBadge(code: 200, message: l10n.authCaptchaEnabledStatus),
            ],
          ),
        ],
      ),
    );
  }
}

class _HoverAuthCard extends StatefulWidget {
  final Widget child;
  const _HoverAuthCard({required this.child});

  @override
  State<_HoverAuthCard> createState() => _HoverAuthCardState();
}

class _HoverAuthCardState extends State<_HoverAuthCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: 250.ms,
        curve: Curves.easeOutCubic,
        transform: _hovering
            ? Matrix4.translationValues(0, -4, 0)
            : Matrix4.identity(),
        width: double.infinity,
        padding: EdgeInsets.all(context.isMobile ? 18 : 28),
        decoration: BoxDecoration(
          color: ext.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color:
                  _hovering ? ext.primary.withValues(alpha: 0.4) : ext.border),
          boxShadow: [
            BoxShadow(
                color: ext.primary.withValues(alpha: _hovering ? 0.15 : 0.05),
                blurRadius: _hovering ? 25 : 10,
                spreadRadius: _hovering ? 2 : 0)
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

class _TerminalSplash extends StatelessWidget {
  final AuralixThemeExtension ext;
  final AppLocalizations l10n;

  const _TerminalSplash({required this.ext, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final apiAuthority = ApiClient.baseAuthority;
    final lines = [
      (ext.primary, '  ___                  _ _       '),
      (ext.primary, ' / _ \\                | (_)      '),
      (ext.primary, '/ /_\\ \\_   _ _ __ __ _| |___  __ '),
      (ext.primary, '|  _  | | | | \'__/ _` | | \\ \\/ /'),
      (ext.primary, '| | | | |_| | | | (_| | | |>  < '),
      (ext.primary, '\\_| |_/\\__,_|_|  \\__,_|_|_/_/\\_\\'),
      (ext.textMuted, ''),
      (ext.textMuted, '  ${l10n.authSplashVersionLine(apiAuthority)}'),
      (ext.textMuted, ''),
      (ext.success, '  [+] ${l10n.authSplashCoreReady}'),
      (ext.success, '  [+] ${l10n.authSplashSocketReady}'),
      (ext.warning, '  [*] ${l10n.authSplashWaitingAuth}'),
      (ext.accentAlt, '  ${l10n.authSplashStartCommand}'),
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: lines
              .asMap()
              .entries
              .map((e) => Text(
                    e.value.$2,
                    style: TextStyle(
                        color: e.value.$1,
                        fontSize: 14,
                        fontFamily: 'JetBrainsMono',
                        height: 1.6,
                        fontWeight: e.value.$1 == ext.primary
                            ? FontWeight.bold
                            : FontWeight.normal),
                  )
                      .animate(delay: (e.key * 80).ms)
                      .fadeIn(duration: 400.ms)
                      .slideX(begin: -0.05))
              .toList(),
        ),
      ),
    );
  }
}
