import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_extension.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/terminal_widgets.dart';
import '../../auth/providers/auth_provider.dart';

class SandboxScreen extends ConsumerStatefulWidget {
  final String? prefilledPath;
  final String? prefilledBody;
  final String? prefilledMethod;
  const SandboxScreen({super.key, this.prefilledPath, this.prefilledBody, this.prefilledMethod});

  @override
  ConsumerState<SandboxScreen> createState() => _SandboxScreenState();
}

class _SandboxScreenState extends ConsumerState<SandboxScreen> {
  late TextEditingController _pathCtrl;
  late TextEditingController _bodyCtrl;
  String _method = 'POST';
  bool _loading = false;
  bool _showHeaders = false;
  final List<ConsoleEntry> _output = [];
  final _scrollCtrl = ScrollController();

  // Header editor state
  final List<Map<String, TextEditingController>> _headers = [];

  @override
  void initState() {
    super.initState();
    _pathCtrl = TextEditingController(text: widget.prefilledPath ?? '/api/hub/curp');
    _bodyCtrl = TextEditingController(text: widget.prefilledBody ?? '{\n  "curp": "LOOE881221HDFPNL09"\n}');
    _method = widget.prefilledMethod ?? 'POST';
    _output.addAll([
      ConsoleEntry.muted('Auralix Hub Sandbox v1.0'),
      ConsoleEntry.muted('10 créditos sandbox disponibles. Las solicitudes fallidas no se descuentan.'),
      ConsoleEntry.info(''),
    ]);
  }

  @override
  void dispose() {
    _pathCtrl.dispose();
    _bodyCtrl.dispose();
    _scrollCtrl.dispose();
    for (final h in _headers) {
      h['key']!.dispose();
      h['value']!.dispose();
    }
    super.dispose();
  }

  Map<String, String> get _builtHeaders {
    final map = <String, String>{};
    for (final h in _headers) {
      final k = h['key']!.text.trim();
      final v = h['value']!.text.trim();
      if (k.isNotEmpty) map[k] = v;
    }
    return map;
  }

