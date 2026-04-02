part of '../screens/landing_screen.dart';

class _HoverLandingCard extends StatefulWidget {
  final Widget child;
  final AuralixThemeExtension ext;

  const _HoverLandingCard({required this.child, required this.ext});

  @override
  State<_HoverLandingCard> createState() => _HoverLandingCardState();
}

class _HoverLandingCardState extends State<_HoverLandingCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: 200.ms,
        curve: Curves.easeOutCubic,
        transform: _hovering
            ? Matrix4.translationValues(0, -4, 0)
            : Matrix4.identity(),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: widget.ext.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: _hovering
                  ? widget.ext.primary.withValues(alpha: 0.5)
                  : widget.ext.border),
          boxShadow: [
            BoxShadow(
                color: widget.ext.primary
                    .withValues(alpha: _hovering ? 0.15 : 0.05),
                blurRadius: _hovering ? 20 : 10,
                spreadRadius: _hovering ? 2 : 0)
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

class _LandingHeroCopy extends StatelessWidget {
  final int serviceCount;
  final int categoryCount;

  const _LandingHeroCopy(
      {required this.serviceCount, required this.categoryCount});

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TypewriterText(
          text: r'$ init_workspace --optimize',
          style: TextStyle(
              color: ext.primary,
              fontSize: 13,
              fontFamily: 'JetBrainsMono',
              fontWeight: FontWeight.bold),
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: 12),
        Text(
          'HIGH-PERFORMANCE APIs\nREADY FOR DEPLOYMENT.',
          style: TextStyle(
              color: ext.text,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              fontFamily: 'JetBrainsMono',
              height: 1.3),
        ),
        const SizedBox(height: 12),
        Text(
          'Unified documentation, secure testing, and comprehensive monitoring enclosed in a single developer experience.',
          style: TextStyle(color: ext.textMuted, fontSize: 13, height: 1.6),
        ),
      ],
    );
  }
}

class _HoverActionPanel extends StatefulWidget {
  final AuralixThemeExtension ext;
  const _HoverActionPanel({required this.ext});

  @override
  State<_HoverActionPanel> createState() => _HoverActionPanelState();
}

class _HoverActionPanelState extends State<_HoverActionPanel> {
  bool _hoveringRegister = false;
  bool _hoveringLogin = false;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _hoveringRegister = true),
          onExit: (_) => setState(() => _hoveringRegister = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => context.go('/register'),
            child: AnimatedContainer(
              duration: 200.ms,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: widget.ext.primary,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: widget.ext.primary),
                boxShadow: [
                  if (_hoveringRegister)
                    BoxShadow(
                        color: widget.ext.primary.withValues(alpha: 0.4),
                        blurRadius: 15)
                ],
              ),
              child: Text('PROVISION ACCOUNT',
                  style: TextStyle(
                      color: widget.ext.bg,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'JetBrainsMono')),
            ),
          ),
        ),
        MouseRegion(
          onEnter: (_) => setState(() => _hoveringLogin = true),
          onExit: (_) => setState(() => _hoveringLogin = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => context.go('/login'),
            child: AnimatedContainer(
              duration: 200.ms,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: _hoveringLogin
                    ? widget.ext.surfaceVariant
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: _hoveringLogin
                        ? widget.ext.border
                        : widget.ext.textMuted.withValues(alpha: 0.3)),
              ),
              child: Text('SYSTEM LOGIN',
                  style: TextStyle(
                      color: widget.ext.text,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'JetBrainsMono')),
            ),
          ),
        ),
      ],
    );
  }
}

class _LandingSectionMatrix extends StatelessWidget {
  final String title;
  final Widget child;
  final AuralixThemeExtension ext;

  const _LandingSectionMatrix(
      {required this.title, required this.child, required this.ext});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, color: ext.primary),
            const SizedBox(width: 8),
            Text('// $title',
                style: TextStyle(
                    color: ext.textMuted,
                    fontSize: 13,
                    fontFamily: 'JetBrainsMono',
                    fontWeight: FontWeight.bold)),
            const SizedBox(width: 16),
            Expanded(child: Divider(color: ext.border)),
          ],
        ),
        const SizedBox(height: 20),
        child,
      ],
    );
  }
}

