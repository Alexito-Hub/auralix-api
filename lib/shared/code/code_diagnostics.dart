import 'dart:convert';

import 'code_highlighting.dart';

class CodeDiagnosticIssue {
  final String message;
  final int? line;
  final int? column;

  const CodeDiagnosticIssue({
    required this.message,
    this.line,
    this.column,
  });
}

const Set<String> _structuralLanguages = {
  'javascript',
  'typescript',
  'dart',
  'java',
  'c',
  'cpp',
  'csharp',
  'go',
  'rust',
  'kotlin',
  'scala',
  'swift',
  'php',
  'css',
};

List<CodeDiagnosticIssue> buildCodeDiagnostics({
  required String code,
  required String language,
}) {
  final normalizedCode = normalizeCodeText(code);
  final safeLanguage = sanitizeCodeLanguage(language, fallback: 'plaintext');

  if (normalizedCode.trim().isEmpty) return const [];

  final issues = <CodeDiagnosticIssue>[];

  if (safeLanguage == 'json') {
    issues.addAll(_buildJsonDiagnostics(normalizedCode));
  }

  if (_structuralLanguages.contains(safeLanguage)) {
    issues.addAll(_buildStructuralDiagnostics(normalizedCode, safeLanguage));
  }

  return issues;
}

List<CodeDiagnosticIssue> _buildJsonDiagnostics(String code) {
  try {
    jsonDecode(code);
    return const [];
  } on FormatException catch (e) {
    final raw = e.message;
    final lineMatch =
        RegExp(r'line\s+(\d+)', caseSensitive: false).firstMatch(raw);
    final columnMatch =
        RegExp(r'column\s+(\d+)', caseSensitive: false).firstMatch(raw);
    return [
      CodeDiagnosticIssue(
        message: 'JSON invalido: ${raw.split('\n').first.trim()}',
        line: lineMatch != null ? int.tryParse(lineMatch.group(1)!) : null,
        column:
            columnMatch != null ? int.tryParse(columnMatch.group(1)!) : null,
      ),
    ];
  } catch (_) {
    return const [
      CodeDiagnosticIssue(message: 'JSON invalido: formato no reconocido'),
    ];
  }
}

bool _usesBackticks(String language) {
  return language == 'javascript' || language == 'typescript';
}

List<CodeDiagnosticIssue> _buildStructuralDiagnostics(
  String code,
  String language,
) {
  final issues = <CodeDiagnosticIssue>[];
  final stack = <({String opener, int line, int column})>[];

  var inSingle = false;
  var inDouble = false;
  var inBacktick = false;
  var inLineComment = false;
  var inBlockComment = false;
  var escaped = false;
  var line = 1;
  var column = 0;

  for (var i = 0; i < code.length; i++) {
    final ch = code[i];
    final next = i + 1 < code.length ? code[i + 1] : '';

    if (inLineComment) {
      if (ch == '\n') {
        inLineComment = false;
        line++;
        column = 0;
      } else {
        column++;
      }
      continue;
    }

    if (inBlockComment) {
      if (ch == '\n') {
        line++;
        column = 0;
      } else {
        column++;
      }

      if (ch == '*' && next == '/') {
        inBlockComment = false;
        i++;
        column++;
      }
      continue;
    }

    if (ch == '\n') {
      line++;
      column = 0;
      escaped = false;
      continue;
    }

    column++;

    if (escaped) {
      escaped = false;
      continue;
    }

    if ((inSingle || inDouble || inBacktick) && ch == r'\') {
      escaped = true;
      continue;
    }

    if (!inSingle && !inDouble && !inBacktick) {
      if (ch == '/' && next == '/') {
        inLineComment = true;
        i++;
        column++;
        continue;
      }
      if (ch == '/' && next == '*') {
        inBlockComment = true;
        i++;
        column++;
        continue;
      }
    }

    if (!inDouble && !inBacktick && ch == "'") {
      inSingle = !inSingle;
      continue;
    }
    if (!inSingle && !inBacktick && ch == '"') {
      inDouble = !inDouble;
      continue;
    }
    if (_usesBackticks(language) && !inSingle && !inDouble && ch == '`') {
      inBacktick = !inBacktick;
      continue;
    }

    if (inSingle || inDouble || inBacktick) {
      continue;
    }

    if (ch == '(' || ch == '[' || ch == '{') {
      stack.add((opener: ch, line: line, column: column));
      continue;
    }

    if (ch == ')' || ch == ']' || ch == '}') {
      if (stack.isEmpty) {
        issues.add(CodeDiagnosticIssue(
          message: 'Cierre sin apertura: $ch',
          line: line,
          column: column,
        ));
        continue;
      }

      final top = stack.removeLast();
      final matches = (top.opener == '(' && ch == ')') ||
          (top.opener == '[' && ch == ']') ||
          (top.opener == '{' && ch == '}');

      if (!matches) {
        issues.add(CodeDiagnosticIssue(
          message: 'Par no coincide: ${top.opener} ... $ch',
          line: line,
          column: column,
        ));
      }
    }
  }

  if (inBlockComment) {
    issues.add(CodeDiagnosticIssue(
      message: 'Comentario de bloque sin cierre',
      line: line,
      column: column,
    ));
  }

  if (inSingle || inDouble || inBacktick) {
    issues.add(CodeDiagnosticIssue(
      message: 'Cadena sin cierre',
      line: line,
      column: column,
    ));
  }

  for (final entry in stack.reversed.take(6)) {
    issues.add(CodeDiagnosticIssue(
      message: 'Apertura sin cierre: ${entry.opener}',
      line: entry.line,
      column: entry.column,
    ));
  }

  return issues;
}
