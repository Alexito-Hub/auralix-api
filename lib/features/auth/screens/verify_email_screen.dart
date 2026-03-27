import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/theme_extension.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String? token;
  const VerifyEmailScreen({super.key, this.token});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _loading = true;
  bool _success = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.token != null) _verify();
  }

  Future<void> _verify() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient.instance.get('/api/hub/auth/verify-email', params: {'token': widget.token});
      if (res.data['status'] == true) {
        setState(() { _success = true; _loading = false; });
      } else {
        setState(() { _error = res.data['msg'] ?? 'Token inválido'; _loading = false; });
      }
    } catch (_) {
      setState(() { _error = 'Error de conexión'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    return Scaffold(
      backgroundColor: ext.bg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: _loading
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: ext.primary),
                      const SizedBox(height: 16),
                      Text('Verificando...', style: TextStyle(color: ext.textMuted)),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _success ? Icons.verified_user_outlined : Icons.error_outline,
                        size: 56,
                        color: _success ? ext.success : ext.error,
                      ).animate().scale(),
                      const SizedBox(height: 20),
                      Text(
                        _success ? '¡Email verificado!' : 'Verificación fallida',
                        style: TextStyle(color: ext.text, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _success
                            ? 'Tu cuenta está activa. Ahora puedes iniciar sesión.'
                            : _error ?? 'El enlace es inválido o ha expirado.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: ext.textMuted, fontSize: 13),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => context.go('/login'),
                        child: Text(_success ? 'Iniciar sesión' : 'Volver al login'),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
