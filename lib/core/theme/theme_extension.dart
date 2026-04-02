import 'package:flutter/material.dart';
import 'app_colors.dart';

class ThemeMetrics {
  final double spaceXs;
  final double spaceSm;
  final double spaceMd;
  final double spaceLg;
  final double spaceXl;
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final double glowBlur;

  const ThemeMetrics({
    this.spaceXs = 4,
    this.spaceSm = 8,
    this.spaceMd = 12,
    this.spaceLg = 16,
    this.spaceXl = 24,
    this.radiusSm = 6,
    this.radiusMd = 10,
    this.radiusLg = 14,
    this.glowBlur = 14,
  });
}

/// ThemeExtension that carries Auralix-specific design tokens.
class AuralixThemeExtension extends ThemeExtension<AuralixThemeExtension> {
  final ThemeColors colors;
  final AppThemeVariant variant;
  final ThemeMetrics metrics;

  const AuralixThemeExtension({
    required this.colors,
    required this.variant,
    this.metrics = const ThemeMetrics(),
  });

  factory AuralixThemeExtension.from(ThemeColors c, AppThemeVariant v) =>
      AuralixThemeExtension(colors: c, variant: v);

  @override
  AuralixThemeExtension copyWith({
    ThemeColors? colors,
    AppThemeVariant? variant,
    ThemeMetrics? metrics,
  }) {
    return AuralixThemeExtension(
      colors: colors ?? this.colors,
      variant: variant ?? this.variant,
      metrics: metrics ?? this.metrics,
    );
  }

  @override
  AuralixThemeExtension lerp(AuralixThemeExtension? other, double t) {
    if (other == null) return this;
    return AuralixThemeExtension(
      colors: t < 0.5 ? colors : other.colors,
      variant: t < 0.5 ? variant : other.variant,
      metrics: t < 0.5 ? metrics : other.metrics,
    );
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

  double get spaceXs => metrics.spaceXs;
  double get spaceSm => metrics.spaceSm;
  double get spaceMd => metrics.spaceMd;
  double get spaceLg => metrics.spaceLg;
  double get spaceXl => metrics.spaceXl;
  double get radiusSm => metrics.radiusSm;
  double get radiusMd => metrics.radiusMd;
  double get radiusLg => metrics.radiusLg;

  Color statusColor(int code) => AppColors.statusColor(colors, code);

  BoxDecoration get glowBorder => BoxDecoration(
        border: Border.all(color: primary.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(radiusMd),
        boxShadow: [
          BoxShadow(color: glow, blurRadius: metrics.glowBlur, spreadRadius: 0),
        ],
      );

  BoxDecoration get glowBorderAlt => BoxDecoration(
        border: Border.all(color: accent.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(radiusMd),
        boxShadow: [
          BoxShadow(
              color: glowAlt, blurRadius: metrics.glowBlur, spreadRadius: 0),
        ],
      );

  BoxDecoration get surfaceDecoration => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radiusMd),
        border: Border.all(color: border),
      );
}
