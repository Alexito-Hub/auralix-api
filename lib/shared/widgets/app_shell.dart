import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme_extension.dart';
// removed unused app_router import
import '../widgets/terminal_nav_rail.dart';

class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  static const _navItems = [
    _NavItem(icon: Icons.dashboard_outlined, label: 'Dashboard', path: '/dashboard'),
    _NavItem(icon: Icons.description_outlined, label: 'Docs', path: '/docs'),
    _NavItem(icon: Icons.terminal_outlined, label: 'Sandbox', path: '/sandbox'),
    _NavItem(icon: Icons.code_outlined, label: 'Snippets', path: '/snippets'),
    _NavItem(icon: Icons.history_outlined, label: 'Historial', path: '/history'),
    _NavItem(icon: Icons.credit_card_outlined, label: 'Billing', path: '/billing'),
    _NavItem(icon: Icons.settings_outlined, label: 'Settings', path: '/settings'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ext = AuralixThemeExtension.of(context);
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      backgroundColor: ext.bg,
      body: Row(
        children: [
          TerminalNavRail(
            items: _navItems
                .map((i) => NavRailItem(
                      icon: i.icon,
                      label: i.label,
                      path: i.path,
                      selected: location.startsWith(i.path),
                    ))
                .toList(),
            onTap: (path) => context.go(path),
          ),
          VerticalDivider(color: ext.border, width: 1, thickness: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String path;
  const _NavItem({required this.icon, required this.label, required this.path});
}
