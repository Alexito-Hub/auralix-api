import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// flutter_animate unused here
import '../../core/theme/theme_extension.dart';

/// Terminal-style card with neon glow border.
class GlowCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final bool useAltGlow;
  final VoidCallback? onTap;

  const GlowCard({
    super.key,
    required this.child,
    this.padding,
    this.useAltGlow = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final deco = useAltGlow ? ext.glowBorderAlt : ext.glowBorder;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: deco.copyWith(color: ext.surface),
        child: child,
      ),
    );
  }
}

/// Terminal-style text input with blinking cursor and prompt prefix.
class TerminalInput extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final String? prefix;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmitted;
  final bool readOnly;
  final int? maxLines;

  const TerminalInput({
    super.key,
    required this.controller,
    required this.hint,
    this.prefix,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onSubmitted,
    this.readOnly = false,
    this.maxLines = 1,
  });

  @override
  State<TerminalInput> createState() => _TerminalInputState();
}

class _TerminalInputState extends State<TerminalInput> {
  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);

    return TextFormField(
      controller: widget.controller,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      readOnly: widget.readOnly,
      maxLines: widget.maxLines,
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator,
      cursorColor: ext.cursor,
      style:
          TextStyle(color: ext.text, fontSize: 14, fontFamily: 'JetBrainsMono'),
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixText: widget.prefix != null ? '${widget.prefix} ' : null,
        prefixStyle: TextStyle(
            color: ext.primary, fontSize: 14, fontFamily: 'JetBrainsMono'),
      ),
    );
  }
}

/// HTTP Status badge with color-coded styling.
class StatusBadge extends StatelessWidget {
  final int code;
  final String? message;

  const StatusBadge({super.key, required this.code, this.message});

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final color = ext.statusColor(code);
    final label = message ?? _defaultMessage(code);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(
            '$code $label',
            style: TextStyle(
                color: color,
                fontSize: 12,
                fontFamily: 'JetBrainsMono',
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _defaultMessage(int code) => switch (code) {
        200 => 'OK',
        201 => 'Created',
        204 => 'No Content',
        301 => 'Moved Permanently',
        304 => 'Not Modified',
        400 => 'Bad Request',
        401 => 'Unauthorized',
        403 => 'Forbidden',
        404 => 'Not Found',
        429 => 'Too Many Requests',
        500 => 'Internal Server Error',
        502 => 'Bad Gateway',
        503 => 'Service Unavailable',
        _ => '',
      };
}

/// Typewriter animated text widget.
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration speed;
  final bool showCursor;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.speed = const Duration(milliseconds: 40),
    this.showCursor = true,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  String _displayed = '';
  int _index = 0;
  late AnimationController _cursorController;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _typeNext();
  }

  void _typeNext() async {
    while (_index < widget.text.length && mounted) {
      await Future.delayed(widget.speed);
      if (!mounted) return;
      setState(() {
        _displayed = widget.text.substring(0, ++_index);
      });
    }
  }

  @override
  void dispose() {
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    return AnimatedBuilder(
      animation: _cursorController,
      builder: (_, __) {
        final cursor =
            widget.showCursor && _cursorController.value > 0.5 ? 'â–‹' : ' ';
        return Text(
          '$_displayed$cursor',
          style: (widget.style ?? TextStyle(color: ext.text, fontSize: 14))
              .copyWith(fontFamily: 'JetBrainsMono'),
        );
      },
    );
  }
}

/// Console output panel â€” scrollable terminal output.
class ConsoleOutput extends StatelessWidget {
  final List<ConsoleEntry> entries;
  final ScrollController? scrollController;

  const ConsoleOutput(
      {super.key, required this.entries, this.scrollController});

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    return Container(
      decoration: ext.surfaceDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ConsoleHeader(),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: entries.length,
              itemBuilder: (_, i) => _ConsoleLine(entry: entries[i]),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: ext.border)),
        color: ext.surfaceVariant,
      ),
      child: Row(
        children: [
          _dot(const Color(0xFFff5f57)),
          const SizedBox(width: 6),
          _dot(const Color(0xFFfebc2e)),
          const SizedBox(width: 6),
          _dot(const Color(0xFF28c840)),
          const SizedBox(width: 12),
          Text('terminal',
              style: TextStyle(color: ext.textMuted, fontSize: 12)),
        ],
      ),
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
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (entry.prefix != null)
            Text('${entry.prefix} ',
                style: TextStyle(
                    color: ext.primary,
                    fontSize: 12,
                    fontFamily: 'JetBrainsMono')),
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
                  ConsoleEntryType.normal => ext.text,
                },
                fontSize: 12,
                fontFamily: 'JetBrainsMono',
              ),
            ),
          ),
          if (entry.copyable)
            IconButton(
              icon: Icon(Icons.copy, size: 14, color: ext.textMuted),
              onPressed: () =>
                  Clipboard.setData(ClipboardData(text: entry.text)),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              tooltip: 'Copy',
            ),
        ],
      ),
    );
  }
}

enum ConsoleEntryType { normal, success, error, warning, info, muted }

class ConsoleEntry {
  final String text;
  final ConsoleEntryType type;
  final String? prefix;
  final bool copyable;

  const ConsoleEntry(this.text,
      {this.type = ConsoleEntryType.normal,
      this.prefix,
      this.copyable = false});

  factory ConsoleEntry.prompt(String cmd) =>
      ConsoleEntry(cmd, prefix: '\$', type: ConsoleEntryType.info);
  factory ConsoleEntry.success(String t) =>
      ConsoleEntry(t, type: ConsoleEntryType.success, prefix: '[+]');
  factory ConsoleEntry.error(String t) =>
      ConsoleEntry(t, type: ConsoleEntryType.error, prefix: '[x]');
  factory ConsoleEntry.warning(String t) =>
      ConsoleEntry(t, type: ConsoleEntryType.warning, prefix: '[!]');
  factory ConsoleEntry.info(String t) =>
      ConsoleEntry(t, type: ConsoleEntryType.info, prefix: 'â„¹');
  factory ConsoleEntry.muted(String t) =>
      ConsoleEntry(t, type: ConsoleEntryType.muted);
}

/// Metric card â€“ used in Dashboard
class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? valueColor;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.subtitle,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    return GlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: ext.textMuted),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: ext.textMuted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? ext.primary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'JetBrainsMono',
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!,
                style: TextStyle(color: ext.textMuted, fontSize: 11)),
          ],
        ],
      ),
    );
  }
}
