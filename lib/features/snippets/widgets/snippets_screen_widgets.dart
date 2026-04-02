part of '../screens/snippets_screen.dart';

String _coerceSnippetLanguageForEditor(String rawLanguage) {
  final raw = rawLanguage.trim().toLowerCase();
  if (raw.isEmpty) return 'plaintext';

  // Keep explicit HTML selection when possible while still highlighting as XML.
  if ((raw == 'html' || raw == 'htm') && _languages.contains('html')) {
    return 'html';
  }

  final normalized = normalizeCodeLanguage(raw);
  if (_languages.contains(normalized)) return normalized;

  final sanitized = sanitizeCodeLanguage(raw, fallback: '');
  if (_languages.contains(sanitized)) return sanitized;

  final inferredFromExt = inferCodeLanguageFromTitle('snippet.$raw');
  final safeFromExt = sanitizeCodeLanguage(inferredFromExt, fallback: '');
  if (_languages.contains(safeFromExt)) return safeFromExt;

  return 'plaintext';
}

dynamic _resolveHighlightModeForEditor({
  required String safeLanguage,
  required String code,
}) {
  final fromDeclared = highlight_languages.builtinLanguages[safeLanguage] ??
      highlight_languages.communityLanguages[safeLanguage];
  if (fromDeclared != null) return fromDeclared;

  final guessed = sanitizeCodeLanguage(
    guessCodeLanguageFromCode(code),
    fallback: 'javascript',
  );
  final fromGuess = highlight_languages.builtinLanguages[guessed] ??
      highlight_languages.communityLanguages[guessed];
  if (fromGuess != null) return fromGuess;

  final jsFallback = highlight_languages.builtinLanguages['javascript'] ??
      highlight_languages.communityLanguages['javascript'];
  if (jsFallback != null) return jsFallback;

  if (highlight_languages.builtinLanguages.isNotEmpty) {
    return highlight_languages.builtinLanguages.values.first;
  }
  if (highlight_languages.communityLanguages.isNotEmpty) {
    return highlight_languages.communityLanguages.values.first;
  }

  return null;
}

class _HoverCreateButton extends StatefulWidget {
  final bool isCreating;
  final VoidCallback onPressed;
  final AuralixThemeExtension ext;

  const _HoverCreateButton(
      {required this.isCreating, required this.onPressed, required this.ext});

  @override
  State<_HoverCreateButton> createState() => _HoverCreateButtonState();
}

class _HoverCreateButtonState extends State<_HoverCreateButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: 200.ms,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isCreating
                ? widget.ext.surfaceVariant
                : (_hovering
                    ? widget.ext.primary.withValues(alpha: 0.9)
                    : widget.ext.primary),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
                color:
                    widget.isCreating ? widget.ext.border : widget.ext.primary),
            boxShadow: [
              if (!widget.isCreating && _hovering)
                BoxShadow(
                    color: widget.ext.primary.withValues(alpha: 0.4),
                    blurRadius: 10)
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.isCreating ? Icons.close : Icons.add_box,
                  size: 14,
                  color: widget.isCreating ? widget.ext.text : widget.ext.bg),
              const SizedBox(width: 8),
              Text(
                widget.isCreating
                    ? l10n.snippetsCreateAbort
                    : l10n.snippetsCreateNew,
                style: TextStyle(
                  color: widget.isCreating ? widget.ext.text : widget.ext.bg,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'JetBrainsMono',
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CyberFilterPanel extends StatelessWidget {
  final bool compact;
  final AuralixThemeExtension ext;
  final AppLocalizations l10n;
  final TextEditingController searchCtrl;
  final String languageFilter;
  final bool onlyProtected;
  final List<DropdownMenuItem<String>> languageItems;
  final ValueChanged<String?> onLanguageChanged;
  final ValueChanged<bool> onProtectedChanged;
  final VoidCallback onClear;
  final VoidCallback onSearchChanged;

  const _CyberFilterPanel({
    required this.compact,
    required this.ext,
    required this.l10n,
    required this.searchCtrl,
    required this.languageFilter,
    required this.onlyProtected,
    required this.languageItems,
    required this.onLanguageChanged,
    required this.onProtectedChanged,
    required this.onClear,
    required this.onSearchChanged,
  });

  Widget _searchField() {
    return TextFormField(
      controller: searchCtrl,
      onChanged: (_) => onSearchChanged(),
      style:
          TextStyle(color: ext.text, fontFamily: 'JetBrainsMono', fontSize: 12),
      decoration: InputDecoration(
        filled: true,
        fillColor: ext.bg.withValues(alpha: 0.5),
        prefixIcon: Icon(Icons.search, size: 16, color: ext.primary),
        hintText: l10n.snippetsSearchHint,
        hintStyle: TextStyle(
            color: ext.textMuted, fontSize: 12, fontFamily: 'JetBrainsMono'),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: OutlineBorder(color: ext.border),
        focusedBorder: OutlineBorder(color: ext.primary),
      ),
    );
  }

  Widget _languageDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: ext.bg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: ext.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          key: ValueKey(languageFilter),
          value: languageFilter,
          dropdownColor: ext.surfaceVariant,
          icon: Icon(Icons.keyboard_arrow_down, size: 16, color: ext.primary),
          isExpanded: true,
          style: TextStyle(
              color: ext.text, fontFamily: 'JetBrainsMono', fontSize: 12),
          items: languageItems,
          onChanged: onLanguageChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ext.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ext.border),
        boxShadow: [
          BoxShadow(color: ext.primary.withValues(alpha: 0.05), blurRadius: 10)
        ],
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _searchField(),
                const SizedBox(height: 12),
                _languageDropdown(),
                const SizedBox(height: 12),
                _FilterActions(
                  onlyProtected: onlyProtected,
                  onProtectedChanged: onProtectedChanged,
                  onClear: onClear,
                  hasActiveFilters: searchCtrl.text.trim().isNotEmpty ||
                      languageFilter != 'all' ||
                      onlyProtected,
                  ext: ext,
                ),
              ],
            )
          : Row(
              children: [
                Expanded(flex: 3, child: _searchField()),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: _languageDropdown()),
                const SizedBox(width: 16),
                _FilterActions(
                  onlyProtected: onlyProtected,
                  onProtectedChanged: onProtectedChanged,
                  onClear: onClear,
                  hasActiveFilters: searchCtrl.text.trim().isNotEmpty ||
                      languageFilter != 'all' ||
                      onlyProtected,
                  ext: ext,
                ),
              ],
            ),
    );
  }
}

class OutlineBorder extends OutlineInputBorder {
  OutlineBorder({required Color color})
      : super(
            borderSide: BorderSide(color: color),
            borderRadius: const BorderRadius.all(Radius.circular(6)));
}

class _FilterActions extends StatelessWidget {
  final bool onlyProtected;
  final ValueChanged<bool> onProtectedChanged;
  final VoidCallback onClear;
  final bool hasActiveFilters;
  final AuralixThemeExtension ext;

