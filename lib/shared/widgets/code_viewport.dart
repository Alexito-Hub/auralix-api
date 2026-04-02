import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';

import '../../core/theme/theme_extension.dart';
import '../code/code_highlighting.dart';

class CodeViewport extends StatelessWidget {
  final AuralixThemeExtension ext;
  final String code;
  final String language;
  final bool rawMode;
  final bool showLineNumbers;
  final bool showWatermark;
  final IconData watermarkIcon;
  final double watermarkSize;
  final double watermarkOpacity;
  final double? maxHeight;
  final EdgeInsets contentPadding;
  final EdgeInsets gutterPadding;
  final double gutterWidth;
  final int chunkLineSize;
  final double codeFontSize;
  final double codeLineHeight;
  final double codeLetterSpacing;
  final double gutterFontSize;

  static const int maxSafeHighlightChars = 450000;

  const CodeViewport({
    super.key,
    required this.ext,
    required this.code,
    required this.language,
    this.rawMode = false,
    this.showLineNumbers = true,
    this.showWatermark = true,
    this.watermarkIcon = Icons.code,
    this.watermarkSize = 180,
    this.watermarkOpacity = 0.03,
    this.maxHeight,
    this.contentPadding = const EdgeInsets.fromLTRB(16, 18, 20, 18),
    this.gutterPadding = const EdgeInsets.fromLTRB(8, 18, 8, 18),
    this.gutterWidth = 56,
    this.chunkLineSize = defaultHighlightChunkLines,
    this.codeFontSize = 13,
    this.codeLineHeight = 1.65,
    this.codeLetterSpacing = 0.2,
    this.gutterFontSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedCode = normalizeCodeText(code);
    final safeLanguage = sanitizeCodeLanguage(language, fallback: 'plaintext');
    final usePlainTextRendering =
        rawMode || normalizedCode.length > maxSafeHighlightChars;

    final codeStyle = TextStyle(
      color: ext.text.withValues(alpha: 0.95),
      fontFamily: 'JetBrainsMono',
      fontSize: codeFontSize,
      height: codeLineHeight,
      letterSpacing: codeLetterSpacing,
    );
    final syntaxTheme = buildCodeHighlightTheme(
      ext,
      fontSize: codeFontSize,
      lineHeight: codeLineHeight,
      letterSpacing: codeLetterSpacing,
    );

    final lineCount = countCodeLines(normalizedCode);
    final lineDigits = math.max(3, lineCount.toString().length);
    final minGutterWidth = 24 +
        (lineDigits * (gutterFontSize * 0.72)) +
        gutterPadding.left +
        gutterPadding.right;
    final resolvedGutterWidth = math.max(gutterWidth, minGutterWidth);
    final lineNumbers = List.generate(
      lineCount,
      (index) => (index + 1).toString().padLeft(lineDigits, ' '),
    ).join('\n');
    final gutterLineHeight = (codeFontSize * codeLineHeight) / gutterFontSize;

    final editorBase = Color.alphaBlend(
      ext.primary.withValues(alpha: 0.06),
      ext.surface,
    );
    final editorBaseAlt = Color.alphaBlend(
      ext.accentAlt.withValues(alpha: 0.04),
      ext.bg,
    );
    final gutterColor = Color.alphaBlend(
      ext.surfaceVariant.withValues(alpha: 0.82),
      ext.bg,
    );

    Widget viewport = usePlainTextRendering
        ? SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: contentPadding,
                child: SelectableText(
                  normalizedCode,
                  style: codeStyle.copyWith(color: ext.text),
                ),
              ),
            ),
          )
        : LayoutBuilder(
            builder: (context, constraints) {
              final lineNumberWidth = showLineNumbers ? resolvedGutterWidth : 0;
              final codeViewportWidth =
                  math.max(constraints.maxWidth - lineNumberWidth, 220.0);
              final estimatedContentWidth =
                  estimateCodeContentWidth(normalizedCode);
              final editorContentWidth =
                  math.max(codeViewportWidth, estimatedContentWidth);

              return SingleChildScrollView(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showLineNumbers)
                      Container(
                        width: resolvedGutterWidth,
                        padding: gutterPadding,
                        decoration: BoxDecoration(
                          color: gutterColor,
                          border: Border(
                            right: BorderSide(
                              color: ext.border.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                        child: Text(
                          lineNumbers,
                          textAlign: TextAlign.right,
                          softWrap: false,
                          overflow: TextOverflow.visible,
                          style: TextStyle(
                            color: ext.textSubtle,
                            fontFamily: 'JetBrainsMono',
                            fontSize: gutterFontSize,
                            height: gutterLineHeight,
                          ),
                        ),
                      ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(minWidth: editorContentWidth),
                          child: Stack(
                            children: [
                              if (showWatermark)
                                Positioned.fill(
                                  child: Opacity(
                                    opacity: watermarkOpacity,
                                    child: Center(
                                      child: Icon(
                                        watermarkIcon,
                                        size: watermarkSize,
                                        color: ext.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              Padding(
                                padding: contentPadding,
                                child: _AdaptiveHighlightView(
                                  code: normalizedCode,
                                  language: safeLanguage,
                                  theme: syntaxTheme,
                                  textStyle: codeStyle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );

    if (maxHeight != null) {
      viewport = ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight!),
        child: viewport,
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [editorBase, editorBaseAlt],
        ),
      ),
      child: viewport,
    );
  }
}

class _AdaptiveHighlightView extends StatelessWidget {
  final String code;
  final String language;
  final Map<String, TextStyle> theme;
  final TextStyle textStyle;

  const _AdaptiveHighlightView({
    required this.code,
    required this.language,
    required this.theme,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    try {
      return HighlightView(
        code,
        language: language,
        theme: theme,
        padding: EdgeInsets.zero,
        textStyle: textStyle,
      );
    } catch (_) {
      return SelectableText(
        code,
        style: textStyle,
      );
    }
  }
}
