import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/theme_extension.dart';

class AuthLayout extends StatelessWidget {
  final String title;
  final Widget child;

  const AuthLayout({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: ext.bg,
      body: Row(
        children: [
          if (isWide)
            Expanded(
              child: Container(
                color: ext.surface,
                child: _TerminalSplash(ext: ext),
              ),
            ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      // Brand
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              border: Border.all(color: ext.primary, width: 2),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [BoxShadow(color: ext.glow, blurRadius: 14)],
                            ),
                            child: Center(
                              child: Text('A', style: TextStyle(color: ext.primary, fontWeight: FontWeight.bold, fontSize: 22)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Auralix Hub', style: TextStyle(color: ext.text, fontSize: 20, fontWeight: FontWeight.bold)),
                              Text(title, style: TextStyle(color: ext.textMuted, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      child,
                    ],
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

class _TerminalSplash extends StatelessWidget {
  final AuralixThemeExtension ext;
  const _TerminalSplash({required this.ext});

  @override
  Widget build(BuildContext context) {
    final lines = [
      (ext.primary, '  ___                  _ _       '),
      (ext.primary, ' / _ \\                | (_)      '),
      (ext.primary, '/ /_\\ \\_   _ _ __ __ _| |___  __ '),
      (ext.primary, '|  _  | | | | \'__/ _` | | \\ \\/ /'),
      (ext.primary, '| | | | |_| | | | (_| | | |>  < '),
      (ext.primary, '\\_| |_/\\__,_|_|  \\__,_|_|_/_/\\_\\'),
      (ext.textMuted, ''),
      (ext.textMuted, '  Hub v1.0.0 · api.auralixpe.xyz'),
      (ext.textMuted, ''),
      (ext.terminalGreen, '  [+] MongoDB connected'),
      (ext.terminalGreen, '  [+] SQLite initialized'),
      (ext.terminalGreen, '  [+] WebSocket ready'),
      (ext.accentAlt, r'  $ ready to serve requests'),
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
                    style: TextStyle(color: e.value.$1, fontSize: 13, fontFamily: 'monospace', height: 1.5),
                  )
                      .animate(delay: (e.key * 80).ms)
                      .fadeIn(duration: 300.ms)
                      .slideX(begin: -0.05))
              .toList(),
        ),
      ),
    );
  }
}