  Future<void> _execute() async {
    final path = _pathCtrl.text.trim();
    if (path.isEmpty) return;

    setState(() {
      _loading = true;
      _output.add(ConsoleEntry.prompt('$_method $path'));
    });

    Map<String, dynamic>? parsedBody;
    if (_method != 'GET' && _bodyCtrl.text.isNotEmpty) {
      try {
        parsedBody = jsonDecode(_bodyCtrl.text) as Map<String, dynamic>;
      } catch (_) {
        _addEntry(ConsoleEntry.error('JSON inválido en el body'));
        setState(() => _loading = false);
        return;
      }
    }

    try {
      final start = DateTime.now().millisecondsSinceEpoch;
      final res = await ApiClient.instance.post('/api/hub/sandbox/execute', data: {
        'method': _method,
        'path': path,
        'body': parsedBody,
        'headers': _builtHeaders,
      });

      final elapsed = DateTime.now().millisecondsSinceEpoch - start;
      final status = res.data['statusCode'] as int? ?? 200;
      final body = res.data['body'];

      _addEntry(ConsoleEntry('HTTP $status · ${elapsed}ms', type: _statusType(status)));
      _addEntry(const ConsoleEntry(''));
      _addEntry(ConsoleEntry(
        const JsonEncoder.withIndent('  ').convert(body),
        copyable: true,
      ));
      _addEntry(ConsoleEntry.muted('─────────────────────────────────────'));
    } catch (e) {
      _addEntry(ConsoleEntry.error('Error: $e'));
    } finally {
      setState(() => _loading = false);
      await Future.delayed(100.ms);
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: 300.ms,
          curve: Curves.easeOut,
        );
      }
    }
  }

  void _addEntry(ConsoleEntry e) {
    setState(() => _output.add(e));
  }

  ConsoleEntryType _statusType(int code) {
    if (code >= 500) return ConsoleEntryType.error;
    if (code >= 400) return ConsoleEntryType.warning;
    if (code >= 200 && code < 300) return ConsoleEntryType.success;
    return ConsoleEntryType.info;
  }

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final user = ref.watch(authProvider).valueOrNull;

    return Scaffold(
      backgroundColor: ext.bg,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(r'$ ', style: TextStyle(color: ext.primary, fontSize: 13)),
                    Text('sandbox', style: TextStyle(color: ext.text, fontSize: 20, fontWeight: FontWeight.bold)),
                  ]),
                  Text('Entorno de pruebas en vivo', style: TextStyle(color: ext.textMuted, fontSize: 12)),
                ]),
                const Spacer(),
                StatusBadge(code: 200, message: '${user?.sandboxCredits ?? 10} créditos sandbox'),
              ],
            ),
            const SizedBox(height: 20),

            // Request builder
            GlowCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Method + Path row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(border: Border(right: BorderSide(color: ext.border))),
                        child: DropdownButton<String>(
                          value: _method,
                          underline: const SizedBox(),
                          dropdownColor: ext.surfaceVariant,
                          style: TextStyle(color: ext.primary, fontFamily: 'JetBrainsMono', fontSize: 13, fontWeight: FontWeight.bold),
                          items: ['GET', 'POST', 'PUT', 'DELETE']
                              .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                              .toList(),
                          onChanged: (v) => setState(() => _method = v!),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _pathCtrl,
                          style: TextStyle(color: ext.text, fontFamily: 'JetBrainsMono', fontSize: 13),
                          decoration: InputDecoration(
                            hintText: '/api/hub/...',
                            hintStyle: TextStyle(color: ext.textMuted, fontSize: 13),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          ),
                        ),
                      ),
                      TextButton.icon(
                        icon: Icon(_showHeaders ? Icons.expand_less : Icons.expand_more, size: 14),
                        label: const Text('Headers', style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(foregroundColor: ext.textMuted),
                        onPressed: () => setState(() => _showHeaders = !_showHeaders),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 40,
                        child: ElevatedButton.icon(
                          onPressed: _loading ? null : _execute,
                          icon: _loading
                              ? const SizedBox(height: 12, width: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.send, size: 14),
                          label: const Text('Ejecutar'),
                        ),
                      ),
                    ],
                  ),

                  // Headers editor
                  if (_showHeaders) ...[
                    Divider(color: ext.border),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text('Headers', style: TextStyle(color: ext.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                            const Spacer(),
                            TextButton.icon(
                              icon: Icon(Icons.add, size: 12, color: ext.primary),
                              label: Text('Agregar', style: TextStyle(fontSize: 11, color: ext.primary)),
                              onPressed: () => setState(() => _headers.add({
                                'key': TextEditingController(),
                                'value': TextEditingController(),
                              })),
                            ),
                          ]),
                          ..._headers.asMap().entries.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(children: [
                              Expanded(
                                child: TextFormField(
                                  controller: e.value['key'],
                                  style: TextStyle(color: ext.text, fontFamily: 'JetBrainsMono', fontSize: 12),
                                  decoration: InputDecoration(hintText: 'Header-Name', hintStyle: TextStyle(color: ext.textMuted, fontSize: 12), contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: e.value['value'],
                                  style: TextStyle(color: ext.text, fontFamily: 'JetBrainsMono', fontSize: 12),
                                  decoration: InputDecoration(hintText: 'value', hintStyle: TextStyle(color: ext.textMuted, fontSize: 12), contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, size: 14, color: ext.error),
                                onPressed: () {
                                  e.value['key']!.dispose();
                                  e.value['value']!.dispose();
                                  setState(() => _headers.removeAt(e.key));
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                              ),
                            ]),
                          )),
                        ],
                      ),
                    ),
                  ],

                  // Body editor
                  if (_method != 'GET') ...[
                    Divider(color: ext.border),
                    SizedBox(
                      height: 100,
                      child: TextFormField(
                        controller: _bodyCtrl,
                        maxLines: null,
                        expands: true,
                        style: TextStyle(color: ext.text, fontFamily: 'JetBrainsMono', fontSize: 12),
                        decoration: InputDecoration(
                          hintText: 'Request body (JSON)',
                          hintStyle: TextStyle(color: ext.textMuted, fontSize: 12),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(8),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Output console with progressive animation
            Expanded(
              child: _AnimatedConsoleOutput(entries: _output, scrollController: _scrollCtrl),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated console that reveals new entries with a fade+slide animation
class _AnimatedConsoleOutput extends StatelessWidget {
  final List<ConsoleEntry> entries;
  final ScrollController scrollController;
  const _AnimatedConsoleOutput({required this.entries, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    return Container(
      decoration: ext.surfaceDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ConsoleHeader(),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: entries.length,
              itemBuilder: (_, i) {
                final entry = entries[i];
                return _ConsoleLine(entry: entry)
                    .animate(key: ValueKey(i))
                    .fadeIn(duration: 180.ms, delay: (i * 15).ms)
                    .slideY(begin: -0.05, duration: 180.ms);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsoleHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: ext.border)), color: ext.surfaceVariant),
      child: Row(children: [
        _dot(const Color(0xFFff5f57)),
        const SizedBox(width: 6),
        _dot(const Color(0xFFfebc2e)),
        const SizedBox(width: 6),
        _dot(const Color(0xFF28c840)),
        const SizedBox(width: 12),
        Text('sandbox output', style: TextStyle(color: ext.textMuted, fontSize: 12)),
      ]),
    );
  }
  Widget _dot(Color c) => Container(width: 12, height: 12, decoration: BoxDecoration(color: c, shape: BoxShape.circle));
}

class _ConsoleLine extends StatelessWidget {
  final ConsoleEntry entry;
  const _ConsoleLine({required this.entry});

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (entry.prefix != null)
            Text('${entry.prefix} ', style: TextStyle(color: ext.primary, fontSize: 12, fontFamily: 'JetBrainsMono')),
          Expanded(
            child: SelectableText(entry.text,
              style: TextStyle(
                color: switch (entry.type) {
                  ConsoleEntryType.success => ext.success,
                  ConsoleEntryType.error   => ext.error,
                  ConsoleEntryType.warning => ext.warning,
                  ConsoleEntryType.info    => ext.accentAlt,
                  ConsoleEntryType.muted   => ext.textMuted,
                  ConsoleEntryType.normal  => ext.text,
                },
                fontSize: 12,
                fontFamily: 'JetBrainsMono',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
