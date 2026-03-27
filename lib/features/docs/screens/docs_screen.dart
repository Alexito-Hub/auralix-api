import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_extension.dart';
import '../../../shared/widgets/terminal_widgets.dart';

class DocsScreen extends StatefulWidget {
  final String? apiId;
  const DocsScreen({super.key, this.apiId});

  @override
  State<DocsScreen> createState() => _DocsScreenState();
}

class _DocsScreenState extends State<DocsScreen> {
  String _selectedApi = 'curp';
  String _selectedLang = 'curl';

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);

    return Scaffold(
      backgroundColor: ext.bg,
      body: Row(
        children: [
          // API list sidebar
          Container(
            width: 200,
            color: ext.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('APIs disponibles', style: TextStyle(color: ext.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                ..._apis.map((a) => ListTile(
                      dense: true,
                      selected: _selectedApi == a.id,
                      selectedTileColor: ext.primary.withValues(alpha: 0.1),
                      title: Text(a.name, style: TextStyle(color: _selectedApi == a.id ? ext.primary : ext.text, fontSize: 13)),
                      subtitle: Text(a.method, style: TextStyle(color: ext.textMuted, fontSize: 10)),
                      onTap: () => setState(() => _selectedApi = a.id),
                    )),
              ],
            ),
          ),
          VerticalDivider(color: ext.border, width: 1),

          // Main docs area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: _ApiDocs(apiId: _selectedApi, selectedLang: _selectedLang, onLangChange: (l) => setState(() => _selectedLang = l)),
            ),
          ),
        ],
      ),
    );
  }
}

const _apis = [
  _ApiMeta(id: 'curp', name: 'API CURP', method: 'POST', tag: 'Identidad'),
];

class _ApiMeta {
  final String id, name, method, tag;
  const _ApiMeta({required this.id, required this.name, required this.method, required this.tag});
}

class _ApiDocs extends StatelessWidget {
  final String apiId;
  final String selectedLang;
  final void Function(String) onLangChange;

  const _ApiDocs({required this.apiId, required this.selectedLang, required this.onLangChange});

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Breadcrumb
        Row(children: [
          Text('docs', style: TextStyle(color: ext.textMuted, fontSize: 12)),
          Icon(Icons.chevron_right, size: 14, color: ext.textMuted),
          Text('curp', style: TextStyle(color: ext.primary, fontSize: 12)),
        ]).animate().fadeIn(),
        const SizedBox(height: 16),

        // Title
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: ext.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
              child: Text('POST', style: TextStyle(color: ext.primary, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 10),
            Text('/api/hub/curp', style: TextStyle(color: ext.text, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'JetBrainsMono')),
          ],
        ),
        const SizedBox(height: 8),
        Text('Consulta datos de una persona mediante su CURP (Clave Única de Registro de Población). Retorna información oficial validada.',
            style: TextStyle(color: ext.textMuted, fontSize: 13)),
        const SizedBox(height: 24),

        // Requirements
        _Section(title: 'Headers requeridos', children: [
          _ParamRow('Authorization', 'Bearer {token}', required: true, ext: ext),
          _ParamRow('Content-Type', 'application/json', required: true, ext: ext),
        ]),
        const SizedBox(height: 20),
        _Section(title: 'Body parameters', children: [
          _ParamRow('curp', 'string — CURP de 18 caracteres', required: true, ext: ext),
        ]),
        const SizedBox(height: 20),

        // Code examples
        _Section(title: 'Ejemplos de código', children: [
          _CodeTabs(selectedLang: selectedLang, onLangChange: onLangChange),
        ]),
        const SizedBox(height: 20),

        // Response example
        _Section(title: 'Respuesta exitosa — 200 OK', children: [
          _ResponseExample(ext: ext),
        ]),
        const SizedBox(height: 20),

        // Status codes
        const _Section(title: 'Códigos de estado', children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusBadge(code: 200, message: 'Consulta exitosa'),
              StatusBadge(code: 400, message: 'CURP inválida'),
              StatusBadge(code: 401, message: 'Sin autenticación'),
              StatusBadge(code: 429, message: 'Límite alcanzado'),
              StatusBadge(code: 500, message: 'Error del servidor'),
            ],
          ),
        ]),
        // Try in Sandbox button
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: () => context.go(
            '/sandbox',
            extra: {'path': '/api/hub/curp', 'method': 'POST', 'body': '{"curp": "LOOE881221HDFPNL09"}'},
          ),
          icon: const Icon(Icons.terminal, size: 16),
          label: const Text('Probar en Sandbox'),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: ext.text, fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...children,
      ],
    );
  }
}

