import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/theme_extension.dart';

class NavRailItem {
  final IconData icon;
  final String label;
  final String path;
  final bool selected;
  const NavRailItem(
      {required this.icon,
      required this.label,
      required this.path,
      required this.selected});
}

class TerminalNavRail extends StatelessWidget {
  final List<NavRailItem> items;
  final void Function(String path) onTap;
  final String footerLabel;

  const TerminalNavRail({
    super.key,
    required this.items,
    required this.onTap,
    this.footerLabel = '',
  });

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    return Container(
      width: 220,
      color: ext.surface,
      child: Column(
        children: [
          // Logo area
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    border: Border.all(color: ext.primary, width: 2),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [BoxShadow(color: ext.glow, blurRadius: 10)],
                  ),
                  child: Center(
                    child: Text('A',
                        style: TextStyle(
                            color: ext.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Auralix',
                        style: TextStyle(
                            color: ext.text,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                    Text('Hub',
                        style: TextStyle(color: ext.textMuted, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Divider(color: ext.border, height: 1),
          const SizedBox(height: 8),
          // Prompt line
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text('~/',
                    style: TextStyle(color: ext.terminalGreen, fontSize: 11)),
                Text('navigate',
                    style: TextStyle(color: ext.textMuted, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Nav items
          Expanded(
            child: Scrollbar(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 8),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _NavRailTile(
                    item: item,
                    onTap: () => onTap(item.path),
                  )
                      .animate(delay: (index * 35).ms)
                      .fadeIn(duration: 180.ms)
                      .slideX(begin: -0.03, duration: 180.ms);
                },
              ),
            ),
          ),
          Divider(color: ext.border, height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.circle, size: 8, color: ext.success),
                const SizedBox(width: 6),
                Text(
                  footerLabel.trim().isEmpty ? 'backend activo' : footerLabel,
                  style: TextStyle(color: ext.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavRailTile extends StatelessWidget {
  final NavRailItem item;
  final VoidCallback onTap;

  const _NavRailTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final selected = item.selected;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? ext.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: selected
                  ? ext.primary.withValues(alpha: 0.4)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              if (selected)
                Text('â–¶ ', style: TextStyle(color: ext.primary, fontSize: 10))
                    .animate(onPlay: (c) => c.repeat())
                    .fadeIn(duration: 600.ms)
                    .then()
                    .fadeOut(duration: 600.ms)
              else
                const SizedBox(width: 14),
              Icon(
                item.icon,
                size: 16,
                color: selected ? ext.primary : ext.textMuted,
              ),
              const SizedBox(width: 10),
              Text(
                item.label,
                style: TextStyle(
                  color: selected ? ext.primary : ext.textMuted,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