  const _FilterActions(
      {required this.onlyProtected,
      required this.onProtectedChanged,
      required this.onClear,
      required this.hasActiveFilters,
      required this.ext});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        InkWell(
          onTap: () => onProtectedChanged(!onlyProtected),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(onlyProtected ? Icons.lock : Icons.lock_open,
                    size: 14,
                    color: onlyProtected ? ext.warning : ext.textMuted),
                const SizedBox(width: 6),
                Text(l10n.snippetsSecureOnly,
                    style: TextStyle(
                        color: onlyProtected ? ext.warning : ext.textMuted,
                        fontSize: 11,
                        fontFamily: 'JetBrainsMono')),
              ],
            ),
          ),
        ),
        if (hasActiveFilters)
          InkWell(
            onTap: onClear,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.clear_all, size: 14, color: ext.error),
                  const SizedBox(width: 6),
                  Text(l10n.snippetsResetFilters,
                      style: TextStyle(
                          color: ext.error,
                          fontSize: 11,
                          fontFamily: 'JetBrainsMono',
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _SnippetTile extends StatefulWidget {
  final Map<String, dynamic> snippet;
  final VoidCallback? onUpdated;

  const _SnippetTile({
    super.key,
    required this.snippet,
    this.onUpdated,
  });

  @override
  State<_SnippetTile> createState() => _SnippetTileState();
}

class _SnippetTileState extends State<_SnippetTile> {
  bool _hovering = false;

  String get _shortId => (widget.snippet['shortId'] ?? '').toString();

  String get _shareUrl => 'https://hub.auralixpe.xyz/s/$_shortId';

  String _formatTimestamp(dynamic value) {
    final parsed = DateTime.tryParse((value ?? '').toString());
    if (parsed == null) return '--';

    final now = DateTime.now();
    final diff = now.difference(parsed.toLocal());
    if (diff.inDays >= 1) {
      final month = parsed.month.toString().padLeft(2, '0');
      final day = parsed.day.toString().padLeft(2, '0');
      return '${parsed.year}-$month-$day';
    }
    if (diff.inHours >= 1) return '${diff.inHours}h';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m';
    return '${math.max(diff.inSeconds, 0)}s';
  }

  Future<void> _openEditor() async {
    if (_shortId.isEmpty) return;

    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _EditSnippetDialog(shortId: _shortId),
      ),
    );

    if (updated == true) {
      widget.onUpdated?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;
    final owner = widget.snippet['owner'] is Map
        ? Map<String, dynamic>.from(widget.snippet['owner'] as Map)
        : const <String, dynamic>{};
    final ownerLabel = ((owner['displayName'] ?? owner['email']) ?? 'anonymous')
        .toString()
        .trim();
    final preview =
        normalizeCodeText((widget.snippet['codePreview'] ?? '').toString())
            .split('\n')
            .map((line) => line.trimRight())
            .where((line) => line.trim().isNotEmpty)
            .take(2)
            .join('\n');
    final updatedAt = _formatTimestamp(widget.snippet['updatedAt']);
    final views = (widget.snippet['viewCount'] ?? 0).toString();
    final langLabel = (widget.snippet['language'] ?? 'txt').toString();
    final shortLang = langLabel.substring(0, math.min(3, langLabel.length));

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go('/s/$_shortId'),
        child: AnimatedContainer(
          duration: 200.ms,
          curve: Curves.easeOutCubic,
          transform: _hovering
              ? Matrix4.translationValues(4, 0, 0)
              : Matrix4.identity(),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ext.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: _hovering
                    ? ext.primary.withValues(alpha: 0.5)
                    : ext.border),
            boxShadow: [
              if (_hovering)
                BoxShadow(
                    color: ext.primary.withValues(alpha: 0.1),
                    blurRadius: 10,
                    spreadRadius: 1)
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: ext.bg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: ext.border),
                ),
                child: Center(
                  child: Text(
                    shortLang.toUpperCase(),
                    style: TextStyle(
                        color: ext.primary,
                        fontSize: 10,
                        fontFamily: 'JetBrainsMono',
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.snippet['title'] ?? l10n.snippetsUntitled,
                      style: TextStyle(
                          color: ext.text,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'JetBrainsMono',
                          letterSpacing: 0.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if (preview.isNotEmpty)
                      Text(
                        preview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: ext.textMuted,
                          fontSize: 11,
                          fontFamily: 'JetBrainsMono',
                          height: 1.45,
                        ),
                      ),
                    if (preview.isNotEmpty) const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.link, size: 12, color: ext.textMuted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(_shareUrl,
                              style: TextStyle(
                                  color: ext.textMuted,
                                  fontSize: 11,
                                  fontFamily: 'JetBrainsMono'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 10,
                      runSpacing: 6,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_outline,
                                size: 11, color: ext.textSubtle),
                            const SizedBox(width: 4),
                            Text(
                              ownerLabel.isEmpty ? 'anonymous' : ownerLabel,
                              style: TextStyle(
                                color: ext.textSubtle,
                                fontSize: 10,
                                fontFamily: 'JetBrainsMono',
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.visibility_outlined,
                                size: 11, color: ext.textSubtle),
                            const SizedBox(width: 4),
                            Text(
                              views,
                              style: TextStyle(
                                color: ext.textSubtle,
                                fontSize: 10,
                                fontFamily: 'JetBrainsMono',
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.schedule,
                                size: 11, color: ext.textSubtle),
                            const SizedBox(width: 4),
                            Text(
                              updatedAt,
                              style: TextStyle(
                                color: ext.textSubtle,
                                fontSize: 10,
                                fontFamily: 'JetBrainsMono',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (widget.snippet['hasPassword'] == true)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                          color: ext.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: ext.warning.withValues(alpha: 0.3))),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock, size: 10, color: ext.warning),
                          const SizedBox(width: 4),
                          Text(l10n.snippetsEncrypted,
                              style: TextStyle(
                                  color: ext.warning,
                                  fontSize: 9,
                                  fontFamily: 'JetBrainsMono',
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  if (widget.snippet['allowRaw'] == false)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: ext.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                        border:
                            Border.all(color: ext.error.withValues(alpha: 0.3)),
                      ),
                      child: Text('RAW OFF',
                          style: TextStyle(
                              color: ext.error,
                              fontSize: 9,
                              fontFamily: 'JetBrainsMono',
                              fontWeight: FontWeight.bold)),
                    ),
                  if (widget.snippet['allowDownload'] == false)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: ext.warning.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: ext.warning.withValues(alpha: 0.3)),
                      ),
                      child: Text('DL OFF',
                          style: TextStyle(
                              color: ext.warning,
                              fontSize: 9,
                              fontFamily: 'JetBrainsMono',
                              fontWeight: FontWeight.bold)),
                    ),
                  IconButton(
                    icon: Icon(Icons.edit,
                        size: 16,
                        color: _hovering ? ext.primary : ext.textMuted),
                    tooltip: 'Edit fragment',
                    onPressed: _openEditor,
                  ),
                  IconButton(
                    icon: Icon(Icons.copy,
                        size: 16,
                        color: _hovering ? ext.primary : ext.textMuted),
                    tooltip: l10n.snippetsCopyUrl,
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: _shareUrl));
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(l10n.snippetsCopyUrlSuccess,
                            style: const TextStyle(
                                fontFamily: 'JetBrainsMono', fontSize: 12)),
                        backgroundColor: ext.surfaceVariant,
                        behavior: SnackBarBehavior.floating,
                      ));
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditSnippetDialog extends StatefulWidget {
  final String shortId;

  const _EditSnippetDialog({required this.shortId});

  @override
  State<_EditSnippetDialog> createState() => _EditSnippetDialogState();
}

class _EditSnippetDialogState extends State<_EditSnippetDialog> {
  final _titleCtrl = TextEditingController();
  final _codeCtrl = AdaptiveCodeController();
  final _passCtrl = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _hasPassword = false;
  bool _clearPassword = false;
  bool _allowRaw = true;
  bool _allowDownload = true;
  bool _rawEditorMode = false;
  bool _normalizingEditorText = false;
  int _cursorLine = 1;
  int _cursorColumn = 1;
  List<CodeDiagnosticIssue> _issues = const [];
  String _language = 'plaintext';
  String? _error;

  @override
  void initState() {
    super.initState();
    _codeCtrl.addListener(_handleEditorChange);
    _titleCtrl.addListener(_handleEditorChange);
    _loadSnippet();
  }

  @override
  void dispose() {
    _codeCtrl.removeListener(_handleEditorChange);
    _titleCtrl.removeListener(_handleEditorChange);
    _titleCtrl.dispose();
    _codeCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSnippet() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res =
          await ApiClient.instance.get('/hub/snippets/${widget.shortId}');
      final ok = res.data is Map && res.data['status'] == true;
      if (!ok) {
        setState(() {
          _error = (res.data is Map ? res.data['msg'] : null)?.toString() ??
              'Failed to load snippet';
          _loading = false;
        });
        return;
      }

      final data = Map<String, dynamic>.from(res.data['data'] as Map);
      final lang = (data['language'] ?? 'plaintext').toString().toLowerCase();

      setState(() {
        _titleCtrl.text = (data['title'] ?? '').toString();
        _codeCtrl.text = normalizeCodeText((data['code'] ?? '').toString());
        _language = _coerceSnippetLanguageForEditor(lang);
        _hasPassword = data['hasPassword'] == true;
        _allowRaw = (data['allowRaw'] ?? true) == true;
        _allowDownload = (data['allowDownload'] ?? true) == true;
        _clearPassword = false;
        _loading = false;
      });
      _syncEditorLanguage();
      _refreshDiagnostics();
    } catch (_) {
      setState(() {
        _error = 'ERR_CONNECTION_REFUSED';
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    final normalizedCode = normalizeCodeText(_codeCtrl.text);
    if (_titleCtrl.text.trim().isEmpty || normalizedCode.trim().isEmpty) {
      setState(() => _error = 'Title and code are required');
      return;
    }

    final codeBytes = utf8.encode(normalizedCode);
    if (codeBytes.length > _maxSnippetCodeBytes) {
      setState(() {
        _error =
            'Código demasiado largo (${_formatCodeBytes(codeBytes.length)}). Máximo 200KB.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final nextPassword = _passCtrl.text.trim();
    try {
      final payload = <String, dynamic>{
        'title': _titleCtrl.text.trim(),
        'language': _language,
        'code': normalizedCode,
        'allowRaw': _allowRaw,
        'allowDownload': _allowDownload,
        if (nextPassword.isNotEmpty) 'password': nextPassword,
        if (_clearPassword && nextPassword.isEmpty) 'clearPassword': true,
      };

      final res = await ApiClient.instance
          .put('/hub/snippets/${widget.shortId}', data: payload);

      if (res.data is Map && res.data['status'] == true) {
        if (!mounted) return;
        Navigator.of(context).pop(true);
        return;
      }

      setState(() {
        _error = (res.data is Map ? res.data['msg'] : null)?.toString() ??
            'Failed to save snippet';
        _saving = false;
      });
    } catch (_) {
      setState(() {
        _error = 'ERR_CONNECTION_REFUSED';
        _saving = false;
      });
    }
  }

  void _handleEditorChange() {
    if (_normalizingEditorText) return;
    _normalizeEditorTextLineEndings();
    _syncEditorLanguage();
    _refreshDiagnostics();
  }

  void _normalizeEditorTextLineEndings() {
    final rawText = _codeCtrl.text;
    final normalizedText = normalizeCodeText(rawText);
    if (rawText == normalizedText) return;

    final selection = _codeCtrl.selection;
    final rawOffset = selection.baseOffset;
    final normalizedOffset = _normalizedOffsetFromRaw(rawText, rawOffset);

    _normalizingEditorText = true;
    _codeCtrl.value = _codeCtrl.value.copyWith(
      text: normalizedText,
      selection: TextSelection.collapsed(
        offset: normalizedOffset.clamp(0, normalizedText.length),
      ),
    );
    _normalizingEditorText = false;
  }

  int _normalizedOffsetFromRaw(String rawText, int rawOffset) {
    if (rawOffset <= 0) return 0;
    final clamped = rawOffset > rawText.length ? rawText.length : rawOffset;
    var removedChars = 0;
    for (var i = 0; i < clamped; i++) {
      if (rawText.codeUnitAt(i) == 13) {
        removedChars++;
      }
    }
    return clamped - removedChars;
  }

  void _syncEditorLanguage() {
    final resolved = resolveCodeLanguage(
      declaredLanguage: _language,
      titleHint: _titleCtrl.text,
      code: _codeCtrl.text,
    );
    final safeLanguage = sanitizeCodeLanguage(resolved, fallback: 'plaintext');
    final mode = _resolveHighlightModeForEditor(
      safeLanguage: safeLanguage,
      code: _codeCtrl.text,
    );

    if (mode != null && _codeCtrl.language != mode) {
      _codeCtrl.language = mode;
    }

    _codeCtrl.syncHighlightStrategy(
      language: safeLanguage,
      code: _codeCtrl.text,
    );
  }

  AdaptiveHighlightMode _nextHighlightMode(AdaptiveHighlightMode current) {
    switch (current) {
      case AdaptiveHighlightMode.auto:
        return AdaptiveHighlightMode.forceStandard;
      case AdaptiveHighlightMode.forceStandard:
        return AdaptiveHighlightMode.forceLexical;
      case AdaptiveHighlightMode.forceLexical:
        return AdaptiveHighlightMode.auto;
    }
  }

  void _cycleHighlightMode() {
    final next = _nextHighlightMode(_codeCtrl.highlightMode);
    _codeCtrl.setHighlightMode(
      next,
      language: _language,
      code: _codeCtrl.text,
    );
    _refreshDiagnostics();
  }

  void _refreshDiagnostics() {
    final text = normalizeCodeText(_codeCtrl.text);
    final selection = _codeCtrl.selection;
    final cursor = selection.baseOffset;
    final normalizedCursor =
        _normalizedOffsetFromRaw(_codeCtrl.text, cursor < 0 ? 0 : cursor);
    final safeCursor =
        normalizedCursor > text.length ? text.length : normalizedCursor;
    final prefix = text.substring(0, safeCursor);

    final line = RegExp(r'\n').allMatches(prefix).length + 1;
    final lastBreak = prefix.lastIndexOf('\n');
    final column = safeCursor - (lastBreak + 1) + 1;

    final resolvedLang = resolveCodeLanguage(
      declaredLanguage: _language,
      titleHint: _titleCtrl.text,
      code: text,
    );
    final diagnostics = buildCodeDiagnostics(
      code: text,
      language: resolvedLang,
    );

    if (!mounted) return;
    setState(() {
      _cursorLine = line;
      _cursorColumn = column;
      _issues = diagnostics;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final canSave = !_loading && !_saving;
    final editorCode = normalizeCodeText(_codeCtrl.text);
    final editorCodeBytes = utf8.encode(editorCode).length;
    final editorLanguage = resolveCodeLanguage(
      declaredLanguage: _language,
      titleHint: _titleCtrl.text,
      code: editorCode,
    );
    final editorLexicalMode = _codeCtrl.lexicalMode;
    final editorHighlightModeLabel = _codeCtrl.highlightModeLabel;
    final issueColor = _issues.isEmpty ? ext.success : ext.warning;
    final issuesByLine = <int, CodeDiagnosticIssue>{};
    for (final issue in _issues) {
      final line = issue.line;
      if (line == null || line <= 0) continue;
      issuesByLine.putIfAbsent(line, () => issue);
    }
    final firstIssue = _issues.isNotEmpty ? _issues.first : null;
    final syntaxTheme = buildCodeHighlightTheme(
      ext,
      fontSize: 13,
      lineHeight: 1.55,
      letterSpacing: 0.2,
    );
    final editorLineCount = countCodeLines(editorCode);
    final editorLineNumberDigits = editorLineCount.toString().length;
    const editorGutterMarkerChars = 1;
    final editorLineNumberWidth = math.max(
      96.0,
      44.0 + ((editorLineNumberDigits + editorGutterMarkerChars) * 12.2),
    );

    return Scaffold(
      backgroundColor: ext.bg,
      body: _loading
          ? Center(
              child:
                  CircularProgressIndicator(color: ext.primary, strokeWidth: 2),
            )
          : SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final editorHeight =
                      math.max(420.0, constraints.maxHeight * 0.62);

                  return Center(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(maxWidth: context.pageMaxWidth),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          context.pageHorizontalPadding,
                          18,
                          context.pageHorizontalPadding,
                          22,
                        ),
                        child: TerminalPageReveal(
                          animationKey: 'snippet-edit-${widget.shortId}',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TerminalPageHeader(
                                title: 'edit_fragment',
                                subtitle: '/s/${widget.shortId}',
                                actions: [
                                  StatusBadge(
                                    code: _issues.isEmpty ? 200 : 422,
                                    message: _issues.isEmpty
                                        ? 'syntax-ok'
                                        : 'syntax-warnings',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: ext.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: ext.border),
                                ),
                                child: Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 340,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        decoration: BoxDecoration(
                                          color: ext.bg,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(color: ext.border),
                                        ),
                                        child: TextFormField(
                                          controller: _titleCtrl,
                                          style: TextStyle(
                                            color: ext.text,
                                            fontSize: 12,
                                            fontFamily: 'JetBrainsMono',
                                          ),
                                          decoration: InputDecoration(
                                            isDense: true,
                                            border: InputBorder.none,
                                            hintText: 'Snippet title',
                                            hintStyle: TextStyle(
                                              color: ext.textMuted,
                                              fontFamily: 'JetBrainsMono',
                                              fontSize: 11,
                                            ),
                                            prefixIconConstraints:
                                                const BoxConstraints(
                                              minWidth: 0,
                                              minHeight: 0,
                                            ),
                                            prefixIcon: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 8),
                                              child: Text(
                                                'title:',
                                                style: TextStyle(
                                                  color: ext.primary,
                                                  fontFamily: 'JetBrainsMono',
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 220,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: ext.bg,
                                          border: Border.all(color: ext.border),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: _language,
                                            isExpanded: true,
                                            dropdownColor: ext.surfaceVariant,
                                            icon: Icon(Icons.arrow_drop_down,
                                                color: ext.textMuted),
                                            style: TextStyle(
                                              color: ext.text,
                                              fontFamily: 'JetBrainsMono',
                                              fontSize: 12,
                                            ),
                                            items: _languages
                                                .map((language) =>
                                                    DropdownMenuItem(
                                                      value: language,
                                                      child: Text(language
                                                          .toUpperCase()),
                                                    ))
                                                .toList(),
                                            onChanged: _saving
                                                ? null
                                                : (value) {
                                                    setState(() {
                                                      _language =
                                                          value ?? 'plaintext';
                                                    });
                                                    _syncEditorLanguage();
                                                    _refreshDiagnostics();
                                                  },
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: ext.bg,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: ext.border),
                                      ),
                                      child: Text(
                                        'Ln $_cursorLine, Col $_cursorColumn | $editorCodeBytes bytes | ${editorLanguage.toUpperCase()} | $editorHighlightModeLabel:${editorLexicalMode ? 'LEX' : 'STD'}',
                                        style: TextStyle(
                                          color: ext.textSubtle,
                                          fontSize: 10,
                                          fontFamily: 'JetBrainsMono',
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: _cycleHighlightMode,
                                      borderRadius: BorderRadius.circular(6),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              editorHighlightModeLabel == 'AUTO'
                                                  ? ext.bg
                                                  : ext.primary
                                                      .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                            color: editorHighlightModeLabel ==
                                                    'AUTO'
                                                ? ext.border
                                                : ext.primary
                                                    .withValues(alpha: 0.6),
                                          ),
                                        ),
                                        child: Text(
                                          editorHighlightModeLabel,
                                          style: TextStyle(
                                            color: editorHighlightModeLabel ==
                                                    'AUTO'
                                                ? ext.textSubtle
                                                : ext.primary,
                                            fontSize: 10.5,
                                            fontFamily: 'JetBrainsMono',
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => setState(() =>
                                          _rawEditorMode = !_rawEditorMode),
                                      borderRadius: BorderRadius.circular(6),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _rawEditorMode
                                              ? ext.warning
                                                  .withValues(alpha: 0.14)
                                              : ext.bg,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                            color: _rawEditorMode
                                                ? ext.warning
                                                    .withValues(alpha: 0.6)
                                                : ext.border,
                                          ),
                                        ),
                                        child: Text(
                                          _rawEditorMode ? 'RAW' : 'CODE',
                                          style: TextStyle(
                                            color: _rawEditorMode
                                                ? ext.warning
                                                : ext.textSubtle,
                                            fontSize: 10.5,
                                            fontFamily: 'JetBrainsMono',
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: editorHeight,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: ext.surface,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: ext.primary
                                            .withValues(alpha: 0.28)),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  ext.surface,
                                                  ext.bg
                                                      .withValues(alpha: 0.98),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: -96,
                                          right: -64,
                                          child: IgnorePointer(
                                            child: Container(
                                              width: 220,
                                              height: 220,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: RadialGradient(
                                                  colors: [
                                                    ext.primary.withValues(
                                                        alpha: 0.14),
                                                    Colors.transparent,
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: -120,
                                          left: -74,
                                          child: IgnorePointer(
                                            child: Container(
                                              width: 260,
                                              height: 260,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: RadialGradient(
                                                  colors: [
                                                    ext.accent.withValues(
                                                        alpha: 0.12),
                                                    Colors.transparent,
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Expanded(
                                              child: _rawEditorMode
                                                  ? Container(
                                                      color: ext.bg,
                                                      padding: const EdgeInsets
                                                          .fromLTRB(
                                                          10, 8, 10, 8),
                                                      child: TextField(
                                                        controller: _codeCtrl,
                                                        expands: true,
                                                        minLines: null,
                                                        maxLines: null,
                                                        smartQuotesType:
                                                            SmartQuotesType
                                                                .disabled,
                                                        keyboardType:
                                                            TextInputType
                                                                .multiline,
                                                        style: TextStyle(
                                                          color: ext.text,
                                                          fontFamily:
                                                              'JetBrainsMono',
                                                          fontSize: 13,
                                                          height: 1.55,
                                                          letterSpacing: 0.2,
                                                        ),
                                                        cursorColor:
                                                            ext.primary,
                                                        autocorrect: false,
                                                        enableSuggestions:
                                                            false,
                                                        decoration:
                                                            const InputDecoration(
                                                          border:
                                                              InputBorder.none,
                                                          isDense: true,
                                                        ),
                                                        onChanged: (_) =>
                                                            _refreshDiagnostics(),
                                                      ),
                                                    )
                                                  : CodeTheme(
                                                      data: CodeThemeData(
                                                          styles: syntaxTheme),
                                                      child: CodeField(
                                                        controller: _codeCtrl,
                                                        expands: true,
                                                        wrap: false,
                                                        lineNumbers: true,
                                                        smartQuotesType:
                                                            SmartQuotesType
                                                                .disabled,
                                                        keyboardType:
                                                            TextInputType
                                                                .multiline,
                                                        lineNumberStyle:
                                                            LineNumberStyle(
                                                          width:
                                                              editorLineNumberWidth,
                                                          margin: 12,
                                                          background: ext
                                                              .surfaceVariant,
                                                          textStyle: TextStyle(
                                                            color:
                                                                ext.textSubtle,
                                                            fontFamily:
                                                                'JetBrainsMono',
                                                            fontSize: 13,
                                                            height: 1.55,
                                                            letterSpacing: 0.2,
                                                          ),
                                                        ),
                                                        lineNumberBuilder:
                                                            (lineNumber,
                                                                style) {
                                                          final lineText =
                                                              lineNumber
                                                                  .toString()
                                                                  .padLeft(
                                                                      editorLineNumberDigits,
                                                                      ' ');
                                                          final issue =
                                                              issuesByLine[
                                                                  lineNumber];
                                                          final prefixedText =
                                                              ' $lineText';
                                                          if (issue == null) {
                                                            return TextSpan(
                                                              text:
                                                                  prefixedText,
                                                              style: style,
                                                            );
                                                          }

                                                          return TextSpan(
                                                            children: [
                                                              TextSpan(
                                                                text: '!',
                                                                style: (style ??
                                                                        const TextStyle())
                                                                    .copyWith(
                                                                  color:
                                                                      ext.error,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w800,
                                                                ),
                                                              ),
                                                              TextSpan(
                                                                text: lineText,
                                                                style: (style ??
                                                                        const TextStyle())
                                                                    .copyWith(
                                                                  color:
                                                                      ext.error,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                        textStyle: TextStyle(
                                                          color: ext.text,
                                                          fontFamily:
                                                              'JetBrainsMono',
                                                          fontSize: 13,
                                                          height: 1.55,
                                                          letterSpacing: 0.2,
                                                        ),
                                                        cursorColor:
                                                            ext.primary,
                                                        background: ext.bg,
                                                        onChanged: (_) =>
                                                            _refreshDiagnostics(),
                                                        textSelectionTheme:
                                                            TextSelectionThemeData(
                                                          cursorColor:
                                                              ext.primary,
                                                          selectionColor: ext
                                                              .primary
                                                              .withValues(
                                                                  alpha: 0.24),
                                                          selectionHandleColor:
                                                              ext.primary,
                                                        ),
                                                      ),
                                                    ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                              decoration: BoxDecoration(
                                                color: ext.surfaceVariant
                                                    .withValues(alpha: 0.8),
                                                border: Border(
                                                  top: BorderSide(
                                                    color: ext.border
                                                        .withValues(alpha: 0.7),
                                                  ),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    _issues.isEmpty
                                                        ? Icons
                                                            .check_circle_outline
                                                        : Icons.error_outline,
                                                    size: 13,
                                                    color: issueColor,
                                                  ),
                                                  const SizedBox(width: 7),
                                                  Expanded(
                                                    child: Text(
                                                      _issues.isEmpty
                                                          ? (_rawEditorMode
                                                              ? 'RAW mode | No syntax diagnostics'
                                                              : 'No syntax diagnostics')
                                                          : '[${firstIssue?.line ?? '--'}:${firstIssue?.column ?? '--'}] ${firstIssue?.message ?? 'Issue detected'}',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: issueColor,
                                                        fontSize: 10.5,
                                                        fontFamily:
                                                            'JetBrainsMono',
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  if (_hasPassword)
                                    InkWell(
                                      onTap: () => setState(() =>
                                          _clearPassword = !_clearPassword),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _clearPassword
                                              ? ext.error
                                                  .withValues(alpha: 0.12)
                                              : ext.warning
                                                  .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                            color: _clearPassword
                                                ? ext.error
                                                    .withValues(alpha: 0.45)
                                                : ext.warning
                                                    .withValues(alpha: 0.45),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              _clearPassword
                                                  ? Icons.lock_open
                                                  : Icons.lock,
                                              size: 12,
                                              color: _clearPassword
                                                  ? ext.error
                                                  : ext.warning,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              _clearPassword
                                                  ? 'Password will be removed'
                                                  : 'Snippet currently protected',
                                              style: TextStyle(
                                                color: _clearPassword
                                                    ? ext.error
                                                    : ext.warning,
                                                fontSize: 10,
                                                fontFamily: 'JetBrainsMono',
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  SizedBox(
                                    width: 320,
                                    child: TerminalInput(
                                      controller: _passCtrl,
                                      hint: 'Set new password (optional)',
                                      prefix: 'pass:',
                                      obscureText: true,
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Checkbox(
                                        value: _allowRaw,
                                        onChanged: _saving
                                            ? null
                                            : (v) => setState(
                                                () => _allowRaw = v ?? true),
                                        activeColor: ext.primary,
                                        checkColor: ext.bg,
                                        side: BorderSide(color: ext.border),
                                      ),
                                      InkWell(
                                        onTap: _saving
                                            ? null
                                            : () => setState(
                                                () => _allowRaw = !_allowRaw),
                                        child: Text('Permitir RAW',
                                            style: TextStyle(
                                                color: ext.text,
                                                fontSize: 11,
                                                fontFamily: 'JetBrainsMono')),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Checkbox(
                                        value: _allowDownload,
                                        onChanged: _saving
                                            ? null
                                            : (v) => setState(() =>
                                                _allowDownload = v ?? true),
                                        activeColor: ext.primary,
                                        checkColor: ext.bg,
                                        side: BorderSide(color: ext.border),
                                      ),
                                      InkWell(
                                        onTap: _saving
                                            ? null
                                            : () => setState(() =>
                                                _allowDownload =
                                                    !_allowDownload),
                                        child: Text('Permitir descarga',
                                            style: TextStyle(
                                                color: ext.text,
                                                fontSize: 11,
                                                fontFamily: 'JetBrainsMono')),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (_error != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: ext.error.withValues(alpha: 0.1),
                                    border: Border(
                                      left: BorderSide(
                                          color: ext.error, width: 4),
                                    ),
                                  ),
                                  child: Text(
                                    _error!,
                                    style: TextStyle(
                                      color: ext.error,
                                      fontSize: 11,
                                      fontFamily: 'JetBrainsMono',
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    onPressed: _saving
                                        ? null
                                        : () =>
                                            Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton.icon(
                                    onPressed: canSave ? _save : null,
                                    icon: _saving
                                        ? SizedBox(
                                            width: 12,
                                            height: 12,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: ext.bg,
                                            ),
                                          )
                                        : const Icon(Icons.save_outlined,
                                            size: 14),
                                    label: Text(
                                        _saving ? 'Saving...' : 'Save changes'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
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
  final _codeCtrl = AdaptiveCodeController();
  final _passCtrl = TextEditingController();
  PlatformFile? _selectedFile;
  String _language = 'javascript';
  bool _withPass = false;
  bool _allowRaw = true;
  bool _allowDownload = true;
  bool _showPreview = true;
  bool _rawEditorMode = false;
  bool _normalizingEditorText = false;
  bool _loading = false;
  int _cursorLine = 1;
  int _cursorColumn = 1;
  List<CodeDiagnosticIssue> _issues = const [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _codeCtrl.addListener(_handleEditorChange);
    _titleCtrl.addListener(_handleEditorChange);
    _syncEditorLanguage();
    _refreshDiagnostics();
  }

  @override
  void dispose() {
    _codeCtrl.removeListener(_handleEditorChange);
    _titleCtrl.removeListener(_handleEditorChange);
    _titleCtrl.dispose();
    _codeCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCodeFile() async {
    final picked = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
      type: FileType.custom,
      allowedExtensions: const [
        'txt',
        'md',
        'json',
        'yaml',
        'yml',
        'xml',
        'js',
        'mjs',
        'cjs',
        'jsx',
        'ts',
        'tsx',
        'mts',
        'cts',
        'dart',
        'py',
        'rb',
        'php',
        'java',
        'kt',
        'swift',
        'go',
        'rs',
        'scala',
        'sql',
        'sh',
        'bash',
        'zsh',
        'ps1',
        'psm1',
        'c',
        'cpp',
        'cs',
        'css',
        'html',
        'graphql',
        'toml',
      ],
    );

    if (picked == null || picked.files.isEmpty) return;
    final file = picked.files.first;
    final bytes = file.bytes;

    if (bytes == null) {
      setState(() => _error = 'No se pudo leer el archivo seleccionado');
      return;
    }

    if (bytes.length > _maxSnippetCodeBytes) {
      setState(() {
        _error =
            'Archivo demasiado grande (${_formatCodeBytes(bytes.length)}). Máximo 200KB.';
      });
      return;
    }

    final text = normalizeCodeText(utf8.decode(bytes, allowMalformed: true));
    if (text.trim().isEmpty) {
      setState(() => _error = 'El archivo está vacío o no es texto válido');
      return;
    }

    final inferredLanguage = _languageFromFileName(file.name);
    final inferredTitle = _titleFromFileName(file.name);

    setState(() {
      _selectedFile = file;
      _codeCtrl.text = text;
      if (_titleCtrl.text.trim().isEmpty) {
        _titleCtrl.text = inferredTitle;
      }
      if (_languages.contains(inferredLanguage)) {
        _language = inferredLanguage;
      }
      _error = null;
    });
    _syncEditorLanguage();
    _refreshDiagnostics();
  }

  void _handleEditorChange() {
    if (_normalizingEditorText) return;
    _normalizeEditorTextLineEndings();
    _syncEditorLanguage();
    _refreshDiagnostics();
  }

  void _normalizeEditorTextLineEndings() {
    final rawText = _codeCtrl.text;
    final normalizedText = normalizeCodeText(rawText);
    if (rawText == normalizedText) return;

    final selection = _codeCtrl.selection;
    final rawOffset = selection.baseOffset;
    final normalizedOffset = _normalizedOffsetFromRaw(rawText, rawOffset);

    _normalizingEditorText = true;
    _codeCtrl.value = _codeCtrl.value.copyWith(
      text: normalizedText,
      selection: TextSelection.collapsed(
        offset: normalizedOffset.clamp(0, normalizedText.length),
      ),
    );
    _normalizingEditorText = false;
  }

  int _normalizedOffsetFromRaw(String rawText, int rawOffset) {
    if (rawOffset <= 0) return 0;
    final clamped = rawOffset > rawText.length ? rawText.length : rawOffset;
    var removedChars = 0;
    for (var i = 0; i < clamped; i++) {
      if (rawText.codeUnitAt(i) == 13) {
        removedChars++;
      }
    }
    return clamped - removedChars;
  }

  void _syncEditorLanguage() {
    final resolved = resolveCodeLanguage(
      declaredLanguage: _language,
      titleHint: _titleCtrl.text,
      code: _codeCtrl.text,
    );
    final safeLanguage = sanitizeCodeLanguage(resolved, fallback: 'plaintext');
    final mode = _resolveHighlightModeForEditor(
      safeLanguage: safeLanguage,
      code: _codeCtrl.text,
    );

    if (mode != null && _codeCtrl.language != mode) {
      _codeCtrl.language = mode;
    }

    _codeCtrl.syncHighlightStrategy(
      language: safeLanguage,
      code: _codeCtrl.text,
    );
  }

  AdaptiveHighlightMode _nextHighlightMode(AdaptiveHighlightMode current) {
    switch (current) {
      case AdaptiveHighlightMode.auto:
        return AdaptiveHighlightMode.forceStandard;
      case AdaptiveHighlightMode.forceStandard:
        return AdaptiveHighlightMode.forceLexical;
      case AdaptiveHighlightMode.forceLexical:
        return AdaptiveHighlightMode.auto;
    }
  }

  void _cycleHighlightMode() {
    final next = _nextHighlightMode(_codeCtrl.highlightMode);
    _codeCtrl.setHighlightMode(
      next,
      language: _language,
      code: _codeCtrl.text,
    );
    _refreshDiagnostics();
  }

  void _refreshDiagnostics() {
    final text = normalizeCodeText(_codeCtrl.text);
    final selection = _codeCtrl.selection;
    final cursor = selection.baseOffset;
    final normalizedCursor =
        _normalizedOffsetFromRaw(_codeCtrl.text, cursor < 0 ? 0 : cursor);
    final safeCursor =
        normalizedCursor > text.length ? text.length : normalizedCursor;
    final prefix = text.substring(0, safeCursor);

    final line = RegExp(r'\n').allMatches(prefix).length + 1;
    final lastBreak = prefix.lastIndexOf('\n');
    final column = safeCursor - (lastBreak + 1) + 1;

    final resolvedLang = resolveCodeLanguage(
      declaredLanguage: _language,
      titleHint: _titleCtrl.text,
      code: text,
    );
    final diagnostics = buildCodeDiagnostics(
      code: text,
      language: resolvedLang,
    );

    if (!mounted) return;
    setState(() {
      _cursorLine = line;
      _cursorColumn = column;
      _issues = diagnostics;
    });
  }

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context)!;
    final normalizedCode = normalizeCodeText(_codeCtrl.text);
    if (_titleCtrl.text.isEmpty || normalizedCode.isEmpty) {
      setState(() => _error = l10n.snippetsValidationTitleCodeRequired);
      return;
    }

    final codeBytes = utf8.encode(normalizedCode);
    if (codeBytes.length > _maxSnippetCodeBytes) {
      setState(() {
        _error =
            'Código demasiado largo (${_formatCodeBytes(codeBytes.length)}). Máximo 200KB.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      dynamic payload;
      if (_selectedFile?.bytes != null) {
        payload = FormData.fromMap({
          'title': _titleCtrl.text.trim(),
          'language': _language,
          'code': normalizedCode,
          'allowRaw': _allowRaw,
          'allowDownload': _allowDownload,
          'codeFile': MultipartFile.fromBytes(
            _selectedFile!.bytes!,
            filename: _selectedFile!.name,
          ),
          if (_withPass && _passCtrl.text.isNotEmpty)
            'password': _passCtrl.text,
        });
      } else {
        payload = {
          'title': _titleCtrl.text.trim(),
          'language': _language,
          'code': normalizedCode,
          'allowRaw': _allowRaw,
          'allowDownload': _allowDownload,
          if (_withPass && _passCtrl.text.isNotEmpty)
            'password': _passCtrl.text,
        };
      }

      final res = await ApiClient.instance.post('/hub/snippets', data: payload);

      if (res.data['status'] == true) {
        widget.onCreated();
      } else {
        setState(() {
          _error = res.data['msg'];
          _loading = false;
        });
      }
    } catch (_) {
      setState(() {
        _error = l10n.snippetsNetworkTimeout;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;
    final previewCode = normalizeCodeText(_codeCtrl.text);
    final previewCodeBytes = utf8.encode(previewCode).length;
    final previewLanguage = resolveCodeLanguage(
      declaredLanguage: _language,
      code: previewCode,
    );
    final syntaxTheme = buildCodeHighlightTheme(
      ext,
      fontSize: 12.5,
      lineHeight: 1.55,
      letterSpacing: 0.2,
    );
    final issueColor = _issues.isEmpty ? ext.success : ext.warning;
    final editorLexicalMode = _codeCtrl.lexicalMode;
    final editorHighlightModeLabel = _codeCtrl.highlightModeLabel;
    final firstIssue = _issues.isNotEmpty ? _issues.first : null;
    final issuesByLine = <int, CodeDiagnosticIssue>{};
    for (final issue in _issues) {
      final line = issue.line;
      if (line == null || line <= 0) continue;
      issuesByLine.putIfAbsent(line, () => issue);
    }
    final createLineCount = countCodeLines(previewCode);
    final createLineNumberDigits = createLineCount.toString().length;
    const createGutterMarkerChars = 1;
    final createLineNumberWidth = math.max(
      92.0,
      40.0 + ((createLineNumberDigits + createGutterMarkerChars) * 11.6),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ext.surface,
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: ext.primary.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(color: ext.primary.withValues(alpha: 0.1), blurRadius: 20)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.data_object, color: ext.primary, size: 18),
              const SizedBox(width: 8),
              Text(l10n.snippetsCreateTitle,
                  style: TextStyle(
                      color: ext.primary,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'JetBrainsMono',
                      letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 20),
          TerminalInput(
              controller: _titleCtrl,
              hint: l10n.snippetsTitleHint,
              prefix: l10n.snippetsTitlePrefix),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
                color: ext.bg,
                border: Border.all(color: ext.border),
                borderRadius: BorderRadius.circular(6)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _language,
                dropdownColor: ext.surfaceVariant,
                icon: Icon(Icons.arrow_drop_down, color: ext.textMuted),
                isExpanded: true,
                style: TextStyle(
                    color: ext.text, fontFamily: 'JetBrainsMono', fontSize: 12),
                items: _languages
                    .map((l) => DropdownMenuItem(
                        value: l,
                        child:
                            Text(l10n.snippetsLanguageOption(l.toUpperCase()))))
                    .toList(),
                onChanged: (v) {
                  setState(() => _language = v ?? 'javascript');
                  _syncEditorLanguage();
                  _refreshDiagnostics();
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: _loading ? null : _pickCodeFile,
                icon: const Icon(Icons.upload_file, size: 14),
                label: const Text('Subir archivo código'),
              ),
              if (_selectedFile != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: ext.bg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: ext.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.description, size: 12, color: ext.primary),
                      const SizedBox(width: 6),
                      Text(
                        '${_selectedFile!.name} (${_formatCodeBytes(_selectedFile!.size)})',
                        style: TextStyle(
                          color: ext.textMuted,
                          fontSize: 10.5,
                          fontFamily: 'JetBrainsMono',
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: _loading
                            ? null
                            : () {
                                setState(() {
                                  _selectedFile = null;
                                });
                              },
                        child: Icon(Icons.close, size: 12, color: ext.error),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.memory, size: 12, color: ext.primary),
              const SizedBox(width: 6),
              Text(
                'Ln $_cursorLine, Col $_cursorColumn | ${_formatCodeBytes(previewCodeBytes)} | ${previewLanguage.toUpperCase()} | $editorHighlightModeLabel:${editorLexicalMode ? 'LEX' : 'STD'}',
                style: TextStyle(
                  color: ext.textSubtle,
                  fontSize: 10,
                  fontFamily: 'JetBrainsMono',
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: _cycleHighlightMode,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Text(
                    editorHighlightModeLabel,
                    style: TextStyle(
                      color: editorHighlightModeLabel == 'AUTO'
                          ? ext.textMuted
                          : ext.primary,
                      fontSize: 10,
                      fontFamily: 'JetBrainsMono',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () => setState(() => _rawEditorMode = !_rawEditorMode),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Text(
                    _rawEditorMode ? 'RAW' : 'CODE',
                    style: TextStyle(
                      color: _rawEditorMode ? ext.warning : ext.textMuted,
                      fontSize: 10,
                      fontFamily: 'JetBrainsMono',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () => setState(() => _showPreview = !_showPreview),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Text(
                    _showPreview ? 'HIDE_PREVIEW' : 'SHOW_PREVIEW',
                    style: TextStyle(
                      color: _showPreview ? ext.primary : ext.textMuted,
                      fontSize: 10,
                      fontFamily: 'JetBrainsMono',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 320,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ext.primary.withValues(alpha: 0.26)),
                boxShadow: [
                  BoxShadow(
                    color: ext.primary.withValues(alpha: 0.08),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              ext.surface,
                              ext.bg.withValues(alpha: 0.98),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: -96,
                      right: -64,
                      child: IgnorePointer(
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                ext.primary.withValues(alpha: 0.14),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -120,
                      left: -74,
                      child: IgnorePointer(
                        child: Container(
                          width: 260,
                          height: 260,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                ext.accent.withValues(alpha: 0.12),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Expanded(
                          child: _rawEditorMode
                              ? Container(
                                  color: ext.bg.withValues(alpha: 0.9),
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 8, 10, 8),
                                  child: TextField(
                                    controller: _codeCtrl,
                                    expands: true,
                                    minLines: null,
                                    maxLines: null,
                                    smartQuotesType: SmartQuotesType.disabled,
                                    keyboardType: TextInputType.multiline,
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    style: TextStyle(
                                      color: ext.text,
                                      fontFamily: 'JetBrainsMono',
                                      fontSize: 12.5,
                                      height: 1.55,
                                      letterSpacing: 0.2,
                                    ),
                                    cursorColor: ext.primary,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      hintText: l10n.snippetsCodeHint,
                                      hintStyle: TextStyle(
                                        color: ext.textMuted
                                            .withValues(alpha: 0.5),
                                        fontFamily: 'JetBrainsMono',
                                      ),
                                    ),
                                    onChanged: (_) => _refreshDiagnostics(),
                                  ),
                                )
                              : CodeTheme(
                                  data: CodeThemeData(styles: syntaxTheme),
                                  child: CodeField(
                                    controller: _codeCtrl,
                                    expands: true,
                                    wrap: false,
                                    lineNumbers: true,
                                    smartQuotesType: SmartQuotesType.disabled,
                                    keyboardType: TextInputType.multiline,
                                    lineNumberStyle: LineNumberStyle(
                                      width: createLineNumberWidth,
                                      margin: 12,
                                      background: ext.surfaceVariant,
                                      textStyle: TextStyle(
                                        color: ext.textSubtle,
                                        fontFamily: 'JetBrainsMono',
                                        fontSize: 12.5,
                                        height: 1.55,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    lineNumberBuilder: (lineNumber, style) {
                                      final lineText =
                                          lineNumber.toString().padLeft(
                                                createLineNumberDigits,
                                                ' ',
                                              );
                                      final issue = issuesByLine[lineNumber];
                                      final prefixedText = ' $lineText';
                                      if (issue == null) {
                                        return TextSpan(
                                          text: prefixedText,
                                          style: style,
                                        );
                                      }

                                      return TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '!',
                                            style: (style ?? const TextStyle())
                                                .copyWith(
                                              color: ext.error,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          TextSpan(
                                            text: lineText,
                                            style: (style ?? const TextStyle())
                                                .copyWith(
                                              color: ext.error,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                    textStyle: TextStyle(
                                      color: ext.text,
                                      fontFamily: 'JetBrainsMono',
                                      fontSize: 12.5,
                                      height: 1.55,
                                      letterSpacing: 0.2,
                                    ),
                                    cursorColor: ext.primary,
                                    background: ext.bg.withValues(alpha: 0.92),
                                    onChanged: (_) => _refreshDiagnostics(),
                                    textSelectionTheme: TextSelectionThemeData(
                                      cursorColor: ext.primary,
                                      selectionColor:
                                          ext.primary.withValues(alpha: 0.24),
                                      selectionHandleColor: ext.primary,
                                    ),
                                  ),
                                ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: ext.surfaceVariant.withValues(alpha: 0.8),
                            border: Border(
                              top: BorderSide(
                                color: ext.border.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _issues.isEmpty
                                    ? Icons.check_circle_outline
                                    : Icons.error_outline,
                                size: 13,
                                color: issueColor,
                              ),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  _issues.isEmpty
                                      ? (_rawEditorMode
                                          ? 'RAW mode | No syntax diagnostics'
                                          : 'No syntax diagnostics')
                                      : '[${firstIssue?.line ?? '--'}:${firstIssue?.column ?? '--'}] ${firstIssue?.message ?? 'Issue detected'}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: issueColor,
                                    fontSize: 10.5,
                                    fontFamily: 'JetBrainsMono',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_showPreview) ...[
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ext.border),
              ),
              child: CodeViewport(
                ext: ext,
                code: previewCode,
                language: previewLanguage,
                maxHeight: 220,
                showLineNumbers: true,
                showWatermark: true,
                watermarkIcon: Icons.code,
                watermarkSize: 140,
                watermarkOpacity: 0.03,
                contentPadding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                gutterPadding: const EdgeInsets.fromLTRB(8, 14, 8, 14),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _withPass,
                    onChanged: (v) => setState(() => _withPass = v ?? false),
                    activeColor: ext.primary,
                    checkColor: ext.bg,
                    side: BorderSide(color: ext.border),
                  ),
                  InkWell(
                    onTap: () => setState(() => _withPass = !_withPass),
                    child: Text(l10n.snippetsRequireDecryptionKey,
                        style: TextStyle(
                            color: ext.text,
                            fontSize: 11,
                            fontFamily: 'JetBrainsMono')),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _allowRaw,
                    onChanged: (v) => setState(() => _allowRaw = v ?? true),
                    activeColor: ext.primary,
                    checkColor: ext.bg,
                    side: BorderSide(color: ext.border),
                  ),
                  InkWell(
                    onTap: () => setState(() => _allowRaw = !_allowRaw),
                    child: Text('Permitir RAW',
                        style: TextStyle(
                            color: ext.text,
                            fontSize: 11,
                            fontFamily: 'JetBrainsMono')),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _allowDownload,
                    onChanged: (v) =>
                        setState(() => _allowDownload = v ?? true),
                    activeColor: ext.primary,
                    checkColor: ext.bg,
                    side: BorderSide(color: ext.border),
                  ),
                  InkWell(
                    onTap: () =>
                        setState(() => _allowDownload = !_allowDownload),
                    child: Text('Permitir descarga',
                        style: TextStyle(
                            color: ext.text,
                            fontSize: 11,
                            fontFamily: 'JetBrainsMono')),
                  ),
                ],
              ),
            ],
          ),
          if (_withPass) ...[
            const SizedBox(height: 12),
            TerminalInput(
                controller: _passCtrl,
                hint: l10n.snippetsEncryptionKeyHint,
                prefix: l10n.snippetsEncryptionKeyPrefix,
                obscureText: true),
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: ext.error.withValues(alpha: 0.1),
                  border: Border(left: BorderSide(color: ext.error, width: 4))),
              child: Text(_error!,
                  style: TextStyle(
                      color: ext.error,
                      fontSize: 11,
                      fontFamily: 'JetBrainsMono')),
            ),
          ],
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: _HoverExecuteButton(
              onPressed: _loading ? () {} : _create,
              loading: _loading,
              ext: ext,
            ),
          ),
        ],
      ),
    );
  }
}

class _HoverExecuteButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool loading;
  final AuralixThemeExtension ext;

  const _HoverExecuteButton(
      {required this.onPressed, required this.loading, required this.ext});

  @override
  State<_HoverExecuteButton> createState() => _HoverExecuteButtonState();
}

class _HoverExecuteButtonState extends State<_HoverExecuteButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: 200.ms,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: widget.loading
                ? widget.ext.surfaceVariant
                : (_hovering
                    ? widget.ext.primary.withValues(alpha: 0.9)
                    : widget.ext.primary),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: widget.ext.primary),
            boxShadow: [
              if (!widget.loading && _hovering)
                BoxShadow(
                    color: widget.ext.primary.withValues(alpha: 0.5),
                    blurRadius: 12)
            ],
          ),
          child: widget.loading
              ? SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      color: widget.ext.primary, strokeWidth: 2))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.upload, size: 14, color: widget.ext.bg),
                    const SizedBox(width: 8),
                    Text(l10n.snippetsExecute,
                        style: TextStyle(
                            color: widget.ext.bg,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'JetBrainsMono')),
                  ],
                ),
        ),
      ),
    );
  }
}
