import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hub_aura/l10n/app_localizations.dart';
import '../../../core/theme/theme_extension.dart';
import '../../../core/network/api_client.dart';
import '../../../core/ui/breakpoints.dart';
import '../../../shared/widgets/terminal_page_layout.dart';
import '../../../shared/widgets/terminal_widgets.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  static const String _connectionErrorKey = '__connection_error__';

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
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiClient.instance.get('/hub/user/history', params: {
        'page': '$page',
        'limit': '25',
      });
      if (res.data['status'] == true) {
        setState(() {
          _logs =
              List<Map<String, dynamic>>.from(res.data['data']['logs'] ?? []);
          _page = res.data['data']['page'] ?? 1;
          _totalPages = res.data['data']['pages'] ?? 1;
          _loading = false;
        });
      } else {
        setState(() {
          _error = res.data['msg'];
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = _connectionErrorKey;
        _loading = false;
      });
    }
  }

  String _resolvedError(AppLocalizations l10n) {
    if (_error == _connectionErrorKey) return l10n.commonConnectionError;
    return _error ?? '';
  }

  List<Map<String, dynamic>> get _filtered {
    switch (_filter) {
      case 'success':
        return _logs.where((l) {
          final code = _asInt(l['statusCode']);
          return code != null && code < 400;
        }).toList();
      case 'error':
        return _logs.where((l) {
          final code = _asInt(l['statusCode']) ?? 0;
          return code >= 400;
        }).toList();
      case 'sandbox':
        return _logs.where((l) => l['isSandbox'] == true).toList();
      default:
        return _logs;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;
    final hPadding = context.pageHorizontalPadding;
    final maxWidth = context.pageMaxWidth;
    final isCompact = context.isMobile;
    return Scaffold(
      backgroundColor: ext.bg,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: EdgeInsets.fromLTRB(hPadding, 20, hPadding, 24),
            child: TerminalPageReveal(
              animationKey: 'history-main',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TerminalPageHeader(
                    title: l10n.navHistory.toLowerCase(),
                    subtitle: l10n.historySubtitle,
                    actions: [
                      IconButton(
                        icon:
                            Icon(Icons.refresh, size: 16, color: ext.textMuted),
                        onPressed: () => _fetch(page: _page),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Filter chips
                  GlowCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.historyRecordsInView(_filtered.length),
                          style: TextStyle(
                            color: ext.textMuted,
                            fontSize: 11.5,
                            fontFamily: 'JetBrainsMono',
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: {
                            'all': l10n.historyFilterAll,
                            'success': l10n.historyFilterSuccess,
                            'error': l10n.historyFilterError,
                            'sandbox': l10n.historyFilterSandbox,
                          }
                              .entries
                              .map((entry) => FilterChip(
                                    label: Text(entry.value,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'JetBrainsMono')),
                                    selected: _filter == entry.key,
                                    onSelected: (_) =>
                                        setState(() => _filter = entry.key),
                                    selectedColor:
                                        ext.primary.withValues(alpha: 0.2),
                                    checkmarkColor: ext.primary,
                                    labelStyle: TextStyle(
                                        color: _filter == entry.key
                                            ? ext.primary
                                            : ext.textMuted),
                                    backgroundColor: ext.surface,
                                    side: BorderSide(
                                        color: _filter == entry.key
                                            ? ext.primary
                                            : ext.border),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Table / list
                  Expanded(
                    child: _loading
                        ? _HistoryLoadingSkeleton(
                            ext: ext,
                            compact: isCompact,
                          )
                        : _error != null
                            ? Center(
                                child: Text(_resolvedError(l10n),
                                    style: TextStyle(color: ext.error)))
                            : _buildTable(ext, isCompact, l10n),
                  ),

                  // Pagination
                  if (_totalPages > 1)
                    Center(
                      child: GlowCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: _page > 1
                                  ? () => _fetch(page: _page - 1)
                                  : null,
                              color: ext.textMuted,
                            ),
                            Text('$_page / $_totalPages',
                                style: TextStyle(
                                    color: ext.textMuted, fontSize: 12)),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: _page < _totalPages
                                  ? () => _fetch(page: _page + 1)
                                  : null,
                              color: ext.textMuted,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTable(
      AuralixThemeExtension ext, bool compact, AppLocalizations l10n) {
    final rows = _filtered;
    if (rows.isEmpty) {
      return Center(
        child: Text(l10n.historyNoRequestsInCategory,
            style: TextStyle(color: ext.textMuted, fontSize: 13)),
      );
    }

    if (compact) {
      return RefreshIndicator(
        color: ext.primary,
        onRefresh: () => _fetch(page: 1),
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: rows.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final l = rows[i];
            final code = _asInt(l['statusCode']) ?? 200;
            final responseMs = _asInt(l['responseTimeMs']) ?? 0;
            final deducted = _asInt(l['creditsDeducted']) ?? 0;
            final color = code >= 500
                ? ext.error
                : code >= 400
                    ? ext.warning
                    : ext.success;
            return GlowCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(l['method'] ?? 'GET',
                          style: TextStyle(
                              color: ext.primary,
                              fontSize: 12,
                              fontFamily: 'JetBrainsMono',
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(3)),
                        child: Text('$code',
                            style: TextStyle(
                                color: color,
                                fontSize: 11,
                                fontFamily: 'JetBrainsMono')),
                      ),
                      const Spacer(),
                      Text('${responseMs}ms',
                          style: TextStyle(
                              color: ext.textMuted,
                              fontSize: 11,
                              fontFamily: 'JetBrainsMono')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(l['endpoint'] ?? '/',
                      style: TextStyle(
                          color: ext.text,
                          fontSize: 12,
                          fontFamily: 'JetBrainsMono'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    children: [
                      Text(
                        l10n.historyCredit(
                          deducted == 0 ? '-' : '-$deducted',
                        ),
                        style: TextStyle(
                            color: deducted == 0 ? ext.textMuted : ext.warning,
                            fontSize: 11,
                            fontFamily: 'JetBrainsMono'),
                      ),
                      Text(
                        l['isSandbox'] == true
                            ? l10n.historyEnvironmentSandbox
                            : l10n.historyEnvironmentProduction,
                        style: TextStyle(
                            color: ext.textSubtle,
                            fontSize: 11,
                            fontFamily: 'JetBrainsMono'),
                      ),
                    ],
                  ),
                ],
              ).animate().fadeIn(duration: 180.ms),
            );
          },
        ),
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
              _hdr(l10n.historyColumnMethod, 70, ext),
              _hdr(l10n.historyColumnStatus, 60, ext),
              _hdr(l10n.historyColumnEndpoint, null, ext),
              _hdr(l10n.historyColumnTime, 80, ext),
              _hdr(l10n.historyColumnCredit, 80, ext),
            ]),
          ),
          // Data rows
          Expanded(
            child: RefreshIndicator(
              color: ext.primary,
              onRefresh: () => _fetch(page: 1),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: rows.length,
                separatorBuilder: (_, __) =>
                    Divider(color: ext.border, height: 1),
                itemBuilder: (_, i) {
                  final l = rows[i];
                  final code = _asInt(l['statusCode']) ?? 200;
                  final responseMs = _asInt(l['responseTimeMs']) ?? 0;
                  final deducted = _asInt(l['creditsDeducted']) ?? 0;
                  final color = code >= 500
                      ? ext.error
                      : code >= 400
                          ? ext.warning
                          : ext.success;
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(children: [
                      SizedBox(
                          width: 70,
                          child: Text(l['method'] ?? 'GET',
                              style: TextStyle(
                                  color: ext.primary,
                                  fontSize: 12,
                                  fontFamily: 'JetBrainsMono',
                                  fontWeight: FontWeight.bold))),
                      SizedBox(
                          width: 60,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(3)),
                            child: Text('$code',
                                style: TextStyle(
                                    color: color,
                                    fontSize: 11,
                                    fontFamily: 'JetBrainsMono'),
                                textAlign: TextAlign.center),
                          )),
                      Expanded(
                          child: Text(l['endpoint'] ?? '/',
                              style: TextStyle(
                                  color: ext.text,
                                  fontSize: 12,
                                  fontFamily: 'JetBrainsMono'),
                              overflow: TextOverflow.ellipsis)),
                      SizedBox(
                          width: 80,
                          child: Text('${responseMs}ms',
                              style: TextStyle(
                                  color: ext.textMuted,
                                  fontSize: 11,
                                  fontFamily: 'JetBrainsMono'),
                              textAlign: TextAlign.end)),
                      SizedBox(
                          width: 80,
                          child: Text(deducted == 0 ? '-' : '-$deducted',
                              style: TextStyle(
                                  color: deducted == 0
                                      ? ext.textMuted
                                      : ext.warning,
                                  fontSize: 11,
                                  fontFamily: 'JetBrainsMono'),
                              textAlign: TextAlign.end)),
                    ]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  Widget _hdr(String t, double? width, AuralixThemeExtension ext) {
    final w = SizedBox(
        width: width,
        child: Text(t,
            style: TextStyle(
                color: ext.textSubtle,
                fontSize: 10,
                fontFamily: 'JetBrainsMono',
                fontWeight: FontWeight.bold)));
    return width == null ? Expanded(child: w) : w;
  }
}

class _HistoryLoadingSkeleton extends StatelessWidget {
  final AuralixThemeExtension ext;
  final bool compact;

  const _HistoryLoadingSkeleton({required this.ext, required this.compact});

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => Container(
          height: 94,
          decoration: BoxDecoration(
            color: ext.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: ext.border),
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fade(begin: 0.45, end: 1, duration: (650 + (i * 60)).ms),
      );
    }

    return GlowCard(
      padding: const EdgeInsets.all(12),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: 8,
        separatorBuilder: (_, __) => Divider(color: ext.border, height: 1),
        itemBuilder: (_, i) => Container(
          height: 32,
          decoration: BoxDecoration(
            color: ext.surfaceVariant.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(4),
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fade(begin: 0.4, end: 1, duration: (620 + (i * 40)).ms),
      ),
    );
  }
}
