import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
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
    if (!_formKey.currentState!.validate()) return;
    if (_captchaToken == null) {
      setState(() => _error = 'Por favor completa el captcha');
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
      setState(() {
        _loading = false;
        _error = err;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);

    return AuthLayout(
      title: 'hub.auralixpe.xyz',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            TypewriterText(
              text: r'$ ssh user@auralix-hub',
              style: TextStyle(
                  color: ext.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Inicia sesión en tu cuenta',
                style: TextStyle(color: ext.textMuted, fontSize: 13)),
            const SizedBox(height: 28),

            // Email
            TerminalInput(
              controller: _emailCtrl,
              hint: 'correo@ejemplo.com',
              prefix: 'email:',
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  (v?.isEmpty ?? true) ? 'Ingresa tu correo' : null,
            ),
            const SizedBox(height: 12),

            // Password
            Stack(
              children: [
                TerminalInput(
                  controller: _passCtrl,
                  hint: '••••••••',
                  prefix: 'pass:',
                  obscureText: !_showPass,
                  validator: (v) =>
                      (v?.isEmpty ?? true) ? 'Ingresa tu contraseña' : null,
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
            ),
            const SizedBox(height: 16),

            // Captcha
            CaptchaWidget(
                onVerified: (token) => setState(() => _captchaToken = token)),
            const SizedBox(height: 16),

            // Error
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ext.error.withValues(alpha: 0.1),
                  border: Border.all(color: ext.error.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, size: 14, color: ext.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: ext.error, fontSize: 12),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.1),

            if (_error != null) const SizedBox(height: 12),

            // Submit
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Iniciar sesión'),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('¿No tienes cuenta? ',
                    style: TextStyle(color: ext.textMuted, fontSize: 13)),
                TextButton(
                  onPressed: () => context.go('/register'),
                  child: const Text('Regístrate'),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () => context.go('/terms'),
                    child: Text('Términos',
                        style: TextStyle(color: ext.textMuted, fontSize: 11))),
                Text(' · ',
                    style: TextStyle(color: ext.textMuted, fontSize: 11)),
                TextButton(
                    onPressed: () => context.go('/privacy'),
                    child: Text('Privacidad',
                        style: TextStyle(color: ext.textMuted, fontSize: 11))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
