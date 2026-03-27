import 'package:flutter/material.dart';
import 'app_colors.dart';

/// ThemeExtension that carries Auralix-specific design tokens.
class AuralixThemeExtension extends ThemeExtension<AuralixThemeExtension> {
  final ThemeColors colors;
  final AppThemeVariant variant;

  const AuralixThemeExtension({required this.colors, required this.variant});

  factory AuralixThemeExtension.from(ThemeColors c, AppThemeVariant v) =>
      AuralixThemeExtension(colors: c, variant: v);

  @override
  AuralixThemeExtension copyWith({ThemeColors? colors, AppThemeVariant? variant}) {
    return AuralixThemeExtension(
      colors: colors ?? this.colors,
      variant: variant ?? this.variant,
    );
  }

  @override
  AuralixThemeExtension lerp(AuralixThemeExtension? other, double t) {
    if (other == null) return this;
    return AuralixThemeExtension(colors: t < 0.5 ? colors : other.colors, variant: t < 0.5 ? variant : other.variant);
  }

  static AuralixThemeExtension of(BuildContext context) {
    return Theme.of(context).extension<AuralixThemeExtension>()!;
  }

  // Convenience getters
  Color get bg => colors.background;
  Color get surface => colors.surface;
  Color get surfaceVariant => colors.surfaceVariant;
  Color get primary => colors.primary;
  Color get secondary => colors.secondary;
  Color get accent => colors.accent;
  Color get accentAlt => colors.accentAlt;
  Color get warning => colors.warning;
  Color get error => colors.error;
  Color get success => colors.success;
  Color get text => colors.text;
  Color get textMuted => colors.textMuted;
  Color get textSubtle => colors.textSubtle;
  Color get border => colors.border;
  Color get glow => colors.glow;
  Color get glowAlt => colors.glowAlt;
  Color get cursor => colors.cursor;
  Color get terminalGreen => colors.terminalGreen;
  Color get terminalCyan => colors.terminalCyan;
  Color get terminalYellow => colors.terminalYellow;
  Color get onPrimary => colors.onPrimary;

  Color statusColor(int code) => AppColors.statusColor(colors, code);

  BoxDecoration get glowBorder => BoxDecoration(
    border: Border.all(color: primary.withValues(alpha: 0.5)),
    borderRadius: BorderRadius.circular(8),
    boxShadow: [BoxShadow(color: glow, blurRadius: 12, spreadRadius: 0)],
  );

  BoxDecoration get glowBorderAlt => BoxDecoration(
    border: Border.all(color: accent.withValues(alpha: 0.5)),
    borderRadius: BorderRadius.circular(8),
    boxShadow: [BoxShadow(color: glowAlt, blurRadius: 12, spreadRadius: 0)],
  );

  BoxDecoration get surfaceDecoration => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: border),
  );
}
