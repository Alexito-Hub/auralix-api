library snippets_screen;

import 'dart:math' as math;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hub_aura/l10n/app_localizations.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/languages/all.dart' as highlight_languages;

import '../../../core/network/api_client.dart';
import '../../../core/theme/theme_extension.dart';
import '../../../core/ui/breakpoints.dart';
import '../../../shared/code/adaptive_code_controller.dart';
import '../../../shared/code/code_diagnostics.dart';
import '../../../shared/code/code_highlighting.dart';
import '../../../shared/widgets/code_viewport.dart';
import '../../../shared/widgets/terminal_page_layout.dart';
import '../../../shared/widgets/terminal_widgets.dart';

part '../widgets/snippets_screen_widgets.dart';

const _languages = [
  'bash',
  'c',
  'cpp',
  'csharp',
  'css',
  'dart',
  'dos',
  'dockerfile',
  'go',
  'graphql',
  'ini',
  'html',
  'java',
  'javascript',
  'json',
  'kotlin',
  'lua',
  'makefile',
  'markdown',
  'php',
  'plaintext',
  'powershell',
  'protobuf',
  'python',
  'r',
  'ruby',
  'rust',
  'scala',
  'shell',
  'sql',
  'swift',
  'toml',
  'typescript',
  'xml',
  'yaml',
];

const _maxSnippetCodeBytes = 200000;

String _formatCodeBytes(int size) {
  if (size < 1024) return '${size}B';
  final kb = size / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(1)}KB';
  final mb = kb / 1024;
  return '${mb.toStringAsFixed(1)}MB';
}

String _languageFromFileName(String fileName) {
  final lower = fileName.toLowerCase();
  if (lower.endsWith('.js') ||
      lower.endsWith('.mjs') ||
      lower.endsWith('.cjs') ||
      lower.endsWith('.jsx')) {
    return 'javascript';
  }
  if (lower.endsWith('.ts') ||
      lower.endsWith('.tsx') ||
      lower.endsWith('.mts') ||
      lower.endsWith('.cts')) {
    return 'typescript';
  }
  if (lower.endsWith('.py')) return 'python';
  if (lower.endsWith('.dart')) return 'dart';
  if (lower.endsWith('.java')) return 'java';
  if (lower.endsWith('.kt')) return 'kotlin';
  if (lower.endsWith('.swift')) return 'swift';
  if (lower.endsWith('.go')) return 'go';
  if (lower.endsWith('.rs')) return 'rust';
  if (lower.endsWith('.rb')) return 'ruby';
  if (lower.endsWith('.php')) return 'php';
  if (lower.endsWith('.sql')) return 'sql';
  if (lower.endsWith('.sh') ||
      lower.endsWith('.bash') ||
      lower.endsWith('.zsh')) {
    return 'shell';
  }
  if (lower.endsWith('.ps1') ||
      lower.endsWith('.psm1') ||
      lower.endsWith('.bat') ||
      lower.endsWith('.cmd')) {
    return 'powershell';
  }
  if (lower.endsWith('.ini') ||
      lower.endsWith('.env') ||
      lower.endsWith('.conf') ||
      lower.endsWith('.properties')) {
    return 'ini';
  }
  if (lower.endsWith('.proto') || lower.endsWith('.pb')) return 'protobuf';
  if (lower == 'makefile') return 'makefile';
  if (lower.endsWith('.json')) return 'json';
  if (lower.endsWith('.yaml') || lower.endsWith('.yml')) return 'yaml';
  if (lower.endsWith('.toml')) return 'toml';
  if (lower.endsWith('.md')) return 'markdown';
  if (lower.endsWith('.xml')) return 'xml';
  if (lower.endsWith('.html') || lower.endsWith('.htm')) return 'html';
  if (lower.endsWith('.css')) return 'css';
  if (lower.endsWith('.graphql')) return 'graphql';
  if (lower.endsWith('.c')) return 'c';
  if (lower.endsWith('.cpp') ||
      lower.endsWith('.cc') ||
      lower.endsWith('.cxx')) {
    return 'cpp';
  }
  if (lower.endsWith('.cs')) return 'csharp';
  return 'plaintext';
}

String _titleFromFileName(String fileName) {
  final trimmed = fileName.trim();
  if (trimmed.isEmpty) return 'untitled';
  final dot = trimmed.lastIndexOf('.');
  final base = dot > 0 ? trimmed.substring(0, dot) : trimmed;
  return base.trim().isEmpty ? 'untitled' : base.trim();
}

