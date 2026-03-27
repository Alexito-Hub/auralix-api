import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
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
  String? _error;
  bool _loading = false;
  bool _done = false;

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
    final err = await ref.read(authProvider.notifier).register(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
          captchaToken: _captchaToken!,
        );
    if (mounted) {
      if (err == null) {
        setState(() {
          _done = true;
          _loading = false;
        });
      } else {
        setState(() {
          _error = err;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);

    if (_done) {
      return AuthLayout(
        title: 'hub.auralixpe.xyz',
        child: Column(
          children: [
            Icon(Icons.mark_email_read_outlined, size: 48, color: ext.success),
            const SizedBox(height: 16),
            Text('¡Cuenta creada!',
                style: TextStyle(
                    color: ext.text,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Revisa tu correo ${_emailCtrl.text} y confirma tu cuenta para continuar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: ext.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Ir al login')),
          ],
        ),
      );
    }

    return AuthLayout(
      title: 'hub.auralixpe.xyz',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('\$ crear nueva cuenta',
                style: TextStyle(
                    color: ext.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Recibirás 20 solicitudes gratuitas + 10 sandbox',
                style: TextStyle(color: ext.textMuted, fontSize: 12)),
            const SizedBox(height: 24),
            TerminalInput(
              controller: _emailCtrl,
              hint: 'correo@ejemplo.com',
              prefix: 'email:',
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v?.isEmpty ?? true) {
                  return 'Ingresa tu correo';
                }
                if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(v!)) {
                  return 'Correo inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TerminalInput(
              controller: _passCtrl,
              hint: 'mínimo 8 caracteres',
              prefix: 'pass:',
              obscureText: true,
              validator: (v) =>
                  (v?.length ?? 0) < 8 ? 'Mínimo 8 caracteres' : null,
            ),
            const SizedBox(height: 12),
            TerminalInput(
              controller: _confirmCtrl,
              hint: 'repite tu contraseña',
              prefix: 'confirm:',
              obscureText: true,
              validator: (v) =>
                  v != _passCtrl.text ? 'Las contraseñas no coinciden' : null,
            ),
            const SizedBox(height: 16),
            CaptchaWidget(onVerified: (t) => setState(() => _captchaToken = t)),
            const SizedBox(height: 16),
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ext.error.withValues(alpha: 0.1),
                  border: Border.all(color: ext.error.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _error!,
                  style: TextStyle(color: ext.error, fontSize: 12),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ).animate().fadeIn(),
              const SizedBox(height: 12),
            ],
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: ext.onPrimary))
                    : const Text('Crear cuenta'),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('¿Ya tienes cuenta? ',
                    style: TextStyle(color: ext.textMuted, fontSize: 13)),
                TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Inicia sesión')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
