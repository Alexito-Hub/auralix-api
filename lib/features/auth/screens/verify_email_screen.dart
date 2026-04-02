import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hub_aura/l10n/app_localizations.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/theme_extension.dart';
import '../widgets/auth_layout.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String? token;
  const VerifyEmailScreen({super.key, this.token});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  static const _tokenMissingCode = '__token_missing__';
  static const _invalidSignatureCode = '__invalid_signature__';
  static const _connectionFailedCode = '__connection_failed__';

  bool _loading = true;
  bool _success = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.token != null && widget.token!.trim().isNotEmpty) {
      _verify();
    } else {
      _loading = false;
      _error = _tokenMissingCode;
    }
  }

  Future<void> _verify() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final res = await ApiClient.instance
          .get('/hub/auth/verify-email', params: {'token': widget.token});
      if (!mounted) return;
      if (res.data['status'] == true) {
        setState(() {
          _success = true;
          _loading = false;
        });
      } else {
        setState(() {
          _error = res.data['msg'] ?? _invalidSignatureCode;
          _loading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = _connectionFailedCode;
        _loading = false;
      });
    }
  }

  String _resolveErrorMessage(AppLocalizations l10n) {
    final raw = _error;
    if (raw == null || raw.trim().isEmpty) {
      return l10n.authVerifyInvalidOrExpired;
    }
    if (raw == _tokenMissingCode) return l10n.authVerifyTokenMissing;
    if (raw == _invalidSignatureCode) return l10n.authVerifyInvalidSignature;
    if (raw == _connectionFailedCode) return l10n.authVerifyConnectionFailed;
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;
    final resolvedError = _resolveErrorMessage(l10n);
    return AuthLayout(
      title: l10n.authVerifyTitle,
      child: _loading
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ext.surfaceVariant,
                  ),
                  child: CircularProgressIndicator(
                      color: ext.primary, strokeWidth: 2),
                ).animate().rotate(duration: 2.seconds).fadeIn(),
                const SizedBox(height: 24),
                Text(l10n.authVerifyChecking,
                        style: TextStyle(
                            color: ext.primary,
                            fontFamily: 'JetBrainsMono',
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.bold))
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fade(duration: 800.ms, begin: 0.4, end: 1.0),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _success
                        ? ext.success.withValues(alpha: 0.1)
                        : ext.error.withValues(alpha: 0.1),
                    border: Border.all(
                        color: _success
                            ? ext.success.withValues(alpha: 0.5)
                            : ext.error.withValues(alpha: 0.5),
                        width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: _success
                              ? ext.success.withValues(alpha: 0.2)
                              : ext.error.withValues(alpha: 0.2),
                          blurRadius: 20),
                    ],
                  ),
                  child: Icon(
                    _success
                        ? Icons.verified_user_outlined
                        : Icons.gpp_bad_outlined,
                    size: 48,
                    color: _success ? ext.success : ext.error,
                  ),
                )
                    .animate()
                    .scale(duration: 400.ms, curve: Curves.easeOutBack)
                    .fadeIn(),
                const SizedBox(height: 20),
                Text(
                  _success
                      ? l10n.authVerifySuccessCode
                      : l10n.authVerifyErrorCode,
                  style: TextStyle(
                      color: _success ? ext.success : ext.error,
                      fontSize: 18,
                      fontFamily: 'JetBrainsMono',
                      fontWeight: FontWeight.bold),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 12),
                Text(
                  _success
                    ? l10n.authVerifySuccessMessage
                    : resolvedError,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: ext.textMuted,
                      fontSize: 13,
                      fontFamily: 'JetBrainsMono'),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 32),
                _HoverActionButton(
                  label: _success
                      ? l10n.authProceedToLogin
                      : l10n.authReturnToLogin,
                  icon: _success ? Icons.login : Icons.arrow_back,
                  onPressed: () => context.go('/login'),
                  ext: ext,
                  isAccent: _success,
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
              ],
            ),
    );
  }
}

// Resusing the Hover Button logic from register for consistency
class _HoverActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final AuralixThemeExtension ext;
  final bool isAccent;

  const _HoverActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
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
    final isDisabled = widget.onPressed == null;
    final baseColor = widget.isAccent ? widget.ext.success : widget.ext.primary;
    final bgColor = isDisabled ? widget.ext.surfaceVariant : baseColor;
    final fgColor = isDisabled ? widget.ext.textMuted : widget.ext.bg;
    final borderColor = isDisabled ? widget.ext.border : baseColor;

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
            child: Row(
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
