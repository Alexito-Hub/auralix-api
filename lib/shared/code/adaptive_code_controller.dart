import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';

import 'code_highlighting.dart';

enum _FallbackSensitivity { low, medium, high }

enum AdaptiveHighlightMode {
  auto,
  forceStandard,
  forceLexical,
}

class AdaptiveCodeController extends CodeController {
  static const int _hardFallbackLineThreshold = 950;
  static const int _hardFallbackCharThreshold = 120000;
  static const int _veryLongSingleLineThreshold = 5000;

  String _resolvedLanguage = 'plaintext';
  bool _lexicalMode = false;
  AdaptiveHighlightMode _highlightMode = AdaptiveHighlightMode.auto;

  bool get lexicalMode => _lexicalMode;
  bool get standardMode => !_lexicalMode;
  String get resolvedLanguage => _resolvedLanguage;
  AdaptiveHighlightMode get highlightMode => _highlightMode;

  String get highlightModeLabel {
    switch (_highlightMode) {
      case AdaptiveHighlightMode.auto:
        return 'AUTO';
      case AdaptiveHighlightMode.forceStandard:
        return 'STANDARD';
      case AdaptiveHighlightMode.forceLexical:
        return 'LEXICAL';
    }
  }

  AdaptiveCodeController({super.text});

  void setHighlightMode(
    AdaptiveHighlightMode mode, {
    String? language,
    String? code,
  }) {
    if (_highlightMode == mode) return;
    _highlightMode = mode;
    syncHighlightStrategy(
      language: language ?? _resolvedLanguage,
      code: code ?? text,
    );
  }

  void syncHighlightStrategy({
    required String language,
    required String code,
  }) {
    final safeLanguage = sanitizeCodeLanguage(language, fallback: 'plaintext');
    final normalizedCode = normalizeCodeText(code);
    final shouldUseLexical = switch (_highlightMode) {
      AdaptiveHighlightMode.auto => _shouldUseLexicalMode(
          language: safeLanguage,
          code: normalizedCode,
        ),
      AdaptiveHighlightMode.forceStandard => false,
      AdaptiveHighlightMode.forceLexical => true,
    };

    if (_resolvedLanguage == safeLanguage && _lexicalMode == shouldUseLexical) {
      return;
    }

    _resolvedLanguage = safeLanguage;
    _lexicalMode = shouldUseLexical;
    notifyListeners();
  }

  bool _shouldUseLexicalMode({
    required String language,
    required String code,
  }) {
    final lines = countCodeLines(code);
    final chars = code.length;
    final longestLine = _maxLineLength(code);
    final complexSource = _isLikelyComplexSource(
      language: _languageFamily(language),
      code: code,
    );

    if (lines >= _hardFallbackLineThreshold) return true;
    if (chars >= _hardFallbackCharThreshold) return true;
    if (longestLine >= _veryLongSingleLineThreshold) return true;
    if (complexSource &&
        (lines >= 420 || chars >= 28000 || longestLine >= 1800)) {
      return true;
    }

    switch (_fallbackSensitivityFor(language)) {
      case _FallbackSensitivity.high:
        return lines >= 700 || chars >= 70000;
      case _FallbackSensitivity.medium:
        return lines >= 780 || chars >= 82000;
      case _FallbackSensitivity.low:
        return lines >= 860 || chars >= 95000;
    }
  }

