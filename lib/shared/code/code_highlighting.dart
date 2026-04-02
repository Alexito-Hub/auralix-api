import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/theme_extension.dart';

const int defaultHighlightChunkLines = 220;

const Map<String, String> codeLanguageAliases = {
  'curl': 'bash',
  'sh': 'bash',
  'shell': 'bash',
  'zsh': 'bash',
  'powershell': 'powershell',
  'ps1': 'powershell',
  'js': 'javascript',
  'mjs': 'javascript',
  'cjs': 'javascript',
  'node': 'javascript',
  'nodejs': 'javascript',
  'ts': 'typescript',
  'mts': 'typescript',
  'cts': 'typescript',
  'tsx': 'typescript',
  'jsx': 'javascript',
  'html': 'xml',
  'htm': 'xml',
  'cs': 'csharp',
  'c#': 'csharp',
  'c++': 'cpp',
  'hpp': 'cpp',
  'h++': 'cpp',
  'py': 'python',
  'rb': 'ruby',
  'kt': 'kotlin',
  'yml': 'yaml',
  'md': 'markdown',
  'docker': 'dockerfile',
  'dockerfile': 'dockerfile',
  'ini': 'ini',
  'dotenv': 'ini',
  'env': 'ini',
  'properties': 'ini',
  'conf': 'ini',
  'proto': 'protobuf',
  'pb': 'protobuf',
  'psm1': 'powershell',
  'bat': 'dos',
  'cmd': 'dos',
  'makefile': 'makefile',
  'plain': 'plaintext',
  'text': 'plaintext',
  'txt': 'plaintext',
};

String normalizeCodeText(String code) {
  return code.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
}

const Map<String, String> codeExtensionAliases = {
  '.js': 'javascript',
  '.mjs': 'javascript',
  '.cjs': 'javascript',
  '.ts': 'typescript',
  '.mts': 'typescript',
  '.cts': 'typescript',
  '.tsx': 'typescript',
  '.jsx': 'javascript',
  '.dart': 'dart',
  '.py': 'python',
  '.rb': 'ruby',
  '.php': 'php',
  '.java': 'java',
  '.kt': 'kotlin',
  '.swift': 'swift',
  '.go': 'go',
  '.rs': 'rust',
  '.scala': 'scala',
  '.sql': 'sql',
  '.sh': 'bash',
  '.bash': 'bash',
  '.zsh': 'bash',
  '.ps1': 'powershell',
  '.c': 'c',
  '.cpp': 'cpp',
  '.h': 'c',
  '.hpp': 'cpp',
  '.cs': 'csharp',
  '.css': 'css',
  '.html': 'xml',
  '.xml': 'xml',
  '.json': 'json',
  '.yaml': 'yaml',
  '.yml': 'yaml',
  '.md': 'markdown',
  '.graphql': 'graphql',
  '.vue': 'xml',
  '.toml': 'toml',
  '.ini': 'ini',
  '.env': 'ini',
  '.conf': 'ini',
  '.properties': 'ini',
  '.proto': 'protobuf',
  '.psm1': 'powershell',
  '.bat': 'dos',
  '.cmd': 'dos',
};

const Set<String> codeHighlightSupportedLanguages = {
  'bash',
  'c',
  'cpp',
  'csharp',
  'css',
  'dart',
  'dockerfile',
  'dos',
  'go',
  'graphql',
  'ini',
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
};

String normalizeCodeLanguage(String value) {
  final lang = value.trim().toLowerCase();
  if (lang.isEmpty) return '';
  return codeLanguageAliases[lang] ?? lang;
}

String sanitizeCodeLanguage(String value, {String fallback = 'plaintext'}) {
  final normalized = normalizeCodeLanguage(value);
  if (normalized.isEmpty) return fallback;
  if (codeHighlightSupportedLanguages.contains(normalized)) return normalized;
  return fallback;
}

String inferCodeLanguageFromTitle(String title) {
  final clean = title.trim().toLowerCase();
  if (clean.isEmpty) return '';

  if (clean == 'dockerfile') return 'dockerfile';
  if (clean == 'makefile') return 'makefile';
  if (clean == '.env') return 'ini';

  final index = clean.lastIndexOf('.');
  if (index == -1 || index == clean.length - 1) return '';

  final ext = clean.substring(index);
  return codeExtensionAliases[ext] ?? '';
}

