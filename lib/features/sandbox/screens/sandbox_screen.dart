import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hub_aura/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/service_catalog.dart';
import '../../../core/ui/breakpoints.dart';
import '../../../core/theme/theme_extension.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/developer_panels.dart';
import '../../../shared/widgets/terminal_page_layout.dart';
import '../../../shared/widgets/terminal_widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/sandbox_provider.dart';

part '../widgets/sandbox_screen_widgets.dart';

class _SandboxHistoryEntry {
  final String method;
  final String path;
  final String? serviceId;
  final Map<String, dynamic>? body;
  final Map<String, String> headers;
  final int? statusCode;
  final bool success;
  final int timestampMs;

  const _SandboxHistoryEntry({
    required this.method,
    required this.path,
    required this.serviceId,
    required this.body,
    required this.headers,
    required this.statusCode,
    required this.success,
    required this.timestampMs,
  });

  Map<String, dynamic> toMap() {
    return {
      'method': method,
      'path': path,
      'serviceId': serviceId,
      'body': body,
      'headers': headers,
      'statusCode': statusCode,
      'success': success,
      'timestampMs': timestampMs,
    };
  }

  factory _SandboxHistoryEntry.fromMap(Map<String, dynamic> map) {
    final rawHeaders = map['headers'];
    final headers = <String, String>{};
    if (rawHeaders is Map) {
      for (final entry in rawHeaders.entries) {
        final key = entry.key.toString().trim();
        if (key.isEmpty) continue;
        headers[key] = entry.value?.toString() ?? '';
      }
    }

    final rawBody = map['body'];
    Map<String, dynamic>? body;
    if (rawBody is Map<String, dynamic>) {
      body = rawBody;
    } else if (rawBody is Map) {
      body = rawBody.map((k, v) => MapEntry(k.toString(), v));
    }

    return _SandboxHistoryEntry(
      method: (map['method'] ?? 'GET').toString().toUpperCase(),
      path: (map['path'] ?? '/').toString(),
      serviceId: map['serviceId']?.toString(),
      body: body,
      headers: headers,
      statusCode: map['statusCode'] is int
          ? map['statusCode'] as int
          : int.tryParse('${map['statusCode'] ?? ''}'),
      success: map['success'] == true,
      timestampMs: map['timestampMs'] is int
          ? map['timestampMs'] as int
          : DateTime.now().millisecondsSinceEpoch,
    );
  }
}

class SandboxScreen extends ConsumerStatefulWidget {
  final String? prefilledServiceId;
  final String? prefilledPath;
  final String? prefilledBody;
  final String? prefilledMethod;
  const SandboxScreen({
    super.key,
    this.prefilledServiceId,
    this.prefilledPath,
    this.prefilledBody,
    this.prefilledMethod,
  });

  @override
  ConsumerState<SandboxScreen> createState() => _SandboxScreenState();
}

class _SandboxScreenState extends ConsumerState<SandboxScreen> {
  static const _historyStorageKey = 'hub_sandbox_local_history_v1';
  static const _maxHistoryEntries = 20;

  late TextEditingController _pathCtrl;
  final Map<String, TextEditingController> _parameterControllers = {};
  final List<_SandboxHistoryEntry> _history = [];
  String? _selectedServiceId;
  String _method = 'POST';
  bool _loading = false;
  bool _showHeaders = false;
  bool _bootstrappedFromCatalog = false;
  bool _bootEntriesAdded = false;
  final List<ConsoleEntry> _output = [];
  final _scrollCtrl = ScrollController();
  static const _methodOptions = ['GET', 'POST', 'PUT', 'DELETE'];

  final List<Map<String, TextEditingController>> _headers = [];

  @override
  void initState() {
    super.initState();
    _selectedServiceId = widget.prefilledServiceId;
    _pathCtrl =
        TextEditingController(text: widget.prefilledPath ?? '/hub/search/food');
    _method = widget.prefilledMethod ?? 'POST';
    _loadHistory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bootEntriesAdded) return;
    _bootEntriesAdded = true;

