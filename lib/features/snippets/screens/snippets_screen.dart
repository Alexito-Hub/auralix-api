import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// flutter_animate unused here
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Removed unused flutter_highlight imports to satisfy analyzer
import '../../../core/theme/theme_extension.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/terminal_widgets.dart';

final _snippetsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final res = await ApiClient.instance.get('/api/hub/snippets');
  if (res.data['status'] == true) return List<Map<String, dynamic>>.from(res.data['data']);
  return [];
});

const _languages = [
  'bash', 'c', 'cpp', 'csharp', 'css', 'dart', 'dockerfile', 'go', 'graphql',
  'html', 'java', 'javascript', 'json', 'kotlin', 'lua', 'markdown', 'php',
  'plaintext', 'python', 'r', 'ruby', 'rust', 'scala', 'shell', 'sql',
  'swift', 'toml', 'typescript', 'xml', 'yaml',
];

class SnippetsScreen extends ConsumerStatefulWidget {
  const SnippetsScreen({super.key});

  @override
  ConsumerState<SnippetsScreen> createState() => _SnippetsScreenState();
}

class _SnippetsScreenState extends ConsumerState<SnippetsScreen> {
  bool _showCreate = false;

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final snippets = ref.watch(_snippetsProvider);

    return Scaffold(
      backgroundColor: ext.bg,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text('\$ ', style: TextStyle(color: ext.primary, fontSize: 13)),
                      Text('snippets', style: TextStyle(color: ext.text, fontSize: 20, fontWeight: FontWeight.bold)),
                    ]),
                    Text('Comparte fragmentos de código', style: TextStyle(color: ext.textMuted, fontSize: 12)),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  icon: Icon(_showCreate ? Icons.close : Icons.add, size: 16),
                  label: Text(_showCreate ? 'Cancelar' : 'Nuevo snippet'),
                  onPressed: () => setState(() => _showCreate = !_showCreate),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_showCreate) ...[
              _CreateSnippetCard(onCreated: () {
                setState(() => _showCreate = false);
                ref.invalidate(_snippetsProvider);
              }),
              const SizedBox(height: 16),
            ],

            Expanded(
              child: snippets.when(
                loading: () => Center(child: CircularProgressIndicator(color: AuralixThemeExtension.of(context).primary)),
                error: (_, __) => Center(child: Text('Error al cargar snippets', style: TextStyle(color: ext.error))),
                data: (list) => list.isEmpty
                    ? Center(child: Text('No tienes snippets aún', style: TextStyle(color: ext.textMuted)))
                    : ListView.separated(
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _SnippetTile(snippet: list[i]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SnippetTile extends StatelessWidget {
  final Map<String, dynamic> snippet;
  const _SnippetTile({required this.snippet});

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final shareUrl = 'https://hub.auralixpe.xyz/s/${snippet['shortId']}';

    return GlowCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: ext.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(snippet['language'] ?? 'text', style: TextStyle(color: ext.primary, fontSize: 11, fontFamily: 'JetBrainsMono')),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(snippet['title'] ?? 'Sin título', style: TextStyle(color: ext.text, fontSize: 14, fontWeight: FontWeight.w600)),
                Text(shareUrl, style: TextStyle(color: ext.textMuted, fontSize: 11, fontFamily: 'JetBrainsMono')),
              ],
            ),
          ),
          if (snippet['hasPassword'] == true)
            Icon(Icons.lock, size: 14, color: ext.warning),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.copy, size: 14, color: ext.textMuted),
            tooltip: 'Copiar URL',
            onPressed: () => Clipboard.setData(ClipboardData(text: shareUrl)),
          ),
        ],
      ),
    );
  }
}

class _CreateSnippetCard extends StatefulWidget {
  final VoidCallback onCreated;
  const _CreateSnippetCard({required this.onCreated});

  @override
  State<_CreateSnippetCard> createState() => _CreateSnippetCardState();
}

class _CreateSnippetCardState extends State<_CreateSnippetCard> {
  final _titleCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _language = 'javascript';
  bool _withPass = false;
  bool _loading = false;
  String? _error;

  Future<void> _create() async {
    if (_titleCtrl.text.isEmpty || _codeCtrl.text.isEmpty) {
      setState(() => _error = 'Título y código son requeridos');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiClient.instance.post('/api/hub/snippets', data: {
        'title': _titleCtrl.text.trim(),
        'language': _language,
        'code': _codeCtrl.text,
        if (_withPass && _passCtrl.text.isNotEmpty) 'password': _passCtrl.text,
      });
      if (res.data['status'] == true) {
        widget.onCreated();
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
    return GlowCard(
      useAltGlow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nuevo snippet', style: TextStyle(color: ext.text, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TerminalInput(controller: _titleCtrl, hint: 'Título del snippet', prefix: 'title:'),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('lang:', style: TextStyle(color: ext.primary, fontSize: 12, fontFamily: 'JetBrainsMono')),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _language,
                dropdownColor: ext.surfaceVariant,
                style: TextStyle(color: ext.text, fontSize: 13, fontFamily: 'JetBrainsMono'),
                underline: const SizedBox(),
                items: _languages.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                onChanged: (v) => setState(() => _language = v!),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 150,
            decoration: BoxDecoration(border: Border.all(color: ext.border), borderRadius: BorderRadius.circular(6), color: ext.surfaceVariant),
            child: TextFormField(
              controller: _codeCtrl,
              maxLines: null,
              expands: true,
              style: TextStyle(color: ext.text, fontFamily: 'JetBrainsMono', fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Pega tu código aquí...',
                hintStyle: TextStyle(color: ext.textMuted, fontSize: 12),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Switch(value: _withPass, onChanged: (v) => setState(() => _withPass = v), activeThumbColor: ext.primary),
              Text('Proteger con contraseña', style: TextStyle(color: ext.text, fontSize: 13)),
              if (_withPass) ...[
                const SizedBox(width: 12),
                Expanded(child: TerminalInput(controller: _passCtrl, hint: 'Contraseña', prefix: 'pwd:', obscureText: true)),
              ],
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: ext.error, fontSize: 12)),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: _loading ? null : _create,
                child: _loading
                    ? SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2, color: ext.onPrimary))
                    : const Text('Crear snippet'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
