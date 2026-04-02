import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/theme_extension.dart';
import '../../../core/ui/breakpoints.dart';
import '../../../shared/code/code_highlighting.dart';
import '../../../shared/widgets/code_viewport.dart';
import '../../../shared/widgets/terminal_page_layout.dart';
import '../../../shared/widgets/terminal_widgets.dart';

class SnippetDetailScreen extends StatefulWidget {
  final String id;
  const SnippetDetailScreen({super.key, required this.id});

  @override
  State<SnippetDetailScreen> createState() => _SnippetDetailScreenState();
}

class _SnippetDetailScreenState extends State<SnippetDetailScreen> {
  bool _loading = true;
  Map<String, dynamic>? _snippet;
  bool _needsPassword = false;
  final _passCtrl = TextEditingController();
  String? _error;
  String _lastPassword = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _load({String? password}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiClient.instance.post(
          '/hub/snippets/${widget.id}/view',
          data: password != null ? {'password': password} : null);
      if (res.statusCode == 401 || res.data['requiresPassword'] == true) {
        setState(() {
          _needsPassword = true;
          _loading = false;
        });
      } else if (res.data['status'] == true) {
        setState(() {
          _snippet = res.data['data'];
          _needsPassword = false;
          _loading = false;
          _lastPassword = password ?? _lastPassword;
        });
      } else {
        setState(() {
          _error = res.data['msg'];
          _loading = false;
        });
      }
    } catch (_) {
      setState(() {
        _error = 'ERR_CONNECTION_REFUSED';
        _loading = false;
      });
    }
  }

  Future<void> _downloadSnippet() async {
    if ((_snippet?['allowDownload'] ?? true) != true) {
      final ext = AuralixThemeExtension.of(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('La descarga está deshabilitada para este snippet'),
        backgroundColor: ext.surfaceVariant,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    final query = <String, String>{};
    if (_lastPassword.trim().isNotEmpty) {
      query['password'] = _lastPassword.trim();
    }

    final endpoint = '/hub/snippets/${widget.id}/download';
    final absolute = ApiClient.buildAbsoluteUrl(endpoint);
    final baseUri = Uri.parse(absolute);
    final uri = query.isEmpty
        ? baseUri
        : baseUri.replace(queryParameters: {
            ...baseUri.queryParameters,
            ...query,
          });

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      final ext = AuralixThemeExtension.of(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('No se pudo iniciar la descarga'),
        backgroundColor: ext.surfaceVariant,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _openRawSnippet() async {
    if ((_snippet?['allowRaw'] ?? true) != true) {
      final ext = AuralixThemeExtension.of(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            const Text('La vista RAW está deshabilitada para este snippet'),
        backgroundColor: ext.surfaceVariant,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    final endpoint = '/s/${widget.id}/raw';
    final uri = Uri.parse(ApiClient.buildAbsoluteUrl(endpoint));

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.platformDefault,
      webOnlyWindowName: '_self',
    );

    if (!opened && mounted) {
      final ext = AuralixThemeExtension.of(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('No se pudo abrir la vista RAW'),
        backgroundColor: ext.surfaceVariant,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final compact = context.isMobile || context.isTablet;

    return Scaffold(
      backgroundColor: ext.bg,
      appBar: compact
          ? AppBar(
              backgroundColor: ext.surface,
              title: Text('hub.auralixpe.xyz/s/${widget.id}',
                  style: TextStyle(
                      color: ext.textMuted,
                      fontSize: 12,
                      fontFamily: 'JetBrainsMono')),
              iconTheme: IconThemeData(color: ext.text, size: 18),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Divider(color: ext.border, height: 1),
              ),
            )
          : null,
      body: Stack(
        children: [
          // Cyber background grid/glow
          Positioned(
            top: -200,
            left: -150,
            child: Container(
              width: 800,
              height: 800,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ext.primary.withValues(alpha: 0.05),
                    Colors.transparent
                  ],
                  stops: const [0.1, 1.0],
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                    duration: 6.seconds,
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.1, 1.1))
                .fade(),
          ),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: context.pageMaxWidth),
              child: Padding(
                padding: EdgeInsets.fromLTRB(context.pageHorizontalPadding, 20,
                    context.pageHorizontalPadding, 24),
                child: TerminalPageReveal(
                  animationKey: 'snippet-detail-${widget.id}',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TerminalPageHeader(
                        title: 'fragment_view',
                        subtitle: 'ID: ${widget.id}',
                        actions: [
                          StatusBadge(
                              code: _loading
                                  ? 102
                                  : (_needsPassword
                                      ? 401
                                      : (_error != null ? 500 : 200)),
                              message: _loading
                                  ? 'processing'
                                  : (_needsPassword
                                      ? 'encrypted'
                                      : (_error != null
                                          ? 'error'
                                          : 'decrypted'))),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: 400.ms,
                          switchInCurve: Curves.easeOutBack,
                          switchOutCurve: Curves.easeInQuint,
                          layoutBuilder: (curr, prev) => Stack(
                              alignment: Alignment.topCenter,
                              children: <Widget>[...prev].followedBy(
                                  <Widget>[if (curr != null) curr]).toList()),
                          child: _buildBody(ext),
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

  Widget _buildBody(AuralixThemeExtension ext) {
    if (_loading) {
      return SizedBox(
        key: const ValueKey('snippet-loading'),
        width: double.infinity,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: ext.primary, strokeWidth: 2),
              const SizedBox(height: 24),
              TypewriterText(
                  text: 'DECRYPTING_PAYLOAD...',
                  style: TextStyle(
                      color: ext.primary,
                      fontFamily: 'JetBrainsMono',
                      fontSize: 12,
                      letterSpacing: 2)),
            ],
          ),
        ),
      );
    }
    if (_needsPassword) {
      return _PasswordGate(
        key: const ValueKey('snippet-password'),
        controller: _passCtrl,
        onSubmit: () => _load(password: _passCtrl.text),
        error: _error,
        ext: ext,
      );
    }
    if (_error != null) {
      return SizedBox(
        key: const ValueKey('snippet-error'),
        width: double.infinity,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ext.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ext.error.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                    color: ext.error.withValues(alpha: 0.2), blurRadius: 20)
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.gpp_bad, size: 48, color: ext.error),
                const SizedBox(height: 16),
                Text('ACCESS_DENIED',
                    style: TextStyle(
                        color: ext.error,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'JetBrainsMono',
                        letterSpacing: 2)),
                const SizedBox(height: 8),
                Text(_error!,
                    style: TextStyle(
                        color: ext.error.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontFamily: 'JetBrainsMono')),
              ],
            ),
          ),
        ),
      );
    }

    return _SnippetView(
        key: const ValueKey('snippet-view'),
        snippet: _snippet!,
        ext: ext,
        onDownload: _downloadSnippet,
        onOpenRaw: _openRawSnippet);
  }
}

