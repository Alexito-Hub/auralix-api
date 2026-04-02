part of '../screens/sandbox_screen.dart';

class _HoverSandboxCard extends StatefulWidget {
  final Widget child;
  const _HoverSandboxCard({required this.child});

  @override
  State<_HoverSandboxCard> createState() => __HoverSandboxCardState();
}

class __HoverSandboxCardState extends State<_HoverSandboxCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: 250.ms,
        curve: Curves.easeOutCubic,
        transform: _hovering
            ? Matrix4.translationValues(0, -2, 0)
            : Matrix4.identity(),
        padding: const EdgeInsets.all(20),
        decoration: ext.surfaceDecoration.copyWith(
          border: Border.all(
              color:
                  _hovering ? ext.primary.withValues(alpha: 0.6) : ext.border),
          boxShadow: _hovering
              ? [
                  BoxShadow(
                      color: ext.primary.withValues(alpha: 0.15),
                      blurRadius: 15,
                      spreadRadius: -2)
                ]
              : [],
          borderRadius: BorderRadius.circular(8),
        ),
        child: widget.child,
      ),
    );
  }
}

class _SandboxParameterForm extends StatelessWidget {
  final List<ApiServiceParameter> parameters;
  final Map<String, TextEditingController> controllers;
  final AuralixThemeExtension ext;

