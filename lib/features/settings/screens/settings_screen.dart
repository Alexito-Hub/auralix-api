import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/theme_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
// removed unused import
import '../../../shared/widgets/terminal_widgets.dart';
import '../../auth/providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameCtrl = TextEditingController();
  final bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final user = ref.watch(authProvider).valueOrNull;
    final currentVariant = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: ext.bg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text('\$ ', style: TextStyle(color: ext.primary, fontSize: 13)),
              Text('settings', style: TextStyle(color: ext.text, fontSize: 20, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 4),
            Text('Personaliza tu experiencia', style: TextStyle(color: ext.textMuted, fontSize: 12)),
            const SizedBox(height: 24),

            // Profile section
            _SettingsSection(
              title: 'Perfil',
              icon: Icons.person_outline,
              children: [
                if (user != null) ...[
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: ext.primary.withValues(alpha: 0.2),
                        child: Text(user.email[0].toUpperCase(),
                            style: TextStyle(color: ext.primary, fontSize: 22, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.email, style: TextStyle(color: ext.text, fontSize: 14, fontWeight: FontWeight.w600)),
                            Row(children: [
                              Icon(
                                user.emailVerified ? Icons.verified : Icons.warning_amber,
                                size: 12,
                                color: user.emailVerified ? ext.success : ext.warning,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                user.emailVerified ? 'Email verificado' : 'Email no verificado',
                                style: TextStyle(color: user.emailVerified ? ext.success : ext.warning, fontSize: 11),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TerminalInput(
                    controller: _nameCtrl..text = user.displayName ?? '',
                    hint: 'Tu nombre',
                    prefix: 'name:',
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: _saving ? null : () => _saveProfile(user.email),
                      child: const Text('Guardar cambios'),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),

            // Theme picker
            _SettingsSection(
              title: 'Tema del terminal',
              icon: Icons.palette_outlined,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: AppThemeVariant.values.map((v) {
                    final c = AppColors.fromVariant(v);
                    final selected = currentVariant == v;
                    return GestureDetector(
                      onTap: () => ref.read(themeProvider.notifier).setTheme(v),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(12),
                        width: 140,
                        decoration: BoxDecoration(
                          color: c.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selected ? c.primary : c.border,
                            width: selected ? 2 : 1,
                          ),
                          boxShadow: selected ? [BoxShadow(color: c.glow, blurRadius: 10)] : [],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(width: 10, height: 10, decoration: BoxDecoration(color: c.primary, shape: BoxShape.circle)),
                                const SizedBox(width: 4),
                                Container(width: 10, height: 10, decoration: BoxDecoration(color: c.secondary, shape: BoxShape.circle)),
                                const SizedBox(width: 4),
                                Container(width: 10, height: 10, decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(_variantName(v), style: TextStyle(color: c.text, fontSize: 12, fontWeight: FontWeight.w600)),
                            if (selected)
                              Text('[Activo]', style: TextStyle(color: c.primary, fontSize: 10)),
                          ],
                        ),
                      ).animate(target: selected ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.02, 1.02)),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Danger zone
            _SettingsSection(
              title: 'Zona de peligro',
              icon: Icons.warning_amber_outlined,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Cerrar sesión', style: TextStyle(color: ext.text, fontSize: 14, fontWeight: FontWeight.w600)),
                          Text('Cierra tu sesión en todos los dispositivos', style: TextStyle(color: ext.textMuted, fontSize: 12)),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () => ref.read(authProvider.notifier).logout(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ext.error,
                        side: BorderSide(color: ext.error.withValues(alpha: 0.5)),
                      ),
                      child: const Text('Cerrar sesión'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile(String email) async {
    // TODO: call PUT /api/hub/user/profile
  }

  String _variantName(AppThemeVariant v) => switch (v) {
    AppThemeVariant.tokyoNight => 'Tokyo Night',
    AppThemeVariant.dracula => 'Dracula',
    AppThemeVariant.nord => 'Nord',
    AppThemeVariant.monokaiPro => 'Monokai Pro',
    AppThemeVariant.auralixDefault => 'Auralix',
  };
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    return GlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 16, color: ext.primary),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(color: ext.text, fontSize: 15, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