String guessCodeLanguageFromCode(String code) {
  // Keep inference stable across OSes by normalizing line endings first.
  final source = normalizeCodeText(code).trimLeft();
  if (source.isEmpty) return 'plaintext';

  final firstLine = source.split('\n').first.toLowerCase();
  if (firstLine.startsWith('#!/')) {
    if (firstLine.contains('python')) return 'python';
    if (firstLine.contains('pwsh') || firstLine.contains('powershell')) {
      return 'powershell';
    }
    if (firstLine.contains('node')) return 'javascript';
    if (firstLine.contains('bash') || firstLine.contains('sh')) return 'bash';
  }

  if (RegExp(r'^\s*<\?php', caseSensitive: false).hasMatch(source)) {
    return 'php';
  }

  if (source.startsWith('curl ')) return 'bash';

  if (RegExp(
    r'^\s*(Get|Set|New|Write|Start|Stop|Invoke)-[A-Za-z]+|^\s*\$[A-Za-z_][A-Za-z0-9_]*\s*=|^\s*\[[A-Za-z0-9_.]+\]',
    multiLine: true,
  ).hasMatch(source)) {
    return 'powershell';
  }

  if (RegExp(
    r'^\s*(sudo\s+|apt\s+|yum\s+|brew\s+|echo\s+|export\s+|chmod\s+|chown\s+|mkdir\s+|cd\s+|ls\b)',
    multiLine: true,
  ).hasMatch(source)) {
    return 'bash';
  }

  if (RegExp(r'(^|\n)\s*(#{1,6}\s+|```|\*\s+|\d+\.\s+)', multiLine: true)
      .hasMatch(source)) {
    return 'markdown';
  }

  if (RegExp(r'^\s*<\?xml').hasMatch(source)) return 'xml';
  if (RegExp(r'^\s*(<!doctype html|<html)', caseSensitive: false)
      .hasMatch(source)) {
    return 'xml';
  }

  if (RegExp(r'^\s*\{').hasMatch(source) &&
      source.contains('"') &&
      source.contains(':')) {
    return 'json';
  }

  if (RegExp(r'^\s*\[').hasMatch(source) && source.contains('{')) {
    return 'json';
  }

  if (RegExp(r'^\s*---').hasMatch(source) &&
      RegExp(r'^\s*[a-zA-Z0-9_-]+\s*:', multiLine: true).hasMatch(source)) {
    return 'yaml';
  }

  if (RegExp(r'^\s*\[[^\]]+\]\s*$', multiLine: true).hasMatch(source) &&
      RegExp(r'^\s*[A-Za-z0-9_.-]+\s*=\s*.+$', multiLine: true)
          .hasMatch(source)) {
    return 'toml';
  }

  if (RegExp(r'^\s*SELECT\b', caseSensitive: false).hasMatch(source)) {
    return 'sql';
  }

  if (RegExp(r'^\s*(query|mutation|subscription|fragment|type|schema)\b',
          caseSensitive: false, multiLine: true)
      .hasMatch(source)) {
    return 'graphql';
  }

  if (RegExp(r'^\s*syntax\s*=\s*"proto[23]"\s*;', caseSensitive: false)
      .hasMatch(source)) {
    return 'protobuf';
  }

  if (RegExp(r'^\s*\[[^\]]+\]\s*$', multiLine: true).hasMatch(source) &&
      RegExp(r'^\s*[a-zA-Z0-9_.-]+\s*=\s*.+$', multiLine: true)
          .hasMatch(source)) {
    return 'ini';
  }

  if (RegExp(r'^\s*#include\s+[<"].+[>"]', multiLine: true).hasMatch(source)) {
    if (RegExp(r'\b(std::|using\s+namespace\s+std\b)', multiLine: true)
        .hasMatch(source)) {
      return 'cpp';
    }
    return 'c';
  }

  if (RegExp("^\\s*import\\s+['\\\"]package:", multiLine: true)
          .hasMatch(source) ||
      RegExp(r'^\s*void\s+main\s*\(', multiLine: true).hasMatch(source)) {
    return 'dart';
  }

  if (RegExp(r'^\s*(def |class |import |from )', multiLine: true)
      .hasMatch(source)) {
    return 'python';
  }

  if (RegExp(
    r'^\s*(using\s+[A-Za-z0-9_.]+\s*;|namespace\s+[A-Za-z0-9_.]+\s*\{|public\s+(class|record|interface)\s+[A-Za-z_][A-Za-z0-9_]*)',
    multiLine: true,
  ).hasMatch(source)) {
    return 'csharp';
  }

  if (RegExp(
    r'^\s*(package\s+[a-z0-9_.]+\s*;|import\s+java\.|public\s+(class|interface|enum)\s+[A-Za-z_][A-Za-z0-9_]*)',
    multiLine: true,
  ).hasMatch(source)) {
    return 'java';
  }

  if (RegExp(r'^\s*(package\s+main|func\s+\w+\s*\()', multiLine: true)
      .hasMatch(source)) {
    return 'go';
  }

  if (RegExp(r'^\s*(fn\s+\w+|use\s+[a-zA-Z0-9_:]+)', multiLine: true)
      .hasMatch(source)) {
    return 'rust';
  }

  if (RegExp(r'^\s*(fun\s+\w+\s*\(|val\s+\w+)', multiLine: true)
      .hasMatch(source)) {
    return 'kotlin';
  }

  if (RegExp(r'^\s*(interface |type |enum |namespace )', multiLine: true)
          .hasMatch(source) ||
      RegExp(r'^\s*import\s+type\s+', multiLine: true).hasMatch(source) ||
      RegExp(r'\b(as\s+const|satisfies)\b', multiLine: true).hasMatch(source) ||
      RegExp(
        r'^\s*(public|private|protected|readonly)\s+[A-Za-z_][A-Za-z0-9_]*\??\s*:\s*[A-Za-z_]',
        multiLine: true,
      ).hasMatch(source) ||
      RegExp(
        r'^\s*(const|let|var|function)\s+[A-Za-z_$][A-Za-z0-9_$]*\s*:\s*[A-Za-z_]',
        multiLine: true,
      ).hasMatch(source) ||
      RegExp(
        r'^\s*[A-Za-z_$][A-Za-z0-9_$]*\??\s*:\s*[A-Za-z_][A-Za-z0-9_<>,\[\]\|&? ]+\s*(=|,|;)',
        multiLine: true,
      ).hasMatch(source)) {
    return 'typescript';
  }

  if (RegExp(r'^\s*([.#]?[A-Za-z_-][A-Za-z0-9_-]*|@media|@keyframes)\b.*\{',
              multiLine: true)
          .hasMatch(source) &&
      source.contains(':') &&
      source.contains(';')) {
    return 'css';
  }

  if (RegExp(r'^\s*(function |const |let |var |import |export |class )',
          multiLine: true)
      .hasMatch(source)) {
    return 'javascript';
  }

  return 'plaintext';
}