  const _SandboxParameterForm({
    required this.parameters,
    required this.controllers,
    required this.ext,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (parameters.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 4),
        child: Text(l10n.sandboxNoDeclaredParams,
            style: TextStyle(
                color: ext.textMuted,
                fontSize: 11,
                fontFamily: 'JetBrainsMono')),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune, size: 16, color: ext.primary),
              const SizedBox(width: 8),
              Text(l10n.sandboxPayloadVariables,
                  style: TextStyle(
                      color: ext.text,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'JetBrainsMono')),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final useTwoColumns = constraints.maxWidth > 920;
              final fieldWidth = useTwoColumns
                  ? (constraints.maxWidth - 16) / 2
                  : constraints.maxWidth;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: parameters.map((parameter) {
                  final controller = controllers[parameter.name];
                  if (controller == null) return const SizedBox.shrink();

                  return SizedBox(
                    width: fieldWidth,
                    child: _HoverParameterInputCard(
                      parameter: parameter,
                      controller: controller,
                      ext: ext,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HoverParameterInputCard extends StatefulWidget {
  final ApiServiceParameter parameter;
  final TextEditingController controller;
  final AuralixThemeExtension ext;

  const _HoverParameterInputCard(
      {required this.parameter, required this.controller, required this.ext});

  @override
  State<_HoverParameterInputCard> createState() =>
      _HoverParameterInputCardState();
}

class _HoverParameterInputCardState extends State<_HoverParameterInputCard> {
  bool _hasFocus = false;

  @override
  Widget build(BuildContext context) {
    final parameter = widget.parameter;
    final ext = widget.ext;
    final l10n = AppLocalizations.of(context)!;
    final multiLine = parameter.type.toLowerCase().contains('object') ||
        parameter.type.toLowerCase().contains('array') ||
        parameter.type.toLowerCase().contains('map') ||
        parameter.example.trim().startsWith('{') ||
        parameter.example.trim().startsWith('[');

    return AnimatedContainer(
      duration: 200.ms,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _hasFocus ? ext.primary.withValues(alpha: 0.05) : ext.bg,
        border: Border.all(color: _hasFocus ? ext.primary : ext.border),
        borderRadius: BorderRadius.circular(6),
        boxShadow: _hasFocus
            ? [
                BoxShadow(
                    color: ext.primary.withValues(alpha: 0.1), blurRadius: 8)
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(parameter.name,
                    style: TextStyle(
                        color: _hasFocus ? ext.primary : ext.text,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'JetBrainsMono')),
              ),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: ext.textMuted.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4)),
                  child: Text(parameter.type,
                      style: TextStyle(
                          color: ext.textMuted,
                          fontSize: 10,
                          fontFamily: 'JetBrainsMono'))),
              const SizedBox(width: 6),
              if (parameter.required)
                Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                            color: ext.error.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: ext.error.withValues(alpha: 0.3))),
                        child: Text(l10n.sandboxRequiredBadge,
                            style: TextStyle(
                                color: ext.error,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'JetBrainsMono')))
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .shimmer(
                        duration: 2.seconds,
                        color: ext.error.withValues(alpha: 0.5)),
            ],
          ),
          const SizedBox(height: 12),
          Focus(
            onFocusChange: (f) => setState(() => _hasFocus = f),
            child: TextFormField(
              controller: widget.controller,
              minLines: multiLine ? 3 : 1,
              maxLines: multiLine ? 8 : 1,
              style: TextStyle(
                  color: ext.text, fontFamily: 'JetBrainsMono', fontSize: 12),
              decoration: InputDecoration(
                hintText: _hintText(parameter, l10n),
                hintStyle: TextStyle(
                    color: ext.textMuted,
                    fontSize: 11.5,
                    fontFamily: 'JetBrainsMono'),
                filled: true,
                fillColor: ext.surface,
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(4)),
                focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: ext.primary.withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(4)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _hintText(ApiServiceParameter parameter, AppLocalizations l10n) {
    if (parameter.description.trim().isNotEmpty) {
      return parameter.description.trim();
    }
    if (parameter.example.trim().isNotEmpty) {
      final compact = parameter.example.trim().replaceAll('\n', ' ');
      return compact.length > 80 ? '${compact.substring(0, 80)}...' : compact;
    }
    return l10n.sandboxInsertPayloadHint(parameter.name);
  }
}

class _SandboxHistoryPanel extends StatelessWidget {
  final List<_SandboxHistoryEntry> entries;
  final ValueChanged<_SandboxHistoryEntry> onRestore;

  const _SandboxHistoryPanel({required this.entries, required this.onRestore});

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;
    return _HoverSandboxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history_toggle_off, size: 16, color: ext.textMuted),
              const SizedBox(width: 8),
              Text(l10n.sandboxHistoryTitle,
                  style: TextStyle(
                      color: ext.text,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'JetBrainsMono')),
              const Spacer(),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: ext.bg,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: ext.border)),
                  child: Text(l10n.sandboxCachedCount(entries.length),
                      style: TextStyle(
                          color: ext.textMuted,
                          fontSize: 10,
                          fontFamily: 'JetBrainsMono'))),
            ],
          ),
          const SizedBox(height: 12),
          ...entries.take(5).map((entry) {
            final timestamp =
                DateTime.fromMillisecondsSinceEpoch(entry.timestampMs);
            final hh = timestamp.hour.toString().padLeft(2, '0');
            final mm = timestamp.minute.toString().padLeft(2, '0');
            final status = entry.statusCode;
            final statusColor = status == null
                ? ext.warning
                : status >= 500
                    ? ext.error
                    : status >= 400
                        ? ext.warning
                        : ext.success;

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _HoverHistoryRow(
                entry: entry,
                ext: ext,
                hh: hh,
                mm: mm,
                status: status,
                statusColor: statusColor,
                onTap: () => onRestore(entry),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _HoverHistoryRow extends StatefulWidget {
  final _SandboxHistoryEntry entry;
  final AuralixThemeExtension ext;
  final String hh;
  final String mm;
  final int? status;
  final Color statusColor;
  final VoidCallback onTap;

  const _HoverHistoryRow(
      {required this.entry,
      required this.ext,
      required this.hh,
      required this.mm,
      required this.status,
      required this.statusColor,
      required this.onTap});

  @override
  State<_HoverHistoryRow> createState() => __HoverHistoryRowState();
}

class __HoverHistoryRowState extends State<_HoverHistoryRow> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: 150.ms,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _hovering
                ? widget.ext.primary.withValues(alpha: 0.1)
                : widget.ext.bg,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
                color: _hovering
                    ? widget.ext.primary.withValues(alpha: 0.3)
                    : widget.ext.border),
          ),
          child: Row(
            children: [
              Text(_hovering ? '> ' : '  ',
                  style: TextStyle(
                      color: widget.ext.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'JetBrainsMono')),
              SizedBox(
                  width: 45,
                  child: Text(widget.entry.method,
                      style: TextStyle(
                          color: widget.ext.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'JetBrainsMono'))),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(widget.entry.path,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: _hovering
                              ? widget.ext.text
                              : widget.ext.textMuted,
                          fontSize: 11,
                          fontFamily: 'JetBrainsMono'))),
              const SizedBox(width: 8),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: widget.statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: widget.statusColor.withValues(alpha: 0.3))),
                  child: Text(
                      widget.status == null
                          ? l10n.sandboxStatusError
                          : '${widget.status}',
                      style: TextStyle(
                          color: widget.statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'JetBrainsMono'))),
              const SizedBox(width: 12),
              Text('${widget.hh}:${widget.mm}',
                  style: TextStyle(
                      color: widget.ext.textMuted,
                      fontSize: 10.5,
                      fontFamily: 'JetBrainsMono')),
              const SizedBox(width: 8),
              Icon(Icons.restore,
                  size: 14,
                  color: _hovering ? widget.ext.primary : widget.ext.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedConsoleOutput extends StatelessWidget {
  final List<ConsoleEntry> entries;
  final ScrollController scrollController;
  const _AnimatedConsoleOutput(
      {required this.entries, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F12), // Deep terminal black
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ext.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 15),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ConsoleHeader(),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: entries.length + 2, // padding + EOF
              itemBuilder: (_, i) {
                if (i == entries.length + 1) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 20),
                    child: Text('EOF_',
                            style: TextStyle(
                                color: ext.primary.withValues(alpha: 0.7),
                                fontFamily: 'JetBrainsMono',
                                fontSize: 12,
                                fontWeight: FontWeight.bold))
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .fade(duration: 800.ms, begin: 0.3, end: 1.0),
                  );
                }
                if (i == entries.length) return const SizedBox(height: 10);

                final entry = entries[i];
                return _ConsoleLine(entry: entry)
                    .animate(key: ValueKey(i))
                    .fadeIn(duration: 180.ms)
                    .slideX(begin: 0.02, duration: 150.ms);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsoleHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
          color: ext.surfaceVariant.withValues(alpha: 0.6),
          border: Border(bottom: BorderSide(color: ext.border))),
      child: Row(children: [
        _dot(const Color(0xFFff5f57)),
        const SizedBox(width: 8),
        _dot(const Color(0xFFfebc2e)),
        const SizedBox(width: 8),
        _dot(const Color(0xFF28c840)),
        const SizedBox(width: 16),
        Text('~/sandbox/stdout.log',
            style: TextStyle(
                color: ext.textMuted,
                fontSize: 11,
                fontFamily: 'JetBrainsMono')),
        const Spacer(),
        Icon(Icons.circle, size: 8, color: ext.success)
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fade(duration: 1.5.seconds, begin: 0.2, end: 1.0),
      ]),
    );
  }

  Widget _dot(Color c) => Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle));
}

class _ConsoleLine extends StatelessWidget {
  final ConsoleEntry entry;
  const _ConsoleLine({required this.entry});

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (entry.prefix != null)
            Text('${entry.prefix} ',
                style: TextStyle(
                    color: ext.primary,
                    fontSize: 12,
                    fontFamily: 'JetBrainsMono',
                    fontWeight: FontWeight.bold)),
          Expanded(
            child: SelectableText(
              entry.text,
              style: TextStyle(
                color: switch (entry.type) {
                  ConsoleEntryType.success => ext.success,
                  ConsoleEntryType.error => ext.error,
                  ConsoleEntryType.warning => ext.warning,
                  ConsoleEntryType.info => ext.accentAlt,
                  ConsoleEntryType.muted => ext.textMuted,
                  ConsoleEntryType.normal => const Color(0xFFE2E8F0),
                },
                fontSize: 12,
                fontFamily: 'JetBrainsMono',
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