  bool _isLikelyComplexSource({
    required String language,
    required String code,
  }) {
    final source = code;

    switch (language) {
      case 'javascript':
      case 'typescript':
        var score = 0;
        if (RegExp(r'`[\s\S]*?\$\{[\s\S]*?\}[\s\S]*?`').hasMatch(source)) {
          score += 2;
        }
        if (RegExp(r'(^|\n)\s*@\w+', multiLine: true).hasMatch(source)) {
          score += 2;
        }
        if (RegExp(r'\?\.|\?\?').hasMatch(source)) {
          score += 1;
        }
        if (RegExp(r'=>').allMatches(source).length >= 4) {
          score += 1;
        }
        if (RegExp(
                r'\b(extends|implements|infer|satisfies|namespace|declare)\b')
            .hasMatch(source)) {
          score += 2;
        }
        if (RegExp(r'\b(await|Promise\.all|Promise\.race)\b')
            .hasMatch(source)) {
          score += 1;
        }
        return score >= 3;
      case 'dart':
        var score = 0;
        if (RegExp(r'\b(async\*|sync\*|yield|yield\*)\b').hasMatch(source)) {
          score += 2;
        }
        if (RegExp(r'(^|\n)\s*@\w+', multiLine: true).hasMatch(source)) {
          score += 1;
        }
        if (RegExp(r'\b(extension|mixin|sealed|base|interface|factory)\b')
            .hasMatch(source)) {
          score += 2;
        }
        if (RegExp(r'\bFuture<|Stream<|Map<|List<').allMatches(source).length >=
            3) {
          score += 1;
        }
        return score >= 3;
      case 'python':
        var score = 0;
        if (RegExp(r'\b(async\s+def|await|yield\s+from)\b').hasMatch(source)) {
          score += 2;
        }
        if (RegExp(r'\b(dataclass|typing\.|Protocol|TypedDict)\b')
            .hasMatch(source)) {
          score += 2;
        }
        if (RegExp(r'\blambda\b').allMatches(source).length >= 2) {
          score += 1;
        }
        return score >= 3;
      case 'java':
      case 'kotlin':
      case 'csharp':
      case 'go':
      case 'rust':
      case 'sql':
        return RegExp(
                    r'\b(async|await|generic|where|implements|extends|trait|interface|join|window|partition)\b',
                    caseSensitive: false)
                .hasMatch(source) &&
            source.length >= 2400;
      default:
        return false;
    }
  }

  _FallbackSensitivity _fallbackSensitivityFor(String language) {
    switch (_languageFamily(language)) {
      case 'javascript':
      case 'typescript':
      case 'dart':
      case 'python':
      case 'php':
      case 'java':
      case 'kotlin':
      case 'csharp':
      case 'go':
      case 'rust':
      case 'sql':
        return _FallbackSensitivity.high;
      case 'json':
      case 'yaml':
      case 'xml':
      case 'graphql':
      case 'markdown':
      case 'toml':
      case 'ini':
        return _FallbackSensitivity.medium;
      default:
        return _FallbackSensitivity.low;
    }
  }

  int _maxLineLength(String code) {
    var maxColumns = 0;
    var current = 0;
    for (var i = 0; i < code.length; i++) {
      final unit = code.codeUnitAt(i);
      if (unit == 10) {
        if (current > maxColumns) maxColumns = current;
        current = 0;
      } else if (unit != 13) {
        current++;
      }
    }
    if (current > maxColumns) maxColumns = current;
    return maxColumns;
  }

  String _languageFamily(String language) {
    if (language == 'shell') return 'bash';
    if (language == 'html') return 'xml';
    return language;
  }

  static final RegExp _tokenRegExp = RegExp(
    r'''(<!--[\s\S]*?-->|/\*[\s\S]*?\*/|//[^\n]*|#[^\n]*|\$[A-Za-z_][A-Za-z0-9_]*|`(?:\\.|[^`])*`|"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|</?[A-Za-z][A-Za-z0-9:_-]*|[A-Za-z_:][-A-Za-z0-9_:.]*(?==)|\b\d+(?:\.\d+)?(?:e[+-]?\d+)?\b|@[A-Za-z_][A-Za-z0-9_]*|\b[A-Za-z_][A-Za-z0-9_]*\b|[{}()[\];,.<>]|[=+\-*/%!?&|:^~]+)''',
    multiLine: true,
  );

  static final RegExp _numberRegExp = RegExp(r'^\d+(?:\.\d+)?(?:e[+-]?\d+)?$');
  static final RegExp _punctuationRegExp = RegExp(r'^[{}()\[\];,.<>]+$');
  static final RegExp _operatorRegExp = RegExp(r'^[=+\-*/%!?&|:^~]+$');
  static final RegExp _identifierRegExp = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');

  static const Set<String> _declarationKeywords = {
    'const',
    'let',
    'var',
    'final',
    'val',
    'late',
    'my',
    'local',
  };

  static const Set<String> _functionDeclarationKeywords = {
    'function',
    'def',
    'fun',
    'fn',
  };

  static const Set<String> _typeDeclarationKeywords = {
    'class',
    'interface',
    'enum',
    'type',
    'struct',
    'trait',
    'record',
    'namespace',
  };