String resolveCodeLanguage({
  required String declaredLanguage,
  String titleHint = '',
  required String code,
  String fallback = 'plaintext',
}) {
  final fromDeclared = normalizeCodeLanguage(declaredLanguage);
  final declaredIsGenericPlain =
      fromDeclared.isEmpty || fromDeclared == 'plaintext';

  if (!declaredIsGenericPlain) {
    final safeDeclared = sanitizeCodeLanguage(fromDeclared, fallback: '');
    if (safeDeclared.isNotEmpty) {
      // Auto-upgrade JS highlight to TS when the source clearly contains TS syntax.
      if (safeDeclared == 'javascript') {
        final fromCodeForJs =
            sanitizeCodeLanguage(guessCodeLanguageFromCode(code), fallback: '');
        if (fromCodeForJs == 'typescript') {
          return 'typescript';
        }
      }
      return safeDeclared;
    }
  }

  final fromTitle =
      normalizeCodeLanguage(inferCodeLanguageFromTitle(titleHint));
  if (fromTitle.isNotEmpty) {
    final safeTitle = sanitizeCodeLanguage(fromTitle, fallback: '');
    if (safeTitle.isNotEmpty) return safeTitle;
  }

  final fromCode = normalizeCodeLanguage(guessCodeLanguageFromCode(code));
  if (fromCode.isNotEmpty) {
    final safeFromCode = sanitizeCodeLanguage(fromCode, fallback: '');
    if (safeFromCode.isNotEmpty) return safeFromCode;
  }

  if (fromDeclared.isNotEmpty) {
    return sanitizeCodeLanguage(fromDeclared, fallback: fallback);
  }

  return sanitizeCodeLanguage(fallback, fallback: 'plaintext');
}

