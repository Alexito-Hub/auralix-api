import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/theme_extension.dart';
import '../../../core/network/api_client.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Canvas-based math captcha widget.
class CaptchaWidget extends StatefulWidget {
  final void Function(String token) onVerified;

  const CaptchaWidget({super.key, required this.onVerified});

  @override
  State<CaptchaWidget> createState() => _CaptchaWidgetState();
}

class _CaptchaWidgetState extends State<CaptchaWidget> {
  String? _challengeId;
  String? _svgPayload;
  bool _loading = false;
  bool _verified = false;
  String? _errorMsg;
  String? _question;
  final _answerCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadChallenge();
  }

  @override
  void dispose() {
    _answerCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadChallenge() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _verified = false;
      _errorMsg = null;
    });
    try {
      final res = await ApiClient.instance.post('/api/hub/captcha/challenge');
      if (kDebugMode) debugPrint('captcha challenge response: ${res.statusCode} | ${res.data}');
      if (res.data['status'] == true) {
        if (!mounted) return;
        setState(() {
          _challengeId = res.data['data']['challengeId'];
          _svgPayload = res.data['data']['payload'];
          _question = res.data['data']['question'];
          _loading = false;
          _errorMsg = null;
        });
      } else {
        final msg = res.data['msg'] ?? 'No se pudo cargar captcha';
        if (!mounted) return;
        setState(() {
          _challengeId = null;
          _svgPayload = null;
          _loading = false;
          _errorMsg = msg;
        });
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('captcha challenge catch: $e');
        debugPrint('$st');
      }
      if (!mounted) return;
      setState(() {
        _challengeId = null;
        _svgPayload = null;
        _loading = false;
        _errorMsg = 'Error de conexión';
      });
    }
  }

  Future<void> _verify() async {
    if (_challengeId == null || _answerCtrl.text.isEmpty) return;
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final res =
          await ApiClient.instance.post('/api/hub/captcha/verify', data: {
        'challengeId': _challengeId,
        'answer': _answerCtrl.text.trim(),
      });
      if (res.data['status'] == true) {
        final data = res.data['data'] ?? {};
        final token = data['token'] ?? data['challengeId'];
        if (!mounted) return;
        setState(() {
          _verified = true;
          _loading = false;
          _errorMsg = null;
        });
        widget.onVerified(token as String);
      } else {
        final msg = res.data['msg'] ?? 'Respuesta incorrecta';
        _answerCtrl.clear();
        if (!mounted) return;
        setState(() {
          _loading = false;
          _errorMsg = msg;
        });
        await _loadChallenge();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMsg = 'Error al verificar. Intenta de nuevo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);

    if (_verified) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: ext.success.withValues(alpha: 0.1),
          border: Border.all(color: ext.success.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(Icons.verified_outlined, size: 16, color: ext.success),
            const SizedBox(width: 8),
            Text('Captcha verificado [OK]',
                style: TextStyle(color: ext.success, fontSize: 12)),
          ],
        ),
      ).animate().fadeIn();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: ext.border),
        borderRadius: BorderRadius.circular(6),
        color: ext.surface,
      ),
      child: _loading
          ? Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: ext.primary),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Verificación de seguridad',
                    style: TextStyle(color: ext.textMuted, fontSize: 11)),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: ext.surfaceVariant,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: _svgPayload != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Show SVG if possible
                            SvgPicture.string(_svgPayload!,
                                height: 80, fit: BoxFit.contain),
                            const SizedBox(height: 6),
                            if (_question != null)
                              Text(_question!,
                                  style: TextStyle(
                                      color: ext.text,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                          ],
                        )
                      : Column(
                          children: [
                            SizedBox(
                                height: 60,
                                child: Center(
                                    child: Text('Captcha no disponible',
                                        style: TextStyle(
                                            color: ext.textMuted,
                                            fontSize: 12)))),
                            const SizedBox(height: 6),
                            TextButton.icon(
                              onPressed: _loadChallenge,
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('Reintentar'),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _answerCtrl,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.send,
                        onFieldSubmitted: (_) => _verify(),
                        style: TextStyle(color: ext.text, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Respuesta',
                          hintStyle:
                              TextStyle(color: ext.textMuted, fontSize: 14),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          isDense: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(color: ext.border)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(color: ext.border)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(color: ext.primary)),
                          filled: true,
                          fillColor: ext.surfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _verify,
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12)),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Verificar'),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(Icons.refresh, size: 18, color: ext.textMuted),
                      onPressed: _loadChallenge,
                      tooltip: 'Nuevo captcha',
                    ),
                  ],
                ),
                if (_errorMsg != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ext.error.withValues(alpha: 0.08),
                      border:
                          Border.all(color: ext.error.withValues(alpha: 0.18)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(_errorMsg!,
                        style: TextStyle(color: ext.error, fontSize: 12)),
                  ),
                ],
              ],
            ),
    );
  }
}
