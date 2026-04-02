import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/theme_extension.dart';
import '../../core/ui/breakpoints.dart';
import '../../features/auth/providers/auth_provider.dart';
import 'package:hub_aura/l10n/app_localizations.dart';
import 'terminal_nav_rail.dart';

class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  List<_NavItem> _navItems(AppLocalizations l10n) => [
        _NavItem(
          icon: Icons.dashboard_outlined,
          label: l10n.navDashboard,
          path: '/dashboard',
        ),
        _NavItem(
          icon: Icons.description_outlined,
          label: l10n.navDocs,
          path: '/docs',
        ),
        _NavItem(
          icon: Icons.terminal_outlined,
          label: l10n.navSandbox,
          path: '/sandbox',
        ),
        _NavItem(
          icon: Icons.code_outlined,
          label: l10n.navSnippets,
          path: '/snippets',
        ),
        _NavItem(
          icon: Icons.history_outlined,
          label: l10n.navHistory,
          path: '/history',
        ),
        _NavItem(
          icon: Icons.settings_outlined,
          label: l10n.navSettings,
          path: '/settings',
        ),
      ];

  String _titleForLocation(
    List<_NavItem> navItems,
    String location,
    AppLocalizations l10n,
  ) {
    final match = navItems.where((item) => location.startsWith(item.path));
    if (match.isNotEmpty) return match.first.label;
    return l10n.appTitle;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ext = AuralixThemeExtension.of(context);
    final location = GoRouterState.of(context).matchedLocation;
    final l10n = AppLocalizations.of(context)!;
    final navItems = _navItems(l10n);
    final title = _titleForLocation(navItems, location, l10n);
    final isCompact = context.isMobile || context.isTablet;
    final user = ref.watch(authProvider).valueOrNull;
    final apiAuthority = ApiClient.baseAuthority;

    final shellChild = child;

    if (isCompact) {
      return Scaffold(
        backgroundColor: ext.bg,
        appBar: _ShellAppBar(
          title: title,
          subtitle: apiAuthority,
          showDrawerButton: true,
        ),
        drawer: _ShellDrawer(
          items: navItems,
          location: location,
          userEmail: user?.email,
          userPlan: user?.plan,
          onNavigate: (path) {
            Navigator.of(context).pop();
            context.go(path);
          },
          onLogout: () async {
            Navigator.of(context).pop();
            await ref.read(authProvider.notifier).logout();
            if (context.mounted) {
              context.go('/login');
            }
          },
        ),
        body: shellChild,
      );
    }

    return Scaffold(
      backgroundColor: ext.bg,
      body: Row(
        children: [
          TerminalNavRail(
            items: navItems
                .map((item) => NavRailItem(
                      icon: item.icon,
                      label: item.label,
                      path: item.path,
                      selected: location.startsWith(item.path),
                    ))
                .toList(),
            footerLabel: apiAuthority,
            onTap: (path) => context.go(path),
          ),
          VerticalDivider(color: ext.border, width: 1, thickness: 1),
          Expanded(child: shellChild),
        ],
      ),
    );
  }
}

class _ShellAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final bool showDrawerButton;

  const _ShellAppBar({
    required this.title,
    required this.subtitle,
    required this.showDrawerButton,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ext = AuralixThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authProvider).valueOrNull;

    return AppBar(
      backgroundColor: ext.surface,
      elevation: 0,
      leading: showDrawerButton
          ? Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.menu, color: ext.text),
                onPressed: () => Scaffold.of(context).openDrawer(),
                tooltip: l10n.appShellOpenNavigation,
              ),
            )
          : null,
      titleSpacing: showDrawerButton ? 0 : 20,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: ext.text,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: ext.textMuted,
              fontSize: 11,
              fontFamily: 'JetBrainsMono',
            ),
          ),
        ],
      ),
      actions: [
        if (user != null)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: ext.primary.withValues(alpha: 0.14),
                  border: Border.all(color: ext.primary.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '${user.plan.toUpperCase()} - ${user.credits} cr',
                  style: TextStyle(
                    color: ext.primary,
                    fontSize: 11,
                    fontFamily: 'JetBrainsMono',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(color: ext.border, height: 1),
      ),
    );
  }
}

class _ShellDrawer extends StatelessWidget {
  final List<_NavItem> items;
  final String location;
  final String? userEmail;
  final String? userPlan;
  final ValueChanged<String> onNavigate;
  final VoidCallback onLogout;

  const _ShellDrawer({
    required this.items,
    required this.location,
    required this.userEmail,
    required this.userPlan,
    required this.onNavigate,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Drawer(
      backgroundColor: ext.surface,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: ext.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.appTitle,
                    style: TextStyle(
                      color: ext.text,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail ?? l10n.appShellNoSession,
                    style: TextStyle(color: ext.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${l10n.appShellPlanLabel}: ${(userPlan ?? 'free').toUpperCase()}',
                    style: TextStyle(
                      color: ext.primary,
                      fontSize: 11,
                      fontFamily: 'JetBrainsMono',
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  ...items.map((item) {
                    final selected = location.startsWith(item.path);
                    return ListTile(
                      leading: Icon(
                        item.icon,
                        size: 18,
                        color: selected ? ext.primary : ext.textMuted,
                      ),
                      title: Text(
                        item.label,
                        style: TextStyle(
                          color: selected ? ext.primary : ext.text,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      selected: selected,
                      selectedTileColor: ext.primary.withValues(alpha: 0.11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onTap: () => onNavigate(item.path),
                    );
                  }),
                ],
              ),
            ),
            Divider(color: ext.border, height: 1),
            ListTile(
              leading: Icon(Icons.logout, color: ext.error, size: 18),
              title: Text(
                l10n.appShellLogout,
                style: TextStyle(color: ext.error),
              ),
              onTap: onLogout,
            ),
          ],
        ),
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
