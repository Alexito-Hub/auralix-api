import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/terminal_card.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF071427),
              Color(0xFF081926),
              Color(0xFF05222A),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(12),
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Auralix Hub',
                                style: GoogleFonts.jetBrainsMono(
                                    textStyle: theme.textTheme.displaySmall
                                        ?.copyWith(
                                            color: const Color(0xFF5EE0FF)))),
                            const Gap(8),
                            Text('APIs · Sandbox · Snippets',
                                style: GoogleFonts.inter(
                                    textStyle: theme.textTheme.titleMedium
                                        ?.copyWith(
                                            color: const Color(0xFF9AA7B2)))),
                          ],
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () => context.go('/login'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00F0FF)),
                              child: const Text('Iniciar sesión',
                                  style: TextStyle(color: Colors.black)),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: () => context.go('/register'),
                              style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Color(0xFF5EE0FF))),
                              child: const Text('Registrarse'),
                            ),
                          ],
                        )
                      ],
                    ),
                    const Gap(28),

                    // Hero + terminal
                    Expanded(
                      child: Row(
                        children: [
                          // Left - text
                          Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Integración rápida. Resultados reales.',
                                    style: GoogleFonts.jetBrainsMono(
                                        textStyle: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700))),
                                const Gap(12),
                                Text(
                                    'Prueba nuestras APIs desde un sandbox interactivo. Documentación técnica y ejemplos listos para usar.',
                                    style: GoogleFonts.inter(
                                        textStyle: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                                color:
                                                    const Color(0xFF9AA7B2)))),
                                const Gap(20),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => context.go('/docs'),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF00F0FF)),
                                      child: const Text('Ver documentación',
                                          style:
                                              TextStyle(color: Colors.black)),
                                    ),
                                    const SizedBox(width: 12),
                                    OutlinedButton(
                                      onPressed: () => context.go('/sandbox'),
                                      style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                              color: Color(0xFF5EE0FF))),
                                      child: const Text('Probar sandbox'),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),

                          const SizedBox(width: 24),

                          // Right - TerminalCard
                          const Expanded(
                            flex: 5,
                            child: TerminalCard(
                              command:
                                  '> curl https://api.auralixpe.xyz/curp?dni=XXXX',
                              statusCode: 200,
                              height: 320,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