    final l10n = AppLocalizations.of(context)!;
    _output.addAll([
      ConsoleEntry.muted(l10n.sandboxBootBanner),
      ConsoleEntry.muted(l10n.sandboxBootReady),
      ConsoleEntry.info(''),
    ]);
  }

  @override
  void dispose() {
    _pathCtrl.dispose();
    for (final controller in _parameterControllers.values) {
      controller.dispose();
    }
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

  ApiServiceMetadata? _resolveSelectedService() {
    final catalog = ref.read(sandboxServiceCatalogProvider).valueOrNull;
    if (catalog == null || catalog.services.isEmpty) return null;
    return catalog.byId(_selectedServiceId) ??
        catalog.byId(widget.prefilledServiceId) ??
        catalog.services.first;
  }

  String _normalizeLocation(String raw) {
    final normalized = raw.trim().toLowerCase();
    if (normalized.isEmpty) return 'body';
    return normalized;
  }

  Map<String, dynamic> _decodeObjectMap(String? rawJson) {
    if (rawJson == null || rawJson.trim().isEmpty) return const {};
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {}
    return const {};
  }

  String _seedValueForParameter(
      ApiServiceParameter parameter, Map<String, dynamic> bodySeed) {
    if (bodySeed.containsKey(parameter.name)) {
      final value = bodySeed[parameter.name];
      return value == null ? '' : value.toString();
    }

    final example = parameter.example.trim();
    if (example.isNotEmpty) {
      try {
        final decoded = jsonDecode(example);
        if (decoded is String || decoded is num || decoded is bool) {
          return decoded.toString();
        }
      } catch (_) {}
      return example;
    }

    final type = parameter.type.toLowerCase();
    if (type.contains('bool')) return 'true';
    if (type.contains('int') || type.contains('number')) return '1';
    return '';
  }

  void _syncParameterControllers(
    ApiServiceMetadata service, {
    String? seedBody,
    bool forceReset = false,
  }) {
    final editable = service.parameters
        .where(
            (parameter) => _normalizeLocation(parameter.location) != 'header')
        .toList();
    final keepNames = editable.map((parameter) => parameter.name).toSet();
    for (final existing in _parameterControllers.keys.toList()) {
      if (keepNames.contains(existing)) continue;
      _parameterControllers[existing]?.dispose();
      _parameterControllers.remove(existing);
    }

    final seedMap = _decodeObjectMap(seedBody);
    for (final parameter in editable) {
      final controller = _parameterControllers.putIfAbsent(
          parameter.name, TextEditingController.new);
      if (forceReset || controller.text.trim().isEmpty) {
        controller.text = _seedValueForParameter(parameter, seedMap);
      }
    }
  }

  dynamic _parseTypedValue(String value, String type) {
    final raw = value.trim();
    if (raw.isEmpty) return '';

    final normalizedType = type.toLowerCase();
    if (normalizedType.contains('bool')) {
      if (raw.toLowerCase() == 'true') {
        return true;
      }
      if (raw.toLowerCase() == 'false') {
        return false;
      }
      return raw;
    }
    if (normalizedType.contains('int')) {
      return int.tryParse(raw) ?? raw;
    }
    if (normalizedType.contains('number') ||
        normalizedType.contains('double') ||
        normalizedType.contains('float')) {
      return double.tryParse(raw) ?? raw;
    }
    if (normalizedType.contains('object') ||
        normalizedType.contains('map') ||
        normalizedType.contains('array') ||
        normalizedType.contains('list') ||
        raw.startsWith('{') ||
        raw.startsWith('[')) {
      try {
        return jsonDecode(raw);
      } catch (_) {
        return raw;
      }
    }
    return raw;
  }

  Iterable<String> _findUnresolvedPathTokens(String path) sync* {
    final matcher = RegExp(r'\{([^}/]+)\}|:([A-Za-z0-9_]+)');
    for (final match in matcher.allMatches(path)) {
      final token = (match.group(1) ?? match.group(2) ?? '').trim();
      if (token.isNotEmpty) yield token;
    }
  }

  void _bootstrapFromService(ApiServiceMetadata service) {
    if (_bootstrappedFromCatalog) return;
    _bootstrappedFromCatalog = true;

    setState(() {
      _selectedServiceId = service.id;
      if ((widget.prefilledPath ?? '').trim().isEmpty) {
        _pathCtrl.text = service.endpoint;
      }
      if ((widget.prefilledMethod ?? '').trim().isEmpty) {
        _method = service.method;
      }
      final bodySeed = (widget.prefilledBody ?? '').trim().isNotEmpty
          ? widget.prefilledBody
          : service.sandboxBodySeed;
      _syncParameterControllers(service, seedBody: bodySeed, forceReset: true);
    });
  }

  void _applyServicePreset(ApiServiceMetadata service) {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _selectedServiceId = service.id;
      _method = service.method;
      _pathCtrl.text = service.endpoint;
      _syncParameterControllers(service,
          seedBody: service.sandboxBodySeed, forceReset: true);
      _output.add(ConsoleEntry.info(l10n.sandboxPresetLoaded(
          service.name, service.method, service.endpoint)));
    });
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_historyStorageKey);
      if (raw == null || raw.trim().isEmpty) return;

      final decoded = jsonDecode(raw);
      if (decoded is! List) return;

      final entries = decoded
          .whereType<Map>()
          .map((row) => row.map((k, v) => MapEntry(k.toString(), v)))
          .map(_SandboxHistoryEntry.fromMap)
          .toList();

      if (!mounted) return;
      setState(() {
        _history
          ..clear()
          ..addAll(entries.take(_maxHistoryEntries));
      });
    } catch (_) {}
  }

  Future<void> _persistHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = _history.map((entry) => entry.toMap()).toList();
    await prefs.setString(_historyStorageKey, jsonEncode(payload));
  }

  Future<void> _recordHistory({
    required String method,
    required String path,
    required String? serviceId,
    required Map<String, dynamic>? body,
    required Map<String, String> headers,
    required int? statusCode,
    required bool success,
  }) async {
    final entry = _SandboxHistoryEntry(
      method: method,
      path: path,
      serviceId: serviceId,
      body: body,
      headers: headers,
      statusCode: statusCode,
      success: success,
      timestampMs: DateTime.now().millisecondsSinceEpoch,
    );

    setState(() {
      _history.insert(0, entry);
      if (_history.length > _maxHistoryEntries) {
        _history.removeRange(_maxHistoryEntries, _history.length);
      }
    });

    await _persistHistory();
  }

  void _restoreHistoryEntry(_SandboxHistoryEntry entry) {
    final l10n = AppLocalizations.of(context)!;
    final catalog = ref.read(sandboxServiceCatalogProvider).valueOrNull;
    final service = catalog?.byId(entry.serviceId);
    final seed = entry.body == null ? null : jsonEncode(entry.body);

    setState(() {
      _method = entry.method;
      _pathCtrl.text = entry.path;
      _selectedServiceId = service?.id;

      if (service != null) {
        _syncParameterControllers(service, seedBody: seed, forceReset: true);
      } else {
        for (final key in _parameterControllers.keys.toList()) {
          _parameterControllers[key]?.dispose();
          _parameterControllers.remove(key);
        }
      }

      for (final item in _headers) {
        item['key']?.dispose();
        item['value']?.dispose();
      }
      _headers
        ..clear()
        ..addAll(
          entry.headers.entries.map(
            (h) => {
              'key': TextEditingController(text: h.key),
              'value': TextEditingController(text: h.value),
            },
          ),
        );

      _output.add(ConsoleEntry.info(service != null
          ? l10n.sandboxHistoryRestored(entry.method, entry.path)
          : l10n.sandboxPartialRestored(entry.method, entry.path)));
    });
  }

  Future<void> _execute() async {
    final l10n = AppLocalizations.of(context)!;
    final basePath = _pathCtrl.text.trim();
    if (basePath.isEmpty) {
      return;
    }

    final service = _resolveSelectedService();
    var requestPath = basePath;
    final query = <String, String>{};
    final body = <String, dynamic>{};

    if (service != null) {
      final editable = service.parameters.where(
          (parameter) => _normalizeLocation(parameter.location) != 'header');

      for (final parameter in editable) {
        final controller = _parameterControllers[parameter.name];
        final rawValue = controller?.text.trim() ?? '';

        if (rawValue.isEmpty) {
          if (parameter.required) {
            _addEntry(ConsoleEntry.error(
                l10n.sandboxMissingRequired(parameter.name)));
            return;
          }
          continue;
        }

        final location = _normalizeLocation(parameter.location);
        if (location == 'path') {
          final encoded = Uri.encodeComponent(rawValue);
          requestPath = requestPath
              .replaceAll('{${parameter.name}}', encoded)
              .replaceAll(':${parameter.name}', encoded);
          continue;
        }

        if (location == 'query') {
          query[parameter.name] = rawValue;
          continue;
        }

        body[parameter.name] = _parseTypedValue(rawValue, parameter.type);
      }
    }

    final unresolvedPathParams = _findUnresolvedPathTokens(requestPath).toSet();
    if (unresolvedPathParams.isNotEmpty) {
      for (final name in unresolvedPathParams) {
        _addEntry(ConsoleEntry.error(l10n.sandboxMissingRequired(name)));
      }
      return;
    }

    if (query.isNotEmpty) {
      final queryString = Uri(queryParameters: query).query;
      requestPath = requestPath.contains('?')
          ? '$requestPath&$queryString'
          : '$requestPath?$queryString';
    }

    final parsedBody = (_method == 'GET' || body.isEmpty) ? null : body;
    final headers = _builtHeaders;

    setState(() {
      _loading = true;
      _output.add(ConsoleEntry.prompt('$_method $requestPath'));
    });

    try {
      final start = DateTime.now().millisecondsSinceEpoch;
      final res = await ApiClient.instance.post('/hub/sandbox/execute', data: {
        'method': _method,
        'path': requestPath,
        'body': parsedBody,
        'headers': headers,
      });

      final elapsed = DateTime.now().millisecondsSinceEpoch - start;
      final root = res.data is Map<String, dynamic>
          ? res.data as Map<String, dynamic>
          : <String, dynamic>{};
      final nested = root['data'] is Map<String, dynamic>
          ? root['data'] as Map<String, dynamic>
          : root;

      final status = _asInt(nested['statusCode']) ??
          _asInt(root['statusCode']) ??
          res.statusCode ??
          200;
      final responseBody = nested.containsKey('body') ? nested['body'] : root;
      final creditsRemaining = _asInt(nested['sandboxCreditsRemaining']);

      _addEntry(ConsoleEntry('HTTP $status | ${elapsed}ms',
          type: _statusType(status)));
      if (creditsRemaining != null) {
        _addEntry(ConsoleEntry.muted(
            'sys.sandboxCredits.remaining = $creditsRemaining'));
      }
      _addEntry(const ConsoleEntry(''));

      _addEntry(ConsoleEntry(
        const JsonEncoder.withIndent('  ').convert(responseBody),
        copyable: true,
      ));

      _addEntry(ConsoleEntry.muted('-' * 45));

      await _recordHistory(
        method: _method,
        path: requestPath,
        serviceId: service?.id,
        body: parsedBody is Map<String, dynamic>
            ? Map<String, dynamic>.from(parsedBody)
            : null,
        headers: headers,
        statusCode: status,
        success: status >= 200 && status < 400,
      );
    } catch (e) {
      _addEntry(ConsoleEntry.error(l10n.sandboxRuntimeError('$e')));
      await _recordHistory(
        method: _method,
        path: requestPath,
        serviceId: service?.id,
        body: parsedBody is Map<String, dynamic>
            ? Map<String, dynamic>.from(parsedBody)
            : null,
        headers: headers,
        statusCode: null,
        success: false,
      );
    } finally {
      setState(() => _loading = false);
      await Future.delayed(100.ms);
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: 300.ms, curve: Curves.easeOut);
      }
    }
  }

  void _addEntry(ConsoleEntry e) => setState(() => _output.add(e));

  ConsoleEntryType _statusType(int code) {
    if (code >= 500) return ConsoleEntryType.error;
    if (code >= 400) return ConsoleEntryType.warning;
    if (code >= 200 && code < 300) return ConsoleEntryType.success;
    return ConsoleEntryType.info;
  }

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authProvider).valueOrNull;
    final catalog = ref.watch(sandboxServiceCatalogProvider).valueOrNull;
    final services = catalog?.services ?? const <ApiServiceMetadata>[];
    final isCompact = context.isMobile || context.isTablet;
    final horizontalPadding =
        context.isMobile ? 12.0 : (context.isTablet ? 16.0 : 24.0);

    final selectedService = services.isEmpty
        ? null
        : catalog?.byId(_selectedServiceId) ??
            catalog?.byId(widget.prefilledServiceId) ??
            services.first;

    if (selectedService != null && !_bootstrappedFromCatalog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _bootstrapFromService(selectedService);
      });
    }

    Widget buildServiceDropdown() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: ext.bg,
          border: Border.all(color: ext.border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: selectedService?.id,
            dropdownColor: ext.surfaceVariant,
            icon: Icon(Icons.swap_vert, size: 14, color: ext.primary),
            style: TextStyle(
                color: ext.text,
                fontSize: 12,
                fontFamily: 'JetBrainsMono',
                fontWeight: FontWeight.bold),
            items: services
                .map(
                  (service) => DropdownMenuItem(
                    value: service.id,
                    child: Text('>> ${service.name} [${service.method}]',
                        overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null || catalog == null) return;
              final service = catalog.byId(value);
              if (service != null) _applyServicePreset(service);
            },
          ),
        ),
      );
    }

    Widget buildMethodSelector() {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _methodOptions.map((method) {
          final selected = _method == method;
          return AnimatedContainer(
            duration: 200.ms,
            child: ChoiceChip(
              label: Text(
                method,
                style: TextStyle(
                    color: selected ? ext.bg : ext.textMuted,
                    fontFamily: 'JetBrainsMono',
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
              selected: selected,
              onSelected: (_) => setState(() => _method = method),
              selectedColor: ext.primary,
              backgroundColor: ext.bg,
              side: BorderSide(color: selected ? ext.primary : ext.border),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
          );
        }).toList(),
      );
    }

    Widget buildPathField() {
      return Container(
        decoration: BoxDecoration(
            color: ext.bg,
            border: Border.all(color: ext.border),
            borderRadius: BorderRadius.circular(6)),
        child: TextFormField(
          controller: _pathCtrl,
          style: TextStyle(
              color: ext.text, fontFamily: 'JetBrainsMono', fontSize: 13),
          decoration: InputDecoration(
            hintText: '/hub/...',
            hintStyle: TextStyle(color: ext.textMuted, fontSize: 13),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      );
    }

    Widget buildExecuteButton() {
      return AnimatedContainer(
        duration: 200.ms,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
                color: ext.success.withValues(alpha: 0.2),
                blurRadius: 10,
                spreadRadius: 0)
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _loading ? null : _execute,
          style: ElevatedButton.styleFrom(
              backgroundColor: ext.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6))),
          icon: _loading
              ? const SizedBox(
                  height: 14,
                  width: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.flash_on, size: 16),
          label: Text(_loading ? l10n.sandboxExecuting : l10n.sandboxExecute,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontFamily: 'JetBrainsMono')),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ext.bg,
      body: Stack(
        children: [
          // Cyberpunk Background Glow
          Positioned(
            top: 50,
            left: -150,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ext.accent.withValues(alpha: 0.1),
                    ext.bg.withValues(alpha: 0.0)
                  ],
                  stops: const [0.1, 1.0],
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fade(duration: 6.seconds, begin: 0.5, end: 1.0),
          ),
          Center(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(maxWidth: isCompact ? double.infinity : 1200),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    horizontalPadding, 16, horizontalPadding, 16),
                child: LayoutBuilder(
                  builder: (context, _) {
                    final content = TerminalPageReveal(
                      animationKey: 'sandbox-core',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TerminalPageHeader(
                            title: 'sandbox',
                            subtitle: l10n.sandboxSubtitle,
                            actions: [
                              StatusBadge(
                                  code: 200,
                                  message: l10n.sandboxLocalCredits(
                                      user?.sandboxCredits ?? 10)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (selectedService != null) ...[
                            ApiCredentialsPanel(
                              title: l10n.sandboxActiveCredentialsTitle,
                              method: _method,
                              endpoint: _pathCtrl.text.trim().isEmpty
                                  ? selectedService.endpoint
                                  : _pathCtrl.text.trim(),
                              requiresAuth: selectedService.requiresAuth,
                            )
                                .animate()
                                .fadeIn(delay: 150.ms)
                                .slideY(begin: -0.05),
                            const SizedBox(height: 16),
                          ],

                          // Settings Editor Card
                          _HoverSandboxCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (services.isNotEmpty) ...[
                                  Row(
                                    children: [
                                      Icon(Icons.api_rounded,
                                          size: 16, color: ext.primary),
                                      const SizedBox(width: 8),
                                      Text(l10n.sandboxCatalogSelectionLabel,
                                          style: TextStyle(
                                              color: ext.primary,
                                              fontSize: 11,
                                              fontFamily: 'JetBrainsMono',
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  buildServiceDropdown(),
                                  const SizedBox(height: 16),
                                ],
                                if (isCompact)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      buildMethodSelector(),
                                      const SizedBox(height: 12),
                                      buildPathField(),
                                      const SizedBox(height: 16),
                                      buildExecuteButton(),
                                      const SizedBox(height: 12),
                                      TextButton.icon(
                                        icon: Icon(
                                            _showHeaders
                                                ? Icons.expand_less
                                                : Icons.keyboard_arrow_down,
                                            size: 16,
                                            color: ext.primary),
                                        label: Text(
                                            l10n.sandboxCustomHeadersToggle,
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: ext.primary,
                                                fontFamily: 'JetBrainsMono')),
                                        onPressed: () => setState(
                                            () => _showHeaders = !_showHeaders),
                                      ),
                                    ],
                                  )
                                else
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                              flex: 3,
                                              child: buildMethodSelector()),
                                          const SizedBox(width: 16),
                                          Expanded(
                                              flex: 7, child: buildPathField()),
                                          const SizedBox(width: 16),
                                          SizedBox(
                                              width: 160,
                                              child: buildExecuteButton()),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          TextButton.icon(
                                            icon: Icon(
                                                _showHeaders
                                                    ? Icons.expand_less
                                                    : Icons.keyboard_arrow_down,
                                                size: 16,
                                                color: ext.accentAlt),
                                            label: Text(
                                                l10n.sandboxCustomHeadersToggle,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: ext.accentAlt,
                                                    fontFamily:
                                                        'JetBrainsMono')),
                                            onPressed: () => setState(() =>
                                                _showHeaders = !_showHeaders),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                if (_showHeaders) ...[
                                  const SizedBox(height: 8),
                                  Divider(color: ext.border),
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          Text(l10n.sandboxInjectedHeadersLabel,
                                              style: TextStyle(
                                                  color: ext.textMuted,
                                                  fontSize: 11,
                                                  fontFamily: 'JetBrainsMono',
                                                  fontWeight: FontWeight.bold)),
                                          const Spacer(),
                                          TextButton.icon(
                                            icon: Icon(Icons.add_box,
                                                size: 12, color: ext.accent),
                                            label: Text(l10n.sandboxAddHeader,
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    color: ext.accent,
                                                    fontFamily: 'JetBrainsMono',
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            onPressed: () => setState(() =>
                                                _headers.add({
                                                  'key':
                                                      TextEditingController(),
                                                  'value':
                                                      TextEditingController()
                                                })),
                                          ),
                                        ]),
                                        const SizedBox(height: 8),
                                        ..._headers.asMap().entries.map(
                                              (e) => Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8),
                                                child: isCompact
                                                    ? Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .stretch,
                                                        children: [
                                                          TextFormField(
                                                              controller: e
                                                                  .value['key'],
                                                              style: TextStyle(
                                                                  color:
                                                                      ext.text,
                                                                  fontFamily:
                                                                      'JetBrainsMono',
                                                                  fontSize: 12),
                                                              decoration: InputDecoration(
                                                                  hintText: l10n
                                                                      .sandboxHeaderKeyHint,
                                                                  fillColor:
                                                                      ext.bg,
                                                                  filled: true,
                                                                  border: OutlineInputBorder(
                                                                      borderSide: BorderSide(
                                                                          color: ext
                                                                              .border)),
                                                                  contentPadding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          12,
                                                                      vertical:
                                                                          12))),
                                                          const SizedBox(
                                                              height: 6),
                                                          TextFormField(
                                                              controller:
                                                                  e.value[
                                                                      'value'],
                                                              style: TextStyle(
                                                                  color:
                                                                      ext.text,
                                                                  fontFamily:
                                                                      'JetBrainsMono',
                                                                  fontSize: 12),
                                                              decoration: InputDecoration(
                                                                  hintText: l10n
                                                                      .sandboxHeaderValueHint,
                                                                  fillColor:
                                                                      ext.bg,
                                                                  filled: true,
                                                                  border: OutlineInputBorder(
                                                                      borderSide: BorderSide(
                                                                          color: ext
                                                                              .border)),
                                                                  contentPadding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          12,
                                                                      vertical:
                                                                          12))),
                                                          Align(
                                                              alignment: Alignment
                                                                  .centerRight,
                                                              child: IconButton(
                                                                  icon: Icon(
                                                                      Icons
                                                                          .close,
                                                                      size: 16,
                                                                      color: ext
                                                                          .error),
                                                                  onPressed:
                                                                      () {
                                                                    e.value['key']!
                                                                        .dispose();
                                                                    e.value['value']!
                                                                        .dispose();
                                                                    setState(() =>
                                                                        _headers
                                                                            .removeAt(e.key));
                                                                  })),
                                                        ],
                                                      )
                                                    : Row(
                                                        children: [
                                                          Expanded(
                                                              child: TextFormField(
                                                                  controller:
                                                                      e.value[
                                                                          'key'],
                                                                  style: TextStyle(
                                                                      color: ext
                                                                          .text,
                                                                      fontFamily:
                                                                          'JetBrainsMono',
                                                                      fontSize:
                                                                          12),
                                                                  decoration: InputDecoration(
                                                                      hintText: l10n
                                                                          .sandboxHeaderKeyHint,
                                                                      fillColor: ext
                                                                          .bg,
                                                                      filled:
                                                                          true,
                                                                      enabledBorder: OutlineInputBorder(
                                                                          borderSide: BorderSide(
                                                                              color: ext
                                                                                  .border)),
                                                                      focusedBorder: OutlineInputBorder(
                                                                          borderSide: BorderSide(
                                                                              color: ext
                                                                                  .primary)),
                                                                      contentPadding:
                                                                          const EdgeInsets.symmetric(horizontal: 12, vertical: 12)))),
                                                          const SizedBox(
                                                              width: 8),
                                                          Expanded(
                                                              child: TextFormField(
                                                                  controller: e.value[
                                                                      'value'],
                                                                  style: TextStyle(
                                                                      color: ext
                                                                          .text,
                                                                      fontFamily:
                                                                          'JetBrainsMono',
                                                                      fontSize:
                                                                          12),
                                                                  decoration: InputDecoration(
                                                                      hintText: l10n
                                                                          .sandboxHeaderValueHint,
                                                                      fillColor: ext
                                                                          .bg,
                                                                      filled:
                                                                          true,
                                                                      enabledBorder: OutlineInputBorder(
                                                                          borderSide: BorderSide(
                                                                              color: ext
                                                                                  .border)),
                                                                      focusedBorder: OutlineInputBorder(
                                                                          borderSide: BorderSide(
                                                                              color: ext
                                                                                  .primary)),
                                                                      contentPadding: const EdgeInsets.symmetric(
                                                                          horizontal: 12,
                                                                          vertical: 12)))),
                                                          const SizedBox(
                                                              width: 8),
                                                          Container(
                                                            decoration: BoxDecoration(
                                                                color: ext.error
                                                                    .withValues(
                                                                        alpha:
                                                                            0.1),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            4)),
                                                            child: IconButton(
                                                                icon: Icon(
                                                                    Icons.close,
                                                                    size: 16,
                                                                    color: ext
                                                                        .error),
                                                                onPressed: () {
                                                                  e.value['key']!
                                                                      .dispose();
                                                                  e.value['value']!
                                                                      .dispose();
                                                                  setState(() =>
                                                                      _headers.removeAt(
                                                                          e.key));
                                                                }),
                                                          ),
                                                        ],
                                                      ),
                                              ),
                                            ),
                                      ],
                                    ),
                                  ).animate().fadeIn().slideY(begin: -0.1),
                                ],
                                if (selectedService != null) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                      width: double.infinity,
                                      height: 1,
                                      color: ext.border.withValues(alpha: 0.5)),
                                  _SandboxParameterForm(
                                    parameters: selectedService.parameters
                                        .where((parameter) =>
                                            _normalizeLocation(
                                                parameter.location) !=
                                            'header')
                                        .toList(),
                                    controllers: _parameterControllers,
                                    ext: ext,
                                  ).animate().fadeIn(delay: 200.ms),
                                ],
                              ],
                            ),
                          ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.05),

                          const SizedBox(height: 20),

                          // History & Console Area
                          if (_history.isNotEmpty) ...[
                            _SandboxHistoryPanel(
                                    entries: _history,
                                    onRestore: _restoreHistoryEntry)
                                .animate()
                                .fadeIn(delay: 300.ms),
                            const SizedBox(height: 20),
                          ],

                          if (isCompact)
                            SizedBox(
                                height: 360,
                                child: _AnimatedConsoleOutput(
                                        entries: _output,
                                        scrollController: _scrollCtrl)
                                    .animate()
                                    .fadeIn(delay: 400.ms)
                                    .slideX(begin: 0.05))
                          else
                            Expanded(
                                child: _AnimatedConsoleOutput(
                                        entries: _output,
                                        scrollController: _scrollCtrl)
                                    .animate()
                                    .fadeIn(delay: 400.ms)
                                    .slideX(begin: 0.05)),
                        ],
                      ),
                    );

                    if (!isCompact) return content;
                    return SingleChildScrollView(child: content);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
