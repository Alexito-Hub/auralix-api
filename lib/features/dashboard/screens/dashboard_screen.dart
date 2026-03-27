import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/theme_extension.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/terminal_widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/request_log_widget.dart';

final _metricsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final res = await ApiClient.instance.get('/api/hub/user/metrics');
  if (res.data['status'] == true) return res.data['data'] as Map<String, dynamic>;
  return {};
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ext = AuralixThemeExtension.of(context);
    final user = ref.watch(authProvider).valueOrNull;
    final metrics = ref.watch(_metricsProvider);

    return Scaffold(
      backgroundColor: ext.bg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('\$ ', style: TextStyle(color: ext.primary, fontSize: 14)),
                        Text('dashboard', style: TextStyle(color: ext.text, fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bienvenido de vuelta, ${user?.displayName ?? user?.email ?? 'dev'}',
                      style: TextStyle(color: ext.textMuted, fontSize: 13),
                    ),
                  ],
                ),
                const Spacer(),
                // Profile chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: ext.surfaceDecoration,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: ext.primary.withValues(alpha: 0.3),
                        child: Text(
                          (user?.email ?? 'U')[0].toUpperCase(),
                          style: TextStyle(color: ext.primary, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user?.email ?? '', style: TextStyle(color: ext.text, fontSize: 12)),
                          Text(user?.plan.toUpperCase() ?? 'FREE', style: TextStyle(color: ext.primary, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ).animate().fadeIn().slideY(begin: -0.05),
            const SizedBox(height: 24),

            // Metrics grid
            metrics.when(
              loading: () => const _MetricsLoading(),
              error: (_, __) => const SizedBox(),
              data: (data) => _MetricsGrid(user: user, data: data),
            ),
            const SizedBox(height: 24),

            // Credits bar
            if (user != null) ...[
              _CreditsBar(user: user),
              const SizedBox(height: 24),
            ],

            // Live logs
            Text(
              'logs en tiempo real',
              style: TextStyle(color: ext.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 320, child: RequestLogWidget()),
          ],
        ),
      ),
    );
  }
}

class _MetricsGrid extends ConsumerWidget {
  final dynamic user;
  final Map<String, dynamic> data;
  const _MetricsGrid({required this.user, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ext = AuralixThemeExtension.of(context);
    final items = [
      (label: 'Solicitudes usadas', value: '${data['used'] ?? 0}', icon: Icons.send_outlined, color: ext.warning),
      (label: 'Solicitudes disponibles', value: '${data['available'] ?? user?.credits ?? 20}', icon: Icons.bolt_outlined, color: ext.success),
      (label: 'Créditos sandbox', value: '${data['sandboxCredits'] ?? user?.sandboxCredits ?? 10}', icon: Icons.terminal_outlined, color: ext.accentAlt),
      (label: 'Total solicitudes', value: '${data['total'] ?? 30}', icon: Icons.data_usage_outlined, color: ext.primary),
    ];

    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width > 700 ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: items
          .asMap()
          .entries
          .map((e) => MetricCard(
                label: e.value.label,
                value: e.value.value,
                icon: e.value.icon,
                valueColor: e.value.color,
              ).animate(delay: (e.key * 100).ms).fadeIn().slideY(begin: 0.1))
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
    final pct = total > 0 ? available / total : 0.0;

    return GlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Plan: ', style: TextStyle(color: ext.textMuted, fontSize: 12)),
              Text(user?.plan?.toUpperCase() ?? 'FREE', style: TextStyle(color: ext.primary, fontSize: 12, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('$available / $total créditos', style: TextStyle(color: ext.text, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct.toDouble(),
              backgroundColor: ext.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                pct > 0.5 ? ext.success : pct > 0.2 ? ext.warning : ext.error,
              ),
              minHeight: 6,
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
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: List.generate(4, (_) => Container(
        decoration: ext.surfaceDecoration,
        child: Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: ext.primary))),
      )),
    );
  }
}