Map<String, TextStyle> buildCodeHighlightTheme(
  AuralixThemeExtension ext, {
  double fontSize = 13,
  double lineHeight = 1.65,
  double letterSpacing = 0.2,
}) {
  final base = TextStyle(
    color: ext.text.withValues(alpha: 0.95),
    fontFamily: 'JetBrainsMono',
    fontSize: fontSize,
    height: lineHeight,
    letterSpacing: letterSpacing,
  );

  return {
    'root': base.copyWith(backgroundColor: Colors.transparent),
    'comment': base.copyWith(color: ext.textSubtle),
    'quote': base.copyWith(color: ext.textSubtle),
    'doctag': base.copyWith(color: ext.warning, fontWeight: FontWeight.w700),
    'punctuation': base.copyWith(color: ext.textMuted),
    'operator': base.copyWith(color: ext.primary),
    'keyword': base.copyWith(color: ext.primary, fontWeight: FontWeight.w700),
    'selector-tag':
        base.copyWith(color: ext.primary, fontWeight: FontWeight.w700),
    'selector-id': base.copyWith(color: ext.primary),
    'selector-class': base.copyWith(color: ext.accent),
    'selector-attr': base.copyWith(color: ext.secondary),
    'selector-pseudo': base.copyWith(color: ext.warning),
    'literal': base.copyWith(color: ext.warning),
    'string': base.copyWith(color: ext.success),
    'meta-string': base.copyWith(color: ext.success),
    'number': base.copyWith(color: ext.accentAlt),
    'title': base.copyWith(color: ext.accent, fontWeight: FontWeight.w700),
    'title.class':
        base.copyWith(color: ext.secondary, fontWeight: FontWeight.w700),
    'title.function':
        base.copyWith(color: ext.accent, fontWeight: FontWeight.w700),
    'function': base.copyWith(color: ext.accent, fontWeight: FontWeight.w700),
    'params': base.copyWith(color: ext.textMuted),
    'built_in': base.copyWith(color: ext.accentAlt),
    'class': base.copyWith(color: ext.secondary, fontWeight: FontWeight.w700),
    'type': base.copyWith(color: ext.secondary),
    'variable': base.copyWith(color: ext.text),
    'property': base.copyWith(color: ext.accentAlt),
    'variable.language': base.copyWith(color: ext.warning),
    'variable.constant':
        base.copyWith(color: ext.warning, fontWeight: FontWeight.w700),
    'meta': base.copyWith(color: ext.warning.withValues(alpha: 0.9)),
    'meta-keyword':
        base.copyWith(color: ext.warning, fontWeight: FontWeight.w700),
    'tag': base.copyWith(color: ext.primary),
    'name': base.copyWith(color: ext.accent),
    'attr': base.copyWith(color: ext.secondary),
    'attribute': base.copyWith(color: ext.secondary),
    'symbol': base.copyWith(color: ext.accentAlt),
    'link': base.copyWith(
      color: ext.primary,
      decoration: TextDecoration.underline,
    ),
    'regexp': base.copyWith(color: ext.accentAlt),
    'subst': base,
  };
}

int countCodeLines(String code) {
  final normalized = normalizeCodeText(code);
  if (normalized.isEmpty) return 1;
  return RegExp(r'\n').allMatches(normalized).length + 1;
}

double estimateCodeContentWidth(
  String code, {
  double charWidth = 7.8,
  double horizontalPadding = 48,
}) {
  final normalized = normalizeCodeText(code);
  final maxColumns = normalized.split('\n').fold<int>(0, (maxLen, line) {
    return math.max(maxLen, line.length);
  });
  return (maxColumns * charWidth) + horizontalPadding;
}

List<String> chunkCodeByLines(String code, int chunkSize) {
  final normalized = normalizeCodeText(code);
  final lines = normalized.split('\n');
  if (lines.length <= chunkSize) return [normalized];

  final chunks = <String>[];
  for (var start = 0; start < lines.length; start += chunkSize) {
    final end = math.min(start + chunkSize, lines.length);
    chunks.add(lines.sublist(start, end).join('\n'));
  }

  return chunks;
}
