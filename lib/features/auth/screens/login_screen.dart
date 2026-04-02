import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hub_aura/l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../../../shared/widgets/terminal_widgets.dart';
import '../../../core/theme/theme_extension.dart';
import '../widgets/captcha_widget.dart';
import '../widgets/auth_layout.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? _captchaToken;
  int _captchaVersion = 0;
  String? _error;
  bool _loading = false;
  bool _showPass = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;
    if (_captchaToken == null) {
      setState(() => _error = l10n.authCaptchaRequired);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final err = await ref.read(authProvider.notifier).login(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
          captchaToken: _captchaToken!,
        );
    if (mounted) {
      if (err != null) {
        setState(() {
          _loading = false;
          _error = err;
          // Refresh captcha on failure
          _captchaToken = null;
          _captchaVersion++;
        });
      } else {
        setState(() => _loading = false);
        context.go('/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AuthLayout(
      title: l10n.authLoginModuleTitle,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.terminal, color: ext.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TypewriterText(
                    text: l10n.authLoginCommand,
                    style: TextStyle(
                      color: ext.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'JetBrainsMono',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.authLoginSubtitle,
              style: TextStyle(
                  color: ext.textMuted,
                  fontSize: 13,
                  fontFamily: 'JetBrainsMono'),
            ),
            const SizedBox(height: 28),

            // Email Input
            TerminalInput(
              controller: _emailCtrl,
              hint: l10n.authEmailHint,
              prefix: l10n.authEmailPrefix,
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  (v?.isEmpty ?? true) ? l10n.commonRequired : null,
            ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.05),
            const SizedBox(height: 16),

            // Password Input
            Stack(
              children: [
                TerminalInput(
                  controller: _passCtrl,
                  hint: l10n.authPasswordHint,
                  prefix: l10n.authPasswordPrefix,
                  obscureText: !_showPass,
                  validator: (v) =>
                      (v?.isEmpty ?? true) ? l10n.commonRequired : null,
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: IconButton(
                    icon: Icon(
                        _showPass ? Icons.visibility_off : Icons.visibility,
                        size: 16,
                        color: ext.textMuted),
                    onPressed: () => setState(() => _showPass = !_showPass),
                    splashRadius: 16,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.05),
            const SizedBox(height: 24),

            // Captcha Container
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: ext.border),
                borderRadius: BorderRadius.circular(8),
                color: ext.bg.withValues(alpha: 0.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CaptchaWidget(
                  key: ValueKey(_captchaVersion),
                  onVerified: (token) => setState(() => _captchaToken = token),
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 300.ms)
                .scale(begin: const Offset(0.95, 0.95)),
            const SizedBox(height: 24),

            // Error Display
            if (_error != null)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ext.error.withValues(alpha: 0.1),
                  border: Border(left: BorderSide(color: ext.error, width: 4)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 16, color: ext.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(
                            color: ext.error,
                            fontSize: 12,
                            fontFamily: 'JetBrainsMono'),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.1),

            // Submit Action
            _HoverLoginButton(
              onPressed: _loading ? null : _submit,
              loading: _loading,
              ext: ext,
              label: l10n.authAuthenticate,
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
            const SizedBox(height: 24),

            // Footer Links
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                Text(
                  l10n.authNoAccount.toUpperCase(),
                  style: TextStyle(
                      color: ext.textMuted,
                      fontSize: 11,
                      fontFamily: 'JetBrainsMono'),
                ),
                InkWell(
                  onHover: (v) {}, // Triggers basic mouse cursor change
                  onTap: () => context.go('/register'),
                  child: Text(
                    '[ ${l10n.authRegister.toUpperCase()} ]',
                    style: TextStyle(
                        color: ext.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'JetBrainsMono'),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 500.ms),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => context.go('/terms'),
                  child: Text(l10n.authTerms.toUpperCase(),
                      style: TextStyle(
                          color: ext.textMuted.withValues(alpha: 0.5),
                          fontSize: 10,
                          fontFamily: 'JetBrainsMono')),
                ),
                Text(' | ',
                    style: TextStyle(
                        color: ext.textMuted.withValues(alpha: 0.5),
                        fontSize: 10)),
                InkWell(
                  onTap: () => context.go('/privacy'),
                  child: Text(l10n.authPrivacy.toUpperCase(),
                      style: TextStyle(
                          color: ext.textMuted.withValues(alpha: 0.5),
                          fontSize: 10,
                          fontFamily: 'JetBrainsMono')),
                ),
              ],
            ).animate().fadeIn(delay: 600.ms),
          ],
        ),
      ),
    );
  }
}

class _HoverLoginButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool loading;
  final AuralixThemeExtension ext;
  final String label;

  const _HoverLoginButton(
      {required this.onPressed,
      required this.loading,
      required this.ext,
      required this.label});

  @override
  State<_HoverLoginButton> createState() => _HoverLoginButtonState();
}

class _HoverLoginButtonState extends State<_HoverLoginButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;
    final bgColor = isDisabled
        ? widget.ext.surfaceVariant
        : (widget.loading ? widget.ext.surfaceVariant : widget.ext.primary);
    final fgColor = isDisabled
        ? widget.ext.textMuted
        : (widget.loading ? widget.ext.primary : widget.ext.bg);
    final borderColor = isDisabled
        ? widget.ext.border
        : (widget.loading ? widget.ext.primary : widget.ext.primary);

    return MouseRegion(
      onEnter: (_) => {if (!isDisabled) setState(() => _hovering = true)},
      onExit: (_) => {if (!isDisabled) setState(() => _hovering = false)},
      cursor:
          isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: 200.ms,
          curve: Curves.easeOutCubic,
          height: 48,
          decoration: BoxDecoration(
            color: _hovering ? bgColor.withValues(alpha: 0.9) : bgColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderColor),
            boxShadow: [
              if (_hovering && !isDisabled)
                BoxShadow(
                    color: widget.ext.primary.withValues(alpha: 0.4),
                    blurRadius: 15,
                    spreadRadius: 1)
            ],
          ),
          child: Center(
            child: widget.loading
                ? SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: widget.ext.primary),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.login, color: fgColor, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        widget.label.toUpperCase(),
                        style: TextStyle(
                            color: fgColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'JetBrainsMono',
                            letterSpacing: 1.2),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
