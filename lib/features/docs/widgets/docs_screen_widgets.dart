part of '../screens/docs_screen.dart';

class _DocsEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const _DocsEmptyState({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    return Center(
      child: Container(
        width: 680,
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(20),
        decoration: ext.surfaceDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    color: ext.text,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle,
                style: TextStyle(
                    color: ext.textMuted, fontSize: 12.5, height: 1.4)),
          ],
        ),
      ),
    );
  }
}

class _DocsServiceCard extends StatelessWidget {
  final ApiServiceMetadata service;
  final VoidCallback onOpen;

  const _DocsServiceCard({required this.service, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;

    return GlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: ext.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  service.method,
                  style: TextStyle(
                    color: ext.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'JetBrainsMono',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  service.name,
                  style: TextStyle(
                    color: ext.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: onOpen,
                child: Text(l10n.docsOpenButton),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            service.endpoint,
            style: TextStyle(
              color: ext.accentAlt,
              fontSize: 12,
              fontFamily: 'JetBrainsMono',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            service.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: ext.textMuted, fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _MetaChip(
                  label: 'project:${service.project}', color: ext.accentAlt),
              ...service.categories.take(2).map(
                    (category) =>
                        _MetaChip(label: category, color: ext.secondary),
                  ),
              if (service.requiresAuth)
                _MetaChip(label: l10n.docsAuthChip, color: ext.warning),
            ],
          ),
        ],
      ),
    );
  }
}

class _ApiDocs extends StatelessWidget {
  final ApiServiceMetadata service;
  final List<ApiServiceMetadata> related;
  final String selectedLang;
  final String catalogSource;
  final DateTime? catalogGeneratedAt;
  final void Function(String) onLangChange;

