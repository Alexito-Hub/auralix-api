import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/theme_extension.dart';
import '../../core/ui/breakpoints.dart';

class TerminalPageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> actions;

  const TerminalPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.actions = const <Widget>[],
  });

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final compact = context.isMobile || context.isTablet;

    final leading = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: ext.success,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: ext.success.withValues(alpha: 0.45), blurRadius: 10),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(r'$ ', style: TextStyle(color: ext.primary, fontSize: 13)),
        Text(
          title,
          style: TextStyle(
            color: ext.text,
            fontSize: compact ? 18 : 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 16,
        vertical: compact ? 11 : 13,
      ),
      decoration: ext.surfaceDecoration.copyWith(
        boxShadow: [
          BoxShadow(
            color: ext.glow.withValues(alpha: 0.12),
            blurRadius: 14,
            spreadRadius: 0,
          ),
        ],
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                leading,
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                      color: ext.textMuted, fontSize: 12, height: 1.35),
                ),
                if (actions.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(spacing: 8, runSpacing: 8, children: actions),
                ],
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      leading,
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                            color: ext.textMuted, fontSize: 12, height: 1.35),
                      ),
                    ],
                  ),
                ),
                if (actions.isNotEmpty)
                  Wrap(spacing: 8, runSpacing: 8, children: actions),
              ],
            ),
    );
  }
}

class TerminalPageReveal extends StatelessWidget {
  final Widget child;
  final Object? animationKey;

  const TerminalPageReveal({
    super.key,
    required this.child,
    this.animationKey,
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(key: ValueKey(animationKey ?? child.hashCode))
        .fadeIn(duration: 220.ms, curve: Curves.easeOutCubic)
        .slideY(
          begin: 0.025,
          end: 0,
          duration: 220.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