  static const Set<String> _markupFamilies = {
    'xml',
    'html',
  };

  static const Set<String> _literalTokens = {
    'true',
    'false',
    'null',
    'undefined',
    'none',
    'nil',
    'yes',
    'no',
    'on',
    'off',
  };

  static const Set<String> _genericKeywordTokens = {
    'if',
    'else',
    'for',
    'while',
    'do',
    'switch',
    'case',
    'default',
    'break',
    'continue',
    'return',
    'try',
    'catch',
    'finally',
    'throw',
    'class',
    'interface',
    'enum',
    'extends',
    'implements',
    'new',
    'import',
    'export',
    'from',
    'as',
    'const',
    'let',
    'var',
    'function',
    'async',
    'await',
    'public',
    'private',
    'protected',
    'readonly',
    'static',
    'package',
    'using',
    'def',
    'fn',
    'fun',
    'match',
    'with',
    'where',
    'in',
    'of',
  };

  static const Set<String> _genericTypeTokens = {
    'string',
    'number',
    'boolean',
    'object',
    'void',
    'int',
    'float',
    'double',
    'decimal',
    'char',
    'byte',
    'long',
    'short',
    'dynamic',
    'any',
    'unknown',
    'never',
    'list',
    'map',
    'set',
  };

  static const Map<String, Set<String>> _languageKeywordTokens = {
    'javascript': {
      'const',
      'let',
      'var',
      'function',
      'class',
      'extends',
      'import',
      'export',
      'default',
      'return',
      'if',
      'else',
      'for',
      'while',
      'switch',
      'case',
      'break',
      'continue',
      'try',
      'catch',
      'finally',
      'throw',
      'new',
      'await',
      'async',
      'yield',
      'this',
      'super',
      'typeof',
      'instanceof',
      'delete',
    },
    'typescript': {
      'type',
      'interface',
      'namespace',
      'implements',
      'readonly',
      'public',
      'private',
      'protected',
      'override',
      'abstract',
      'satisfies',
      'declare',
      'infer',
      'keyof',
      'is',
      'as',
    },
    'python': {
      'def',
      'class',
      'lambda',
      'from',
      'import',
      'as',
      'if',
      'elif',
      'else',
      'for',
      'while',
      'try',
      'except',
      'finally',
      'raise',
      'return',
      'yield',
      'with',
      'async',
      'await',
      'pass',
      'global',
      'nonlocal',
      'assert',
      'del',
      'in',
      'is',
      'and',
      'or',
      'not',
    },
    'dart': {
      'import',
      'export',
      'library',
      'part',
      'class',
      'mixin',
      'extension',
      'enum',
      'if',
      'else',
      'for',
      'while',
      'switch',
      'case',
      'default',
      'break',
      'continue',
      'return',
      'try',
      'catch',
      'finally',
      'throw',
      'new',
      'const',
      'final',
      'late',
      'required',
      'static',
      'covariant',
      'factory',
      'operator',
      'async',
      'await',
      'yield',
    },
    'bash': {
      'if',
      'then',
      'else',
      'fi',
      'for',
      'while',
      'do',
      'done',
      'case',
      'esac',
      'function',
      'in',
      'until',
      'select',
      'time',
    },
    'powershell': {
      'function',
      'param',
      'if',
      'elseif',
      'else',
      'switch',
      'foreach',
      'for',
      'while',
      'do',
      'try',
      'catch',
      'finally',
      'return',
      'throw',
      'class',
      'enum',
      'using',
      'begin',
      'process',
      'end',
    },
    'java': {
      'package',
      'import',
      'class',
      'interface',
      'enum',
      'extends',
      'implements',
      'public',
      'private',
      'protected',
      'static',
      'final',
      'abstract',
      'synchronized',
      'volatile',
      'transient',
      'if',
      'else',
      'for',
      'while',
      'switch',
      'case',
      'break',
      'continue',
      'return',
      'try',
      'catch',
      'finally',
      'throw',
      'new',
    },
    'kotlin': {
      'package',
      'import',
      'class',
      'object',
      'interface',
      'fun',
      'val',
      'var',
      'if',
      'else',
      'when',
      'for',
      'while',
      'return',
      'break',
      'continue',
      'try',
      'catch',
      'finally',
      'throw',
      'in',
      'is',
      'as',
      'typealias',
      'sealed',
      'data',
      'companion',
      'suspend',
    },
    'csharp': {
      'using',
      'namespace',
      'class',
      'record',
      'struct',
      'interface',
      'enum',
      'public',
      'private',
      'protected',
      'internal',
      'static',
      'readonly',
      'virtual',
      'override',
      'async',
      'await',
      'if',
      'else',
      'switch',
      'case',
      'for',
      'foreach',
      'while',
      'return',
      'break',
      'continue',
      'try',
      'catch',
      'finally',
      'throw',
      'new',
      'where',
    },
    'go': {
      'package',
      'import',
      'func',
      'type',
      'struct',
      'interface',
      'map',
      'chan',
      'select',
      'go',
      'defer',
      'if',
      'else',
      'for',
      'switch',
      'case',
      'default',
      'return',
      'break',
      'continue',
      'fallthrough',
      'range',
      'var',
      'const',
    },
    'rust': {
      'fn',
      'let',
      'mut',
      'pub',
      'impl',
      'trait',
      'struct',
      'enum',
      'mod',
      'use',
      'crate',
      'match',
      'if',
      'else',
      'for',
      'while',
      'loop',
      'break',
      'continue',
      'return',
      'where',
      'async',
      'await',
      'move',
      'unsafe',
      'dyn',
    },
    'sql': {
      'select',
      'from',
      'where',
      'insert',
      'into',
      'update',
      'set',
      'delete',
      'join',
      'inner',
      'left',
      'right',
      'full',
      'group',
      'by',
      'order',
      'having',
      'limit',
      'offset',
      'create',
      'alter',
      'drop',
      'table',
      'index',
      'view',
      'primary',
      'foreign',
      'key',
      'on',
      'as',
      'and',
      'or',
      'not',
      'null',
      'distinct',
      'union',
    },
    'graphql': {
      'query',
      'mutation',
      'subscription',
      'fragment',
      'type',
      'input',
      'enum',
      'interface',
      'union',
      'scalar',
      'schema',
      'extend',
      'implements',
      'on',
    },
    'php': {
      'function',
      'class',
      'interface',
      'trait',
      'extends',
      'implements',
      'public',
      'private',
      'protected',
      'static',
      'abstract',
      'final',
      'if',
      'else',
      'elseif',
      'switch',
      'case',
      'for',
      'foreach',
      'while',
      'do',
      'return',
      'break',
      'continue',
      'try',
      'catch',
      'finally',
      'throw',
      'namespace',
      'use',
      'new',
    },
  };

