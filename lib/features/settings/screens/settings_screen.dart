import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/theme_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/breakpoints.dart';
import 'package:hub_aura/l10n/app_localizations.dart';
import '../../../shared/widgets/developer_panels.dart';
import '../../../shared/widgets/terminal_page_layout.dart';
import '../../../shared/widgets/terminal_widgets.dart';
import '../providers/settings_provider.dart';

part '../widgets/settings_screen_widgets.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameCtrl = TextEditingController();
  bool _saving = false;
  bool _nameHydrated = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final l10n = AppLocalizations.of(context)!;
    final displayName = _nameCtrl.text.trim();
    if (displayName.isEmpty) return;

    setState(() => _saving = true);
    final ext = AuralixThemeExtension.of(context);

    try {
      final res = await ApiClient.instance.put(
        '/hub/user/profile',
        data: {'displayName': displayName},
      );
      if (!mounted) return;

      if (res.data['status'] == true) {
        ref.invalidate(settingsAuthProvider);
        _showTerminalToast(context, ext, l10n.settingsProfileSaved);
      } else {
        _showTerminalToast(
            context, ext, res.data['msg'] ?? l10n.settingsProfileSaveError,
            error: true);
      }
    } catch (_) {
      if (!mounted) return;
      _showTerminalToast(context, ext, l10n.settingsProfileTimeout,
          error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showTerminalToast(
      BuildContext context, AuralixThemeExtension ext, String message,
      {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: ext.surfaceVariant,
            border: Border.all(color: error ? ext.error : ext.success),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: (error ? ext.error : ext.success).withValues(alpha: 0.2),
                blurRadius: 10,
                spreadRadius: 1,
              )
            ],
          ),
          child: Row(
            children: [
              Icon(error ? Icons.warning_amber : Icons.check_circle_outline,
                  color: error ? ext.error : ext.success, size: 16),
              const SizedBox(width: 8),
              Expanded(
                  child: Text('> $message',
                      style: TextStyle(
                          color: ext.text,
                          fontSize: 12,
                          fontFamily: 'JetBrainsMono',
                          fontWeight: FontWeight.bold))),
            ],
          ),
        ),
      ),
    );
  }

  String _variantName(AppThemeVariant v) => switch (v) {
        AppThemeVariant.neutralDark => AppColors.variantLabel(v),
        AppThemeVariant.cyberGreen => AppColors.variantLabel(v),
        AppThemeVariant.oceanBlue => AppColors.variantLabel(v),
        AppThemeVariant.neoViolet => AppColors.variantLabel(v),
      };

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(settingsAuthProvider).valueOrNull;
    final currentVariant = ref.watch(settingsThemeProvider);
    final currentLocale = ref.watch(settingsLocaleProvider);
    final languageSelection = currentLocale?.languageCode ?? 'system';
    final hPadding = context.pageHorizontalPadding;

    if (user != null && !_nameHydrated) {
      _nameCtrl.text = user.displayName ?? '';
      _nameHydrated = true;
    }
    if (user == null) {
      _nameHydrated = false;
    }

    return Scaffold(
      backgroundColor: ext.bg,
      body: Stack(
        children: [
          // Cyberpunk Background Glow
          Positioned(
            bottom: -150,
            right: -100,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ext.accent.withValues(alpha: 0.08),
                    ext.bg.withValues(alpha: 0.0)
                  ],
                  stops: const [0.1, 1.0],
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fade(
                    duration: const Duration(seconds: 8), begin: 0.5, end: 1.0)
                .scale(
                    begin: const Offset(0.95, 0.95),
                    end: const Offset(1.05, 1.05)),
          ),

          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: context.pageMaxWidth),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(hPadding, 20, hPadding, 60),
                child: TerminalPageReveal(
                  animationKey: 'settings-main',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TerminalPageHeader(
                        title: l10n.navSettings.toLowerCase(),
                        subtitle: l10n.settingsPageSubtitle,
                        actions: const [
                          StatusBadge(code: 200, message: 'SYS_CFG_READY')
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Profile section
                      _HoverSettingsSection(
                        title: l10n.settingsOperatorProfileTitle,
                        icon: Icons.api_outlined,
                        delay: const Duration(milliseconds: 100),
                        children: [
                          if (user != null) ...[
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color:
                                            ext.primary.withValues(alpha: 0.5),
                                        width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                          color: ext.primary
                                              .withValues(alpha: 0.2),
                                          blurRadius: 10)
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 28,
                                    backgroundColor: ext.surfaceVariant,
                                    child: Text(
                                      user.email[0].toUpperCase(),
                                      style: TextStyle(
                                          color: ext.primary,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'JetBrainsMono'),
                                    ),
                                  ),
                                )
                                    .animate(
                                        onPlay: (c) => c.repeat(reverse: true))
                                    .shimmer(
                                        duration: const Duration(seconds: 2),
                                        color:
                                            ext.primary.withValues(alpha: 0.3)),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.email,
                                        style: TextStyle(
                                            color: ext.text,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'JetBrainsMono'),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                              user.emailVerified
                                                  ? Icons.verified_user
                                                  : Icons.gpp_maybe,
                                              size: 14,
                                              color: user.emailVerified
                                                  ? ext.success
                                                  : ext.warning),
                                          const SizedBox(width: 6),
                                          Text(
                                            user.emailVerified
                                                ? l10n.settingsEmailVerified
                                                : l10n.settingsEmailNotVerified,
                                            style: TextStyle(
                                                color: user.emailVerified
                                                    ? ext.success
                                                    : ext.warning,
                                                fontSize: 10,
                                                fontFamily: 'JetBrainsMono',
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Divider(
                                color: ext.border.withValues(alpha: 0.5),
                                height: 1),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Icon(Icons.badge_outlined,
                                    size: 14, color: ext.textMuted),
                                const SizedBox(width: 8),
                                Text(l10n.settingsPublicAlias,
                                    style: TextStyle(
                                        color: ext.textMuted,
                                        fontSize: 11,
                                        fontFamily: 'JetBrainsMono')),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TerminalInput(
                              controller: _nameCtrl,
                              hint: l10n.settingsAliasHint,
                              prefix: l10n.settingsAliasPrefix,
                            ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    if (_saving)
                                      BoxShadow(
                                          color: ext.primary
                                              .withValues(alpha: 0.3),
                                          blurRadius: 10)
                                  ],
                                ),
                                child: OutlinedButton(
                                  onPressed: _saving ? null : _saveProfile,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: ext.primary,
                                    side: BorderSide(
                                        color:
                                            ext.primary.withValues(alpha: 0.5)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                  ),
                                  child: _saving
                                      ? SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: ext.primary))
                                      : Text(l10n.settingsUpdateProfile,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'JetBrainsMono',
                                              fontSize: 12)),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Theme picker
                      _HoverSettingsSection(
                        title: l10n.settingsThemeMatrixTitle,
                        icon: Icons.color_lens_outlined,
                        delay: const Duration(milliseconds: 200),
                        children: [
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: AppThemeVariant.values.map((v) {
                              final c = AppColors.fromVariant(v);
                              final selected = currentVariant == v;
                              return GestureDetector(
                                onTap: () => ref
                                    .read(settingsThemeProvider.notifier)
                                    .setTheme(v),
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOutCubic,
                                    padding: const EdgeInsets.all(16),
                                    width: context.isMobile
                                        ? double.infinity
                                        : 160,
                                    constraints: context.isMobile
                                        ? const BoxConstraints(maxWidth: 250)
                                        : null,
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? c.primary.withValues(alpha: 0.05)
                                          : c.background,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: selected
                                              ? c.primary
                                              : c.border.withValues(alpha: 0.5),
                                          width: selected ? 2 : 1),
                                      boxShadow: selected
                                          ? [
                                              BoxShadow(
                                                  color: c.primary
                                                      .withValues(alpha: 0.2),
                                                  blurRadius: 15)
                                            ]
                                          : [],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            _ColorDot(c.primary),
                                            const SizedBox(width: 6),
                                            _ColorDot(c.secondary),
                                            const SizedBox(width: 6),
                                            _ColorDot(c.accent),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          _variantName(v).toUpperCase(),
                                          style: TextStyle(
                                              color:
                                                  selected ? c.primary : c.text,
                                              fontSize: 13,
                                              fontFamily: 'JetBrainsMono',
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        if (selected)
                                          Text(
                                            l10n.settingsThemeActive,
                                            style: TextStyle(
                                                color: c.primary,
                                                fontSize: 10,
                                                fontFamily: 'JetBrainsMono',
                                                fontWeight: FontWeight.bold),
                                          )
                                              .animate(
                                                  onPlay: (ct) =>
                                                      ct.repeat(reverse: true))
                                              .fade(
                                                  duration: const Duration(
                                                      milliseconds: 1500),
                                                  begin: 0.5,
                                                  end: 1.0)
                                        else
                                          Text(
                                            l10n.settingsThemeInactive,
                                            style: TextStyle(
                                                color: c.textMuted,
                                                fontSize: 10,
                                                fontFamily: 'JetBrainsMono'),
                                          ),
                                      ],
                                    ),
                                  ).animate(target: selected ? 1 : 0).scale(
                                      begin: const Offset(1, 1),
                                      end: const Offset(1.03, 1.03)),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Language Section
                      _HoverSettingsSection(
                        title: l10n.languageLabel.toUpperCase(),
                        icon: Icons.language_rounded,
                        delay: const Duration(milliseconds: 300),
                        children: [
                          Row(
                            children: [
                              Icon(Icons.terminal,
                                  size: 14, color: ext.textMuted),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  l10n.settingsLocaleAutoLabel.toUpperCase(),
                                  style: TextStyle(
                                    color: ext.textMuted,
                                    fontSize: 11,
                                    fontFamily: 'JetBrainsMono',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: ext.bg,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: ext.border),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: languageSelection,
                                dropdownColor: ext.surfaceVariant,
                                icon: Icon(Icons.arrow_drop_down,
                                    color: ext.primary),
                                style: TextStyle(
                                    color: ext.text,
                                    fontSize: 13,
                                    fontFamily: 'JetBrainsMono',
                                    fontWeight: FontWeight.bold),
                                items: [
                                  DropdownMenuItem(
                                      value: 'system',
                                      child: Text(
                                          '> ${l10n.languageSystem.toUpperCase()}')),
                                  DropdownMenuItem(
                                      value: 'es',
                                      child: Text(
                                          '> ${l10n.languageSpanish.toUpperCase()}')),
                                  DropdownMenuItem(
                                      value: 'en',
                                      child: Text(
                                          '> ${l10n.languageEnglish.toUpperCase()}')),
                                ],
                                onChanged: (value) {
                                  if (value == null) return;
                                  if (value == 'system') {
                                    ref
                                        .read(settingsLocaleProvider.notifier)
                                        .setLocale(null);
                                    return;
                                  }
                                  ref
                                      .read(settingsLocaleProvider.notifier)
                                      .setLocale(Locale(value));
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: Text(
                              '// ${l10n.layoutResponsiveSubtitle} (${languageSelection == 'system' ? l10n.languageSystem : languageSelection.toUpperCase()})',
                              key: ValueKey(languageSelection),
                              style: TextStyle(
                                  color: ext.textMuted,
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  fontFamily: 'JetBrainsMono'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      _HoverSettingsSection(
                        title: l10n.settingsDesignTokensTitle,
                        icon: Icons.code,
                        delay: const Duration(milliseconds: 400),
                        children: const [
                          DesignTokensPanel(),
                        ],
                      ),
                      const SizedBox(height: 20),

                      _HoverSettingsSection(
                        title: l10n.settingsApiCredentialsTitle,
                        icon: Icons.vpn_key_outlined,
                        delay: const Duration(milliseconds: 500),
                        children: [
                          ApiCredentialsPanel(
                            title: l10n.settingsSessionTokenPanelTitle,
                            method: 'GET',
                            endpoint: '/hub/auth/me',
                            requiresAuth: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Danger zone
                      _HoverSettingsSection(
                        title: l10n.settingsCriticalDirectivesTitle,
                        icon: Icons.warning_amber_rounded,
                        delay: const Duration(milliseconds: 600),
                        danger: true,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: ext.error.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: ext.error.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.settingsTerminateSessionTitle,
                                        style: TextStyle(
                                            color: ext.error,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'JetBrainsMono'),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        l10n.settingsTerminateSessionDescription,
                                        style: TextStyle(
                                            color: ext.textMuted,
                                            fontSize: 11,
                                            fontFamily: 'JetBrainsMono'),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                OutlinedButton.icon(
                                  onPressed: () => ref
                                      .read(settingsAuthProvider.notifier)
                                      .logout(),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: ext.error,
                                    side: BorderSide(
                                        color:
                                            ext.error.withValues(alpha: 0.5)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                  ),
                                  icon: const Icon(Icons.power_settings_new,
                                      size: 16),
                                  label: Text(l10n.settingsPurgeButton,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'JetBrainsMono',
                                          fontSize: 12)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Center(
                        child: Text(
                          l10n.authVersionLabel,
                          style: TextStyle(
                              color: ext.textMuted.withValues(alpha: 0.5),
                              fontFamily: 'JetBrainsMono',
                              fontSize: 10),
                        ),
                      ),
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
