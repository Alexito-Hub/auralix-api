import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// flutter_animate not used here
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import '../../../core/theme/theme_extension.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/terminal_widgets.dart';

class SnippetDetailScreen extends StatefulWidget {
  final String id;
  const SnippetDetailScreen({super.key, required this.id});

  @override
  State<SnippetDetailScreen> createState() => _SnippetDetailScreenState();
}

class _SnippetDetailScreenState extends State<SnippetDetailScreen> {
  bool _loading = true;
  Map<String, dynamic>? _snippet;
  bool _needsPassword = false;
  final _passCtrl = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({String? password}) async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiClient.instance.post('/api/hub/snippets/${widget.id}/view',
          data: password != null ? {'password': password} : null);
      if (res.statusCode == 401 || res.data['requiresPassword'] == true) {
        setState(() { _needsPassword = true; _loading = false; });
      } else if (res.data['status'] == true) {
        setState(() { _snippet = res.data['data']; _needsPassword = false; _loading = false; });
      } else {
        setState(() { _error = res.data['msg']; _loading = false; });
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
      appBar: AppBar(
        backgroundColor: ext.surface,
        title: Text('hub.auralixpe.xyz/s/${widget.id}',
            style: TextStyle(color: ext.textMuted, fontSize: 13, fontFamily: 'JetBrainsMono')),
        iconTheme: IconThemeData(color: ext.text),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: ext.primary))
          : _needsPassword
              ? _PasswordGate(controller: _passCtrl, onSubmit: () => _load(password: _passCtrl.text), error: _error, ext: ext)
              : _error != null
                  ? Center(child: Text(_error!, style: TextStyle(color: ext.error)))
                  : _SnippetView(snippet: _snippet!, ext: ext),
    );
  }
}

class _PasswordGate extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final String? error;
  final AuralixThemeExtension ext;
  const _PasswordGate({required this.controller, required this.onSubmit, this.error, required this.ext});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 40, color: ext.primary),
              const SizedBox(height: 16),
              Text('Snippet protegido', style: TextStyle(color: ext.text, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Ingresa la contraseña para ver este snippet', style: TextStyle(color: ext.textMuted, fontSize: 13)),
              const SizedBox(height: 20),
              TerminalInput(controller: controller, hint: 'Contraseña', prefix: 'pwd:', obscureText: true, onSubmitted: (_) => onSubmit()),
              if (error != null) ...[const SizedBox(height: 8), Text(error!, style: TextStyle(color: ext.error, fontSize: 12))],
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onSubmit, child: const Text('Acceder')),
            ],
          ),
        ),
      ),
    );
  }
}

class _SnippetView extends StatelessWidget {
  final Map<String, dynamic> snippet;
  final AuralixThemeExtension ext;
  const _SnippetView({required this.snippet, required this.ext});

  @override
  Widget build(BuildContext context) {
    final code = snippet['code'] as String? ?? '';
    final lang = snippet['language'] as String? ?? 'plaintext';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          color: ext.surface,
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(snippet['title'] ?? 'Snippet', style: TextStyle(color: ext.text, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(lang, style: TextStyle(color: ext.primary, fontSize: 12, fontFamily: 'JetBrainsMono')),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.copy, color: ext.textMuted),
                onPressed: () => Clipboard.setData(ClipboardData(text: code)),
                tooltip: 'Copiar código',
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: HighlightView(
              code,
              language: lang,
              theme: monokaiSublimeTheme,
              padding: const EdgeInsets.all(20),
              textStyle: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 14, height: 1.6),
            ),
          ),
        ),
      ],
    );
  }
}
