import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

typedef ResponseStream = Stream<String> Function();

class TerminalCard extends StatefulWidget {
  final String command;
  final int statusCode;
  final ResponseStream? responseStream;
  final double height;

  const TerminalCard({
    super.key,
    required this.command,
    this.statusCode = 200,
    this.responseStream,
    this.height = 260,
  });

  @override
  State<TerminalCard> createState() => _TerminalCardState();
}

class _TerminalCardState extends State<TerminalCard> {
  final List<String> _lines = [];
  StreamSubscription<String>? _sub;
  bool _running = false;
  bool _showCursor = true;
  Timer? _cursorTimer;

  Color _statusColor(int code) {
    if (code >= 200 && code < 300) return const Color(0xFF28FFB3);
    if (code >= 300 && code < 400) return const Color(0xFF5EE0FF);
    if (code >= 400 && code < 500) return const Color(0xFFFFB86B);
    return const Color(0xFFFF6B6B);
  }

  void _start() {
    if (_running) return;
    setState(() {
      _lines.clear();
      _lines.add('');
      _running = true;
    });

    // start cursor timer
    _cursorTimer?.cancel();
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      setState(() => _showCursor = !_showCursor);
    });

    final stream = widget.responseStream?.call() ?? _simulateResponse();
    _sub = stream.listen((chunk) {
      setState(() {
        if (chunk == '\n') {
          _lines.add('');
        } else {
          if (_lines.isEmpty) {
            _lines.add(chunk);
          } else {
            _lines[_lines.length - 1] = _lines.last + chunk;
          }
        }
      });
    }, onDone: () {
      _cursorTimer?.cancel();
      setState(() {
        _running = false;
        _showCursor = false;
      });
    }, onError: (_) {
      _cursorTimer?.cancel();
      setState(() {
        _running = false;
        _lines.add('Error al obtener respuesta');
        _showCursor = false;
      });
    });
  }

  Stream<String> _simulateResponse() async* {
    // Emit characters one by one and newlines as separate events
    final content = [
      '{',
      '\n',
      '  "curp": "XXXX000000HDFABC01",',
      '\n',
      '  "name": "Juan",',
      '\n',
      '  "lastName": "Pérez"',
      '\n',
      '}',
      '\n'
    ];

    for (final part in content) {
      if (part == '\n') {
        // newline marker
        await Future.delayed(const Duration(milliseconds: 80));
        yield '\n';
        continue;
      }
      for (var i = 0; i < part.length; i++) {
        await Future.delayed(const Duration(milliseconds: 8));
        yield part[i];
      }
      await Future.delayed(const Duration(milliseconds: 60));
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: widget.height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: _statusColor(widget.statusCode).withAlpha((0.12 * 255).round()),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: command and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.command,
                  style: const TextStyle(fontFamily: 'JetBrains Mono')),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(widget.statusCode).withAlpha((0.12 * 255).round()),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('${widget.statusCode}',
                        style: TextStyle(
                            color: _statusColor(widget.statusCode),
                            fontFamily: 'JetBrains Mono')),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _running ? null : _start,
                    child: Text(_running ? 'Running...' : 'Run'),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // Body: streaming lines
          Expanded(
            child: SingleChildScrollView(
              child: SelectableText(
                _lines.isEmpty
                    ? 'Presiona Run para ver la respuesta...'
                    : (_lines.join('\n') +
                        (_running && _showCursor ? ' ▌' : '')),
                style: GoogleFonts.jetBrainsMono(
                    textStyle: const TextStyle(height: 1.35)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
