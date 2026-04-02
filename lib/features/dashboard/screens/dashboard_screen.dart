import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_extension.dart';
import '../../../core/network/api_client.dart';
import '../../../core/ui/breakpoints.dart';
import '../../../shared/widgets/terminal_page_layout.dart';
import '../../../shared/widgets/terminal_widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/request_log_widget.dart';

// Provides metrics summary (used/available credits, etc)
final _metricsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    final res = await ApiClient.instance.get('/hub/user/metrics');
    if (res.data['status'] == true) {
      return res.data['data'] as Map<String, dynamic>;
    }
  } catch (_) {}
  return {};
});

// Provides 8 most recent history logs for the preview panel
final _historyPreviewProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    final res = await ApiClient.instance
        .get('/hub/user/history', params: {'limit': '8'});
    if (res.data['status'] == true) {
      return List<Map<String, dynamic>>.from(res.data['data']['logs'] ?? []);
    }
  } catch (_) {}
  return const <Map<String, dynamic>>[];
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ext = AuralixThemeExtension.of(context);
    final user = ref.watch(authProvider).valueOrNull;
    final metrics = ref.watch(_metricsProvider);
    final historyPreview = ref.watch(_historyPreviewProvider);
    final hPadding = context.pageHorizontalPadding;
    final maxWidth = context.pageMaxWidth;
    final compact = context.isMobile || context.isTablet;

    final profileChip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: ext.surfaceDecoration.copyWith(
        border: Border.all(color: ext.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: ext.primary.withValues(alpha: 0.1), blurRadius: 10)
        ],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ext.primary, width: 1.5),
            ),
            child: CircleAvatar(
              radius: 12,
              backgroundColor: ext.primary.withValues(alpha: 0.2),
              child: Text(
                (user?.email ?? 'U')[0].toUpperCase(),
                style: TextStyle(
                    color: ext.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'JetBrainsMono'),
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .shimmer(duration: 2.seconds, color: ext.primary),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.email ?? 'developer@local',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: ext.text,
                      fontSize: 12,
                      fontFamily: 'JetBrainsMono'),
                ),
                Text(
                  user?.plan.toUpperCase() ?? 'FREE TIER',
                  style: TextStyle(
                      color: ext.accent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: ext.bg,
      body: Stack(
        children: [
          // Cyberpunk Background Glow Effect
          Positioned(
            top: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ext.primary.withValues(alpha: 0.1),
                    ext.bg.withValues(alpha: 0.0)
                  ],
                  stops: const [0.1, 1.0],
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fade(duration: 4.seconds, begin: 0.4, end: 1.0),
          ),

          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(hPadding, 20, hPadding, 48),
                child: TerminalPageReveal(
                  animationKey: 'dashboard-main',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TerminalPageHeader(
                        title: 'dashboard',
                        subtitle:
                            'Sistema central: AnalÃ­ticas y Consumo en lÃ­nea // Welcome, ${user?.displayName ?? user?.email.split('@').first ?? 'dev'}',
                        actions: [profileChip],
                      ),
                      const SizedBox(height: 24),

                      // Metrics Cards
                      metrics
                          .when(
                            loading: () => const _MetricsLoading(),
                            error: (_, __) => const SizedBox(),
                            data: (data) =>
                                _MetricsGrid(user: user, data: data),
                          )
                          .animate()
                          .fadeIn(duration: 300.ms, curve: Curves.easeOut)
                          .slideY(begin: 0.05),
                      const SizedBox(height: 24),

                      // Credits Bar
                      if (user != null) ...[
                        _CreditsBar(user: user)
                            .animate()
                            .fadeIn(delay: 150.ms)
                            .slideX(begin: -0.05),
                        const SizedBox(height: 24),
                      ],

                      // Consumo / Billing Shortcut
                      HoverGlowCard(
                        child: compact
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.insights,
                                          size: 16, color: ext.accent),
                                      const SizedBox(width: 8),
                                      Text('ESTADO DEL CONSUMO',
                                          style: TextStyle(
                                              color: ext.text,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'JetBrainsMono')),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                      'Cuando necesites ampliar lÃ­mites de llamadas por segundo, compra un plan superior o recarga crÃ©ditos desde Billing.',
                                      style: TextStyle(
                                          color: ext.textMuted,
                                          fontSize: 12,
                                          height: 1.5)),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () => context.go('/billing'),
                                      icon: const Icon(Icons.credit_card,
                                          size: 14),
                                      label: const Text(
                                          'COMPRAR PLAN / CRÃ‰DITOS'),
                                      style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16)),
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Icon(Icons.insights,
                                      size: 24, color: ext.accent),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'ESTADO DEL CONSUMO - SALUD DEL SISTEMA',
                                            style: TextStyle(
                                                color: ext.text,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                fontFamily: 'JetBrainsMono')),
                                        const SizedBox(height: 4),
                                        Text(
                                            'El dashboard muestra la salud y actividad general. El panel de Billing solo aparece cuando decides efectuar una compra para ampliar cuotas.',
                                            style: TextStyle(
                                                color: ext.textMuted,
                                                fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  ElevatedButton.icon(
                                    onPressed: () => context.go('/billing'),
                                    icon:
                                        const Icon(Icons.credit_card, size: 16),
                                    label: const Text('COMPRAR PLAN',
                                        style: TextStyle(
                                            fontFamily: 'JetBrainsMono',
                                            fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 16)),
                                  ),
                                ],
                              ),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                      const SizedBox(height: 32),

                      // History Preview
                      _HistoryPreviewPanel(state: historyPreview, ext: ext)
                          .animate()
                          .fadeIn(delay: 300.ms),
                      const SizedBox(height: 32),

                      // Live Logs Terminal
                      Row(
                        children: [
                          Icon(Icons.terminal_outlined,
                              size: 16, color: ext.primary),
                          const SizedBox(width: 8),
                          Text('LOGS EN TIEMPO REAL',
                              style: TextStyle(
                                  color: ext.primary,
                                  fontSize: 12,
                                  fontFamily: 'JetBrainsMono',
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Divider(
                                  color: ext.primary.withValues(alpha: 0.2))),
                        ],
                      ).animate().fadeIn(delay: 400.ms),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: context.isMobile ? 300 : 380,
                        child: const RequestLogWidget(),
                      ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.05),

                      // Terminal EOF marker
                      const SizedBox(height: 24),
                      Center(
                        child: const Text('EOF',
                                style: TextStyle(
                                    fontFamily: 'JetBrainsMono',
                                    fontSize: 12,
                                    color: Colors.grey))
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .fade(duration: 800.ms, begin: 0.3, end: 1.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HoverGlowCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const HoverGlowCard({super.key, required this.child, this.padding});

  @override
  State<HoverGlowCard> createState() => _HoverGlowCardState();
}

class _HoverGlowCardState extends State<HoverGlowCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: 200.ms,
        curve: Curves.easeOutCubic,
        transform: _hovering
            ? Matrix4.translationValues(0, -2, 0)
            : Matrix4.identity(),
        padding: widget.padding ?? const EdgeInsets.all(20),
        decoration: ext.surfaceDecoration.copyWith(
          border: Border.all(
              color:
                  _hovering ? ext.primary.withValues(alpha: 0.5) : ext.border),
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

class _HistoryPreviewPanel extends StatelessWidget {
  final AsyncValue<List<Map<String, dynamic>>> state;
  final AuralixThemeExtension ext;

  const _HistoryPreviewPanel({required this.state, required this.ext});

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, size: 16, color: ext.textMuted),
              const SizedBox(width: 8),
              Text('ACTIVIDAD RECIENTE',
                  style: TextStyle(
                      color: ext.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'JetBrainsMono',
                      letterSpacing: 0.5)),
              const Spacer(),
              TextButton.icon(
                onPressed: () => context.go('/history'),
                icon: const Icon(Icons.arrow_forward, size: 14),
                label: const Text('VER HISTORIAL COMPLETO',
                    style:
                        TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          state.when(
            loading: () => SizedBox(
                height: 90,
                child: Center(
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: ext.primary)))),
            error: (_, __) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error al cargar la actividad. Reintente.',
                    style: TextStyle(color: ext.error, fontSize: 12))),
            data: (rows) {
              if (rows.isEmpty) {
                return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text('Sin actividad reciente.',
                        style: TextStyle(
                            color: ext.textMuted,
                            fontSize: 12,
                            fontFamily: 'JetBrainsMono')));
              }
              return Column(
                children: rows
                    .take(6)
                    .map((row) => HoverHistoryItem(row: row, ext: ext))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class HoverHistoryItem extends StatefulWidget {
  final Map<String, dynamic> row;
  final AuralixThemeExtension ext;

  const HoverHistoryItem({super.key, required this.row, required this.ext});

  @override
  State<HoverHistoryItem> createState() => _HoverHistoryItemState();
}

class _HoverHistoryItemState extends State<HoverHistoryItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final code = asInt(widget.row['statusCode']) ?? 0;
    final statusColor = code >= 500
        ? widget.ext.error
        : (code >= 400 ? widget.ext.warning : widget.ext.success);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: 150.ms,
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _hover
              ? widget.ext.primary.withValues(alpha: 0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
              color: _hover
                  ? widget.ext.primary.withValues(alpha: 0.2)
                  : Colors.transparent),
        ),
        child: Row(
          children: [
            Text(
              _hover ? '> ' : '  ',
              style: TextStyle(
                  color: widget.ext.primary,
                  fontSize: 12,
                  fontFamily: 'JetBrainsMono',
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 45,
              child: Text(
                asString(widget.row['method'], fallback: 'REQ'),
                style: TextStyle(
                    color: widget.ext.primary,
                    fontSize: 11,
                    fontFamily: 'JetBrainsMono',
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                asString(widget.row['endpoint'], fallback: '/'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: _hover ? widget.ext.text : widget.ext.textMuted,
                    fontSize: 12,
                    fontFamily: 'JetBrainsMono'),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border:
                      Border.all(color: statusColor.withValues(alpha: 0.3))),
              child: Text('$code',
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontFamily: 'JetBrainsMono',
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  String asString(dynamic value, {required String fallback}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  int? asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }
}

class _MetricsGrid extends StatelessWidget {
  final dynamic user;
  final Map<String, dynamic> data;
  const _MetricsGrid({required this.user, required this.data});

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final columns = context.isMobile ? 1 : (context.isTablet ? 2 : 4);
    final aspect = context.isMobile ? 2.4 : (context.isTablet ? 2.0 : 1.6);

    final items = [
      (
        label: 'SOLICITUDES USADAS',
        value: '${data['used'] ?? 0}',
        icon: Icons.send_outlined,
        color: ext.warning
      ),
      (
        label: 'DISPONIBLES',
        value: '${data['available'] ?? user?.credits ?? 0}',
        icon: Icons.bolt_outlined,
        color: ext.success
      ),
      (
        label: 'CRÃ‰DITOS SANDBOX',
        value: '${data['sandboxCredits'] ?? user?.sandboxCredits ?? 0}',
        icon: Icons.terminal_outlined,
        color: ext.accentAlt
      ),
      (
        label: 'TOTAL SOLICITUDES',
        value: '${data['total'] ?? 0}',
        icon: Icons.data_usage_outlined,
        color: ext.primary
      ),
    ];

    return GridView.count(
      crossAxisCount: columns,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: aspect,
      children: items
          .asMap()
          .entries
          .map((e) => HoverGlowCard(
                padding: const EdgeInsets.all(0),
                child: MetricCard(
                  label: e.value.label,
                  value: e.value.value,
                  icon: e.value.icon,
                  valueColor: e.value.color,
                ),
              )
                  .animate(delay: (e.key * 100).ms)
                  .fadeIn(duration: 300.ms)
                  .slideX(begin: 0.05))
          .toList(),
    );
  }
}

class _CreditsBar extends StatelessWidget {
  final dynamic user;
  const _CreditsBar({required this.user});

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final total = (user?.credits ?? 20) + (user?.sandboxCredits ?? 10);
    final available = user?.credits ?? 20;
    final pct = total > 0 ? (available / total).clamp(0.0, 1.0) : 0.0;
    final barColor =
        pct > 0.5 ? ext.success : (pct > 0.2 ? ext.warning : ext.error);

    return HoverGlowCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined,
                  size: 16, color: ext.textMuted),
              const SizedBox(width: 8),
              Text('RESERVA DE CRÃ‰DITOS: ',
                  style: TextStyle(
                      color: ext.textMuted,
                      fontSize: 12,
                      fontFamily: 'JetBrainsMono',
                      fontWeight: FontWeight.bold)),
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: ext.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border:
                        Border.all(color: ext.primary.withValues(alpha: 0.3))),
                child: Text(user?.plan?.toUpperCase() ?? 'FREE',
                    style: TextStyle(
                        color: ext.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'JetBrainsMono',
                        letterSpacing: 0.5)),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .shimmer(duration: 2.seconds, color: ext.primary),
              const Spacer(),
              Text('$available ',
                  style: TextStyle(
                      color: ext.text,
                      fontSize: 16,
                      fontFamily: 'JetBrainsMono',
                      fontWeight: FontWeight.bold)),
              Text('/ $total',
                  style: TextStyle(
                      color: ext.textMuted,
                      fontSize: 12,
                      fontFamily: 'JetBrainsMono')),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                Container(
                    height: 8,
                    width: double.infinity,
                    color: ext.border.withValues(alpha: 0.5)),
                FractionallySizedBox(
                  widthFactor: pct,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                        color: barColor,
                        boxShadow: [
                          BoxShadow(
                              color: barColor.withValues(alpha: 0.5),
                              blurRadius: 6,
                              spreadRadius: 1)
                        ],
                        borderRadius: BorderRadius.circular(6)),
                  ).animate().shimmer(
                      duration: 2.seconds,
                      color: Colors.white.withValues(alpha: 0.4)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsLoading extends StatelessWidget {
  const _MetricsLoading();

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final columns = context.isMobile ? 1 : (context.isTablet ? 2 : 4);
    final aspect = context.isMobile ? 2.4 : (context.isTablet ? 2.0 : 1.6);
    return GridView.count(
      crossAxisCount: columns,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: aspect,
      children: List.generate(
          4,
          (_) => Container(
                decoration: ext.surfaceDecoration
                    .copyWith(borderRadius: BorderRadius.circular(8)),
                child: Center(
                    child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: ext.primary.withValues(alpha: 0.5)))),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fade(begin: 0.5, end: 1.0, duration: 1.seconds)),
    );
  }
}