  const _ApiDocs({
    required this.service,
    required this.related,
    required this.selectedLang,
    required this.catalogSource,
    required this.catalogGeneratedAt,
    required this.onLangChange,
  });

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(l10n.navDocs.toLowerCase(),
              style: TextStyle(color: ext.textMuted, fontSize: 12)),
          Icon(Icons.chevron_right, size: 14, color: ext.textMuted),
          Text(service.slug,
              style: TextStyle(color: ext.primary, fontSize: 12)),
        ]).animate().fadeIn(),
        if (catalogSource.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '${l10n.docsSourceLabel}: $catalogSource${catalogGeneratedAt != null ? ' | ${catalogGeneratedAt!.toIso8601String()}' : ''}',
            style: TextStyle(
              color: ext.textSubtle,
              fontSize: 10.5,
              fontFamily: 'JetBrainsMono',
            ),
          ),
        ],
        const SizedBox(height: 16),
        GlowCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: ext.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4)),
                    child: Text(service.method,
                        style: TextStyle(
                            color: ext.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                  if (service.requiresAuth) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: ext.warning.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: ext.warning.withValues(alpha: 0.4)),
                      ),
                      child: Text(l10n.docsAuthChip.toUpperCase(),
                          style: TextStyle(
                              color: ext.warning,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(service.endpoint,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: ext.text,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'JetBrainsMono')),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(service.description,
                  style: TextStyle(
                      color: ext.textMuted, fontSize: 13, height: 1.4)),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetaChip(
                      label: 'project:${service.project}',
                      color: ext.accentAlt),
                  ...service.categories.map((category) =>
                      _MetaChip(label: category, color: ext.secondary)),
                  ...service.tags.map(
                      (tag) => _MetaChip(label: '#$tag', color: ext.primary)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ApiCredentialsPanel(
          title: l10n.docsCredentialsTitle,
          method: service.method,
          endpoint: service.endpoint,
          requiresAuth: service.requiresAuth,
        ),
        const SizedBox(height: 20),
        _Section(title: l10n.docsRequiredHeadersSection, children: [
          _ParamRow(
            ApiServiceParameter(
              name: 'Content-Type',
              type: 'application/json',
              description: l10n.docsContentTypeDescription,
              required: true,
              location: 'header',
              example: 'application/json',
            ),
            ext: ext,
          ),
          if (service.requiresAuth)
            _ParamRow(
              ApiServiceParameter(
                name: 'Authorization',
                type: 'Bearer <token>',
                description: l10n.docsAuthorizationDescription,
                required: true,
                location: 'header',
                example: '',
              ),
              ext: ext,
            ),
          ...service.parameters
              .where((p) => p.location.toLowerCase() == 'header')
              .map((p) => _ParamRow(p, ext: ext)),
        ]),
        const SizedBox(height: 20),
        _Section(
          title: l10n.docsParamsByLocationSection,
          children: service.parameters
                  .where((p) => p.location.toLowerCase() != 'header')
                  .isEmpty
              ? [
                  Text(l10n.docsNoExplicitParams,
                      style: TextStyle(color: ext.textMuted, fontSize: 12))
                ]
              : [
                  _ParamLocationGroup(
                    parameters: service.parameters
                        .where((p) => p.location.toLowerCase() != 'header')
                        .toList(),
                  ),
                ],
        ),
        const SizedBox(height: 20),
        _Section(title: l10n.docsCodeExamplesSection, children: [
          _CodeTabs(
            selectedLang: selectedLang,
            snippets: service.codeExamples,
            onLangChange: onLangChange,
          ),
        ]),
        const SizedBox(height: 20),
        _Section(title: l10n.docsResponseSuccessSection, children: [
          _ResponseExample(ext: ext, json: service.responseExample),
        ]),
        const SizedBox(height: 20),
        _Section(title: l10n.docsStatusCodesSection, children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...service.visibleStatusCodes
                  .map((code) => StatusBadge(code: code)),
            ],
          ),
        ]),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: () => context.go(
            '/sandbox',
            extra: {
              'serviceId': service.id,
              'path': service.endpoint,
              'method': service.method,
              'body': service.sandboxBodySeed,
            },
          ),
          icon: const Icon(Icons.terminal, size: 16),
          label: Text(service.requiresAuth
              ? l10n.docsTrySandboxWithSession
              : l10n.docsTrySandbox),
        ),
        if (related.isNotEmpty) ...[
          const SizedBox(height: 24),
          _Section(
            title: l10n.docsRelatedServicesSection,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: related
                    .map((item) => ActionChip(
                          label: Text(item.name),
                          onPressed: () => context.go('/docs/${item.slug}'),
                        ))
                    .toList(),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MetaChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          fontFamily: 'JetBrainsMono',
        ),
      ),
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
    return GlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: ext.text, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _ParamRow extends StatelessWidget {
  final ApiServiceParameter parameter;
  final AuralixThemeExtension ext;

  const _ParamRow(this.parameter, {required this.ext});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final details =
        '${parameter.type}${parameter.description.isEmpty ? '' : ' - ${parameter.description}'}';

    if (context.isMobile) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(parameter.name,
                style: TextStyle(
                    color: ext.accentAlt,
                    fontFamily: 'JetBrainsMono',
                    fontSize: 13)),
            const SizedBox(height: 4),
            Text(details, style: TextStyle(color: ext.text, fontSize: 13)),
            if (parameter.required) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: ext.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(3)),
                child: Text(l10n.docsRequiredBadge,
                    style: TextStyle(color: ext.error, fontSize: 10)),
              ),
            ],
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 200,
            child: Text(parameter.name,
                style: TextStyle(
                    color: ext.accentAlt,
                    fontFamily: 'JetBrainsMono',
                    fontSize: 13)),
          ),
          Expanded(
            child:
                Text(details, style: TextStyle(color: ext.text, fontSize: 13)),
          ),
          if (parameter.required) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: ext.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(3)),
              child: Text(l10n.docsRequiredBadge,
                  style: TextStyle(color: ext.error, fontSize: 10)),
            ),
          ],
        ],
      ),
    );
  }
}

class _ParamLocationGroup extends StatelessWidget {
  final List<ApiServiceParameter> parameters;

  const _ParamLocationGroup({required this.parameters});

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final grouped = <String, List<ApiServiceParameter>>{};

    for (final parameter in parameters) {
      final location = parameter.location.trim().toLowerCase().isEmpty
          ? 'body'
          : parameter.location.trim().toLowerCase();
      grouped.putIfAbsent(location, () => []).add(parameter);
    }

    const priority = ['path', 'query', 'body'];
    final extra = grouped.keys.where((k) => !priority.contains(k)).toList()
      ..sort();
    final ordered = [...priority.where(grouped.containsKey), ...extra];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ordered.map((location) {
        final items = grouped[location] ?? const <ApiServiceParameter>[];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: ext.border),
              color: ext.surfaceVariant.withValues(alpha: 0.35),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.toUpperCase(),
                  style: TextStyle(
                    color: ext.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'JetBrainsMono',
                  ),
                ),
                const SizedBox(height: 8),
                ...items.map((item) => _ParamRow(item, ext: ext)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CodeTabs extends StatelessWidget {
  final String selectedLang;
  final Map<String, String> snippets;
  final void Function(String) onLangChange;

  const _CodeTabs({
    required this.selectedLang,
    required this.snippets,
    required this.onLangChange,
  });

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;
    final langs = snippets.keys.toList();
    if (langs.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ext.surfaceVariant,
          border: Border.all(color: ext.border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          l10n.docsNoSnippetsMessage,
          style: TextStyle(color: ext.textMuted, fontSize: 12, height: 1.35),
        ),
      );
    }

    final selected = langs.contains(selectedLang)
        ? selectedLang
        : (langs.isEmpty ? 'curl' : langs.first);
    final code = snippets[selected] ?? '';
    final highlightLang = resolveCodeLanguage(
      declaredLanguage: selected,
      code: code,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: langs
                .map((l) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _LangTab(
                        label: l,
                        selected: l == selectedLang,
                        onTap: () => onLangChange(l),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
        _EditorCodeSurface(
          ext: ext,
          code: code,
          language: highlightLang,
          headerLabel: 'LANG: ${selected.toUpperCase()}',
          icon: Icons.code,
          copyLabel: l10n.docsCopyTooltip,
        ),
      ],
    );
  }
}

class _EditorCodeSurface extends StatefulWidget {
  final AuralixThemeExtension ext;
  final String code;
  final String language;
  final String headerLabel;
  final IconData icon;
  final String copyLabel;