class SnippetsScreen extends ConsumerStatefulWidget {
  const SnippetsScreen({super.key});

  @override
  ConsumerState<SnippetsScreen> createState() => _SnippetsScreenState();
}

class _SnippetsScreenState extends ConsumerState<SnippetsScreen> {
  static const int _pageSize = 20;

  bool _showCreate = false;
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  String _languageFilter = 'all';
  bool _onlyProtected = false;

  final List<Map<String, dynamic>> _snippets = [];
  bool _initialLoading = true;
  bool _loadingMore = false;
  bool _refreshing = false;
  String? _loadError;
  int _page = 1;
  int _pages = 1;
  int _total = 0;

  bool get _hasMore => _page < _pages;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    _fetchSnippets(reset: true);
  }

  Future<void> _refreshFeed() => _fetchSnippets(reset: true);

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    if (_scrollCtrl.position.extentAfter < 320) {
      _fetchSnippets(loadMore: true);
    }
  }

  List<Map<String, dynamic>> _extractItems(dynamic payload) {
    if (payload is List) {
      return payload
          .whereType<Map>()
          .map((row) => row.map((k, v) => MapEntry(k.toString(), v)))
          .toList();
    }
    if (payload is Map && payload['items'] is List) {
      final items = payload['items'] as List;
      return items
          .whereType<Map>()
          .map((row) => row.map((k, v) => MapEntry(k.toString(), v)))
          .toList();
    }
    return const <Map<String, dynamic>>[];
  }

  List<Map<String, dynamic>> _mergeByShortId(
    List<Map<String, dynamic>> current,
    List<Map<String, dynamic>> incoming,
  ) {
    final merged = <String, Map<String, dynamic>>{};
    for (final row in current) {
      final shortId = (row['shortId'] ?? '').toString();
      if (shortId.isEmpty) continue;
      merged[shortId] = row;
    }
    for (final row in incoming) {
      final shortId = (row['shortId'] ?? '').toString();
      if (shortId.isEmpty) continue;
      merged[shortId] = row;
    }
    final out = merged.values.toList();
    out.sort((a, b) {
      final left = DateTime.tryParse((a['createdAt'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final right = DateTime.tryParse((b['createdAt'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return right.compareTo(left);
    });
    return out;
  }

  Future<void> _fetchSnippets({bool reset = false, bool loadMore = false}) async {
    if (loadMore && (_initialLoading || _refreshing || _loadingMore || !_hasMore)) {
      return;
    }
    if (reset && (_refreshing || _loadingMore)) {
      return;
    }

    final targetPage = loadMore ? (_page + 1) : 1;
    setState(() {
      if (loadMore) {
        _loadingMore = true;
      } else if (_snippets.isEmpty) {
        _initialLoading = true;
      } else {
        _refreshing = true;
      }
      _loadError = null;
    });

    try {
      final res = await ApiClient.instance.get('/hub/snippets', params: {
        'page': '$targetPage',
        'limit': '$_pageSize',
      });

      if (res.data is Map && res.data['status'] == true) {
        final payload = res.data['data'];
        final items = _extractItems(payload);
        final pagination = res.data['pagination'];

        int nextTotal = items.length;
        int nextPage = targetPage;
        int nextPages = 1;

        if (pagination is Map) {
          nextTotal = int.tryParse('${pagination['total'] ?? items.length}') ??
              items.length;
          nextPage = int.tryParse('${pagination['page'] ?? targetPage}') ??
              targetPage;
          nextPages = int.tryParse('${pagination['pages'] ?? 1}') ?? 1;
        }

        final merged = loadMore ? _mergeByShortId(_snippets, items) : items;
        if (!mounted) return;
        setState(() {
          _snippets
            ..clear()
            ..addAll(merged);
          _total = nextTotal;
          _page = nextPage;
          _pages = nextPages < 1 ? 1 : nextPages;
          _initialLoading = false;
          _loadingMore = false;
          _refreshing = false;
          _loadError = null;
        });
        return;
      }

      final message =
          (res.data is Map ? res.data['msg'] : null)?.toString() ??
              'Failed to load snippets';
      if (!mounted) return;
      setState(() {
        _initialLoading = false;
        _loadingMore = false;
        _refreshing = false;
        _loadError = message;
      });
    } on DioException catch (e) {
      final payload = e.response?.data;
      final message = payload is Map ? payload['msg']?.toString() : null;
      if (!mounted) return;
      setState(() {
        _initialLoading = false;
        _loadingMore = false;
        _refreshing = false;
        _loadError = message ?? 'Connection error';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _initialLoading = false;
        _loadingMore = false;
        _refreshing = false;
        _loadError = 'Failed to load snippets';
      });
    }
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<DropdownMenuItem<String>> _languageItems(AppLocalizations l10n) {
    return [
      DropdownMenuItem<String>(
          value: 'all', child: Text(l10n.snippetsAnyLanguage)),
      ..._languages.map((language) => DropdownMenuItem<String>(
          value: language, child: Text(language.toUpperCase()))),
    ];
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> list) {
    final query = _searchCtrl.text.trim().toLowerCase();
    return list.where((snippet) {
      final title = (snippet['title'] ?? '').toString().toLowerCase();
      final language =
          (snippet['language'] ?? 'plaintext').toString().toLowerCase();
      final shortId = (snippet['shortId'] ?? '').toString().toLowerCase();
      final owner = (snippet['owner'] ?? {}) as Map<String, dynamic>;
      final ownerName = (owner['displayName'] ?? '').toString().toLowerCase();
      final ownerEmail = (owner['email'] ?? '').toString().toLowerCase();
      final preview = (snippet['codePreview'] ?? '').toString().toLowerCase();
      final hasPassword = snippet['hasPassword'] == true;

      final matchesQuery = query.isEmpty ||
          title.contains(query) ||
          language.contains(query) ||
          shortId.contains(query) ||
          ownerName.contains(query) ||
          ownerEmail.contains(query) ||
          preview.contains(query);
      final matchesLanguage =
          _languageFilter == 'all' || language == _languageFilter;
      final matchesProtected = !_onlyProtected || hasPassword;

      return matchesQuery && matchesLanguage && matchesProtected;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;
    final compact = context.isMobile;

    return Scaffold(
      backgroundColor: ext.bg,
      body: Stack(
        children: [
          // Matrix BG Glow
          Positioned(
            top: -150,
            right: -100,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ext.accent.withValues(alpha: 0.05),
                    Colors.transparent
                  ],
                  stops: const [0.1, 1.0],
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                    duration: 4.seconds,
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.05, 1.05))
                .fade(),
          ),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: context.pageMaxWidth),
              child: RefreshIndicator(
                color: ext.primary,
                onRefresh: _refreshFeed,
                child: SingleChildScrollView(
                  controller: _scrollCtrl,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(context.pageHorizontalPadding, 20,
                      context.pageHorizontalPadding, 24),
                  child: TerminalPageReveal(
                    animationKey: 'snippets-screen',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      TerminalPageHeader(
                        title: l10n.navSnippets.toLowerCase(),
                        subtitle: l10n.snippetsSubtitle,
                        actions: [
                          _HoverCreateButton(
                            isCreating: _showCreate,
                            onPressed: () =>
                                setState(() => _showCreate = !_showCreate),
                            ext: ext,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Dynamic Control Panel
                      _CyberFilterPanel(
                        compact: compact,
                        ext: ext,
                        l10n: l10n,
                        searchCtrl: _searchCtrl,
                        languageFilter: _languageFilter,
                        onlyProtected: _onlyProtected,
                        languageItems: _languageItems(l10n),
                        onLanguageChanged: (val) =>
                            setState(() => _languageFilter = val ?? 'all'),
                        onProtectedChanged: (val) =>
                            setState(() => _onlyProtected = val),
                        onClear: () => setState(() {
                          _searchCtrl.clear();
                          _languageFilter = 'all';
                          _onlyProtected = false;
                        }),
                        onSearchChanged: () => setState(() {}),
                      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05),

                      const SizedBox(height: 24),

                      // Create Form Injection
                      if (_showCreate) ...[
                        _CreateSnippetCard(
                          onCreated: () {
                            setState(() => _showCreate = false);
                            _refreshFeed();
                          },
                        ).animate().fadeIn().slideY(begin: -0.1),
                        const SizedBox(height: 24),
                      ],

                      // Feed
                      AnimatedSwitcher(
                        duration: 300.ms,
                        switchInCurve: Curves.easeOutBack,
                        switchOutCurve: Curves.easeInCubic,
                        layoutBuilder: (curr, prev) => Stack(
                            alignment: Alignment.topCenter,
                            children: <Widget>[...prev].followedBy(
                                <Widget>[if (curr != null) curr]).toList()),
                        child: _initialLoading && _snippets.isEmpty
                            ? _SnippetsFeedSkeleton(ext: ext, l10n: l10n)
                            : _loadError != null && _snippets.isEmpty
                                ? SizedBox(
                                    key: const ValueKey('snippets-error'),
                                    height: 160,
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _loadError ?? l10n.snippetsFetchError,
                                            style: TextStyle(
                                                color: ext.error,
                                                fontFamily: 'JetBrainsMono',
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 10),
                                          TextButton(
                                            onPressed: _refreshFeed,
                                            child: Text(l10n.commonRetry),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(
                                    key: ValueKey(
                                    'snippets-list-${_snippets.length}-$_page-${_loadingMore ? 1 : 0}'),
                                    child: Builder(builder: (_) {
                                      final filtered = _applyFilters(_snippets);
                                      if (_snippets.isEmpty) {
                                        return SizedBox(
                                          key: const ValueKey(
                                              'snippets-empty-all'),
                                          height: 180,
                                          child: Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.code_off,
                                                    size: 48,
                                                    color: ext.textMuted
                                                        .withValues(alpha: 0.2)),
                                                const SizedBox(height: 16),
                                                Text(l10n.snippetsEmptyAll,
                                                    style: TextStyle(
                                                        color: ext.textMuted,
                                                        fontFamily:
                                                            'JetBrainsMono',
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            ),
                                          ),
                                        );
                                      }

                                      if (filtered.isEmpty) {
                                        return SizedBox(
                                          key: const ValueKey(
                                              'snippets-empty-filtered'),
                                          height: 120,
                                          child: Center(
                                            child: Text(
                                                l10n.snippetsEmptyFiltered,
                                                style: TextStyle(
                                                    color: ext.textMuted,
                                                    fontFamily:
                                                        'JetBrainsMono')),
                                          ),
                                        );
                                      }

                                      final summaryTotal =
                                          _total > 0 ? _total : _snippets.length;
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (_refreshing)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 12),
                                              child: LinearProgressIndicator(
                                                minHeight: 2,
                                                color: ext.primary,
                                                backgroundColor: ext.border,
                                              ),
                                            ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(bottom: 12),
                                            child: Row(
                                              children: [
                                                Container(
                                                    width: 4,
                                                    height: 4,
                                                    decoration: BoxDecoration(
                                                        color: ext.primary,
                                                        shape:
                                                            BoxShape.circle)),
                                                const SizedBox(width: 8),
                                                Text(
                                                  l10n.snippetsYieldSummary(
                                                      filtered.length,
                                                      summaryTotal),
                                                  style: TextStyle(
                                                      color: ext.textMuted,
                                                      fontSize: 11,
                                                      fontFamily:
                                                          'JetBrainsMono',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 1.0),
                                                ),
                                              ],
                                            ),
                                          ),
                                          ListView.separated(
                                            itemCount: filtered.length,
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            separatorBuilder: (_, __) =>
                                                const SizedBox(height: 12),
                                            itemBuilder: (_, i) => _SnippetTile(
                                                    snippet: filtered[i],
                                                    key: ValueKey(
                                                        filtered[i]['shortId']),
                                                    onUpdated: _refreshFeed)
                                                .animate()
                                                .fadeIn(delay: (i * 50).ms)
                                                .slideX(begin: 0.05),
                                          ),
                                          if (_loadingMore)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 14, bottom: 8),
                                              child: Center(
                                                child: SizedBox(
                                                  height: 18,
                                                  width: 18,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: ext.primary,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    }),
                                  ),
                      ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SnippetsFeedSkeleton extends StatelessWidget {
  final AuralixThemeExtension ext;
  final AppLocalizations l10n;

  const _SnippetsFeedSkeleton({required this.ext, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('snippets-loading'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: TypewriterText(
              text: l10n.snippetsLoadingFragments,
              style: TextStyle(
                color: ext.primary,
                fontFamily: 'JetBrainsMono',
                fontSize: 12,
              ),
            ),
          ),
          ...List.generate(
            4,
            (index) => Container(
              margin: EdgeInsets.only(bottom: index == 3 ? 0 : 12),
              height: 98,
              decoration: BoxDecoration(
                color: ext.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ext.border),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fade(begin: 0.45, end: 1, duration: (700 + (index * 80)).ms),
          ),
        ],
      ),
    );
  }
}