  static const Map<String, Set<String>> _languageTypeTokens = {
    'typescript': {
      'string',
      'number',
      'boolean',
      'unknown',
      'any',
      'never',
      'void',
      'readonly',
      'record',
      'partial',
      'required',
      'pick',
      'omit',
    },
    'dart': {
      'int',
      'double',
      'num',
      'bool',
      'String',
      'Object',
      'dynamic',
      'Future',
      'Stream',
      'List',
      'Map',
      'Set',
      'Widget',
    },
    'java': {
      'int',
      'long',
      'double',
      'float',
      'boolean',
      'byte',
      'short',
      'char',
      'void',
      'String',
      'Object',
      'List',
      'Map',
      'Set',
    },
    'kotlin': {
      'Int',
      'Long',
      'Double',
      'Float',
      'Boolean',
      'String',
      'Unit',
      'Any',
      'List',
      'Map',
      'Set',
    },
    'csharp': {
      'int',
      'long',
      'double',
      'float',
      'decimal',
      'bool',
      'string',
      'object',
      'void',
      'var',
      'Task',
      'List',
      'Dictionary',
    },
    'python': {
      'int',
      'float',
      'bool',
      'str',
      'bytes',
      'list',
      'tuple',
      'dict',
      'set',
      'object',
      'none',
    },
    'go': {
      'int',
      'int32',
      'int64',
      'uint',
      'float32',
      'float64',
      'bool',
      'string',
      'byte',
      'rune',
      'error',
      'interface',
      'struct',
      'map',
    },
    'rust': {
      'i8',
      'i16',
      'i32',
      'i64',
      'i128',
      'u8',
      'u16',
      'u32',
      'u64',
      'u128',
      'f32',
      'f64',
      'bool',
      'str',
      'String',
      'Vec',
      'Option',
      'Result',
    },
  };

