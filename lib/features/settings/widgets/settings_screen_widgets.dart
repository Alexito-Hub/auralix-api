part of '../screens/settings_screen.dart';

class _ColorDot extends StatelessWidget {
  final Color color;
  const _ColorDot(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 4)
        ],
      ),
    );
  }
}

class _HoverSettingsSection extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final Duration delay;
  final bool danger;

  const _HoverSettingsSection({
    required this.title,
    required this.icon,
    required this.children,
    this.delay = Duration.zero,
    this.danger = false,
  });

  @override
  State<_HoverSettingsSection> createState() => _HoverSettingsSectionState();
}

class _HoverSettingsSectionState extends State<_HoverSettingsSection> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final glowColor = widget.danger ? ext.error : ext.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        transform: _hovering
            ? Matrix4.translationValues(0, -2, 0)
            : Matrix4.identity(),
        padding: const EdgeInsets.all(20),
        decoration: ext.surfaceDecoration.copyWith(
          border: Border.all(
              color: _hovering ? glowColor.withValues(alpha: 0.5) : ext.border),
          boxShadow: _hovering
              ? [
                  BoxShadow(
                      color: glowColor.withValues(alpha: 0.1), blurRadius: 15)
                ]
              : [],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(widget.icon, size: 16, color: glowColor),
                const SizedBox(width: 10),
                Text(
                  '> ${widget.title.toUpperCase()}',
                  style: TextStyle(
                      color: glowColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'JetBrainsMono'),
                ),
                if (_hovering) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 6,
                    height: 14,
                    color: glowColor.withValues(alpha: 0.7),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .fade(duration: const Duration(milliseconds: 400)),
                ],
              ],
            ),
            const SizedBox(height: 20),
            ...widget.children,
          ],
        ),
      ).animate().fadeIn(delay: widget.delay).slideY(begin: 0.05),
    );
  }
}
