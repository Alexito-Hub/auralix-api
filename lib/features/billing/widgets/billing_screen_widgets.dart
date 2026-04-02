part of '../screens/billing_screen.dart';

class HoverBillingCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const HoverBillingCard({super.key, required this.child, this.padding});

  @override
  State<HoverBillingCard> createState() => _HoverBillingCardState();
}

class _HoverBillingCardState extends State<HoverBillingCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: 250.ms,
        curve: Curves.easeOutCubic,
        transform: _hovering
            ? Matrix4.translationValues(0, -3, 0)
            : Matrix4.identity(),
        padding: widget.padding ?? const EdgeInsets.all(24),
        decoration: ext.surfaceDecoration.copyWith(
          border: Border.all(
              color:
                  _hovering ? ext.primary.withValues(alpha: 0.6) : ext.border),
          boxShadow: _hovering
              ? [
                  BoxShadow(
                      color: ext.primary.withValues(alpha: 0.15),
                      blurRadius: 15,
                      spreadRadius: 0)
                ]
              : [],
          borderRadius: BorderRadius.circular(8),
        ),
        child: widget.child,
      ),
    );
  }
}

class _PlanCard extends StatefulWidget {
  final Map<String, dynamic> plan;
  final bool selected;
  final bool bestValue;
  final String helperText;
  final String? unitPrice;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.bestValue,
    required this.helperText,
    required this.unitPrice,
    required this.onTap,
  });

  @override
  State<_PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<_PlanCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final badge = widget.plan['badge'] as String?;
    final rawCredits = widget.plan['credits'];
    final credits = rawCredits is num
        ? rawCredits.toInt()
        : int.tryParse('${rawCredits ?? ''}') ?? -1;

    final isActive = widget.selected || _hovering;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          transform: isActive
              ? Matrix4.translationValues(0, -4, 0)
              : Matrix4.identity(),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.selected
                ? ext.primary.withValues(alpha: 0.08)
                : ext.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: widget.selected
                    ? ext.primary
                    : (isActive
                        ? ext.primary.withValues(alpha: 0.4)
                        : ext.border),
                width: widget.selected ? 2 : 1),
            boxShadow: widget.selected
                ? [
                    BoxShadow(
                        color: ext.primary.withValues(alpha: 0.2),
                        blurRadius: 15)
                  ]
                : (_hovering
                    ? [
                        BoxShadow(
                            color: ext.primary.withValues(alpha: 0.1),
                            blurRadius: 8)
                      ]
                    : []),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                      widget.selected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 16,
                      color: widget.selected ? ext.primary : ext.textMuted),
                  const SizedBox(width: 8),
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                          color: ext.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                              color: ext.warning.withValues(alpha: 0.3))),
                      child: Text(badge.toUpperCase(),
                          style: TextStyle(
                              color: ext.warning,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'JetBrainsMono')),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .shimmer(duration: 2.seconds, color: ext.warning),
                  if (widget.bestValue)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: ext.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                              color: ext.success.withValues(alpha: 0.3))),
                      child: Text('BEST VALUE',
                          style: TextStyle(
                              color: ext.success,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'JetBrainsMono')),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(widget.plan['name'].toString().toUpperCase(),
                  style: TextStyle(
                      color: isActive ? ext.text : ext.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'JetBrainsMono')),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('\$${widget.plan['price']}',
                      style: TextStyle(
                          color: widget.selected ? ext.primary : ext.text,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'JetBrainsMono')),
                  const SizedBox(width: 4),
                  Text(widget.plan['currency'].toString(),
                      style: TextStyle(
                          color: ext.textMuted,
                          fontSize: 12,
                          fontFamily: 'JetBrainsMono',
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              if (widget.unitPrice != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: ext.bg, borderRadius: BorderRadius.circular(3)),
                  child: Text('â‰ˆ \$${widget.unitPrice} / u',
                      style: TextStyle(
                          color: ext.textMuted,
                          fontSize: 10,
                          fontFamily: 'JetBrainsMono')),
                ),
              const Spacer(),
              Divider(color: ext.border.withValues(alpha: 0.5), height: 24),
              Text(credits < 0 ? 'ILIMITADO' : '$credits CRÃ‰DITOS',
                  style: TextStyle(
                      color: ext.text,
                      fontSize: 11,
                      fontFamily: 'JetBrainsMono',
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                widget.helperText,
                style:
                    TextStyle(color: ext.textMuted, fontSize: 11, height: 1.35),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