class _ParamRow extends StatelessWidget {
  final String name, value;
  final bool required;
  final AuralixThemeExtension ext;

  const _ParamRow(this.name, this.value, {required this.required, required this.ext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 180, child: Text(name, style: TextStyle(color: ext.accentAlt, fontFamily: 'JetBrainsMono', fontSize: 13))),
          Text(value, style: TextStyle(color: ext.text, fontSize: 13)),
          if (required) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: ext.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(3)),
              child: Text('required', style: TextStyle(color: ext.error, fontSize: 10)),
            ),
          ],
        ],
      ),
    );
  }
}

class _CodeTabs extends StatelessWidget {
  final String selectedLang;
  final void Function(String) onLangChange;

  const _CodeTabs({required this.selectedLang, required this.onLangChange});

  static const _snippets = {
    'curl': '''curl -X POST https://api.auralixpe.xyz/api/hub/curp \\
  -H "Authorization: Bearer TOKEN" \\
  -H "Content-Type: application/json" \\
  -d '{"curp": "LOOE881221HDFPNL09"}'
''',
    'javascript': '''const res = await fetch('https://api.auralixpe.xyz/api/hub/curp', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer TOKEN',
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({ curp: 'LOOE881221HDFPNL09' }),
});
const data = await res.json();
console.log(data);
''',
    'python': '''import requests

response = requests.post(
    'https://api.auralixpe.xyz/api/hub/curp',
    headers={
        'Authorization': 'Bearer TOKEN',
        'Content-Type': 'application/json',
    },
    json={'curp': 'LOOE881221HDFPNL09'},
)
print(response.json())
''',
  };

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final langs = _snippets.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: langs.map((l) => _LangTab(label: l, selected: l == selectedLang, onTap: () => onLangChange(l))).toList(),
        ),
        const SizedBox(height: 0),
        Container(
          decoration: BoxDecoration(
            color: ext.surfaceVariant,
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(6), topRight: Radius.circular(6), bottomRight: Radius.circular(6)),
            border: Border.all(color: ext.border),
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: HighlightView(
                  _snippets[selectedLang]!,
                  language: selectedLang == 'curl' ? 'bash' : selectedLang,
                  theme: monokaiSublimeTheme,
                  padding: const EdgeInsets.all(16),
                  textStyle: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 13, height: 1.6),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: Icon(Icons.copy, size: 14, color: ext.textMuted),
                  tooltip: 'Copiar',
                  onPressed: () => Clipboard.setData(ClipboardData(text: _snippets[selectedLang]!)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LangTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _LangTab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? ext.surfaceVariant : Colors.transparent,
          border: Border(
            top: BorderSide(color: selected ? ext.border : Colors.transparent),
            left: BorderSide(color: selected ? ext.border : Colors.transparent),
            right: BorderSide(color: selected ? ext.border : Colors.transparent),
            bottom: selected ? const BorderSide(color: Colors.transparent) : BorderSide(color: ext.border),
          ),
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
        ),
        child: Text(label, style: TextStyle(color: selected ? ext.text : ext.textMuted, fontSize: 12, fontFamily: 'JetBrainsMono')),
      ),
    );
  }
}

class _ResponseExample extends StatelessWidget {
  final AuralixThemeExtension ext;
  const _ResponseExample({required this.ext});

  static const _json = '''{
  "status": true,
  "data": {
    "curp": "LOOE881221HDFPNL09",
    "nombre": "EDGAR",
    "primerApellido": "LOPEZ",
    "segundoApellido": "ORTIZ",
    "fechaNacimiento": "1988-12-21",
    "sexo": "H",
    "claveEntidad": "DF",
    "municipio": "GUSTAVO A. MADERO",
    "docProbatorio": 1
  }
}''';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(color: ext.surfaceVariant, borderRadius: BorderRadius.circular(6), border: Border.all(color: ext.border)),
          child: HighlightView(
            _json,
            language: 'json',
            theme: monokaiSublimeTheme,
            padding: const EdgeInsets.all(16),
            textStyle: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 13, height: 1.6),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: Icon(Icons.copy, size: 14, color: ext.textMuted),
            onPressed: () => Clipboard.setData(const ClipboardData(text: _json)),
            tooltip: 'Copiar respuesta',
          ),
        ),
      ],
    );
  }
}