class _PasswordGate extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final String? error;
  final AuralixThemeExtension ext;
  const _PasswordGate(
      {super.key,
      required this.controller,
      required this.onSubmit,
      this.error,
      required this.ext});

  @override
  State<_PasswordGate> createState() => _PasswordGateState();
}

class _PasswordGateState extends State<_PasswordGate> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: widget.ext.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: widget.ext.warning.withValues(alpha: 0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: widget.ext.warning.withValues(alpha: 0.15),
                  blurRadius: 30)
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_person, size: 56, color: widget.ext.warning)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                      duration: 2.seconds,
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1.05, 1.05)),
              const SizedBox(height: 24),
              Text(
                'ENCRYPTED_FRAGMENT',
                style: TextStyle(
                  color: widget.ext.warning,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'JetBrainsMono',
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This payload requires a decryption key to view its contents.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: widget.ext.textMuted,
                    fontSize: 12,
                    fontFamily: 'JetBrainsMono'),
              ),
              const SizedBox(height: 32),
              TerminalInput(
                controller: widget.controller,
                hint: 'Enter decryption key',
                prefix: 'key:',
                obscureText: true,
                onSubmitted: (_) => widget.onSubmit(),
              ),
              if (widget.error != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: widget.ext.error.withValues(alpha: 0.1),
                      border: Border(
                          left: BorderSide(color: widget.ext.error, width: 4))),
                  child: Text(widget.error!,
                      style: TextStyle(
                          color: widget.ext.error,
                          fontSize: 11,
                          fontFamily: 'JetBrainsMono')),
                ),
              ],
              const SizedBox(height: 32),
              MouseRegion(
                onEnter: (_) => setState(() => _hovering = true),
                onExit: (_) => setState(() => _hovering = false),
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: widget.onSubmit,
                  child: AnimatedContainer(
                    duration: 200.ms,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _hovering
                          ? widget.ext.warning.withValues(alpha: 0.9)
                          : widget.ext.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: widget.ext.warning),
                      boxShadow: [
                        if (_hovering)
                          BoxShadow(
                              color: widget.ext.warning.withValues(alpha: 0.4),
                              blurRadius: 15)
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.key,
                              size: 16,
                              color: _hovering
                                  ? widget.ext.bg
                                  : widget.ext.warning),
                          const SizedBox(width: 8),
                          Text(
                            'INITIATE_DECRYPTION',
                            style: TextStyle(
                              color: _hovering
                                  ? widget.ext.bg
                                  : widget.ext.warning,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'JetBrainsMono',
                              letterSpacing: 2,
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
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),
      ),
    );
  }
}

