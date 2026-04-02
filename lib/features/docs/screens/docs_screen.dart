library docs_screen;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hub_aura/l10n/app_localizations.dart';
import '../providers/docs_provider.dart';
import '../../../core/services/service_catalog.dart';
import '../../../core/theme/theme_extension.dart';
import '../../../core/ui/breakpoints.dart';
import '../../../shared/code/code_highlighting.dart';
import '../../../shared/widgets/developer_panels.dart';
import '../../../shared/widgets/code_viewport.dart';
import '../../../shared/widgets/terminal_page_layout.dart';
import '../../../shared/widgets/terminal_widgets.dart';

part '../widgets/docs_screen_widgets.dart';

class DocsScreen extends ConsumerStatefulWidget {
  final String? apiId;
  const DocsScreen({super.key, this.apiId});

  @override
  ConsumerState<DocsScreen> createState() => _DocsScreenState();
}

class _DocsScreenState extends ConsumerState<DocsScreen> {
  String? _selectedApi;
  String _selectedLang = 'curl';
  final TextEditingController _searchCtrl = TextEditingController();
  String _categoryFilter = 'all';

  @override
  void initState() {
    super.initState();
    _selectedApi = widget.apiId;
  }

  @override
  void didUpdateWidget(covariant DocsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.apiId != widget.apiId) {
      _selectedApi = widget.apiId;
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool _isProjectService(ApiServiceMetadata service) {
    final project = service.project.trim().toLowerCase();
    final endpoint = service.endpoint.trim().toLowerCase();
    final categories = service.categories.join(' ').toLowerCase();
    return project == 'hub' ||
        project.contains('hub') ||
        endpoint.startsWith('/hub/') ||
        categories.contains('hub');
  }

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;
    final catalogState = ref.watch(docsCatalogProvider);

    return Scaffold(
      backgroundColor: ext.bg,
      body: catalogState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _DocsEmptyState(
          title: l10n.docsLoadErrorTitle,
          subtitle: '$error',
        ),
        data: (catalog) {
          final scopedServices = catalog.services
              .where(_isProjectService)
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name));

          final scopedCatalog = ServiceCatalog(
            services: scopedServices,
            sourcePath: catalog.sourcePath,
            generatedAt: catalog.generatedAt,
          );

          if (scopedCatalog.isEmpty) {
            return _DocsEmptyState(
              title: l10n.docsNoApisTitle,
              subtitle: l10n.docsNoApisSubtitle,
            );
          }

          final routeQuery = (widget.apiId ?? '').trim();
          final hasExplicitSelection =
              (_selectedApi?.trim().isNotEmpty ?? false) ||
                  routeQuery.isNotEmpty;

          final selected = hasExplicitSelection
              ? scopedCatalog.byId(_selectedApi) ??
                  scopedCatalog.byId(routeQuery)
              : null;

          final compact = context.isMobile || context.isTablet;
          final hPadding = context.pageHorizontalPadding;
          final maxWidth = context.pageMaxWidth;

          final categories = <String>['all', ...scopedCatalog.categories];
          final activeCategory =
              categories.contains(_categoryFilter) ? _categoryFilter : 'all';

          if (activeCategory != _categoryFilter) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() => _categoryFilter = activeCategory);
            });
          }

          final query = _searchCtrl.text.trim().toLowerCase();
          final visibleServices = scopedCatalog.services.where((service) {
            final categoryHit = activeCategory == 'all' ||
                service.categories
                    .map((value) => value.toLowerCase())
                    .contains(activeCategory.toLowerCase());
            final haystack =
                '${service.name} ${service.endpoint} ${service.method} ${service.description} ${service.tags.join(' ')}'
                    .toLowerCase();
            final queryHit = query.isEmpty || haystack.contains(query);
            return categoryHit && queryHit;
          }).toList();

          void openService(ApiServiceMetadata service) {
            setState(() {
              _selectedApi = service.id;
              _selectedLang = service.codeExamples.keys.isNotEmpty
                  ? service.codeExamples.keys.first
                  : 'curl';
            });
            context.go('/docs/${service.slug}');
          }

          if (selected == null && hasExplicitSelection) {
            return _DocsEmptyState(
              title: l10n.docsServiceNotFoundTitle,
              subtitle: l10n.docsServiceNotFoundSubtitle,
            );
          }

          if (selected == null) {
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(hPadding, 20, hPadding, 24),
                  child: TerminalPageReveal(
                    animationKey:
                        'docs-index-${visibleServices.length}-${activeCategory}_$query',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TerminalPageHeader(
                          title: 'docs',
                          subtitle: l10n.docsIndexSubtitle,
                          actions: [
                            StatusBadge(
                              code: 200,
                              message: l10n.docsServicesCount(
                                  scopedCatalog.services.length),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        GlowCard(
                          child: compact
                              ? Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    TextFormField(
                                      controller: _searchCtrl,
                                      onChanged: (_) => setState(() {}),
                                      style: TextStyle(
                                        color: ext.text,
                                        fontFamily: 'JetBrainsMono',
                                        fontSize: 12,
                                      ),
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.search,
                                            size: 16, color: ext.textMuted),
                                        hintText: l10n.docsSearchHint,
                                        hintStyle: TextStyle(
                                            color: ext.textMuted, fontSize: 12),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 10),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<String>(
                                      initialValue: activeCategory,
                                      key: ValueKey(activeCategory),
                                      dropdownColor: ext.surfaceVariant,
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 10),
                                      ),
                                      items: categories
                                          .map(
                                            (category) => DropdownMenuItem(
                                              value: category,
                                              child: Text(
                                                category == 'all'
                                                    ? l10n.docsAllCategories
                                                    : category,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (value) => setState(() {
                                        _categoryFilter = value ?? 'all';
                                      }),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: TextFormField(
                                        controller: _searchCtrl,
                                        onChanged: (_) => setState(() {}),
                                        style: TextStyle(
                                          color: ext.text,
                                          fontFamily: 'JetBrainsMono',
                                          fontSize: 12,
                                        ),
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(Icons.search,
                                              size: 16, color: ext.textMuted),
                                          hintText: l10n.docsSearchHint,
                                          hintStyle: TextStyle(
                                              color: ext.textMuted,
                                              fontSize: 12),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 10),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      flex: 2,
                                      child: DropdownButtonFormField<String>(
                                        initialValue: activeCategory,
                                        key: ValueKey(activeCategory),
                                        dropdownColor: ext.surfaceVariant,
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                        ),
                                        items: categories
                                            .map(
                                              (category) => DropdownMenuItem(
                                                value: category,
                                                child: Text(
                                                  category == 'all'
                                                      ? l10n.docsAllCategories
                                                      : category,
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (value) => setState(() {
                                          _categoryFilter = value ?? 'all';
                                        }),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        const SizedBox(height: 14),
                        if (visibleServices.isEmpty)
                          _DocsEmptyState(
                            title: l10n.docsNoResultsTitle,
                            subtitle: l10n.docsNoResultsSubtitle,
                          )
                        else
                          Column(
                            children: visibleServices
                                .map(
                                  (service) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _DocsServiceCard(
                                      service: service,
                                      onOpen: () => openService(service),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          final langs = selected.codeExamples.keys.toList();
          final currentLang = langs.contains(_selectedLang)
              ? _selectedLang
              : (langs.isNotEmpty ? langs.first : 'curl');

          if (currentLang != _selectedLang) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() => _selectedLang = currentLang);
            });
          }

          final selector = DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: selected.id,
              dropdownColor: ext.surfaceVariant,
              style: TextStyle(
                color: ext.text,
                fontSize: 12,
                fontFamily: 'JetBrainsMono',
              ),
              items: scopedCatalog.services
                  .map(
                    (service) => DropdownMenuItem(
                      value: service.id,
                      child: Text(
                        '${service.name} (${service.method})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                final service = scopedCatalog.byId(value);
                if (service == null) return;
                openService(service);
              },
            ),
          );

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(hPadding, 20, hPadding, 24),
                child: TerminalPageReveal(
                  animationKey: '${selected.id}|$currentLang',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TerminalPageHeader(
                        title: 'docs',
                        subtitle: l10n.docsDetailsSubtitle(selected.name),
                        actions: [
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedApi = null;
                              });
                              context.go('/docs');
                            },
                            icon: const Icon(Icons.list_alt, size: 14),
                            label: Text(l10n.docsIndexButton),
                          ),
                          StatusBadge(
                            code: 200,
                            message: l10n.docsServicesCount(
                                scopedCatalog.services.length),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      GlowCard(
                        child: compact
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.docsActiveServiceLabel,
                                    style: TextStyle(
                                      color: ext.primary,
                                      fontSize: 11,
                                      fontFamily: 'JetBrainsMono',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  selector,
                                ],
                              )
                            : Row(
                                children: [
                                  Text(
                                    l10n.docsActiveServiceLabel,
                                    style: TextStyle(
                                      color: ext.primary,
                                      fontSize: 11,
                                      fontFamily: 'JetBrainsMono',
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(child: selector),
                                ],
                              ),
                      ),
                      const SizedBox(height: 16),
                      AnimatedSwitcher(
                        duration: 220.ms,
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: KeyedSubtree(
                          key: ValueKey('${selected.id}|$currentLang'),
                          child: _ApiDocs(
                            service: selected,
                            related: scopedCatalog.relatedFor(selected),
                            selectedLang: currentLang,
                            catalogSource: scopedCatalog.sourcePath,
                            catalogGeneratedAt: scopedCatalog.generatedAt,
                            onLangChange: (lang) =>
                                setState(() => _selectedLang = lang),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
