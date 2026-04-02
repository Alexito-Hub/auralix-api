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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String? _captchaToken;
  int _captchaVersion = 0;
  String? _error;
  bool _loading = false;
  bool _done = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
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
    final err = await ref.read(authProvider.notifier).register(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
          captchaToken: _captchaToken!,
        );
    if (mounted) {
      if (err == null) {
        final isAuthenticated = ref.read(authProvider).valueOrNull != null;
        if (isAuthenticated) {
          setState(() => _loading = false);
          context.go('/dashboard');
          return;
        }

        setState(() {
          _done = true;
          _loading = false;
        });
      } else {
        setState(() {
          _error = err;
          _loading = false;
          _captchaToken = null;
          _captchaVersion++;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (_done) {
      return AuthLayout(
        title: l10n.authRegisterCompleteTitle,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ext.success.withValues(alpha: 0.1),
                border: Border.all(
                    color: ext.success.withValues(alpha: 0.5), width: 2),
                boxShadow: [
                  BoxShadow(
                      color: ext.success.withValues(alpha: 0.2),
                      blurRadius: 20),
                ],
              ),
              child: Icon(Icons.mark_email_read_outlined,
                  size: 48, color: ext.success),
            )
                .animate()
                .scale(duration: 400.ms, curve: Curves.easeOutBack)
                .fadeIn(),
            const SizedBox(height: 24),
            Text(l10n.authRegisterAccountCreated,
                    style: TextStyle(
                        color: ext.success,
                        fontSize: 20,
                        fontFamily: 'JetBrainsMono',
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5))
                .animate()
                .fadeIn(delay: 200.ms),
            const SizedBox(height: 12),
            Text(
              l10n.authRegisterVerifyEmailMessage(_emailCtrl.text),
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: ext.textMuted,
                  fontSize: 13,
                  fontFamily: 'JetBrainsMono'),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 32),
            _HoverActionButton(
              label: l10n.authProceedToLogin,
              icon: Icons.arrow_forward,
              onPressed: () => context.go('/login'),
              ext: ext,
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
          ],
        ),
      );
    }

    return AuthLayout(
      title: l10n.authRegisterModuleTitle,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.person_add_alt_1, color: ext.accent, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TypewriterText(
                    text: l10n.authRegisterCommand,
                    style: TextStyle(
                      color: ext.accent,
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
              l10n.authRegisterSubtitle,
              style: TextStyle(
                  color: ext.textMuted,
                  fontSize: 13,
                  fontFamily: 'JetBrainsMono'),
            ),
            const SizedBox(height: 28),

            // Email
            TerminalInput(
              controller: _emailCtrl,
              hint: l10n.authEmailHint,
              prefix: l10n.authEmailPrefix,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v?.isEmpty ?? true) return l10n.commonRequired;
                if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(v!)) {
                  return l10n.authInvalidEmail;
                }
                return null;
              },
            ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.05),
            const SizedBox(height: 16),

            // Password
            TerminalInput(
              controller: _passCtrl,
              hint: l10n.authRegisterPasswordHint,
              prefix: l10n.authPasswordPrefix,
              obscureText: true,
              validator: (v) =>
                  (v?.length ?? 0) < 8 ? l10n.authMin8Chars : null,
            ).animate().fadeIn(delay: 150.ms).slideX(begin: -0.05),
            const SizedBox(height: 16),

            // Confirm Password
            TerminalInput(
              controller: _confirmCtrl,
              hint: l10n.authRegisterConfirmPasswordHint,
              prefix: l10n.authRegisterConfirmPrefix,
              obscureText: true,
              validator: (v) =>
                  v != _passCtrl.text ? l10n.authPasswordMismatch : null,
            ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.05),
            const SizedBox(height: 24),

            // Captcha
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
                  onVerified: (t) => setState(() => _captchaToken = t),
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 250.ms)
                .scale(begin: const Offset(0.95, 0.95)),
            const SizedBox(height: 24),

            // Error
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
            _HoverActionButton(
              label: l10n.authProvisionAccount,
              icon: Icons.add_circle_outline,
              onPressed: _loading ? null : _submit,
              loading: _loading,
              ext: ext,
              isAccent: true,
            ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.1),
            const SizedBox(height: 24),

            // Footer
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                Text(l10n.authExistingUser,
                    style: TextStyle(
                        color: ext.textMuted,
                        fontSize: 11,
                        fontFamily: 'JetBrainsMono')),
                InkWell(
                  onHover: (v) {},
                  onTap: () => context.go('/login'),
                  child: Text(
                    '[ ${l10n.authLogin.toUpperCase()} ]',
                    style: TextStyle(
                        color: ext.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'JetBrainsMono'),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 450.ms),
          ],
        ),
      ),
    );
  }
}

class _HoverActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool loading;
  final AuralixThemeExtension ext;
  final bool isAccent;

  const _HoverActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.loading = false,
    required this.ext,
    this.isAccent = false,
  });

  @override
  State<_HoverActionButton> createState() => _HoverActionButtonState();
}

class _HoverActionButtonState extends State<_HoverActionButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null && !widget.loading;
    final baseColor = widget.isAccent ? widget.ext.accent : widget.ext.primary;
    final bgColor = isDisabled
        ? widget.ext.surfaceVariant
        : (widget.loading ? widget.ext.surfaceVariant : baseColor);
    final fgColor = isDisabled
        ? widget.ext.textMuted
        : (widget.loading ? baseColor : widget.ext.bg);
    final borderColor = isDisabled
        ? widget.ext.border
        : (widget.loading ? baseColor : baseColor);

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
                    color: baseColor.withValues(alpha: 0.4),
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
                        strokeWidth: 2, color: baseColor),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(widget.icon, color: fgColor, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        widget.label,
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