  const _EditorCodeSurface({
    required this.ext,
    required this.code,
    required this.language,
    required this.headerLabel,
    required this.icon,
    required this.copyLabel,
  });

  @override
  State<_EditorCodeSurface> createState() => _EditorCodeSurfaceState();
}

class _EditorCodeSurfaceState extends State<_EditorCodeSurface> {
  bool _rawMode = false;
  bool _showLineNumbers = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: widget.ext.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: widget.ext.surfaceVariant.withValues(alpha: 0.8),
              border: Border(bottom: BorderSide(color: widget.ext.border)),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(7)),
            ),
            child: Row(
              children: [
                Icon(widget.icon, size: 12, color: widget.ext.primary),
                const SizedBox(width: 6),
                Text(
                  widget.headerLabel,
                  style: TextStyle(
                    color: widget.ext.primary,
                    fontSize: 10.5,
                    fontFamily: 'JetBrainsMono',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () =>
                      setState(() => _showLineNumbers = !_showLineNumbers),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: Text(
                      _showLineNumbers ? 'LINES' : 'NO_LINES',
                      style: TextStyle(
                        color: _showLineNumbers
                            ? widget.ext.primary
                            : widget.ext.textMuted,
                        fontSize: 10,
                        fontFamily: 'JetBrainsMono',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => setState(() => _rawMode = !_rawMode),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: Text(
                      _rawMode ? 'CODE' : 'RAW',
                      style: TextStyle(
                        color: _rawMode
                            ? widget.ext.primary
                            : widget.ext.textMuted,
                        fontSize: 10,
                        fontFamily: 'JetBrainsMono',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () =>
                      Clipboard.setData(ClipboardData(text: widget.code)),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.copy, size: 12, color: widget.ext.textMuted),
                        const SizedBox(width: 5),
                        Text(
                          widget.copyLabel,
                          style: TextStyle(
                            color: widget.ext.textMuted,
                            fontSize: 10,
                            fontFamily: 'JetBrainsMono',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_rawMode)
            _DocsRawViewport(ext: widget.ext, code: widget.code)
          else
            CodeViewport(
              ext: widget.ext,
              code: widget.code,
              language: widget.language,
              maxHeight: 440,
              showLineNumbers: _showLineNumbers,
              showWatermark: true,
              watermarkIcon: widget.icon,
              watermarkSize: 180,
              watermarkOpacity: 0.03,
              contentPadding: const EdgeInsets.fromLTRB(16, 18, 20, 18),
              gutterPadding: const EdgeInsets.fromLTRB(8, 18, 8, 18),
            ),
        ],
      ),
    );
  }
}

class _DocsRawViewport extends StatelessWidget {
  final AuralixThemeExtension ext;
  final String code;

  const _DocsRawViewport({required this.ext, required this.code});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 440),
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: SelectableText(
              code,
              style: TextStyle(
                color: ext.text,
                fontFamily: 'JetBrainsMono',
                fontSize: 12.5,
                height: 1.55,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LangTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _LangTab(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? ext.surfaceVariant : Colors.transparent,
          border: Border.all(
            color: selected ? ext.border : ext.border.withValues(alpha: 0.35),
          ),
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6), topRight: Radius.circular(6)),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? ext.text : ext.textMuted,
                fontSize: 12,
                fontFamily: 'JetBrainsMono')),
      ),
    );
  }
}

class _ResponseExample extends StatelessWidget {
  final AuralixThemeExtension ext;
  final String json;
  const _ResponseExample({required this.ext, required this.json});

  static const _fallback = '{\n  "status": true,\n  "data": {}\n}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final payload = json.trim().isEmpty ? _fallback : json;
    return _EditorCodeSurface(
      ext: ext,
      code: payload,
      language: 'json',
      headerLabel: 'RESPONSE: JSON',
      icon: Icons.data_object,
      copyLabel: l10n.docsCopyResponseTooltip,
    );
  }
}
