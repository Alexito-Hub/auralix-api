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

import '../providers/snippets_provider.dart';
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
  bool _showCreate = false;
  final _searchCtrl = TextEditingController();
  String _languageFilter = 'all';
  bool _onlyProtected = false;

  @override
  void dispose() {
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
    final snippets = ref.watch(snippetsProvider);
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
              child: SingleChildScrollView(
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
                            ref.invalidate(snippetsProvider);
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
                        child: snippets.when(
                          loading: () => SizedBox(
                            key: const ValueKey('snippets-loading'),
                            height: 180,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(
                                      color: ext.primary, strokeWidth: 2),
                                  const SizedBox(height: 16),
                                  TypewriterText(
                                      text: l10n.snippetsLoadingFragments,
                                      style: TextStyle(
                                          color: ext.primary,
                                          fontFamily: 'JetBrainsMono',
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                          error: (_, __) => SizedBox(
                            key: const ValueKey('snippets-error'),
                            height: 120,
                            child: Center(
                              child: Text(l10n.snippetsFetchError,
                                  style: TextStyle(
                                      color: ext.error,
                                      fontFamily: 'JetBrainsMono',
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          data: (list) {
                            final filtered = _applyFilters(list);
                            if (list.isEmpty) {
                              return SizedBox(
                                key: const ValueKey('snippets-empty-all'),
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
                                              fontFamily: 'JetBrainsMono',
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              );
                            }
                            if (filtered.isEmpty) {
                              return SizedBox(
                                key: const ValueKey('snippets-empty-filtered'),
                                height: 120,
                                child: Center(
                                  child: Text(l10n.snippetsEmptyFiltered,
                                      style: TextStyle(
                                          color: ext.textMuted,
                                          fontFamily: 'JetBrainsMono')),
                                ),
                              );
                            }

                            return Container(
                              key: ValueKey('snippets-list-${filtered.length}'),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      children: [
                                        Container(
                                            width: 4,
                                            height: 4,
                                            decoration: BoxDecoration(
                                                color: ext.primary,
                                                shape: BoxShape.circle)),
                                        const SizedBox(width: 8),
                                        Text(
                                          l10n.snippetsYieldSummary(
                                              filtered.length, list.length),
                                          style: TextStyle(
                                              color: ext.textMuted,
                                              fontSize: 11,
                                              fontFamily: 'JetBrainsMono',
                                              fontWeight: FontWeight.bold,
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
                                    itemBuilder: (_, i) =>
                                        _SnippetTile(
                                                snippet: filtered[i],
                                                key: ValueKey(
                                                    filtered[i]['shortId']),
                                                onUpdated: () => ref.invalidate(
                                                    snippetsProvider))
                                            .animate()
                                            .fadeIn(delay: (i * 50).ms)
                                            .slideX(begin: 0.05),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
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
