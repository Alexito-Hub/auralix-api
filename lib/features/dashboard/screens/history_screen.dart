import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_extension.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/terminal_widgets.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  List<Map<String, dynamic>> _logs = [];
  bool _loading = true;
  String? _error;
  int _page = 1;
  int _totalPages = 1;
  String _filter = 'all'; // all | success | error | sandbox

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch({int page = 1}) async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiClient.instance.get('/api/hub/user/history', params: {
        'page': '$page',
        'limit': '25',
      });
      if (res.data['status'] == true) {
        setState(() {
          _logs = List<Map<String, dynamic>>.from(res.data['data']['logs'] ?? []);
          _page = res.data['data']['page'] ?? 1;
          _totalPages = res.data['data']['pages'] ?? 1;
          _loading = false;
        });
      } else {
        setState(() { _error = res.data['msg']; _loading = false; });
      }
    } catch (e) {
      setState(() { _error = 'Error de conexión'; _loading = false; });
    }
  }

  List<Map<String, dynamic>> get _filtered {
    switch (_filter) {
      case 'success': return _logs.where((l) => (l['statusCode'] as int? ?? 0) < 400).toList();
      case 'error':   return _logs.where((l) => (l['statusCode'] as int? ?? 0) >= 400).toList();
      case 'sandbox': return _logs.where((l) => l['isSandbox'] == true).toList();
      default:        return _logs;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    return Scaffold(
      backgroundColor: ext.bg,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(children: [
              Text(r'$ ', style: TextStyle(color: ext.primary, fontSize: 13)),
              Text('historial', style: TextStyle(color: ext.text, fontSize: 20, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(icon: Icon(Icons.refresh, size: 16, color: ext.textMuted), onPressed: () => _fetch(page: _page)),
            ]),
            Text('Registro completo de solicitudes', style: TextStyle(color: ext.textMuted, fontSize: 12)),
            const SizedBox(height: 16),

            // Filter chips
            Row(
              children: ['all', 'success', 'error', 'sandbox'].map((f) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(f, style: const TextStyle(fontSize: 12, fontFamily: 'JetBrainsMono')),
                  selected: _filter == f,
                  onSelected: (_) => setState(() => _filter = f),
                  selectedColor: ext.primary.withValues(alpha: 0.2),
                  checkmarkColor: ext.primary,
                  labelStyle: TextStyle(color: _filter == f ? ext.primary : ext.textMuted),
                  backgroundColor: ext.surface,
                  side: BorderSide(color: _filter == f ? ext.primary : ext.border),
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),

            // Table
            Expanded(
              child: _loading
                  ? Center(child: CircularProgressIndicator(color: ext.primary))
                  : _error != null
                      ? Center(child: Text(_error!, style: TextStyle(color: ext.error)))
                      : _buildTable(ext),
            ),

            // Pagination
            if (_totalPages > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _page > 1 ? () => _fetch(page: _page - 1) : null,
                    color: ext.textMuted,
                  ),
                  Text('$_page / $_totalPages', style: TextStyle(color: ext.textMuted, fontSize: 12)),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _page < _totalPages ? () => _fetch(page: _page + 1) : null,
                    color: ext.textMuted,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(AuralixThemeExtension ext) {
    final rows = _filtered;
    if (rows.isEmpty) {
      return Center(
        child: Text('No hay solicitudes en esta categoría', style: TextStyle(color: ext.textMuted, fontSize: 13)),
      );
    }
    return GlowCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: ext.surfaceVariant,
              border: Border(bottom: BorderSide(color: ext.border)),
            ),
            child: Row(children: [
              _hdr('METHOD', 70, ext),
              _hdr('STATUS', 60, ext),
              _hdr('ENDPOINT', null, ext),
              _hdr('TIEMPO', 80, ext),
              _hdr('CRÉDITO', 80, ext),
            ]),
          ),
          // Data rows
          Expanded(
            child: ListView.separated(
              itemCount: rows.length,
              separatorBuilder: (_, __) => Divider(color: ext.border, height: 1),
              itemBuilder: (_, i) {
                final l = rows[i];
                final code = l['statusCode'] as int? ?? 200;
                final color = code >= 500 ? ext.error : code >= 400 ? ext.warning : ext.success;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(children: [
                    SizedBox(width: 70, child: Text(l['method'] ?? 'GET', style: TextStyle(color: ext.primary, fontSize: 12, fontFamily: 'JetBrainsMono', fontWeight: FontWeight.bold))),
                    SizedBox(width: 60, child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(3)),
                      child: Text('$code', style: TextStyle(color: color, fontSize: 11, fontFamily: 'JetBrainsMono'), textAlign: TextAlign.center),
                    )),
                    Expanded(child: Text(l['endpoint'] ?? '/', style: TextStyle(color: ext.text, fontSize: 12, fontFamily: 'JetBrainsMono'), overflow: TextOverflow.ellipsis)),
                    SizedBox(width: 80, child: Text('${l['responseTimeMs'] ?? 0}ms', style: TextStyle(color: ext.textMuted, fontSize: 11, fontFamily: 'JetBrainsMono'), textAlign: TextAlign.end)),
                    SizedBox(width: 80, child: Text(l['creditsDeducted'] == 0 ? '-' : '-${l['creditsDeducted']}', style: TextStyle(color: l['creditsDeducted'] == 0 ? ext.textMuted : ext.warning, fontSize: 11, fontFamily: 'JetBrainsMono'), textAlign: TextAlign.end)),
                  ]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _hdr(String t, double? width, AuralixThemeExtension ext) {
    final w = SizedBox(width: width, child: Text(t, style: TextStyle(color: ext.textSubtle, fontSize: 10, fontFamily: 'JetBrainsMono', fontWeight: FontWeight.bold)));
    return width == null ? Expanded(child: w) : w;
  }
}