class _CyberStep extends StatefulWidget {
  final String step;
  final String label;

  const _CyberStep({required this.step, required this.label});

  @override
  State<_CyberStep> createState() => _CyberStepState();
}

class _CyberStepState extends State<_CyberStep> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _hovering
              ? ext.primary.withValues(alpha: 0.1)
              : ext.surfaceVariant,
          border: Border(
              left: BorderSide(
                  color: _hovering ? ext.primary : ext.border, width: 3)),
          borderRadius: const BorderRadius.only(
              topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.step,
                style: TextStyle(
                    color: ext.primary,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'JetBrainsMono',
                    fontSize: 11)),
            const SizedBox(width: 8),
            Text(widget.label,
                style: TextStyle(
                    color: ext.text,
                    fontSize: 13,
                    fontFamily: 'JetBrainsMono')),
          ],
        ),
      ),
    );
  }
}

class _CyberFeature extends StatefulWidget {
  final IconData icon;
  final String title;
  final String text;
  final AuralixThemeExtension ext;

  const _CyberFeature(
      {required this.icon,
      required this.title,
      required this.text,
      required this.ext});

  @override
  State<_CyberFeature> createState() => _CyberFeatureState();
}

class _CyberFeatureState extends State<_CyberFeature> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: 200.ms,
        width: 250,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.ext.surface,
          border: Border.all(
              color: _hovering
                  ? widget.ext.primary.withValues(alpha: 0.5)
                  : widget.ext.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(widget.icon, color: widget.ext.primary, size: 24),
            const SizedBox(height: 12),
            Text(widget.title,
                style: TextStyle(
                    color: widget.ext.text,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'JetBrainsMono',
                    letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Text(widget.text,
                style: TextStyle(
                    color: widget.ext.textMuted, fontSize: 12, height: 1.4)),
          ],
        ),
      ),
    );
  }
}

class _HoverEndpointChip extends StatefulWidget {
  final ApiServiceMetadata service;
  final AuralixThemeExtension ext;

  const _HoverEndpointChip({required this.service, required this.ext});

  @override
  State<_HoverEndpointChip> createState() => _HoverEndpointChipState();
}

class _HoverEndpointChipState extends State<_HoverEndpointChip> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go('/docs/${widget.service.slug}'),
        child: AnimatedContainer(
          duration: 150.ms,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _hovering ? widget.ext.surfaceVariant : Colors.transparent,
            border: Border.all(
                color: _hovering ? widget.ext.primary : widget.ext.border),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.service.method,
                  style: TextStyle(
                      color: _hovering ? widget.ext.primary : widget.ext.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'JetBrainsMono')),
              const SizedBox(width: 8),
              Text(widget.service.name,
                  style: TextStyle(
                      color: widget.ext.text,
                      fontSize: 12,
                      fontFamily: 'JetBrainsMono')),
            ],
          ),
        ),
      ),
    );
  }
}

class _CyberFooterLink extends StatefulWidget {
  final String label;
  final String target;
  final AuralixThemeExtension ext;

  const _CyberFooterLink(
      {required this.label, required this.target, required this.ext});

  @override
  State<_CyberFooterLink> createState() => _CyberFooterLinkState();
}

class _CyberFooterLinkState extends State<_CyberFooterLink> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go(widget.target),
        child: AnimatedDefaultTextStyle(
          duration: 150.ms,
          style: TextStyle(
            color: _hovering ? widget.ext.primary : widget.ext.textMuted,
            fontSize: 11,
            fontFamily: 'JetBrainsMono',
            decoration:
                _hovering ? TextDecoration.underline : TextDecoration.none,
          ),
          child: Text('[$widget.label]'),
        ),
      ),
    );
  }
}