  Set<String> _keywordsForLanguage(String language) {
    final family = _languageFamily(language);
    final specific = _languageKeywordTokens[family];
    if (specific == null || specific.isEmpty) {
      return _genericKeywordTokens;
    }
    return {..._genericKeywordTokens, ...specific};
  }

  Set<String> _typesForLanguage(String language) {
    final family = _languageFamily(language);
    final specific = _languageTypeTokens[family];
    if (specific == null || specific.isEmpty) {
      return _genericTypeTokens;
    }
    return {..._genericTypeTokens, ...specific};
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    bool? withComposing,
  }) {
    if (!_lexicalMode) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }

    final theme = CodeTheme.of(context);
    final root = (theme?.styles['root'] ?? const TextStyle()).merge(style);
    final comment = _resolveThemeStyle(theme, 'comment', root);
    final string = _resolveThemeStyle(theme, 'string', root);
    final number = _resolveThemeStyle(theme, 'number', root);
    final keyword = _resolveThemeStyle(theme, 'keyword', root);
    final type = _resolveThemeStyle(theme, 'type', root);
    final literal = _resolveThemeStyle(theme, 'literal', root);
    final punctuation = _resolveThemeStyle(theme, 'punctuation', root);
    final operator = _resolveThemeStyle(theme, 'operator', root);
    final tag = _resolveThemeStyle(theme, 'tag', root);
    final attribute = _resolveThemeStyle(theme, 'attr', root);
    final meta = _resolveThemeStyle(theme, 'meta', root);
    final variable = _resolveThemeStyle(theme, 'variable', root);
    final function = _resolveThemeStyle(theme, 'function', root);
    final classTitle = _resolveThemeStyle(theme, 'title.class', type);
    final property = _resolveThemeStyle(theme, 'property', root);
    final params = _resolveThemeStyle(theme, 'params', variable);
    final keywords = _keywordsForLanguage(_resolvedLanguage);
    final types = _typesForLanguage(_resolvedLanguage);

    final spans = <TextSpan>[];
    final source = text;
    var cursor = 0;
    var declarationListActive = false;
    var expectVariableName = false;
    var expectFunctionName = false;
    var expectTypeName = false;
    var expectPropertyName = false;
    var pendingFunctionParameterList = false;
    var inFunctionParameters = false;
    var functionParameterDepth = 0;
    var expectParameterName = false;

    for (final match in _tokenRegExp.allMatches(source)) {
      if (match.start > cursor) {
        spans.add(TextSpan(
          text: source.substring(cursor, match.start),
          style: root,
        ));
      }

      final token = match.group(0) ?? '';
      final lower = token.toLowerCase();
      final isIdentifier = _identifierRegExp.hasMatch(token);

      TextStyle? contextualOverride;
      if (isIdentifier) {
        if (expectFunctionName) {
          contextualOverride = function;
        } else if (expectTypeName) {
          contextualOverride = classTitle;
        } else if (expectVariableName) {
          contextualOverride = variable;
        } else if (expectPropertyName) {
          contextualOverride = property;
        } else if (inFunctionParameters &&
            expectParameterName &&
            !_literalTokens.contains(lower) &&
            !keywords.contains(lower) &&
            !types.contains(lower)) {
          contextualOverride = params;
        }
      }

      spans.add(TextSpan(
        text: token,
        style: contextualOverride ??
            _tokenStyle(
              token: token,
              root: root,
              comment: comment,
              string: string,
              number: number,
              keyword: keyword,
              type: type,
              literal: literal,
              punctuation: punctuation,
              operator: operator,
              tag: tag,
              attribute: attribute,
              meta: meta,
              variable: variable,
              keywords: keywords,
              types: types,
            ),
      ));

      if (isIdentifier) {
        if (expectFunctionName) {
          expectFunctionName = false;
          pendingFunctionParameterList = true;
        } else if (expectTypeName) {
          expectTypeName = false;
        } else if (expectVariableName) {
          expectVariableName = false;
        } else if (expectPropertyName) {
          expectPropertyName = false;
        } else if (inFunctionParameters && expectParameterName) {
          expectParameterName = false;
        }
      }

      if (_declarationKeywords.contains(lower)) {
        declarationListActive = true;
        expectVariableName = true;
        expectFunctionName = false;
        expectTypeName = false;
      }

      if (_functionDeclarationKeywords.contains(lower)) {
        expectFunctionName = true;
        declarationListActive = false;
        expectVariableName = false;
        expectTypeName = false;
      }

      if (_typeDeclarationKeywords.contains(lower)) {
        expectTypeName = true;
        declarationListActive = false;
        expectVariableName = false;
        expectFunctionName = false;
      }

      if (token == '.') {
        expectPropertyName = true;
      } else if (_punctuationRegExp.hasMatch(token) && token != ',') {
        expectPropertyName = false;
      }

      if (declarationListActive) {
        if (token == ',') {
          expectVariableName = true;
        } else if (token == ';') {
          declarationListActive = false;
          expectVariableName = false;
        } else if (token == '=') {
          expectVariableName = false;
        }
      }

      if (token == '(') {
        if (pendingFunctionParameterList) {
          inFunctionParameters = true;
          functionParameterDepth = 1;
          expectParameterName = true;
          pendingFunctionParameterList = false;
        } else if (inFunctionParameters) {
          functionParameterDepth++;
          expectParameterName = true;
        }
      } else if (token == ')') {
        if (inFunctionParameters) {
          functionParameterDepth--;
          if (functionParameterDepth <= 0) {
            inFunctionParameters = false;
            functionParameterDepth = 0;
            expectParameterName = false;
          } else {
            expectParameterName = false;
          }
        }
      } else if (token == ',' && inFunctionParameters) {
        expectParameterName = true;
      } else if ((token == ':' ||
              token == '=' ||
              token == '=>' ||
              token == '->') &&
          inFunctionParameters) {
        expectParameterName = false;
      }

      cursor = match.end;
    }

    if (cursor < source.length) {
      spans.add(TextSpan(text: source.substring(cursor), style: root));
    }

    return TextSpan(style: root, children: spans);
  }

  TextStyle _resolveThemeStyle(
    CodeThemeData? theme,
    String key,
    TextStyle fallback,
  ) {
    return theme?.styles[key]?.merge(fallback) ?? fallback;
  }

  TextStyle _tokenStyle({
    required String token,
    required TextStyle root,
    required TextStyle comment,
    required TextStyle string,
    required TextStyle number,
    required TextStyle keyword,
    required TextStyle type,
    required TextStyle literal,
    required TextStyle punctuation,
    required TextStyle operator,
    required TextStyle tag,
    required TextStyle attribute,
    required TextStyle meta,
    required TextStyle variable,
    required Set<String> keywords,
    required Set<String> types,
  }) {
    if (token.isEmpty) return root;

    if (token.startsWith('//') ||
        token.startsWith('/*') ||
        token.startsWith('#')) {
      return comment;
    }

    final first = token[0];
    if (first == '"' || first == '\'' || first == '`') {
      return string;
    }

    if (token.startsWith(r'$')) {
      return variable;
    }

    if (token.startsWith('@')) {
      return meta;
    }

    if (_isMarkupTagToken(token)) {
      return tag;
    }

    if (_isMarkupAttributeToken(token)) {
      return attribute;
    }

    if (_numberRegExp.hasMatch(token)) {
      return number;
    }

    if (_punctuationRegExp.hasMatch(token)) {
      return punctuation;
    }

    if (_operatorRegExp.hasMatch(token)) {
      return operator;
    }

    final lower = token.toLowerCase();
    if (keywords.contains(lower)) return keyword;
    if (types.contains(lower)) return type;
    if (_literalTokens.contains(lower)) return literal;

    return root;
  }

  bool _isMarkupTagToken(String token) {
    if (!_markupFamilies.contains(_languageFamily(_resolvedLanguage))) {
      return false;
    }
    return token.startsWith('<');
  }

  bool _isMarkupAttributeToken(String token) {
    if (!_markupFamilies.contains(_languageFamily(_resolvedLanguage))) {
      return false;
    }
    if (token.isEmpty) return false;
    if (token.startsWith('<') || token.startsWith('/')) return false;
    return RegExp(r'^[A-Za-z_:][-A-Za-z0-9_:.]*$').hasMatch(token);
  }
}
