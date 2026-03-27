import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/theme_extension.dart';
import '../../../core/network/api_client.dart';
import '../providers/ws_logs_provider.dart';

class RequestLogWidget extends ConsumerStatefulWidget {
  const RequestLogWidget({super.key});

  @override
  ConsumerState<RequestLogWidget> createState() => _RequestLogWidgetState();
}

class _RequestLogWidgetState extends ConsumerState<RequestLogWidget> {
  final _scrollCtrl = ScrollController();
  List<Map<String, dynamic>> _polledLogs = [];

  @override
  void initState() {
    super.initState();
    _fetchLogs();
    // Also trigger WebSocket connection
    ref.read(wsLogsProvider.notifier).connect();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchLogs() async {
    try {
      final res = await ApiClient.instance.get('/api/hub/user/history', params: {'limit': '30'});
      if (res.data['status'] == true) {
        final logs = List<Map<String, dynamic>>.from(res.data['data']['logs'] ?? []);
        if (mounted) setState(() => _polledLogs = logs);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final wsLogs = ref.watch(wsLogsProvider);

    // Merge live WS logs + polled history, WS takes precedence
    final showLive = wsLogs.isNotEmpty;

    return Container(
      decoration: ext.surfaceDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: ext.surfaceVariant,
              border: Border(bottom: BorderSide(color: ext.border)),
            ),
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: ext.success, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text('logs en tiempo real', style: TextStyle(color: ext.textMuted, fontSize: 12, fontFamily: 'JetBrainsMono')),
                const Spacer(),
                if (showLive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: ext.success.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(3)),
                    child: Text('LIVE', style: TextStyle(color: ext.success, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.refresh, size: 14, color: ext.textMuted),
                  onPressed: _fetchLogs,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                  tooltip: 'Actualizar',
                ),
              ],
            ),
          ),

          // Log rows
          Expanded(
            child: showLive
                ? _buildLiveList(ext, wsLogs)
                : _buildPolledList(ext, _polledLogs),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveList(AuralixThemeExtension ext, List<WsLogEntry> logs) {
    if (logs.isEmpty) return _emptyState(ext);
    return ListView.builder(
      controller: _scrollCtrl,
      reverse: true,
      itemCount: logs.length,
      itemBuilder: (_, i) => _LogRow(
        method: logs[i].method,
        path: logs[i].path,
        statusCode: logs[i].statusCode,
        durationMs: logs[i].durationMs,
        ext: ext,
      ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.1),
    );
  }

  Widget _buildPolledList(AuralixThemeExtension ext, List<Map<String, dynamic>> logs) {
    if (logs.isEmpty) return _emptyState(ext);
    return ListView.builder(
      controller: _scrollCtrl,
      itemCount: logs.length,
      itemBuilder: (_, i) => _LogRow(
        method: logs[i]['method'] ?? 'GET',
        path: logs[i]['endpoint'] ?? '/',
        statusCode: logs[i]['statusCode'] ?? 200,
        durationMs: logs[i]['responseTimeMs'] ?? 0,
        ext: ext,
      ),
    );
  }

  Widget _emptyState(AuralixThemeExtension ext) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.terminal, size: 32, color: ext.textSubtle),
            const SizedBox(height: 8),
            Text('Ninguna solicitud aún', style: TextStyle(color: ext.textMuted, fontSize: 12)),
          ],
        ),
      );
}

class _LogRow extends StatelessWidget {
  final String method;
  final String path;
  final int statusCode;
  final int durationMs;
  final AuralixThemeExtension ext;

  const _LogRow({
    required this.method,
    required this.path,
    required this.statusCode,
    required this.durationMs,
    required this.ext,
  });

  Color get _statusColor {
    if (statusCode >= 500) return ext.error;
    if (statusCode >= 400) return ext.warning;
    if (statusCode >= 200 && statusCode < 300) return ext.success;
    return ext.textMuted;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        children: [
          // Method
          SizedBox(
            width: 52,
            child: Text(
              method,
              style: TextStyle(
                color: method == 'POST' ? ext.primary : method == 'DELETE' ? ext.error : ext.accentAlt,
                fontSize: 11,
                fontFamily: 'JetBrainsMono',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Status
          Container(
            width: 38,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              '$statusCode',
              style: TextStyle(color: _statusColor, fontSize: 11, fontFamily: 'JetBrainsMono'),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 10),
          // Path
          Expanded(
            child: Text(
              path,
              style: TextStyle(color: ext.text, fontSize: 12, fontFamily: 'JetBrainsMono'),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Duration
          Text(
            '${durationMs}ms',
            style: TextStyle(color: ext.textMuted, fontSize: 11, fontFamily: 'JetBrainsMono'),
          ),
        ],
      ),
    );
  }
}