class _SnippetView extends StatefulWidget {
  final Map<String, dynamic> snippet;
  final AuralixThemeExtension ext;
  final VoidCallback onDownload;
  final VoidCallback onOpenRaw;
  const _SnippetView(
      {super.key,
      required this.snippet,
      required this.ext,
      required this.onDownload,
      required this.onOpenRaw});

  @override
  State<_SnippetView> createState() => _SnippetViewState();
}

class _SnippetViewState extends State<_SnippetView> {
  bool _copied = false;

  void _handleCopy(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  String _formatDate(dynamic value) {
    final parsed = DateTime.tryParse((value ?? '').toString());
    if (parsed == null) return '--';
    final local = parsed.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$month-$day $hour:$minute';
  }

  Map<String, dynamic> _ownerMap() {
    if (widget.snippet['owner'] is Map) {
      return Map<String, dynamic>.from(widget.snippet['owner'] as Map);
    }
    return const <String, dynamic>{};
  }

  @override
  Widget build(BuildContext context) {
    final code = widget.snippet['code'] as String? ?? '';
    final effectiveCode = code;
    final declaredLang =
        (widget.snippet['language'] as String? ?? 'plaintext').trim();
    final title = (widget.snippet['title'] ?? 'UNTITLED_PAYLOAD').toString();
    final resolvedLang = resolveCodeLanguage(
      declaredLanguage: declaredLang,
      titleHint: title,
      code: effectiveCode,
    );
    final displayLang = resolvedLang.toUpperCase();
    final owner = _ownerMap();
    final ownerName = ((owner['displayName'] ?? owner['email']) ?? 'anonymous')
        .toString()
        .trim();
    final ownerEmail = (owner['email'] ?? '').toString();
    final createdAt = _formatDate(widget.snippet['createdAt']);
    final updatedAt = _formatDate(widget.snippet['updatedAt']);
    final viewCount = (widget.snippet['viewCount'] ?? 0).toString();
    final allowRaw = (widget.snippet['allowRaw'] ?? true) == true;
    final allowDownload = (widget.snippet['allowDownload'] ?? true) == true;

    Widget actionButton({
      required IconData icon,
      required String label,
      required bool active,
      required VoidCallback onTap,
    }) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: 180.ms,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: active ? widget.ext.primary : widget.ext.bg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: active ? widget.ext.primary : widget.ext.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 13,
                  color: active ? widget.ext.bg : widget.ext.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: active ? widget.ext.bg : widget.ext.textMuted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'JetBrainsMono',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: widget.ext.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: widget.ext.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
              color: widget.ext.primary.withValues(alpha: 0.05), blurRadius: 20)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: widget.ext.surfaceVariant,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(9)),
              border: Border(
                  bottom: BorderSide(
                      color: widget.ext.primary.withValues(alpha: 0.2))),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                      color: widget.ext.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: widget.ext.primary, blurRadius: 6)
                      ]),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fade(duration: 1.seconds, begin: 0.3, end: 1),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              color: widget.ext.text,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'JetBrainsMono',
                              letterSpacing: 0.5)),
                      const SizedBox(height: 4),
                      Text('LANG: $displayLang | MODE: CODE',
                          style: TextStyle(
                              color: widget.ext.primary,
                              fontSize: 10,
                              fontFamily: 'JetBrainsMono',
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1)),
                      const SizedBox(height: 4),
                      Text(
                        'UPLOADER: ${ownerName.isEmpty ? 'anonymous' : ownerName}${ownerEmail.isEmpty ? '' : ' <$ownerEmail>'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: widget.ext.textSubtle,
                          fontSize: 10,
                          fontFamily: 'JetBrainsMono',
                        ),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    actionButton(
                      icon: Icons.download,
                      label: 'DOWNLOAD',
                      active: allowDownload,
                      onTap: allowDownload ? widget.onDownload : () {},
                    ),
                    actionButton(
                      icon: Icons.open_in_new,
                      label: 'RAW',
                      active: allowRaw,
                      onTap: allowRaw ? widget.onOpenRaw : () {},
                    ),
                    actionButton(
                      icon: _copied ? Icons.check : Icons.copy,
                      label: _copied ? 'COPIED' : 'COPY',
                      active: _copied,
                      onTap: () => _handleCopy(code),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: CodeViewport(
              ext: widget.ext,
              code: effectiveCode,
              language: resolvedLang,
              rawMode: false,
              showLineNumbers: true,
              showWatermark: true,
              watermarkIcon: Icons.code,
              watermarkSize: 220,
              watermarkOpacity: 0.035,
              contentPadding: const EdgeInsets.fromLTRB(18, 24, 20, 24),
              gutterPadding: const EdgeInsets.fromLTRB(8, 24, 8, 24),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: widget.ext.surfaceVariant,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(9)),
              border: Border(
                  top: BorderSide(
                      color: widget.ext.primary.withValues(alpha: 0.2))),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Icon(Icons.person_outline,
                      size: 12, color: widget.ext.primary),
                  const SizedBox(width: 6),
                  Text(
                    ownerName.isEmpty ? 'anonymous' : ownerName,
                    style: TextStyle(
                      color: widget.ext.textMuted,
                      fontSize: 10,
                      fontFamily: 'JetBrainsMono',
                    ),
                  ),
                  const SizedBox(width: 14),
                  Icon(Icons.visibility_outlined,
                      size: 12, color: widget.ext.primary),
                  const SizedBox(width: 6),
                  Text(
                    viewCount,
                    style: TextStyle(
                      color: widget.ext.textMuted,
                      fontSize: 10,
                      fontFamily: 'JetBrainsMono',
                    ),
                  ),
                  const SizedBox(width: 14),
                  Icon(Icons.calendar_today_outlined,
                      size: 11, color: widget.ext.primary),
                  const SizedBox(width: 6),
                  Text(
                    createdAt,
                    style: TextStyle(
                      color: widget.ext.textMuted,
                      fontSize: 10,
                      fontFamily: 'JetBrainsMono',
                    ),
                  ),
                  const SizedBox(width: 14),
                  Icon(Icons.update, size: 12, color: widget.ext.primary),
                  const SizedBox(width: 6),
                  Text(
                    updatedAt,
                    style: TextStyle(
                      color: widget.ext.textMuted,
                      fontSize: 10,
                      fontFamily: 'JetBrainsMono',
                    ),
                  ),
                  const SizedBox(width: 14),
                  Icon(Icons.data_object, size: 12, color: widget.ext.primary),
                  const SizedBox(width: 6),
                  Text(
                    'BYTES: ${code.length}',
                    style: TextStyle(
                      color: widget.ext.textMuted,
                      fontSize: 10,
                      fontFamily: 'JetBrainsMono',
                    ),
                  ),
                  const SizedBox(width: 14),
                  Icon(Icons.tune, size: 12, color: widget.ext.primary),
                  const SizedBox(width: 6),
                  Text(
                    'RAW:${allowRaw ? 'ON' : 'OFF'} | DL:${allowDownload ? 'ON' : 'OFF'}',
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
    );
  }
}
